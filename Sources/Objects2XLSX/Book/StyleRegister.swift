//
// StyleRegister.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.
//

import Foundation
import IdentifiedCollections

/// A centralized registry that manages Excel style components and generates the styles.xml for XLSX files.
///
/// `StyleRegister` acts as the style management hub for Excel document generation, handling the collection,
/// deduplication, and XML serialization of all style elements including fonts, fills, borders, alignments,
/// and number formats.
/// 当创建 Cell 后，会将每个 Cell 的 Style 注册在此，以实现去重，并统一生成 styles.xml
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
/// let registor = StyleRegistor()
///
/// // Register a custom style
/// let cellStyle = CellStyle(
///     font: Font(size: 14, name: "Arial", bold: true),
///     fill: Fill.solid(.blue),
///     alignment: Alignment.center
/// )
/// let styleID = registor.registerStyle(cellStyle, for: .text)
///
/// // Generate the complete styles XML
/// let stylesXML = registor.generateStylesXML()
/// ```
///
/// ## Excel Compatibility
/// The generated XML follows the Office Open XML specification and includes all required
/// default elements that Excel expects, ensuring maximum compatibility across Excel versions.
final class StyleRegister {
    /// Pool storing all registered fonts used in styles.
    private(set) var fontPool = IdentifiedArrayOf<Font>()
    /// Pool storing all registered fill patterns used in styles.
    private(set) var fillPool = IdentifiedArrayOf<Fill>()
    /// Pool storing all registered text alignments used in styles.
    private(set) var alignmentPool = IdentifiedArrayOf<Alignment>()
    /// Pool storing all registered border styles used in styles.
    private(set) var borderPool = IdentifiedArrayOf<Border>()
    /// Pool storing all registered number formats used in styles.
    private(set) var numberFormatPool = IdentifiedArrayOf<NumberFormat>()
    /// Pool storing all resolved styles, each referencing components by their IDs.
    private(set) var resolvedStylePool = IdentifiedArrayOf<ResolvedStyle>()

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
            case .int, .string, .boolean, .url, .double:
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

        // Excel built-in number format IDs:
        // 0   -> General (default)
        // 1   -> 0
        // 2   -> 0.00
        // 9   -> 0%
        // 10  -> 0.00%
        // 14  -> m/d/yy
        // 15  -> d-mmm-yy
        // 22  -> m/d/yy h:mm
        // ... up to 163 built-in formats
        // Custom formats start at 164

        if let index = numberFormatPool.ids.firstIndex(of: numberFormat.id) {
            return 164 + index
        }

        let customIndex = numberFormatPool.append(numberFormat).index
        return 164 + customIndex
    }

    /// Initializes the style registries with default styles pre-registered.
    /// - Note: Pre-registering default fills, fonts, borders, and styles is required by Excel,
    ///         with default style always at index 0.
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
    
    /// Generates the complete styles.xml content for the XLSX file
    /// - Returns: XML string conforming to Office Open XML standards
    func generateXML() -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
        """
        
        // Generate number formats section (custom formats only)
        xml += generateNumberFormatsXML()
        
        // Generate fonts section
        xml += generateFontsXML()
        
        // Generate fills section
        xml += generateFillsXML()
        
        // Generate borders section
        xml += generateBordersXML()
        
        // Generate cell style XFs (not used in this implementation, but required by Excel)
        xml += generateCellStyleXfsXML()
        
        // Generate cell XFs (the actual styles used by cells)
        xml += generateCellXfsXML()
        
        // Generate cell styles (named styles, required but minimal)
        xml += generateCellStylesXML()
        
        xml += "</styleSheet>"
        return xml
    }
    
    /// Generates the numFmts section for custom number formats
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
    
    /// Generates the fonts section
    private func generateFontsXML() -> String {
        var xml = "<fonts count=\"\(fontPool.count)\">"
        
        for font in fontPool {
            xml += font.xmlContent
        }
        
        xml += "</fonts>"
        return xml
    }
    
    /// Generates the fills section
    private func generateFillsXML() -> String {
        var xml = "<fills count=\"\(fillPool.count)\">"
        
        for fill in fillPool {
            xml += fill.xmlContent
        }
        
        xml += "</fills>"
        return xml
    }
    
    /// Generates the borders section
    private func generateBordersXML() -> String {
        var xml = "<borders count=\"\(borderPool.count)\">"
        
        for border in borderPool {
            xml += border.xmlContent
        }
        
        xml += "</borders>"
        return xml
    }
    
    /// Generates the cellStyleXfs section (master styles)
    private func generateCellStyleXfsXML() -> String {
        // Excel requires at least one cellStyleXf (the master style)
        return "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
    }
    
    /// Generates the cellXfs section (the actual cell formats)
    private func generateCellXfsXML() -> String {
        var xml = "<cellXfs count=\"\(resolvedStylePool.count)\">"
        
        for resolvedStyle in resolvedStylePool {
            xml += "<xf"
            
            // Add numFmtId
            if let numFmtId = resolvedStyle.numFmtId {
                xml += " numFmtId=\"\(numFmtId)\""
            } else {
                xml += " numFmtId=\"0\""
            }
            
            // Add fontId
            if let fontId = resolvedStyle.fontID {
                xml += " fontId=\"\(fontId)\""
            } else {
                xml += " fontId=\"0\""
            }
            
            // Add fillId
            if let fillId = resolvedStyle.fillID {
                xml += " fillId=\"\(fillId)\""
            } else {
                xml += " fillId=\"0\""
            }
            
            // Add borderId
            if let borderId = resolvedStyle.borderID {
                xml += " borderId=\"\(borderId)\""
            } else {
                xml += " borderId=\"0\""
            }
            
            // Add alignment if present
            if let alignmentId = resolvedStyle.alignmentID,
               alignmentId < alignmentPool.count {
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
    
    /// Generates the cellStyles section (named styles)
    private func generateCellStylesXML() -> String {
        // Excel requires at least the "Normal" style
        return "<cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles>"
    }
}

/// Represents a fully resolved style referencing component style IDs.
/// Used to identify unique combinations of style components in the registry.
struct ResolvedStyle: Hashable, Sendable, Identifiable {
    let fontID: Int?
    let fillID: Int?
    let alignmentID: Int?
    let numFmtId: Int?
    let borderID: Int?

    /// A unique string identifier combining all component IDs, used for hashing and comparison.
    var id: String {
        let numFmtStr = numFmtId.map(String.init) ?? "default"
        let fontStr = fontID.map(String.init) ?? "default"
        let fillStr = fillID.map(String.init) ?? "default"
        let alignStr = alignmentID.map(String.init) ?? "default"
        let borderStr = borderID.map(String.init) ?? "default"

        return "\(numFmtStr)_\(fontStr)_\(fillStr)_\(alignStr)_\(borderStr)"
    }
}
