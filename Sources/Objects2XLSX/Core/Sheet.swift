//
// Sheet.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Sheet<ObjectType> {
    public let name: String
    public let columns: [AnyColumn<ObjectType>]
    public var rowBodyHeight: Int?
    public var columnWidth: Int?
    public var columnHeaderHeight: Int?
    public var columnHeaderStyle: CellStyle?
    public var columnBodyStyle: CellStyle?

    public init(
        name: String,
        nameSanitizer: SheetNameSanitizer = .default,
        rowBodyHeight: Int? = nil,
        columnWidth: Int? = nil,
        columnHeaderHeight: Int? = nil,
        columnHeaderStyle: CellStyle? = nil,
        columnBodyStyle: CellStyle? = nil,
        columns: [AnyColumn<ObjectType>])
    {
        self.name = nameSanitizer(name)
        self.columns = columns
        self.rowBodyHeight = rowBodyHeight
        self.columnWidth = columnWidth
        self.columnHeaderHeight = columnHeaderHeight
        self.columnHeaderStyle = columnHeaderStyle
        self.columnBodyStyle = columnBodyStyle
    }

    public init(
        name: String,
        nameSanitizer: SheetNameSanitizer = .default,
        @ColumnBuilder<ObjectType> columns: () -> [AnyColumn<ObjectType>])
    {
        self.name = nameSanitizer(name)
        self.columns = columns()
    }

    func makeSheetData(
        with objects: [ObjectType],
        hasHeader: Bool = true,
        styleRegistor: StyleRegistor,
        shareStringRegistor: ShareStringRegistor) -> SheetData? // TODO: 返回 SheetData,临时
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

extension Sheet {
    /// 设置整张表的 body 行高
    public func rowBodyHeight(_ height: Int) -> Self {
        var newSelf = self
        newSelf.rowBodyHeight = height
        return newSelf
    }

    /// 设置整张表的 header 行高
    public func columnHeaderHeight(_ height: Int) -> Self {
        var newSelf = self
        newSelf.columnHeaderHeight = height
        return newSelf
    }

    /// 设置整张表的列宽
    public func columnWidth(_ width: Int) -> Self {
        var newSelf = self
        newSelf.columnWidth = width
        return newSelf
    }

    /// 设置整张表的 header 样式
    public func columnHeaderStyle(_ style: CellStyle) -> Self {
        var newSelf = self
        newSelf.columnHeaderStyle = style
        return newSelf
    }

    /// 设置整张表的 body 样式
    public func columnBodyStyle(_ style: CellStyle) -> Self {
        var newSelf = self
        newSelf.columnBodyStyle = style
        return newSelf
    }
}
