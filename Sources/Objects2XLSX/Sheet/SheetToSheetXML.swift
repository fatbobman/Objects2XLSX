//
// SheetToSheetXML.swift
// Created by Xu Yang on 2025-06-19.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

extension Sheet {
    func makeSheetXML(
        with objects: [ObjectType],
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML? // TODO: 返回 SheetData,临时
    {
        let mergedSheetStyle = mergedSheetStyle(bookStyle: bookStyle, sheetStyle: style)
        let columns = activeColumns(objects: objects)
        var rows: [Row] = []
        var currentRow = 1 // 当前行号
        if hasHeader {
            // 生成表头行
            currentRow += 1
        }

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
        return nil
    }

    /// 合并 bookStyle 和 sheetStyle，如果 bookStyle 为 nil，则返回 sheetStyle
    /// - Parameters:
    ///   - bookStyle: 书本样式
    ///   - sheetStyle: 工作表样式
    /// - Returns: 合并后的样式
    private func mergedSheetStyle(bookStyle: BookStyle, sheetStyle: SheetStyle) -> SheetStyle {
        SheetStyle.merge(base: bookStyle.defaultSheetStyle, additional: sheetStyle) ?? sheetStyle
    }

    private func mergedHeaderStyle(bookStyle: BookStyle, sheetStyle: SheetStyle, column: AnyColumn<ObjectType>) -> CellStyle? {
        let headerStyle = CellStyle.merge(
            bookStyle.defaultHeaderCellStyle,
            sheetStyle.columnHeaderStyle,
            column.headerStyle)
        return headerStyle
    }

    private func mergedBodyStyle(bookStyle: BookStyle, sheetStyle: SheetStyle, column: AnyColumn<ObjectType>) -> CellStyle? {
        let bodyStyle = CellStyle.merge(
            bookStyle.defaultBodyCellStyle,
            sheetStyle.columnBodyStyle,
            column.bodyStyle)
        return bodyStyle
    }

    private func generateHeaderCell(column: AnyColumn<ObjectType>, columnIndex: Int, styleID: Int?) -> Cell {
        //  let style = mergedHeaderStyle(bookStyle: bookStyle, sheetStyle: sheetStyle, column: column)
        let cell = Cell(row: 1, column: columnIndex, value: .string(column.name), styleID: styleID)
        return cell
    }

    private func addBorderIfNeeded(cell: Cell, row: Int, column: Int, borderRange: SheetStyle.BorderRegion?) -> Cell {
        guard let borderRange else { return cell }

        return cell
    }
}
