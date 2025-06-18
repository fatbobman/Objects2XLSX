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
    public let columns: [AnyColumn<ObjectType>]
    public var hasHeader: Bool
    public var style: SheetStyle
    public var dataProvider: (() -> [ObjectType])?

    private var data: [ObjectType]?

    private var rowsCount: Int {
        data?.count ?? 0
    }

    private var columnsCount: Int {
        columns.count
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
        hasHeader: Bool = true,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetData? // TODO: 返回 SheetData,临时
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
}

// MARK: Modifiers

extension Sheet {
    /// 设置整张表的 body 行高
    public func rowBodyHeight(_ height: Int) {
        style.defaultRowHeight = Double(height)
    }

    /// 设置整张表的 header 行高
    public func columnHeaderHeight(_ height: Int) {
        style.rowHeights[0] = SheetStyle.RowHeight(
            height: Double(height),
            isCustomHeight: true)
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

    /// 根据 数据量，自动设置数据区域
    public func setDataAreaBorder(borderStyle: BorderStyle = .thin) {
        let dataAreaBorder = SheetStyle.DataAreaBorder(
            startRow: hasHeader ? 1 : 0,
            startColumn: 0,
            endRow: rowsCount - 1,
            endColumn: columnsCount - 1,
            border: Border.all(style: borderStyle))
        style.dataAreaBorder = dataAreaBorder
    }
}
