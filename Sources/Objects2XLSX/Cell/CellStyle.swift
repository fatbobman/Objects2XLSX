//
// CellStyle.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Represents the visual formatting and styling properties applied to Excel cells.
///
/// `CellStyle` combines multiple formatting aspects (typography, colors, alignment, borders)
/// into a cohesive styling definition. This design enables efficient style reuse and follows
/// Excel's separation of content from presentation.
///
/// ## Style Components
/// - **Font**: Typography settings (size, family, weight, color)
/// - **Fill**: Background colors and patterns
/// - **Alignment**: Text positioning and flow control
/// - **Border**: Cell boundary styling and colors
///
/// ## Style Hierarchy and Merging
/// Styles can be merged with different priority levels:
/// 1. Book-level default styles (lowest priority)
/// 2. Sheet-level styles (medium priority)
/// 3. Column-level styles (higher priority)
/// 4. Cell-level styles (highest priority)
///
/// ## Usage Example
/// ```swift
/// let headerStyle = CellStyle(
///     font: Font(size: 14, name: "Arial", bold: true),
///     fill: Fill.solid(.blue),
///     alignment: Alignment.center,
///     border: Border.all(style: .thin, color: .black)
/// )
/// ```
///
/// ## Performance Considerations
/// CellStyle implements `Hashable` to enable efficient deduplication in the style registry,
/// ensuring that identical styles are stored only once regardless of how many cells use them.
public struct CellStyle: Equatable, Sendable, Hashable {
    /// Typography settings for text within the cell (nil = use default font)
    public let font: Font?
    /// Background color and pattern for the cell (nil = no fill)
    public let fill: Fill?
    /// Text positioning and flow control within the cell (nil = default alignment)
    public let alignment: Alignment?
    /// Border styling for cell boundaries (nil = no border)
    public let border: Border?

    /// Creates a new cell style with the specified formatting components.
    ///
    /// All parameters are optional, allowing you to specify only the styling aspects
    /// you want to customize. Unspecified components will use Excel's defaults.
    ///
    /// - Parameters:
    ///   - font: Typography settings (nil uses default font)
    ///   - fill: Background styling (nil uses no fill)
    ///   - alignment: Text positioning (nil uses default alignment)
    ///   - border: Cell boundary styling (nil uses no border)
    public init(font: Font? = nil, fill: Fill? = nil, alignment: Alignment? = nil, border: Border? = nil) {
        self.font = font
        self.fill = fill
        self.alignment = alignment
        self.border = border
    }
}

extension CellStyle {
    /// The default cell style with standard Excel formatting.
    ///
    /// Provides a baseline style that matches Excel's default cell appearance:
    /// - Default font (typically Calibri 11pt)
    /// - No background fill
    /// - Standard left alignment for text, right for numbers
    /// - No borders
    ///
    /// This style serves as a reference point for style comparisons and merging.
    public static let `default` = CellStyle(
        font: .default,
        fill: Fill.none,
        alignment: .default,
        border: Border.none)
}

extension CellStyle {
    /// Merges two cell styles with priority-based property overriding.
    ///
    /// Combines style properties from a base style and an additional style, where
    /// non-nil properties from the additional style take precedence over the base style.
    /// This enables hierarchical style application common in Excel formatting.
    ///
    /// ## Merge Logic
    /// - If both styles are nil: returns nil
    /// - If only one style exists: returns that style
    /// - If both styles exist: additional style properties override base style properties
    ///
    /// - Parameters:
    ///   - base: The foundational style (lower priority)
    ///   - additional: The overlaying style (higher priority)
    /// - Returns: Merged style, or nil if both input styles are nil
    static func merge(base: CellStyle?, additional: CellStyle?) -> CellStyle? {
        // Return nil if both styles are nil
        guard base != nil || additional != nil else { return nil }

        // Return the non-nil style if only one exists
        guard let base else { return additional }
        guard let additional else { return base }

        // Merge properties with additional style taking precedence
        return CellStyle(
            font: additional.font ?? base.font,
            fill: additional.fill ?? base.fill,
            alignment: additional.alignment ?? base.alignment,
            border: additional.border ?? base.border)
    }

    /// Merges multiple cell styles in priority order from lowest to highest precedence.
    ///
    /// Applies cascading style merging where later styles in the parameter list override
    /// properties from earlier styles. This is particularly useful for implementing
    /// Excel's hierarchical styling system where book, sheet, column, and cell styles
    /// are applied in order of increasing precedence.
    ///
    /// ## Usage Example
    /// ```swift
    /// let finalStyle = CellStyle.merge(
    ///     book.defaultBodyStyle,      // Lowest priority
    ///     sheet.columnBodyStyle,      // Medium priority
    ///     column.bodyStyle,           // Higher priority
    ///     cell.specificStyle          // Highest priority
    /// )
    /// ```
    ///
    /// - Parameter styles: Array of styles ordered by priority (low to high)
    /// - Returns: Final merged style with all applicable properties, or nil if all styles are nil
    static func merge(_ styles: CellStyle?...) -> CellStyle? {
        styles.reduce(nil) { result, style in
            merge(base: result, additional: style)
        }
    }
}
