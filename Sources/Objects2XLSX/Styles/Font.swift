//
// Font.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents a font in an Excel Cell.
///
/// `Font` is a structure that represents a font in an Excel Cell.
/// It provides a way to create a font with a size, name, bold, and color.
public struct Font: Equatable, Sendable, Hashable {
    /// The size of the font.
    var size: Int?
    /// The name of the font.
    var name: String?
    /// Whether the font is bold.
    var bold: Bool?
    /// The color of the font.
    var color: Color?
    /// Whether the font is italic.
    var italic: Bool?
    /// Whether the font is underlined.
    var underline: Bool?

    /// Creates a font with the given size, name, bold, and color.
    ///
    /// - Parameter size: The size of the font.
    /// - Parameter name: The name of the font.
    /// - Parameter bold: Whether the font is bold.
    /// - Parameter italic: Whether the font is italic.
    /// - Parameter underline: Whether the font is underlined.
    /// - Parameter color: The color of the font.
    public init(
        size: Int? = nil,
        name: String? = nil,
        bold: Bool? = nil,
        italic: Bool? = nil,
        underline: Bool? = nil,
        color: Color? = nil)
    {
        self.size = size
        self.name = name
        self.bold = bold
        self.color = color
        self.italic = italic
        self.underline = underline
    }

    /// The default font.
    public static let `default` = Font(size: 12, name: "Calibri")
    /// The header font.
    public static let header = Font(size: 12, name: "Calibri", bold: true)
}

extension Font: Identifiable {
    public var id: String {
        let boldStr = bold == true ? "_bold" : ""
        let colorStr = color?.hexString ?? "default"
        return "\(name ?? "default")_\(size ?? 12)\(boldStr)_\(colorStr)"
    }
}

// MARK: - Font Extensions

extension Font {
    /// Makes the font bold.
    ///
    /// - Returns: A new font with the bold property set to true.
    public func bolded() -> Self {
        var newSelf = self
        newSelf.bold = true
        return newSelf
    }

    /// Sets the color of the font.
    ///
    /// - Parameter color: The color of the font.
    /// - Returns: A new font with the color property set to the given color.
    public func color(_ color: Color) -> Self {
        var newSelf = self
        newSelf.color = color
        return newSelf
    }

    /// Sets the size of the font.
    ///
    /// - Parameter size: The size of the font.
    /// - Returns: A new font with the size property set to the given size.
    public func size(_ size: Int) -> Self {
        var newSelf = self
        newSelf.size = size
        return newSelf
    }

    /// Sets the italic property of the font.
    ///
    /// - Parameter italic: Whether the font is italic.
    /// - Returns: A new font with the italic property set to the given value.
    public func italic(_ italic: Bool) -> Self {
        var newSelf = self
        newSelf.italic = italic
        return newSelf
    }

    /// Sets the underline property of the font.
    ///
    /// - Parameter underline: Whether the font is underlined.
    /// - Returns: A new font with the underline property set to the given value.
    public func underline(_ underline: Bool) -> Self {
        var newSelf = self
        newSelf.underline = underline
        return newSelf
    }

    /// Sets the name of the font.
    ///
    /// - Parameter name: The name of the font.
    /// - Returns: A new font with the name property set to the given name.
    public func name(_ name: String) -> Self {
        var newSelf = self
        newSelf.name = name
        return newSelf
    }
}

// MARK: - Font XML Generation

extension Font {
    var xmlContent: String {
        var xml = "<font>"

        // font size
        xml += "<sz val=\"\(size ?? 12)\"/>"

        // color
        if let color {
            xml += "<color rgb=\"\(color.argbHexString)\"/>"
        } else {
            // if no color is specified, use the theme color (hardcoded)
            xml += "<color theme=\"1\"/>"
        }

        // font name
        xml += "<name val=\"\(name ?? "Calibri")\"/>"

        // font family (hardcoded, based on common fonts)
        let fontFamily = getFontFamily(for: name ?? "Calibri")
        xml += "<family val=\"\(fontFamily)\"/>"

        // bold, italic, underline, etc.
        if let bold, bold {
            xml += "<b/>"
        }

        if let italic, italic {
            xml += "<i/>"
        }

        if let underline, underline {
            xml += "<u val=\"single\"/>"
        }

        xml += "</font>"
        return xml
    }

    /// Determines the appropriate font family classification for Excel.
    ///
    /// Excel uses numeric font family codes to optimize font selection:
    /// - 1: Roman (serif fonts like Times New Roman)
    /// - 2: Swiss (sans-serif fonts like Arial, Calibri)
    /// - 3: Modern (monospace fonts like Courier New)
    ///
    /// - Parameter fontName: The font family name to classify
    /// - Returns: Excel font family code (1-3, defaults to 2 for sans-serif)
    private func getFontFamily(for fontName: String) -> Int {
        switch fontName.lowercased() {
            case "times", "times new roman", "georgia":
                1 // Roman (serif fonts)
            case "calibri", "arial", "helvetica", "tahoma":
                2 // Swiss (sans-serif fonts)
            case "courier", "courier new", "consolas":
                3 // Modern (monospace fonts)
            default:
                2 // Default to sans-serif for unknown fonts
        }
    }
}
