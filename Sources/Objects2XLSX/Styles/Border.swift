//
// Border.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Comprehensive border styling for Excel cells.

 `Border` provides complete control over cell border appearance, supporting
 individual configuration of each border side (left, right, top, bottom) plus
 optional diagonal borders. Each side can have its own style and color.

 ## Overview

 This structure enables precise border control for Excel cells, supporting
 all Excel border styles from simple outlines to complex pattern borders.
 Border sides are configured independently, allowing for asymmetric border
 designs and selective edge styling.

 ## Key Features

 - **Individual Side Control**: Configure left, right, top, bottom borders independently
 - **Style Variety**: Support for all Excel border styles (thin, thick, dashed, dotted, etc.)
 - **Color Customization**: Full color support for each border side
 - **Diagonal Borders**: Optional diagonal border support for future use
 - **Preset Configurations**: Convenient presets for common border patterns

 ## Usage Examples

 ### Basic Borders
 ```swift
 let thinBorder = Border.all(style: .thin, color: .black)
 let thickOutline = Border.outline(style: .thick, color: .blue)
 ```

 ### Custom Side Configuration
 ```swift
 let customBorder = Border(
     left: Border.Side(style: .thick, color: .red),
     right: Border.Side(style: .thin, color: .black),
     top: Border.Side(style: .dashed, color: .gray)
     // bottom remains nil (no border)
 )
 ```

 ### Selective Borders
 ```swift
 let horizontalOnly = Border.horizontal(style: .medium, color: .black)
 let verticalOnly = Border.vertical(style: .thin, color: .gray)
 ```

 ## Excel Compatibility

 All border styles correspond directly to Excel's native border options:
 - Style names match Excel's internal style identifiers
 - Colors use Excel's ARGB format for perfect compatibility
 - Border merging follows Excel's precedence rules
 - XML generation produces Excel-compatible markup

 - Note: Diagonal borders are supported in the structure but may have limited Excel compatibility
 */
public struct Border: Equatable, Sendable, Hashable {
    /**
     Configuration for an individual border side.
     
     `Side` represents the styling for a single edge of a cell border,
     combining line style and color information. This granular approach
     allows for precise control over each border edge.
     
     ## Properties
     - **style**: The line style (thin, thick, dashed, etc.)
     - **color**: The border color (defaults to black)
     
     ## Usage
     ```swift
     let redThickSide = Border.Side(style: .thick, color: .red)
     let defaultThinSide = Border.Side(style: .thin) // Black by default
     ```
     */
    public struct Side: Equatable, Sendable, Hashable {
        /// Border line style
        public let style: BorderStyle
        /// Border color
        public let color: Color

        public init(style: BorderStyle, color: Color = .black) {
            self.style = style
            self.color = color
        }
    }

    /// Left border
    public let left: Side?
    /// Right border
    public let right: Side?
    /// Top border
    public let top: Side?
    /// Bottom border
    public let bottom: Side?
    /// Diagonal border (optional, for future use)
    public let diagonal: Side?

    public init(
        left: Side? = nil,
        right: Side? = nil,
        top: Side? = nil,
        bottom: Side? = nil,
        diagonal: Side? = nil)
    {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        self.diagonal = diagonal
    }
}

/**
 Excel-compatible border line styles.

 These style options correspond exactly to Excel's built-in border styles,
 ensuring perfect visual compatibility when the generated Excel files are
 opened in Excel or other spreadsheet applications.

 ## Style Categories

 ### Basic Styles
 - **none**: No border (transparent)
 - **thin**: Standard thin line (most common)
 - **medium**: Medium thickness line
 - **thick**: Heavy line for emphasis
 - **hair**: Very thin hairline

 ### Pattern Styles
 - **dashed**: Dashed line pattern
 - **dotted**: Dotted line pattern
 - **double**: Double line style
 - **dashDot**: Alternating dash and dot pattern
 - **dashDotDot**: Dash followed by two dots pattern

 ### Specialized Styles
 - **mediumDashed**: Medium-weight dashed line
 - **mediumDashDot**: Medium-weight dash-dot pattern
 - **mediumDashDotDot**: Medium-weight dash-dot-dot pattern
 - **slantDashDot**: Slanted dash-dot pattern

 - Note: Visual appearance may vary slightly between Excel versions and platforms
 */
public enum BorderStyle: String, CaseIterable, Sendable {
    case none
    case thin
    case medium
    case thick
    case dashed
    case dotted
    case double
    case hair
    case mediumDashed
    case dashDot
    case mediumDashDot
    case dashDotDot
    case mediumDashDotDot
    case slantDashDot
}

// MARK: - Border Extensions

// MARK: - Border Convenience Extensions

extension Border {
    /// Creates a border with no styling (transparent on all sides).
    ///
    /// This is the default border state, equivalent to no border styling.
    /// Useful when you want to explicitly specify no borders.
    public static let none = Border()

