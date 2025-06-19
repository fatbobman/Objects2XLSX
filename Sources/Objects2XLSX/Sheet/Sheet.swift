//
// Sheet.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 工作表
///
/// 注意事项：Sheet 并非线程安全的，Book、Sheet 应该执行在 ObjectType 的同一个线程上。
/// 比如，如果你通过 Core Data 获取的数据，它应该在数据所在上下文环境中执行
/// SwiftData 的话，应该在获取数据的 ModelActor 中执行
public final class Sheet<ObjectType>: SheetProtocol {
    public let name: String
    /// sheet 中声明的所有列列（包含 when 为false 的列），并不一定会全部生成
    /// 生成时，将根据第一个对象，筛选出有效的列（ activeColumns ）
    public let columns: [AnyColumn<ObjectType>]
    /// 是否创建 header 行（标题行）
    public var hasHeader: Bool
    /// sheet 的样式
    public var style: SheetStyle
    /// 数据提供者，用于获取数据
    public var dataProvider: (() -> [ObjectType])?

    /// 数据提供者，用于获取数据
    private var data: [ObjectType]?

    /// 数据行数
    private var rowsCount: Int {
        (data?.count ?? 0) + (hasHeader ? 1 : 0)
    }

    /// 列数
    private var columnsCount: Int {
        activeColumns().count
    }

    public init(
        name: String,
        nameSanitizer: SheetNameSanitizer = .default,
        hasHeader: Bool = true,
        style: SheetStyle = SheetStyle(),
        dataProvider: (() -> [ObjectType])? = nil,
        @ColumnBuilder<ObjectType> columns: () -> [AnyColumn<ObjectType>])
    {
        self.name = nameSanitizer(name)
        self.columns = columns()
        self.hasHeader = hasHeader
        self.style = style
        self.dataProvider = dataProvider
    }

    func makeSheetData(
        with objects: [ObjectType],
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML? // TODO: 返回 SheetData,临时
    {
        /*
            // 1. 筛选有效列（基于 when 条件和第一个对象）
            let activeColumns = filterActiveColumns(for: objects.first)

            // 2. 计算最终的样式和尺寸设置
            let resolvedStyles = resolveSheetAndColumnStyles()
            let resolvedDimensions = resolveSheetAndColumnDimensions()

            // 3. 构建样式映射表（避免重复计算）
            let styleRegistry = buildStyleRegistry(resolvedStyles)

            // 4. 生成表头行（如果需要）
           let headerCells = generateHeaderCells(activeColumns, styleRegistry)

           // 5. 逐行处理对象数据
          for (rowIndex, object) in objects.enumerated() {
              // 6. 对当前行，逐列生成 Cell
              let rowCells = generateRowCells(
                  object: object,
                  rowIndex: rowIndex,
                  activeColumns: activeColumns,
                  styleRegistry: styleRegistry
              )
          }

          // 7. 汇总所有数据，构建最终的 XlsxSheetData
         let sheetData = XlsxSheetData(
             cells: allCells,
             dimensions: resolvedDimensions,
             styleRegistry: styleRegistry,
             metadata: sheetMetadata
         )
          */
        nil
    }

    /// Converts the sheet to a type-erased AnySheet
    public func eraseToAnySheet() -> AnySheet {
        AnySheet(self)
    }

    /// 根据第一个对象，筛选出有效的列
    private func activeColumns() -> [AnyColumn<ObjectType>] {
        guard let firstObject = data?.first else { return [] }
        return columns.filter { $0.shouldGenerate(for: firstObject) }
    }
}

// MARK: Modifiers

extension Sheet {
    /// 设置整张表的 body 行高
    public func rowBodyHeight(_ height: Double?) {
        style.defaultRowHeight = height
    }

    /// 设置表的 header 行高
    public func columnHeaderHeight(_ height: Double?) {
        style.rowHeights[0] = height
    }

    /// 设置整张表的列宽
    public func columnWidth(_ width: Int) {
        style.defaultColumnWidth = Double(width)
    }

    /// 设置整张表的 header 样式
    public func columnHeaderStyle(_ style: CellStyle) {
        self.style.columnHeaderStyle = style
    }

    /// 设置整张表的 body 样式
    public func columnBodyStyle(_ style: CellStyle) {
        self.style.columnBodyStyle = style
    }

    public func dataProvider(_ dataProvider: @escaping () -> [ObjectType]) {
        self.dataProvider = dataProvider
    }

    public func showHeader(_ show: Bool) {
        hasHeader = show
    }

    public func sheetStyle(_ style: SheetStyle) {
        self.style = style
    }

    /// 自动设置数据区域（用于 dimension）
    public func updateDataRange() {
        guard rowsCount > 0, columnsCount > 0 else {
            style.dataRange = nil
            return
        }

        style.dataRange = SheetStyle.DataRange(
            startRow: 1,
            startColumn: 1,
            endRow: rowsCount,
            endColumn: columnsCount)
    }

    /// 添加数据区域边框
    public func addDataBorder(
        borderStyle: BorderStyle = .thin,
        includeHeader: Bool = true) -> Self
    {
        let dataRowCount = data?.count ?? 0
        guard dataRowCount > 0 || (hasHeader && includeHeader) else { return self }

        let borderRegion = SheetStyle.BorderRegion(
            startRow: includeHeader && hasHeader ? 1 : (hasHeader ? 2 : 1),
            startColumn: 1,
            endRow: rowsCount,
            endColumn: columnsCount,
            border: Border.all(style: borderStyle))

        style.borders.append(borderRegion)
        return self
    }

    /// 添加仅数据行的边框（不包含标题）
    public func addDataOnlyBorder(borderStyle: BorderStyle = .thin) -> Self {
        let dataRowCount = data?.count ?? 0
        guard dataRowCount > 0 else { return self }

        let borderRegion = SheetStyle.BorderRegion(
            startRow: hasHeader ? 2 : 1,
            startColumn: 1,
            endRow: hasHeader ? dataRowCount + 1 : dataRowCount,
            endColumn: columnsCount,
            border: Border.all(style: borderStyle))

        style.borders.append(borderRegion)
        return self
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
