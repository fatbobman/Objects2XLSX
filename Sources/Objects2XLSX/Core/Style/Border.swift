//
// Border.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// Represents a border style for Excel cells
public struct Border: Equatable, Sendable, Hashable {
    /// Individual border side configuration
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

/// Border line styles (Excel standard)
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

extension Border {
    /// No border (all sides empty)
    public static let none = Border()

    /// All sides with same style and color
    public static func all(style: BorderStyle, color: Color = .black) -> Border {
        let side = Side(style: style, color: color)
        return Border(left: side, right: side, top: side, bottom: side)
    }

    /// Only outline (top, right, bottom, left)
    public static func outline(style: BorderStyle, color: Color = .black) -> Border {
        all(style: style, color: color)
    }

    /// Only horizontal borders (top, bottom)
    public static func horizontal(style: BorderStyle, color: Color = .black) -> Border {
        let side = Side(style: style, color: color)
        return Border(top: side, bottom: side)
    }

    /// Only vertical borders (left, right)
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
    /// Generate XML for this border
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

        // Diagonal border (optional)
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
