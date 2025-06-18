//
// Fill.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// Represents a fill pattern for Excel cells
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

/// Pattern types for fill
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

/// Gradient types (future use)
public enum GradientType: Sendable, Hashable {
    case linear(angle: Double)
    case radial
}

extension Fill {
    /// Create default fills required by Excel
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
                // 渐变填充的实现（未来功能）
                var xml = "<fill><gradientFill"
                switch type {
                    case let .linear(angle):
                        xml += " degree=\"\(angle)\""
                    case .radial:
                        xml += " type=\"path\""
                }
                xml += ">"

                // 添加渐变色点
                for (index, color) in colors.enumerated() {
                    let position = colors.count > 1 ? Double(index) / Double(colors.count - 1) : 0.0
                    xml += "<stop position=\"\(position)\"><color rgb=\"\(color.argbHexString)\"/></stop>"
                }

                xml += "</gradientFill></fill>"
                return xml
        }
    }
}
