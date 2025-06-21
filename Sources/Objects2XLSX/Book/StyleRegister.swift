//
// StyleRegister.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.
//

import Foundation

/// A centralized registry that manages Excel style components and generates the styles.xml for XLSX files.
///
/// `StyleRegister` acts as the style management hub for Excel document generation, handling the collection,
/// deduplication, and XML serialization of all style elements including fonts, fills, borders, alignments,
/// and number formats. When cells are created, their styles are registered here to achieve deduplication
/// and unified generation of styles.xml.
///
/// ## Architecture
/// The register maintains separate pools for each style component:
/// - **Font Pool**: Typography settings (size, family, weight, color)
/// - **Fill Pool**: Background colors, patterns, and gradients
/// - **Border Pool**: Cell border styles and colors for all sides
/// - **Alignment Pool**: Text positioning and formatting options
/// - **Number Format Pool**: Custom data formatting patterns
/// - **Resolved Style Pool**: Final combined styles with component references
///
/// ## Key Features
/// - **Automatic Deduplication**: Identical components are reused to minimize file size
/// - **Excel Compliance**: Generates standards-compliant Office Open XML
/// - **Smart Defaults**: Pre-populates required default styles per Excel specifications
/// - **Type Safety**: Uses strongly-typed components with validation
/// - **Efficient Indexing**: Assigns sequential IDs for optimal reference management
///
/// ## Workflow
/// 1. **Registration**: Style components are registered and deduplicated
/// 2. **Resolution**: High-level `CellStyle` objects are resolved into component references
/// 3. **Generation**: Complete `styles.xml` content is generated for the Excel package
///
/// ## Usage Example
/// ```swift
/// let register = StyleRegister()
///
/// // Register a custom style
/// let cellStyle = CellStyle(
///     font: Font(size: 14, name: "Arial", bold: true),
///     fill: Fill.solid(.blue),
///     alignment: Alignment.center
/// )
/// let styleID = register.registerCellStyle(cellStyle, cellType: .string("text"))
///
/// // Generate the complete styles XML
/// let stylesXML = register.generateXML()
/// ```
///
/// ## Excel Compatibility
/// The generated XML follows the Office Open XML specification and includes all required
/// default elements that Excel expects, ensuring maximum compatibility across Excel versions.
final class StyleRegister {
    /// Pool storing all registered fonts used in styles.
    private(set) var fontPool = DeduplicatedArray<Font>()
    /// Pool storing all registered fill patterns used in styles.
    private(set) var fillPool = DeduplicatedArray<Fill>()
    /// Pool storing all registered text alignments used in styles.
    private(set) var alignmentPool = DeduplicatedArray<Alignment>()
    /// Pool storing all registered border styles used in styles.
    private(set) var borderPool = DeduplicatedArray<Border>()
    /// Pool storing all registered number formats used in styles.
    private(set) var numberFormatPool = DeduplicatedArray<NumberFormat>()
    /// Pool storing all resolved styles, each referencing components by their IDs.
    private(set) var resolvedStylePool = DeduplicatedArray<ResolvedStyle>()

    /// Registers a font if provided and returns its assigned ID.
    /// - Parameter font: The optional `Font` to register.
    /// - Returns: The index of the font in the pool, or 0 if `font` is nil (default font).
    private func registerFont(_ font: Font?) -> Int? {
        guard let font else { return 0 }
        return fontPool.append(font).index
    }

    /// Registers a fill pattern if provided and returns its assigned ID.
    /// - Parameter fill: The optional `Fill` to register.
    /// - Returns: The index of the fill in the pool, or 0 if `fill` is nil (default fill).
    private func registerFill(_ fill: Fill?) -> Int? {
        guard let fill else {
            return 0
        }
        return fillPool.append(fill).index
    }

    /// Registers an alignment if provided and returns its assigned ID.
    /// - Parameter alignment: The optional `Alignment` to register.
    /// - Returns: The index of the alignment in the pool, or nil if `alignment` is nil.
    private func registerAlignment(_ alignment: Alignment?) -> Int? {
        guard let alignment else { return nil }
        return alignmentPool.append(alignment).index
    }

