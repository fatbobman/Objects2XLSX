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

        // 字体大小
        xml += "<sz val=\"\(size ?? 12)\"/>"

        // 颜色处理
        if let color = color {
            xml += "<color rgb=\"\(color.argbHexString)\"/>"
        } else {
            // 没有指定颜色时，使用主题色（写死）
            xml += "<color theme=\"1\"/>"
        }

        // 字体名称
        xml += "<name val=\"\(name ?? "Calibri")\"/>"

        // 字体族（写死，基于常见字体）
        let fontFamily = getFontFamily(for: name ?? "Calibri")
        xml += "<family val=\"\(fontFamily)\"/>"

        // 粗体、斜体等...
        if let bold = bold, bold {
            xml += "<b/>"
        }

        if let italic = italic, italic {
            xml += "<i/>"
        }

        if let underline = underline, underline {
            xml += "<u val=\"single\"/>"
        }

        xml += "</font>"
        return xml
    }

    // 根据字体名称推断字体族
    private func getFontFamily(for fontName: String) -> Int {
        switch fontName.lowercased() {
        case "times", "times new roman", "georgia":
            return 1  // Roman (衬线)
        case "calibri", "arial", "helvetica", "tahoma":
            return 2  // Swiss (无衬线)
        case "courier", "courier new", "consolas":
            return 3  // Modern (等宽)
        default:
            return 2  // 默认无衬线
        }
    }
}
