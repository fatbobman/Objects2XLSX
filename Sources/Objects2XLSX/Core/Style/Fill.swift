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
public enum PatternType: String, CaseIterable, Sendable, Hashable {
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
    // 可以根据需要添加更多
}

/// Gradient types (future use)
public enum GradientType: Sendable, Hashable {
    case linear(angle: Double)
    case radial
}

extension Fill {
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
                return "<patternFill patternType=\"none\"/>"

            case let .solid(color):
                return """
                    <patternFill patternType="solid">
                        <fgColor rgb="\(color.argbHexString)"/>
                    </patternFill>
                    """

            case let .pattern(type, fg, bg):
                var xml = "<patternFill patternType=\"\(type.rawValue)\">"
                xml += "<fgColor rgb=\"\(fg.argbHexString)\"/>"
                if let bgColor = bg {
                    xml += "<bgColor rgb=\"\(bgColor.argbHexString)\"/>"
                }
                xml += "</patternFill>"
                return xml

            case .gradient:
                // 未来实现渐变填充
                return "<patternFill patternType=\"none\"/>"
        }
    }
}
