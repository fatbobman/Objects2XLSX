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
        return makeSheetXML(
            with: objects,
            bookStyle: bookStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegistor,
            overrideSheetStyle: nil
        )
    }
    
    private func makeSheetXML(
        with objects: [ObjectType],
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister,
        overrideSheetStyle: SheetStyle?) -> SheetXML? // TODO: 返回 SheetData,临时
    {
        let sheetStyleToUse = overrideSheetStyle ?? style
        let mergedSheetStyle = mergedSheetStyle(bookStyle: bookStyle, sheetStyle: sheetStyleToUse)
        let columns = activeColumns(objects: objects)
        var rows: [Row] = []
        var currentRow = 1 // 当前行号
        // 生成表头行
        if hasHeader {
            let headerRow = generateHeaderRow(
                columns: columns,
                rowIndex: currentRow,
                bookStyle: bookStyle,
                sheetStyle: mergedSheetStyle,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegistor
            )
            rows.append(headerRow)
            currentRow += 1
        }

        return SheetXML(name: name, rows: rows, style: mergedSheetStyle)
    }
    
    /// 便捷方法：使用 dataProvider 提供的数据生成 SheetXML
    func makeSheetXML(
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML?
    {
        guard let dataProvider = dataProvider else { return nil }
        let objects = dataProvider()
        
        return makeSheetXML(
            with: objects,
            bookStyle: bookStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegistor,
            overrideSheetStyle: sheetStyle
        )
    }

    /// 合并 bookStyle 和 sheetStyle，如果 bookStyle 为 nil，则返回 sheetStyle
    /// - Parameters:
    ///   - bookStyle: 书本样式
    ///   - sheetStyle: 工作表样式
    /// - Returns: 合并后的样式
    private func mergedSheetStyle(bookStyle: BookStyle, sheetStyle: SheetStyle) -> SheetStyle {
        SheetStyle.merge(base: bookStyle.defaultSheetStyle, additional: sheetStyle) ?? sheetStyle
    }

    private func mergedHeaderCellStyle(bookStyle: BookStyle, sheetStyle: SheetStyle, column: AnyColumn<ObjectType>) -> CellStyle? {
        let headerStyle = CellStyle.merge(
            bookStyle.defaultHeaderCellStyle,
            sheetStyle.columnHeaderStyle,
            column.headerStyle)
        return headerStyle
    }

    private func mergedBodyCellStyle(bookStyle: BookStyle, sheetStyle: SheetStyle, column: AnyColumn<ObjectType>) -> CellStyle? {
        let bodyStyle = CellStyle.merge(
            bookStyle.defaultBodyCellStyle,
            sheetStyle.columnBodyStyle,
            column.bodyStyle)
        return bodyStyle
    }

    /// 生成表头行
    private func generateHeaderRow(
        columns: [AnyColumn<ObjectType>],
        rowIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister
    ) -> Row {
        let rowHeight = sheetStyle.rowHeights[rowIndex] ?? sheetStyle.defaultRowHeight
        var headerRow = Row(index: rowIndex, cells: [], height: rowHeight)

        for (index, column) in columns.enumerated() {
            let columnIndex = index + 1
            let headerCell = generateHeaderCell(
                column: column,
                rowIndex: rowIndex,
                columnIndex: columnIndex,
                bookStyle: bookStyle,
                sheetStyle: sheetStyle,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegistor
            )
            headerRow.cells.append(headerCell)
        }

        return headerRow
    }

    /// 生成单个表头单元格
    private func generateHeaderCell(
        column: AnyColumn<ObjectType>,
        rowIndex: Int,
        columnIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister
    ) -> Cell {
        // 合并样式
        var cellStyle = mergedHeaderCellStyle(bookStyle: bookStyle, sheetStyle: sheetStyle, column: column)

        // 应用所有适用的边框区域
        cellStyle = applyBordersToCell(cellStyle: cellStyle, row: rowIndex, column: columnIndex, borders: sheetStyle.borders)

        // 准备单元格值
        let cellValue = Cell.CellType.string(column.name)
        let sharedStringID = shareStringRegistor.register(column.name)

        // 注册样式
        let styleID = styleRegister.registerCellStyle(cellStyle, cellType: cellValue)

        return Cell(
            row: rowIndex,
            column: columnIndex,
            value: cellValue,
            styleID: styleID,
            sharedStringID: sharedStringID
        )
    }

    /// 应用所有适用的边框区域到单元格样式
    private func applyBordersToCell(cellStyle: CellStyle?, row: Int, column: Int, borders: [SheetStyle.BorderRegion]) -> CellStyle? {
        var resultStyle = cellStyle

        // 遍历所有边框区域，应用适用的边框
        for borderRegion in borders {
            if let border = Border.forCellAt(row: row, column: column, in: borderRegion) {
                let borderStyle = CellStyle(font: nil, fill: nil, alignment: nil, border: border)
                // 合并边框样式，后面的边框区域优先级更高
                resultStyle = CellStyle.merge(resultStyle, borderStyle)
            }
        }

        return resultStyle
    }
}
