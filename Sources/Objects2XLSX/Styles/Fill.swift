//
// Fill.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Cell background fill patterns and colors for Excel styling.

 `Fill` provides comprehensive background styling for Excel cells, supporting
 solid colors, pattern fills, and gradient fills. This enumeration covers all
 Excel fill options while maintaining type safety and ease of use.

 ## Overview

 Excel cells can have various background fills, from simple solid colors to
 complex patterns and gradients. This enumeration provides type-safe access
 to all fill options, with automatic XML generation for Excel compatibility.

 ## Fill Types

 ### Basic Fills
 - **none**: Transparent background (Excel default)
 - **solid**: Single color background fill

 ### Advanced Fills
 - **pattern**: Patterned fills with foreground and background colors
 - **gradient**: Gradient fills with multiple colors and direction control

 ## Usage Examples

 ### Solid Color Fills
 ```swift
 let redFill = Fill.solid(.red)
 let blueFill = Fill.solid(red: 0, green: 100, blue: 255)
 let hexFill = Fill.solid(hex: "#FF5733")
 ```

 ### Pattern Fills
 ```swift
 let stripedFill = Fill.pattern(.darkHorizontal, foreground: .black, background: .white)
 let dottedFill = Fill.pattern(.gray125, foreground: .blue)
 ```

 ### Gradient Fills (Future Extension)
 ```swift
 let linearGradient = Fill.gradient(.linear(angle: 45), colors: [.red, .yellow, .green])
 let radialGradient = Fill.gradient(.radial, colors: [.white, .blue])
 ```

 ## Excel Compatibility

 All fill types generate Excel-compatible XML:
 - Solid fills use Excel's patternFill with solid pattern type
 - Pattern fills support all Excel pattern types with proper color mapping
 - Gradient fills follow Excel's gradientFill specification
 - Default fills include Excel-required empty fill slots

 - Note: Some advanced fill types may have limited support in older Excel versions
 */
public enum Fill: Equatable, Sendable, Hashable {
    /// No fill (transparent)
    case none

    /// Solid color fill
    case solid(Color)

    /// Pattern fills (future extensions)
    case pattern(PatternType, foreground: Color, background: Color? = nil)

    /// Gradient fills (future extensions)
    case gradient(GradientType, colors: [Color])
}

extension Fill: Identifiable {
    public var id: String {
        switch self {
            case .none:
                "none"
            case let .solid(color):
                "solid_\(color.hexString)"
            case let .pattern(type, fg, bg):
                "pattern_\(type.rawValue)_\(fg.hexString)_\(bg?.hexString ?? "none")"
            case .gradient:
                "gradient_\(UUID().uuidString)" // 复杂情况可以用更详细的ID
        }
    }
}

/**
 Pattern types for Excel cell background fills.

 These pattern types correspond directly to Excel's built-in fill patterns,
 providing access to all pattern options available in Excel's Format Cells dialog.

 ## Pattern Categories

 ### Basic Patterns
 - **none**: No pattern (transparent)
 - **solid**: Solid fill (most common)

 ### Gray Patterns
 - **gray125**: 12.5% gray pattern
 - **gray0625**: 6.25% gray pattern

 ### Line Patterns
 - **darkHorizontal**: Dark horizontal lines
 - **darkVertical**: Dark vertical lines
 - **lightHorizontal**: Light horizontal lines
 - **lightVertical**: Light vertical lines

 ### Diagonal Patterns
 - **darkDown**: Dark diagonal lines (top-left to bottom-right)
 - **darkUp**: Dark diagonal lines (bottom-left to top-right)
 - **lightDown**: Light diagonal lines (top-left to bottom-right)
 - **lightUp**: Light diagonal lines (bottom-left to top-right)

 ### Grid Patterns
 - **darkGrid**: Dark grid pattern (horizontal and vertical)
 - **darkTrellis**: Dark trellis pattern (diagonal grid)
 - **lightGrid**: Light grid pattern
 - **lightTrellis**: Light trellis pattern

 ## Usage
 Pattern fills require a foreground color and optionally a background color:
 ```swift
 let pattern = Fill.pattern(.darkGrid, foreground: .black, background: .white)
 ```

 - Note: Visual appearance may vary between Excel versions and display settings
 */
