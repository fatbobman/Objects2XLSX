//
// SheetStyle.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct SheetStyle: Equatable, Hashable, Sendable {
    /// 列宽设置
    public struct ColumnWidth: Equatable, Hashable, Sendable {
        public let width: Double
        public let unit: Unit // 可以是 points 或 characters
        public let isCustomWidth: Bool
    }

    /// 打印设置
    public struct PrintSettings: Equatable, Hashable, Sendable {
        public let paperSize: PaperSize
        public let orientation: Orientation
        public let scale: Double
        public let fitToPage: Bool
        public let margins: Margins
        public let repeatRows: [Int]? // 重复打印的行
        public let repeatColumns: [Int]? // 重复打印的列
    }

    /// 页面设置
    public struct PageSetup: Equatable, Hashable, Sendable {
        public let header: String?
        public let footer: String?
        public let centerHorizontally: Bool
        public let centerVertically: Bool
        public let printGridlines: Bool
        public let printRowAndColumnHeadings: Bool
    }

    /// 合并单元格
    public struct MergedCell: Equatable, Hashable, Sendable {
        public let startRow: Int
        public let startColumn: Int
        public let endRow: Int
        public let endColumn: Int
    }

    /// 冻结窗格设置
    public struct FreezePanes: Equatable, Hashable, Sendable {
        /// 冻结的行数
        public let frozenRows: Int
        /// 冻结的列数
        public let frozenColumns: Int
        /// 是否冻结顶部行
        public let freezeTopRow: Bool
        /// 是否冻结首列
        public let freezeFirstColumn: Bool
    }

    /// 缩放设置
    public struct Zoom: Equatable, Hashable, Sendable {
        /// 缩放比例 (10-400)
        public let scale: Int
        /// 是否使用自定义缩放
        public let isCustomScale: Bool
    }

    /// 数据区域边框设置
    public struct DataRange: Equatable, Hashable, Sendable {
        /// 数据区域的起始行
        public let startRow: Int
        /// 数据区域的起始列
        public let startColumn: Int
        /// 数据区域的结束行
        public let endRow: Int
        /// 数据区域的结束列
        public let endColumn: Int
    }

    public struct BorderRegion: Equatable, Hashable, Sendable {
        let startRow: Int
        let startColumn: Int
        let endRow: Int
        let endColumn: Int
        let border: Border
    }

    /// 列宽设置，key 为列索引
    public var columnWidths: [Int: ColumnWidth] = [:]

    /// 行高设置，key 为行索引
    public var rowHeights: [Int: Double] = [:]

    /// 打印设置
    public var printSettings: PrintSettings?

    /// 页面设置
    public var pageSetup: PageSetup?

    /// 默认列宽
    public var defaultColumnWidth: Double? = 8.43

    /// 默认行高
    public var defaultRowHeight: Double? = 15.0

    /// 是否显示网格线
    public var showGridlines: Bool = true

    /// 是否显示行列标题
    public var showRowAndColumnHeadings: Bool = true

    /// 是否显示零值
    public var showZeros: Bool = true

    /// 是否显示公式
    public var showFormulas: Bool = false

    /// 是否显示大纲符号
    public var showOutlineSymbols: Bool = true

    /// 是否显示分页符
    public var showPageBreaks: Bool = false

    /// 工作表标签颜色
    public var tabColor: Color?

    /// 冻结窗格设置
    public var freezePanes: FreezePanes?

    /// 缩放设置
    public var zoom: Zoom?

    /// 数据区域边框设置
    public var dataRange: DataRange?

    // 边框样式定义（可以有多个）
    public var borders: [BorderRegion] = []

    /// 表头样式
    public var columnHeaderStyle: CellStyle?

    /// 表体样式
    public var columnBodyStyle: CellStyle?

    public init() {}

    /// 默认的工作表样式
    public static let `default` = SheetStyle(
        defaultColumnWidth: 8.43,
        defaultRowHeight: 15.0,
        showGridlines: true,
        showRowAndColumnHeadings: true,
        showZeros: true,
        showFormulas: false,
        showOutlineSymbols: true,
        showPageBreaks: false,
        columnHeaderStyle: CellStyle.default,
        columnBodyStyle: CellStyle.default)

    /// 创建一个基础的 SheetStyle 实例
    public init(
        defaultColumnWidth: Double? = nil,
        defaultRowHeight: Double? = nil,
        showGridlines: Bool = true,
        showRowAndColumnHeadings: Bool = true,
        showZeros: Bool = true,
        showFormulas: Bool = false,
        showOutlineSymbols: Bool = true,
        showPageBreaks: Bool = false,
        columnHeaderStyle: CellStyle? = CellStyle.default,
        columnBodyStyle: CellStyle? = CellStyle.default)
    {
        self.defaultColumnWidth = defaultColumnWidth
        self.defaultRowHeight = defaultRowHeight
        self.showGridlines = showGridlines
        self.showRowAndColumnHeadings = showRowAndColumnHeadings
        self.showZeros = showZeros
        self.showFormulas = showFormulas
        self.showOutlineSymbols = showOutlineSymbols
        self.showPageBreaks = showPageBreaks
        self.columnHeaderStyle = columnHeaderStyle
        self.columnBodyStyle = columnBodyStyle
    }
}