    /// Registers a border if provided and returns its assigned ID.
    /// - Parameter border: The optional `Border` to register.
    /// - Returns: The index of the border in the pool, or 0 if `border` is nil (default border).
    private func registerBorder(_ border: Border?) -> Int? {
        guard let border else { return 0 }
        return borderPool.append(border).index
    }

    /// Registers a comprehensive cell style by registering its components and creating a resolved style.
    /// - Parameters:
    ///   - style: The optional `CellStyle` to register.
    ///   - cellType: The optional `Cell.CellType` used to generate number formats.
    /// - Returns: The index of the resolved style in the pool, or nil if `style` is nil.
    /// - Note: Resolved styles reference component styles by their assigned IDs.
    func registerCellStyle(_ style: CellStyle?, cellType: Cell.CellType?) -> Int? {
        guard let style else { return nil }

        // Register individual style components
        let numberFormat = generateNumberFormat(for: cellType)
        let numFmtId = registerNumberFormat(numberFormat)
        let fontID = registerFont(style.font)
        let fillID = registerFill(style.fill)
        let alignmentID = registerAlignment(style.alignment)
        let borderID = registerBorder(style.border)

        // Create a resolved style referencing the component IDs
        let resolved = ResolvedStyle(
            fontID: fontID,
            fillID: fillID,
            alignmentID: alignmentID,
            numFmtId: numFmtId,
            borderID: borderID)

        // Append the resolved style to the pool and return its index
        return resolvedStylePool.append(resolved).index
    }

    /// Generates a number format based on the cell type, mapping to appropriate Excel number formats.
    /// - Parameter cellType: The optional `Cell.CellType` to determine the format.
    /// - Returns: A corresponding `NumberFormat` or nil if cell type is unknown.
    /// - Note: Maps percentages, dates, and default types to Excel numeric formats.
    private func generateNumberFormat(for cellType: Cell.CellType?) -> NumberFormat? {
        guard let cellType else { return nil }

        switch cellType {
            case let .percentage(_, precision):
                return .percentage(precision: precision)
            case .date:
                return .dateTime
            case .int, .string, .boolean, .url, .double, .doubleValue, .optionalDouble, .empty:
                return .general
        }
    }

    /// Registers a number format and returns its assigned Excel number format ID.
    /// - Parameter numberFormat: The optional `NumberFormat` to register.
    /// - Returns: The Excel number format ID corresponding to the format, or nil if no format provided.
    /// - Note: Uses Excel built-in format IDs when available, otherwise assigns custom IDs starting from 164.
    private func registerNumberFormat(_ numberFormat: NumberFormat?) -> Int? {
        guard let numberFormat else { return nil }

        // Prefer built-in Excel format IDs
        if let builtinId = numberFormat.builtinId {
            return builtinId
        }

        // Excel built-in number format IDs reference:
        // 0   -> General (default format)
        // 1   -> 0 (integer with no decimals)
        // 2   -> 0.00 (number with 2 decimal places)
        // 9   -> 0% (percentage with no decimals)
        // 10  -> 0.00% (percentage with 2 decimal places)
        // 14  -> m/d/yy (short date format)
        // 15  -> d-mmm-yy (date with abbreviated month)
        // 22  -> m/d/yy h:mm (date and time)
        // ... up to 163 are reserved for built-in formats
        // Custom formats start at ID 164 and increment from there

        if let index = numberFormatPool.ids.firstIndex(of: numberFormat.id) {
            return 164 + index
        }

        let customIndex = numberFormatPool.append(numberFormat).index
        return 164 + customIndex
    }

    /// Initializes the style registries with required default styles pre-registered.
    ///
    /// Excel requires certain default elements to be present at specific indices:
    /// - Index 0 must contain the default fill, font, border, and resolved style
    /// - These defaults serve as fallbacks when no custom styling is applied
    ///
    /// - Note: This initialization ensures Excel compatibility by meeting the
    ///         Office Open XML specification requirements for default style elements.
    init() {
        // Pre-register default fill pattern
        fillPool.append(.none)

        // Pre-register default font
        fontPool.append(Font.default)

        // Pre-register default border
        borderPool.append(.none)

        // Pre-register default resolved style at index 0 per Excel requirements
        let defaultStyle = ResolvedStyle(
            fontID: 0,
            fillID: 0,
            alignmentID: nil,
            numFmtId: nil,
            borderID: 0)
        resolvedStylePool.append(defaultStyle)
    }