public enum PatternType: String, CaseIterable, Sendable, Hashable, Equatable {
    case none
    case solid
    case gray125
    case gray0625
    case darkHorizontal
    case darkVertical
    case darkDown
    case darkUp
    case darkGrid
    case darkTrellis
    case lightHorizontal
    case lightVertical
    case lightDown
    case lightUp
    case lightGrid
    case lightTrellis
}

/**
 Gradient fill types for advanced Excel styling.

 `GradientType` defines the direction and style of gradient fills,
 supporting both linear and radial gradient patterns.

 ## Gradient Types

 - **linear**: Linear gradient with specified angle in degrees
 - **radial**: Radial gradient emanating from center

 ## Usage
 ```swift
 let horizontalGradient = GradientType.linear(angle: 0)    // Left to right
 let verticalGradient = GradientType.linear(angle: 90)     // Top to bottom
 let diagonalGradient = GradientType.linear(angle: 45)     // Diagonal
 let circularGradient = GradientType.radial               // Center outward
 ```

 - Note: This is a future enhancement - gradient support may be limited in current Excel versions
 */
public enum GradientType: Sendable, Hashable {
    case linear(angle: Double)
    case radial
}

extension Fill {
    /// Default fill patterns required by Excel specification.
    ///
    /// Excel requires at least two default fill entries in the styles.xml file:
    /// - Index 0: Default fill (none)
    /// - Index 1: Gray125 pattern fill
    ///
    /// These fills are automatically included in every Excel workbook's style registry.
    static let defaultFills: [Fill] = [
        .none, // index 0: Excel requires at least one fill
        .none, // index 1: transparent fill
    ]

    /// Create a solid color fill with RGB values
    /// - Parameters:
    ///   - red: The red component (0-255).
    ///   - green: The green component (0-255).
    ///   - blue: The blue component (0-255).
    /// - Returns: A `Fill` instance with the specified solid color.
    public static func solid(red: UInt8, green: UInt8, blue: UInt8) -> Fill {
        .solid(Color.rgb(red, green, blue))
    }

    /// Create a solid color fill with hex, prfixed with `#`
    ///
    /// - Parameter hex: The hex color code, e.g. `#FF0000` for red.
    /// - Returns: A `Fill` instance with the specified solid color.
    /// - Note: The hex code should start with `#` and be 7 characters long (including `#`).
    public static func solid(hex: String) -> Fill {
        .solid(Color(hex: hex))
    }
}

extension Fill {
    /// Generate XML for this fill
    var xmlContent: String {
        switch self {
            case .none:
                return "<fill><patternFill patternType=\"none\"/></fill>"

            case let .solid(color):
                return """
                    <fill>
                        <patternFill patternType="solid">
                            <fgColor rgb="\(color.argbHexString)"/>
                        </patternFill>
                    </fill>
                    """

            case let .pattern(type, foreground, background):
                var xml = "<fill><patternFill patternType=\"\(type.rawValue)\">"
                xml += "<fgColor rgb=\"\(foreground.argbHexString)\"/>"
                if let bgColor = background {
                    xml += "<bgColor rgb=\"\(bgColor.argbHexString)\"/>"
                }
                xml += "</patternFill></fill>"
                return xml

            case let .gradient(type, colors):
                // Gradient fill implementation (future feature)
                var xml = "<fill><gradientFill"
                switch type {
                    case let .linear(angle):
                        xml += " degree=\"\(angle)\""
                    case .radial:
                        xml += " type=\"path\""
                }
                xml += ">"

                // Add gradient color stops
                for (index, color) in colors.enumerated() {
                    let position = colors.count > 1 ? Double(index) / Double(colors.count - 1) : 0.0
                    xml += "<stop position=\"\(position)\"><color rgb=\"\(color.argbHexString)\"/></stop>"
                }

                xml += "</gradientFill></fill>"
                return xml
        }
    }
}
