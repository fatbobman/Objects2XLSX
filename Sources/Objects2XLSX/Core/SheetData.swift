//
// SheetData.swift
// Created by Xu Yang on 2025-06-07.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 表格数据，包含生成 xlsx sheet XML 所需的所有信息
public struct SheetData {
    /// Sheet 的基本信息
    public let name: String
    /// 所有单元格数据
    public let cells: [Cell]
    /// 列信息（宽度、样式等）
    public let columns: [ColumnInfo]
    /// 行信息（高度、样式等）
    public let rows: [RowInfo]
    /// Sheet 的尺寸信息
    public let dimension: SheetDimension
    /// 是否包含表头
    public let hasHeader: Bool

    public init(
        name: String,
        cells: [Cell],
        columns: [ColumnInfo],
        rows: [RowInfo],
        dimension: SheetDimension,
        hasHeader: Bool = true)
    {
        self.name = name
        self.cells = cells
        self.columns = columns
        self.rows = rows
        self.dimension = dimension
        self.hasHeader = hasHeader
    }
}

/// 列信息
public struct ColumnInfo {
    /// 列索引（从1开始，Excel格式）
    public let index: Int
    /// 列宽（Excel单位）
    public let width: Double?
    /// 列的默认样式ID
    public let styleID: Int?
    /// 是否隐藏
    public let hidden: Bool

    public init(index: Int, width: Double? = nil, styleID: Int? = nil, hidden: Bool = false) {
        self.index = index
        self.width = width
        self.styleID = styleID
        self.hidden = hidden
    }
}

/// 行信息
public struct RowInfo {
    /// 行索引（从1开始，Excel格式）
    public let index: Int
    /// 行高（Excel单位：磅）
    public let height: Double?
    /// 行的默认样式ID
    public let styleID: Int?
    /// 是否隐藏
    public let hidden: Bool
    /// 是否是表头行
    public let isHeader: Bool

    public init(
        index: Int,
        height: Double? = nil,
        styleID: Int? = nil,
        hidden: Bool = false,
        isHeader: Bool = false)
    {
        self.index = index
        self.height = height
        self.styleID = styleID
        self.hidden = hidden
        self.isHeader = isHeader
    }
}

/// Sheet 尺寸信息
public struct SheetDimension {
    /// 起始行（通常为1）
    public let startRow: Int
    /// 结束行
    public let endRow: Int
    /// 起始列（通常为1）
    public let startColumn: Int
    /// 结束列
    public let endColumn: Int

    public init(startRow: Int = 1, endRow: Int, startColumn: Int = 1, endColumn: Int) {
        self.startRow = startRow
        self.endRow = endRow
        self.startColumn = startColumn
        self.endColumn = endColumn
    }

    /// Excel 格式的范围字符串，如 "A1:C10"
    public var excelRange: String {
        let startCell = "\(columnIndexToExcelColumn(startColumn))\(startRow)"
        let endCell = "\(columnIndexToExcelColumn(endColumn))\(endRow)"
        return "\(startCell):\(endCell)"
    }
}

/// 将列索引转换为 Excel 列名（如 1->A, 27->AA）
func columnIndexToExcelColumn(_ index: Int) -> String {
    var result = ""
    var num = index - 1

    repeat {
        result = String(Character(UnicodeScalar(65 + num % 26)!)) + result
        num = num / 26 - 1
    } while num >= 0

    return result
}
