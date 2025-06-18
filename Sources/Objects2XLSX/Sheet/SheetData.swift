//
// SheetData.swift
// Created by Xu Yang on 2025-06-07.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct SheetData {
    /// 工作表名称
    public let name: String

    /// 所有单元格（含表头 + 内容）
    public let cells: [Cell]

    /// 所有列的信息（顺序对应列索引）
    public let columns: [ResolvedColumn]

    /// 所有行的信息（用于自定义行高等）
    public let rows: [ResolvedRow]

    /// 表头是否存在
    public let hasHeader: Bool

    /// 单元格范围（用于写入 `<dimension>`）
    public let dimension: SheetDimension

    /// 列宽定义（对应 <cols>）
    public let columnWidths: [ColumnWidth]

    /// Sheet 层面的默认样式信息（行高、列宽等）
    public let sheetDefaults: SheetDefaults

    /// 引用的样式注册器（用于生成 styles.xml）
    private let styleRegister: StyleRegister

    /// 引用的共享字符串注册器（用于生成 sharedStrings.xml）
    private let shareStringRegister: ShareStringRegister
}

public struct ResolvedColumn {
    public let index: Int // 从 0 开始
    public let name: String // 表头文字
    public let width: Int? // 字符宽度（用于列宽）
    public let headerStyleID: Int? // 表头样式
    public let bodyStyleID: Int? // 内容样式
}

public struct ResolvedRow {
    public let index: Int // 从 0 开始
    public let height: Double? // 自定义行高
}

public struct SheetDimension {
    public let startRow: Int // Excel 行号，从 1 开始
    public let endRow: Int
    public let startColumn: Int // Excel 列号，从 1 开始
    public let endColumn: Int
}

public struct ColumnWidth {
    public let index: Int
    public let width: Int
}

public struct SheetDefaults {
    public let defaultRowHeight: Double?
    public let defaultColumnWidth: Int?
}

// extension SheetData {
//     /// 获取某一行的所有 cell
//     func cellsInRow(_ rowIndex: Int) -> [Cell]

//     /// 获取某一列的所有 cell
//     func cellsInColumn(_ columnIndex: Int) -> [Cell]

//     /// 查找某个 Cell（按 row + column）
//     func cellAt(row: Int, column: Int) -> Cell?

//     /// 返回 sheet 所有 cell 的 Excel 坐标
//     func allCellAddresses() -> [String]
// }

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
