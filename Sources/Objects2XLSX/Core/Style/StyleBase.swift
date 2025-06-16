//
// StyleBase.swift
// Created by Xu Yang on 2025-06-05.
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

    /// Creates a font with the given size, name, bold, and color.
    ///
    /// - Parameter size: The size of the font.
    /// - Parameter name: The name of the font.
    /// - Parameter bold: Whether the font is bold.
    /// - Parameter color: The color of the font.
    public init(
        size: Int? = nil,
        name: String? = nil,
        bold: Bool? = nil,
        color: Color? = nil)
    {
        self.size = size
        self.name = name
        self.bold = bold
        self.color = color
    }

    /// The default font.
    public static let `default` = Font(size: 11, name: "Calibri")
    /// The header font.
    public static let header = Font(size: 11, name: "Calibri", bold: true)
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
}

/// A structure that represents the alignment of a cell in an Excel Cell.
///
/// `Alignment` is a structure that represents the alignment of a cell in an Excel Cell.
/// It provides a way to create an alignment with a leading, center, or trailing property.
public enum Alignment: Equatable, Sendable, Hashable {
    /// Aligns the text to the left.
    case leading
    /// Aligns the text to the center.
    case center
    /// Aligns the text to the right.
    case trailing
}

/// A structure that represents a color in an Excel Cell.
///
/// `Color` is a structure that represents a color in an Excel Cell.
/// It provides a way to create a color with a hex code.
public enum Color: Equatable, Sendable, Hashable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange
    case brown
    case gray
    case black
    case white
    case custom(String)

    /// The hex code of the color.
    ///
    /// - Returns: The hex code of the color.
    var hex: String { // TODO: 考虑添加透明度的支持
        switch self {
            case .red: "#FF0000"
            case .blue: "#0000FF"
            case .green: "#00FF00"
            case .yellow: "#FFFF00"
            case .purple: "#800080"
            case .orange: "#FFA500"
            case .brown: "#A52A2A"
            case .gray: "#808080"
            case .black: "#000000"
            case .white: "#FFFFFF"
            case let .custom(hex): hex
        }
    }
}
