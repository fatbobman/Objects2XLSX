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
/// `StyleRegistor` acts as the style management hub for Excel document generation, handling the collection,
/// deduplication, and XML serialization of all style elements including fonts, fills, borders, alignments,
/// and number formats.
///
/// ## Architecture
/// The registor maintains separate pools for each style component:
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

/// Represents the number format of a cell, including built-in and custom formats.
public enum NumberFormat: Equatable, Sendable, Hashable, Identifiable {
    /// General format (default).
    case general
    /// Percentage format with specified decimal precision.
    case percentage(precision: Int)
    /// Date format.
    case date
    /// Time format.
    case time
    /// Date and time format.
    case dateTime
    /// Currency format (future extension).
    case currency
    /// Scientific notation format (future extension).
    case scientific

    /// A unique string identifier for the format, used for hashing and comparison.
    public var id: String {
        switch self {
            case .general:
                "General"
            case let .percentage(precision):
                "Percentage(\(precision))"
            case .date:
                "Date"
            case .time:
                "Time"
            case .dateTime:
                "DateTime"
            case .currency:
                "Currency"
            case .scientific:
                "Scientific"
        }
    }

    /// The Excel format code string for this number format, if applicable.
    var formatCode: String? {
        switch self {
            case .general:
                nil // Use Excel default
            case let .percentage(precision):
                "0.\(String(repeating: "0", count: precision))%"
            case .date:
                "yyyy-mm-dd"
            case .time:
                "hh:mm:ss"
            case .dateTime:
                "yyyy-mm-dd hh:mm:ss"
            case .currency:
                "\"$\"#,##0.00"
            case .scientific:
                "0.00E+00"
        }
    }

    /// The built-in Excel number format ID for this format if available.
    var builtinId: Int? {
        switch self {
            case .date:
                14 // Excel built-in date format
            case .dateTime:
                22 // Excel built-in date-time format
            default:
                nil
        }
    }
}