// MARK: 实现方法

extension SheetStyle {
    public mutating func setColumnWidth(_ width: ColumnWidth, at index: Int) {
        columnWidths[index] = width
    }

    public mutating func setRowHeight(_ height: Double, at index: Int) {
        rowHeights[index] = height
    }

    public mutating func setPrintSettings(_ printSettings: PrintSettings) {
        self.printSettings = printSettings
    }

    public mutating func setPageSetup(_ pageSetup: PageSetup) {
        self.pageSetup = pageSetup
    }
}

// MARK: Modifiers

extension SheetStyle {
    public func defaultColumnWidth(_ width: Double?) -> Self {
        var newSelf = self
        newSelf.defaultColumnWidth = width
        return newSelf
    }

    public func defaultRowHeight(_ height: Double?) -> Self {
        var newSelf = self
        newSelf.defaultRowHeight = height
        return newSelf
    }

    public func showGridlines(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showGridlines = show
        return newSelf
    }

    public func showRowAndColumnHeadings(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showRowAndColumnHeadings = show
        return newSelf
    }

    public func showZeros(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showZeros = show
        return newSelf
    }

    public func showFormulas(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showFormulas = show
        return newSelf
    }

    public func showOutlineSymbols(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showOutlineSymbols = show
        return newSelf
    }

    public func showPageBreaks(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showPageBreaks = show
        return newSelf
    }

    public func tabColor(_ color: Color) -> Self {
        var newSelf = self
        newSelf.tabColor = color
        return newSelf
    }

    /// 设置冻结窗格
    public func freezePanes(_ freezePanes: FreezePanes) -> Self {
        var newSelf = self
        newSelf.freezePanes = freezePanes
        return newSelf
    }

    /// 设置缩放
    public func zoom(_ zoom: Zoom) -> Self {
        var newSelf = self
        newSelf.zoom = zoom
        return newSelf
    }
}

// MARK: Internal Methods

extension SheetStyle {
    /// 设置数据区域边框
    func dataRange(
        startRow: Int,
        startColumn: Int,
        endRow: Int) -> Self
    {
        var newSelf = self
        newSelf.dataRange = DataRange(
            startRow: startRow,
            startColumn: startColumn,
            endRow: endRow,
            endColumn: startColumn)
        return newSelf
    }

    // /// 设置数据区域边框（使用范围）
    // func dataAreaBorder(_ range: CellRange, border: Border) -> Self {
    //     dataRange(
    //         startRow: range.startRow,
    //         startColumn: range.startColumn,
    //         endRow: range.endRow,
    //         endColumn: range.endColumn,
    //         border: border)
    // }
}

