//
// Color.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 ARGB color representation for Excel styling.

 `Color` provides comprehensive color support for Excel styling, using ARGB
 (Alpha, Red, Green, Blue) format for maximum compatibility with Excel's
 color system. This structure supports both RGB and ARGB color definitions
 with flexible construction options.

 ## Overview

 This implementation uses Excel's native ARGB color format, ensuring perfect
 color reproduction when Excel files are opened in Excel or other spreadsheet
 applications. The structure supports transparency through alpha channel
 control and provides convenient constructors for common color formats.

 ## Key Features

 - **ARGB Format**: Native Excel color format with alpha channel support
 - **Hex Support**: Direct hex string input with automatic parsing
 - **RGB Convenience**: Traditional RGB construction with optional alpha
 - **Predefined Colors**: Common color constants for immediate use
 - **Transparency Levels**: Five predefined alpha levels from transparent to opaque

 ## Usage Examples

 ### Basic Color Creation
 ```swift
 let red = Color(red: 255, green: 0, blue: 0)
 let blue = Color.blue
 let transparent = Color(red: 255, green: 0, blue: 0, alpha: .transparent)
 ```

 ### Hex Color Support
 ```swift
 let hexColor = Color(hex: "#FF5733")
 let hexColorNoHash = Color(hex: "FF5733")
 ```

 ### Advanced Color with Alpha
 ```swift
 let semiTransparent = Color.rgba(255, 128, 0, .medium) // 50% transparent orange
 let opaqueGreen = Color.rgb(0, 255, 0) // Fully opaque green
 ```

 ## Excel Integration

 Colors integrate seamlessly with Excel's styling system:
 - ARGB format matches Excel's internal color representation
 - Alpha channel provides transparency effects in supported Excel versions
 - Hex output formats support both Excel XML and display purposes
 - Predefined colors use standard Excel color values

 - Note: Alpha channel support may vary depending on Excel version and context
 */
public struct Color: Equatable, Sendable, Hashable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    /// Alpha channel for transparency control
    public let alpha: ColorAlpha

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: ColorAlpha = .opaque) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public init(hex: String, alpha: ColorAlpha = .opaque) {
        // Handle hex string input, supporting both #RRGGBB and RRGGBB formats
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard hexString.count == 6,
              let red = UInt8(hexString.prefix(2), radix: 16),
              let green = UInt8(hexString.dropFirst(2).prefix(2), radix: 16),
              let blue = UInt8(hexString.suffix(2), radix: 16)
        else {
            fatalError("Invalid hex color string")
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// ARGB hexadecimal string representation (Excel format).
    ///
    /// This format is used internally by Excel for color storage and is the
    /// primary format for XML generation. The format is AARRGGBB where:
    /// - AA: Alpha channel (00-FF)
    /// - RR: Red channel (00-FF)
    /// - GG: Green channel (00-FF)
    /// - BB: Blue channel (00-FF)
    public var argbHexString: String {
        String(format: "%02X%02X%02X%02X", alpha.rawValue, red, green, blue)
    }

    /// RGB hexadecimal string representation (backward compatibility).
    ///
    /// This format excludes the alpha channel and provides a standard
    /// 6-character hex color string commonly used in web and design contexts.
    /// Format is RRGGBB without alpha information.
    public var hexString: String {
        String(format: "%02X%02X%02X", red, green, blue)
    }
}

// MARK: - Convenience Constructors
extension Color {
    public static func rgba(_ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: ColorAlpha) -> Color {
        Color(red: red, green: green, blue: blue, alpha: alpha)
    }

    public static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Color {
        Color(red: red, green: green, blue: blue, alpha: .opaque)
    }
}

/**
 Alpha channel levels for color transparency.

 `ColorAlpha` provides predefined transparency levels that correspond to
 common alpha values used in design and Excel styling. These levels offer
 a balance between precise control and ease of use.

 ## Transparency Levels

 - **transparent**: Completely transparent (0% opacity)
 - **light**: Very light transparency (25% opacity)
 - **medium**: Medium transparency (50% opacity)
 - **strong**: Strong opacity with slight transparency (75% opacity)
 - **opaque**: Completely opaque (100% opacity, default)

 ## Usage

 ```swift
 let transparentRed = Color(red: 255, green: 0, blue: 0, alpha: .transparent)
 let semiTransparentBlue = Color(red: 0, green: 0, blue: 255, alpha: .medium)
 ```

 - Note: Alpha channel support depends on the Excel version and styling context
 */
public enum ColorAlpha: UInt8, CaseIterable, Sendable, Hashable, Equatable {
    case transparent = 0  /// Completely transparent (0% opacity)
    case light = 64       /// Light transparency (25% opacity)
    case medium = 128     /// Medium transparency (50% opacity)
    case strong = 192     /// Strong opacity (75% opacity)
    case opaque = 255     /// Completely opaque (100% opacity, default)
}

// MARK: - Predefined Colors

extension Color {
    /// Pure black color (RGB: 0, 0, 0)
    public static let black = Color(red: 0, green: 0, blue: 0)
    
    /// Pure white color (RGB: 255, 255, 255)
    public static let white = Color(red: 255, green: 255, blue: 255)
    
    /// Pure red color (RGB: 255, 0, 0)
    public static let red = Color(red: 255, green: 0, blue: 0)
    
    /// Pure green color (RGB: 0, 255, 0)
    public static let green = Color(red: 0, green: 255, blue: 0)
    
    /// Pure blue color (RGB: 0, 0, 255)
    public static let blue = Color(red: 0, green: 0, blue: 255)
    
    /// Pure yellow color (RGB: 255, 255, 0)
    public static let yellow = Color(red: 255, green: 255, blue: 0)
    
    /// Pure cyan color (RGB: 0, 255, 255)
    public static let cyan = Color(red: 0, green: 255, blue: 255)
    
    /// Pure magenta color (RGB: 255, 0, 255)
    public static let magenta = Color(red: 255, green: 0, blue: 255)
    
    /// Medium gray color (RGB: 128, 128, 128)
    public static let gray = Color(red: 128, green: 128, blue: 128)
    
    /// Light gray color (RGB: 211, 211, 211)
    public static let lightGray = Color(red: 211, green: 211, blue: 211)
}