    /// Creates a border with the same style and color on all four sides.
    ///
    /// This is the most common border pattern, creating a complete outline
    /// around the cell with consistent styling.
    ///
    /// - Parameters:
    ///   - style: The border line style to apply to all sides
    ///   - color: The border color to apply to all sides (defaults to black)
    /// - Returns: A `Border` with identical styling on all four sides
    public static func all(style: BorderStyle, color: Color = .black) -> Border {
        let side = Side(style: style, color: color)
        return Border(left: side, right: side, top: side, bottom: side)
    }

    /// Creates a complete outline border (identical to `all`).
    ///
    /// This method is an alias for `all()` that provides more semantic clarity
    /// when the intent is to create a complete cell outline.
    ///
    /// - Parameters:
    ///   - style: The border line style for the outline
    ///   - color: The border color for the outline (defaults to black)
    /// - Returns: A `Border` with complete outline styling
    public static func outline(style: BorderStyle, color: Color = .black) -> Border {
        all(style: style, color: color)
    }

    /// Creates horizontal borders only (top and bottom sides).
    ///
    /// This pattern is useful for table row separation or creating
    /// horizontal dividers within data ranges.
    ///
    /// - Parameters:
    ///   - style: The border line style for horizontal borders
    ///   - color: The border color (defaults to black)
    /// - Returns: A `Border` with only top and bottom styling
    public static func horizontal(style: BorderStyle, color: Color = .black) -> Border {
        let side = Side(style: style, color: color)
        return Border(top: side, bottom: side)
    }

    /// Creates vertical borders only (left and right sides).
    ///
    /// This pattern is useful for table column separation or creating
    /// vertical dividers within data ranges.
    ///
    /// - Parameters:
    ///   - style: The border line style for vertical borders
    ///   - color: The border color (defaults to black)
    /// - Returns: A `Border` with only left and right styling
    public static func vertical(style: BorderStyle, color: Color = .black) -> Border {
        let side = Side(style: style, color: color)
        return Border(left: side, right: side)
    }
}

extension Border: Identifiable {
    public var id: String {
        let leftStr = left?.id ?? "none"
        let rightStr = right?.id ?? "none"
        let topStr = top?.id ?? "none"
        let bottomStr = bottom?.id ?? "none"
        let diagonalStr = diagonal?.id ?? "none"

        return "\(leftStr)_\(rightStr)_\(topStr)_\(bottomStr)_\(diagonalStr)"
    }
}

extension Border.Side: Identifiable {
    public var id: String {
        "\(style.rawValue)_\(color.argbHexString)"
    }
}

// MARK: - XML Generation

extension Border {
    var xmlContent: String {
        var xml = "<border>"

        // Left border
        if let left {
            xml += "<left style=\"\(left.style.rawValue)\">"
            xml += "<color rgb=\"\(left.color.argbHexString)\"/>"
            xml += "</left>"
        } else {
            xml += "<left/>"
        }

        // Right border
        if let right {
            xml += "<right style=\"\(right.style.rawValue)\">"
            xml += "<color rgb=\"\(right.color.argbHexString)\"/>"
            xml += "</right>"
        } else {
            xml += "<right/>"
        }

        // Top border
        if let top {
            xml += "<top style=\"\(top.style.rawValue)\">"
            xml += "<color rgb=\"\(top.color.argbHexString)\"/>"
            xml += "</top>"
        } else {
            xml += "<top/>"
        }

        // Bottom border
        if let bottom {
            xml += "<bottom style=\"\(bottom.style.rawValue)\">"
            xml += "<color rgb=\"\(bottom.color.argbHexString)\"/>"
            xml += "</bottom>"
        } else {
            xml += "<bottom/>"
        }

        // Diagonal border
        if let diagonal {
            xml += "<diagonal style=\"\(diagonal.style.rawValue)\">"
            xml += "<color rgb=\"\(diagonal.color.argbHexString)\"/>"
            xml += "</diagonal>"
        } else {
            xml += "<diagonal/>"
        }

        xml += "</border>"
        return xml
    }
}

extension Border {
    /**
     Merges two border configurations with precedence handling.
     
     This method combines two border configurations, with the additional border
     taking precedence over the base border for any conflicting sides. This is
     useful when applying multiple border styles to overlapping regions.
     
     - Parameters:
        - base: The base border configuration (lower precedence)
        - additional: The additional border configuration (higher precedence)
     
     - Returns: A merged `Border` with combined styling, or `nil` if both inputs are `nil`
     
     ## Merge Logic
     
     For each border side (left, right, top, bottom, diagonal):
     1. If `additional` has a style for that side, use it
     2. Otherwise, use the style from `base` if available
     3. If neither has a style, that side remains unset
     
     ## Usage Example
     ```swift
     let baseBorder = Border.all(style: .thin, color: .black)
     let accentBorder = Border(top: Border.Side(style: .thick, color: .red))
     let merged = Border.merge(base: baseBorder, additional: accentBorder)
     // Result: thin black borders on left/right/bottom, thick red border on top
     ```
     */
    public static func merge(base: Border?, additional: Border?) -> Border? {
        guard let base else { return additional }
        guard let additional else { return base }

        return Border(
            left: additional.left ?? base.left,
            right: additional.right ?? base.right,
            top: additional.top ?? base.top,
            bottom: additional.bottom ?? base.bottom,
            diagonal: additional.diagonal ?? base.diagonal)
    }
}