// 辅助枚举
extension SheetStyle {
    public enum Unit: String, Sendable, CaseIterable, Hashable, Equatable {
        case points
        case characters
    }

    public enum PaperSize: String, Sendable, CaseIterable, Hashable, Equatable {
        case a4
        case letter
        case legal
    }

    public enum Orientation: String, Sendable, CaseIterable, Hashable, Equatable {
        case portrait
        case landscape
    }

    public struct Margins: Equatable, Hashable, Sendable {
        public let top: Double
        public let bottom: Double
        public let left: Double
        public let right: Double
        public let header: Double
        public let footer: Double
    }
}

/// 单元格范围
public struct CellRange: Equatable, Hashable, Sendable {
    public let startRow: Int
    public let startColumn: Int
    public let endRow: Int
    public let endColumn: Int

    public init(
        startRow: Int,
        startColumn: Int,
        endRow: Int,
        endColumn: Int)
    {
        self.startRow = startRow
        self.startColumn = startColumn
        self.endRow = endRow
        self.endColumn = endColumn
    }

    /// 创建单个单元格的范围
    public static func cell(row: Int, column: Int) -> Self {
        Self(
            startRow: row,
            startColumn: column,
            endRow: row,
            endColumn: column)
    }

    /// 创建行范围
    public static func rows(start: Int, end: Int, column: Int) -> Self {
        Self(
            startRow: start,
            startColumn: column,
            endRow: end,
            endColumn: column)
    }

    /// 创建列范围
    public static func columns(start: Int, end: Int, row: Int) -> Self {
        Self(
            startRow: row,
            startColumn: start,
            endRow: row,
            endColumn: end)
    }
}

// MARK: 便捷方法

extension SheetStyle.FreezePanes {
    /// 冻结顶部行
    public static func freezeTopRow() -> Self {
        Self(frozenRows: 1, frozenColumns: 0, freezeTopRow: true, freezeFirstColumn: false)
    }

    /// 冻结首列
    public static func freezeFirstColumn() -> Self {
        Self(frozenRows: 0, frozenColumns: 1, freezeTopRow: false, freezeFirstColumn: true)
    }

    /// 冻结指定行列
    public static func freeze(rows: Int, columns: Int) -> Self {
        Self(frozenRows: rows, frozenColumns: columns, freezeTopRow: false, freezeFirstColumn: false)
    }
}

extension SheetStyle.Zoom {
    /// 默认缩放 (100%)
    public static let `default` = Self(scale: 100, isCustomScale: false)

    /// 自定义缩放
    public static func custom(_ scale: Int) -> Self {
        Self(scale: max(10, min(400, scale)), isCustomScale: true)
    }
}

/*
 边框使用方法（临时记录）

 let style = SheetStyle()
     .dataAreaBorder(
         startRow: 0,
         startColumn: 0,
         endRow: 10,
         endColumn: 5,
         border: Border.all(.thin)
     )

 // 方式2：使用范围
 let style = SheetStyle()
     .dataAreaBorder(
         CellRange(startRow: 0, startColumn: 0, endRow: 10, endColumn: 5),
         border: Border.all(.thin)
     )

 // 在生成 XML 时，为数据区域的每个单元格添加边框， 这个应在用在 SheetData 上？
 if let dataAreaBorder = sheetStyle.dataAreaBorder {
     for row in dataAreaBorder.startRow...dataAreaBorder.endRow {
         for col in dataAreaBorder.startColumn...dataAreaBorder.endColumn {
             // 获取单元格
             if let cell = sheet.cell(at: row, column: col) {
                 // 合并边框样式
                 let combinedBorder = cell.style?.border?.merging(dataAreaBorder.border) ?? dataAreaBorder.border
                 // 更新单元格样式
                 cell.style = cell.style?.border(combinedBorder) ?? CellStyle(border: combinedBorder)
             }
         }
     }
 }
 */
