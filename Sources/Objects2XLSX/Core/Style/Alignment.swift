//
// Alignment.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents the alignment of a cell in an Excel Cell.
///
/// `Alignment` is a structure that represents the alignment of a cell in an Excel Cell.
/// It provides a way to create an alignment with a leading, center, or trailing property.
/// Alignment Settings
public struct Alignment: Equatable, Sendable, Hashable {
    /// Horizontal alignment
    public let horizontal: HorizontalAlignment?
    /// Vertical alignment
    public let vertical: VerticalAlignment?
    /// Wrap text
    public let wrapText: Bool?
    /// Indent level (0-250)
    public let indent: Int?
    /// Text rotation angle (-90 to 90, or 255 means vertical text)
    public let textRotation: Int?

    public init(
        horizontal: HorizontalAlignment? = nil,
        vertical: VerticalAlignment? = nil,
        wrapText: Bool? = nil,
        indent: Int? = nil,
        textRotation: Int? = nil)
    {
        self.horizontal = horizontal
        self.vertical = vertical
        self.wrapText = wrapText

        // 验证缩进值
        if let indent, indent > 0 {
            self.indent = max(0, min(250, indent))
        } else {
            self.indent = nil
        }

        // 验证旋转角度
        if let rotation = textRotation,
           rotation == 255 || (rotation >= -90 && rotation <= 90)
        {
            self.textRotation = rotation
        } else {
            self.textRotation = nil
        }
    }
}

extension Alignment {
    /// Default alignment (no specific settings)
    public static let `default`: Alignment? = nil

    /// 居中对齐
    public static let center = Alignment(horizontal: .center, vertical: .center)

    /// 左上对齐
    public static let topLeft = Alignment(horizontal: .left, vertical: .top)

    /// 右下对齐
    public static let bottomRight = Alignment(horizontal: .right, vertical: .bottom)

    /// 左对齐 + 自动换行
    public static let leftWrap = Alignment(horizontal: .left, wrapText: true)

    /// 居中 + 自动换行
    public static let centerWrap = Alignment(horizontal: .center, vertical: .center, wrapText: true)

    /// 垂直文本（特殊旋转值）
    public static let verticalText = Alignment(textRotation: 255)

    /// 创建带缩进的左对齐（自动验证缩进值）
    public static func leftIndented(_ level: Int) -> Alignment {
        Alignment(horizontal: .left, indent: level)
    }

    /// 创建带旋转的对齐（自动验证角度）
    public static func rotated(_ angle: Int) -> Alignment {
        Alignment(textRotation: angle)
    }
}

extension Alignment: Identifiable {
    public var id: String {
        var components: [String] = []

        if let horizontal {
            components.append("h:\(horizontal.rawValue)")
        }
        if let vertical {
            components.append("v:\(vertical.rawValue)")
        }
        if let wrapText, wrapText {
            components.append("wrap:1")
        }
        if let indent, indent > 0 {
            components.append("indent:\(indent)")
        }
        if let textRotation, textRotation != 0 {
            components.append("rotation:\(textRotation)")
        }

        return components.isEmpty ? "default" : components.joined(separator: "_")
    }
}

// Horizontal alignment types
public enum HorizontalAlignment: String, CaseIterable, Sendable {
    case general // General (default)
    case left // Left alignment
    case center // Center alignment
    case right // Right alignment
    case fill // Fill
    case justify // Justify
    case centerContinuous // Center across selection
    case distributed // Distributed
}

/// Vertical alignment types
public enum VerticalAlignment: String, CaseIterable, Sendable {
    case top // Top alignment
    case center // Center alignment
    case bottom // Bottom alignment (default)
    case justify // Justify
    case distributed // Distributed
}

// MARK: - Alignment XML Generation

extension Alignment {
    /// Generate XML for this alignment
    var xmlContent: String {
        var attributes: [String] = []

        // 水平对齐
        if let horizontal {
            attributes.append("horizontal=\"\(horizontal.rawValue)\"")
        }

        // 垂直对齐
        if let vertical {
            attributes.append("vertical=\"\(vertical.rawValue)\"")
        }

        // 文本换行
        if let wrapText, wrapText {
            attributes.append("wrapText=\"1\"")
        }

        // 文本缩进（只在特定水平对齐时有效）
        if let indent,
           indent > 0,
           let horizontal,
           [.left, .right, .distributed].contains(horizontal)
        {
            let validIndent = max(0, min(250, indent)) // Excel 限制：0-250
            attributes.append("indent=\"\(validIndent)\"")
        }

        // 文本旋转（验证有效范围）
        if let textRotation,
           isValidTextRotation(textRotation)
        {
            attributes.append("textRotation=\"\(textRotation)\"")
        }

        // 如果没有任何属性，返回空字符串（使用 Excel 默认值）
        guard !attributes.isEmpty else {
            return ""
        }

        return "<alignment \(attributes.joined(separator: " "))/>"
    }

    /// 验证文本旋转角度是否有效
    private func isValidTextRotation(_ rotation: Int) -> Bool {
        rotation == 255 || (rotation >= -90 && rotation <= 90)
    }
}