    /// Generates the complete styles.xml content for the XLSX file.
    ///
    /// Creates a comprehensive styles document containing all registered style components
    /// organized into the required sections: number formats, fonts, fills, borders,
    /// cell style XFs (master styles), cell XFs (actual styles), and named cell styles.
    ///
    /// The generated XML follows the Office Open XML specification structure and includes
    /// all necessary default elements that Excel expects for proper document rendering.
    ///
    /// - Returns: Complete XML string ready for inclusion in the XLSX package as styles.xml
    func generateXML() -> String {
        var xml = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
            """

        // Generate number formats section (custom formats only, built-ins are implicit)
        xml += generateNumberFormatsXML()

        // Generate fonts section (typography definitions)
        xml += generateFontsXML()

        // Generate fills section (background colors and patterns)
        xml += generateFillsXML()

        // Generate borders section (cell border definitions)
        xml += generateBordersXML()

        // Generate cell style XFs (master format templates, required by Excel spec)
        xml += generateCellStyleXfsXML()

        // Generate cell XFs (actual format definitions referenced by cells)
        xml += generateCellXfsXML()

        // Generate named cell styles (style names like "Normal", minimal but required)
        xml += generateCellStylesXML()

        // Generate differential formatting (required by Excel spec, even if empty)
        xml += "<dxfs count=\"0\"/>"

        // Generate table styles (required by Excel spec, even if empty)
        xml += "<tableStyles count=\"0\" defaultTableStyle=\"TableStyleMedium2\" defaultPivotStyle=\"PivotStyleLight16\"/>"

        xml += "</styleSheet>"
        return xml
    }

    /// Generates the numFmts section containing custom number format definitions.
    ///
    /// Only custom number formats (ID 164+) are included since Excel has built-in
    /// formats for standard cases. Each format includes its ID and format code.
    ///
    /// - Returns: XML fragment for the numFmts section, or empty string if no custom formats
    private func generateNumberFormatsXML() -> String {
        guard !numberFormatPool.isEmpty else { return "" }

        var xml = "<numFmts count=\"\(numberFormatPool.count)\">"

        for (index, numberFormat) in numberFormatPool.enumerated() {
            let formatId = 164 + index // Custom formats start at 164
            if let formatCode = numberFormat.formatCode {
                xml += "<numFmt numFmtId=\"\(formatId)\" formatCode=\"\(formatCode.xmlEscaped)\"/>"
            }
        }

        xml += "</numFmts>"
        return xml
    }

    /// Generates the fonts section containing all registered font definitions.
    ///
    /// Each font element includes typography properties like size, family name,
    /// weight (bold), style (italic), and color. The default font is always first.
    ///
    /// - Returns: XML fragment for the fonts section
    private func generateFontsXML() -> String {
        var xml = "<fonts count=\"\(fontPool.count)\">"

        for font in fontPool {
            xml += font.xmlContent
        }

        xml += "</fonts>"
        return xml
    }

    /// Generates the fills section containing all registered fill pattern definitions.
    ///
    /// Includes solid colors, patterns, and gradients. The default "none" fill
    /// is always at index 0 as required by Excel specifications.
    ///
    /// - Returns: XML fragment for the fills section
    private func generateFillsXML() -> String {
        var xml = "<fills count=\"\(fillPool.count)\">"

        for fill in fillPool {
            xml += fill.xmlContent
        }

        xml += "</fills>"
        return xml
    }

    /// Generates the borders section containing all registered border style definitions.
    ///
    /// Each border can define styles for left, right, top, bottom, and diagonal sides
    /// with individual line styles and colors. The default "none" border is always first.
    ///
    /// - Returns: XML fragment for the borders section
    private func generateBordersXML() -> String {
        var xml = "<borders count=\"\(borderPool.count)\">"

        for border in borderPool {
            xml += border.xmlContent
        }

        xml += "</borders>"
        return xml
    }

    /// Generates the cellStyleXfs section containing master style format templates.
    ///
    /// These are template formats that named styles reference. Excel requires at least
    /// one master style (the default) that references the default format components.
    ///
    /// - Returns: XML fragment for the cellStyleXfs section with required default master style
    private func generateCellStyleXfsXML() -> String {
        // Excel specification requires at least one cellStyleXf (the master default style)
        "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
    }

    /// Generates the cellXfs section containing actual cell format definitions.
    ///
    /// These are the format definitions that cells reference by index. Each cellXf
    /// combines references to font, fill, border, alignment, and number format components.
    /// This is where the actual styling magic happens for individual cells.
    ///
    /// - Returns: XML fragment for the cellXfs section
    private func generateCellXfsXML() -> String {
        var xml = "<cellXfs count=\"\(resolvedStylePool.count)\">"

        for resolvedStyle in resolvedStylePool {
            xml += "<xf"

            // Add number format ID (defaults to 0 for General format)
            if let numFmtId = resolvedStyle.numFmtId {
                xml += " numFmtId=\"\(numFmtId)\""
            } else {
                xml += " numFmtId=\"0\""
            }

            // Add font ID (defaults to 0 for default font)
            if let fontId = resolvedStyle.fontID {
                xml += " fontId=\"\(fontId)\""
            } else {
                xml += " fontId=\"0\""
            }

            // Add fill ID (defaults to 0 for no fill)
            if let fillId = resolvedStyle.fillID {
                xml += " fillId=\"\(fillId)\""
            } else {
                xml += " fillId=\"0\""
            }

            // Add border ID (defaults to 0 for no border)
            if let borderId = resolvedStyle.borderID {
                xml += " borderId=\"\(borderId)\""
            } else {
                xml += " borderId=\"0\""
            }

            // Add alignment if present (requires applyAlignment flag and inline definition)
            if let alignmentId = resolvedStyle.alignmentID,
               alignmentId < alignmentPool.count
            {
                xml += " applyAlignment=\"1\">"
                xml += alignmentPool[alignmentId].xmlContent
                xml += "</xf>"
            } else {
                xml += "/>"
            }
        }

        xml += "</cellXfs>"
        return xml
    }

    /// Generates the cellStyles section containing named style definitions.
    ///
    /// Named styles like "Normal", "Heading 1", etc. reference master styles in cellStyleXfs.
    /// Excel requires at least the "Normal" style which serves as the document default.
    ///
    /// - Returns: XML fragment for the cellStyles section with required "Normal" style
    private func generateCellStylesXML() -> String {
        // Excel specification requires at least the "Normal" style definition
        "<cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles>"
    }
}

/// Represents a fully resolved style that combines references to all style component IDs.
///
/// `ResolvedStyle` serves as the final style definition that cells reference. Instead of
/// storing the actual style objects, it stores the indices of components in their respective
/// pools. This approach enables efficient deduplication and compact storage.
///
/// ## Component References
/// - **fontID**: Index in the font pool (typography settings)
/// - **fillID**: Index in the fill pool (background colors/patterns)
/// - **borderID**: Index in the border pool (cell border styles)
/// - **alignmentID**: Index in the alignment pool (text positioning)
/// - **numFmtId**: Excel number format ID (built-in or custom)
///
/// ## Usage in Excel
/// Cells reference resolved styles by their index in the resolved style pool,
/// creating a two-level indirection that maximizes reuse and minimizes file size.
struct ResolvedStyle: Hashable, Sendable, Identifiable {
    /// Reference to font component (nil defaults to index 0)
    let fontID: Int?
    /// Reference to fill component (nil defaults to index 0)
    let fillID: Int?
    /// Reference to alignment component (nil means no alignment applied)
    let alignmentID: Int?
    /// Excel number format ID (nil defaults to General format)
    let numFmtId: Int?
    /// Reference to border component (nil defaults to index 0)
    let borderID: Int?

    /// Generates a unique identifier by combining all component references.
    ///
    /// This ID is used for hashing and equality comparison to ensure that resolved
    /// styles with identical component combinations are deduplicated effectively.
    ///
    /// - Returns: A string identifier in the format "numFmt_font_fill_align_border"
    var id: String {
        let numFmtStr = numFmtId.map(String.init) ?? "default"
        let fontStr = fontID.map(String.init) ?? "default"
        let fillStr = fillID.map(String.init) ?? "default"
        let alignStr = alignmentID.map(String.init) ?? "default"
        let borderStr = borderID.map(String.init) ?? "default"

        return "\(numFmtStr)_\(fontStr)_\(fillStr)_\(alignStr)_\(borderStr)"
    }
}
