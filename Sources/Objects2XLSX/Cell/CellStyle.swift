//
// CellStyle.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents a cell ofstyle in an Excel sheet.
public struct CellStyle: Equatable, Sendable, Hashable {
    /// The font of the cell style.
    public let font: Font?
    /// The fill color of the cell style.
    public let fill: Fill?
    /// The alignment of the cell style.
    public let alignment: Alignment?
    /// The border of the cell style.
    public let border: Border?

    /// Creates a cell style with the given font, fill color, and alignment.
    ///
    /// - Parameter font: The font of the cell style.
    /// - Parameter fillColor: The fill color of the cell style.
    /// - Parameter alignment: The alignment of the cell style.
    ///
    public init(font: Font? = nil, fill: Fill? = nil, alignment: Alignment? = nil, border: Border? = nil) {
        self.font = font
        self.fill = fill
        self.alignment = alignment
        self.border = border
    }
}

extension CellStyle {
    public static let `default` = CellStyle(
        font: .default,
        fill: Fill.none,
        alignment: .default,
        border: Border.none)
}

extension CellStyle {
    /// 合并两个 CellStyle，additional 的非 nil 属性会覆盖 base 的对应属性
    /// - Parameters:
    ///   - base: 基础样式
    ///   - additional: 附加样式（优先级更高）
    /// - Returns: 合并后的样式，如果两个都是 nil 则返回 nil
    static func merge(base: CellStyle?, additional: CellStyle?) -> CellStyle? {
        // 如果都是 nil，返回 nil
        guard base != nil || additional != nil else { return nil }

        // 如果只有一个不是 nil，直接返回那个
        guard let base else { return additional }
        guard let additional else { return base }

        // 两个都不是 nil，逐个属性合并
        // additional 的非 nil 值会覆盖 base 的值
        return CellStyle(
            font: additional.font ?? base.font,
            fill: additional.fill ?? base.fill,
            alignment: additional.alignment ?? base.alignment,
            border: additional.border ?? base.border)
    }

    /// 合并多个样式，后面的样式优先级更高
    ///
    /// ```swift
    ///  // 使用示例：
    /// let finalStyle = CellStyle.merge(
    ///     book.defaultBodyStyle,      // 最低优先级
    ///     sheet.columnBodyStyle,      // 中等优先级
    ///     column.bodyStyle           // 最高优先级
    /// )
    /// ```
    /// - Parameter styles: 样式数组，按优先级从低到高排列
    /// - Returns: 合并后的样式
    static func merge(_ styles: CellStyle?...) -> CellStyle? {
        styles.reduce(nil) { result, style in
            merge(base: result, additional: style)
        }
    }
}
