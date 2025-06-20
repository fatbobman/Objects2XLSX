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
        shareStringRegistor: ShareStringRegister) -> SheetXML?
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
        overrideSheetStyle: SheetStyle?) -> SheetXML?
    {
        let sheetStyleToUse = overrideSheetStyle ?? style
        var mergedSheetStyle = mergedSheetStyle(bookStyle: bookStyle, sheetStyle: sheetStyleToUse)
        let columns = activeColumns(objects: objects)

        // Transfer column widths from Column definitions to SheetStyle
        // Use all columns for width transfer even if no data exists
        let columnsForWidth = objects.isEmpty ? self.columns : columns
        for (index, column) in columnsForWidth.enumerated() {
            if let width = column.width {
                let columnIndex = index + 1 // Excel uses 1-based column indexing
                mergedSheetStyle.columnWidths[columnIndex] = SheetStyle.ColumnWidth(
                    width: Double(width),
                    unit: .characters,
                    isCustomWidth: true
                )
            }
        }

        // 计算数据区域并设置边框区域（如果启用）
        let dataRowCount = objects.count
        let dataColumnCount = columns.count
        if dataRowCount > 0 && dataColumnCount > 0 && mergedSheetStyle.dataBorder.enabled {
            mergedSheetStyle = setupDataBorderRegion(
                sheetStyle: mergedSheetStyle,
                dataRowCount: dataRowCount,
                dataColumnCount: dataColumnCount
            )
        }

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

        // 生成数据行
        let dataRows = generateDataRows(
            objects: objects,
            columns: columns,
            startRowIndex: currentRow,
            bookStyle: bookStyle,
            sheetStyle: mergedSheetStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegistor
        )
        rows.append(contentsOf: dataRows)

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

        // 应用数据边框
        cellStyle = applyBordersToCell(cellStyle: cellStyle, row: rowIndex, column: columnIndex, borders: sheetStyle.dataBorder, sheetStyle: sheetStyle)

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

    /// 生成数据行
    private func generateDataRows(
        objects: [ObjectType],
        columns: [AnyColumn<ObjectType>],
        startRowIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister
    ) -> [Row] {
        var rows: [Row] = []

        for (objectIndex, object) in objects.enumerated() {
            let rowIndex = startRowIndex + objectIndex
            let dataRow = generateDataRow(
                object: object,
                columns: columns,
                rowIndex: rowIndex,
                bookStyle: bookStyle,
                sheetStyle: sheetStyle,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegistor
            )
            rows.append(dataRow)
        }

        return rows
    }

    /// 生成单个数据行
    private func generateDataRow(
        object: ObjectType,
        columns: [AnyColumn<ObjectType>],
        rowIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister
    ) -> Row {
        let rowHeight = sheetStyle.rowHeights[rowIndex] ?? sheetStyle.defaultRowHeight
        var dataRow = Row(index: rowIndex, cells: [], height: rowHeight)

        for (columnIndex, column) in columns.enumerated() {
            let columnNumber = columnIndex + 1
            let dataCell = generateDataCell(
                object: object,
                column: column,
                rowIndex: rowIndex,
                columnIndex: columnNumber,
                bookStyle: bookStyle,
                sheetStyle: sheetStyle,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegistor
            )
            dataRow.cells.append(dataCell)
        }

        return dataRow
    }

    /// 生成单个数据单元格
    private func generateDataCell(
        object: ObjectType,
        column: AnyColumn<ObjectType>,
        rowIndex: Int,
        columnIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister
    ) -> Cell {
        // 合并样式
        var cellStyle = mergedBodyCellStyle(bookStyle: bookStyle, sheetStyle: sheetStyle, column: column)

        // 应用数据边框
        cellStyle = applyBordersToCell(cellStyle: cellStyle, row: rowIndex, column: columnIndex, borders: sheetStyle.dataBorder, sheetStyle: sheetStyle)

        // 生成单元格值
        let cellValue = column.generateCellValue(for: object)

        // 处理共享字符串
        var sharedStringID: Int? = nil
        switch cellValue {
        case .string(let stringValue):
            if let actualString = stringValue {
                sharedStringID = shareStringRegistor.register(actualString)
            }
        case .url(let urlValue):
            if let actualURL = urlValue {
                sharedStringID = shareStringRegistor.register(actualURL.absoluteString)
            }
        default:
            break // 其他类型不使用共享字符串
        }

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

    /// 设置数据边框区域
    private func setupDataBorderRegion(
        sheetStyle: SheetStyle,
        dataRowCount: Int,
        dataColumnCount: Int
    ) -> SheetStyle {
        var updatedStyle = sheetStyle

        // 根据是否包含表头计算起始行
        let startRow = sheetStyle.dataBorder.includeHeader && hasHeader ? 1 : (hasHeader ? 2 : 1)
        let endRow = hasHeader ? dataRowCount + 1 : dataRowCount

        // 设置数据区域
        updatedStyle.dataRange = SheetStyle.DataRange(
            startRow: startRow,
            startColumn: 1,
            endRow: endRow,
            endColumn: dataColumnCount
        )

        return updatedStyle
    }

    /// 应用数据边框到单元格样式
    private func applyBordersToCell(cellStyle: CellStyle?, row: Int, column: Int, borders: SheetStyle.DataBorderSettings, sheetStyle: SheetStyle) -> CellStyle? {
        guard borders.enabled else { return cellStyle }

        // 检查是否在数据区域内
        guard let dataRange = sheetStyle.dataRange else { return cellStyle }

        guard row >= dataRange.startRow && row <= dataRange.endRow &&
              column >= dataRange.startColumn && column <= dataRange.endColumn else {
            return cellStyle
        }

        // 判断位置类型
        let isTopEdge = row == dataRange.startRow
        let isBottomEdge = row == dataRange.endRow
        let isLeftEdge = column == dataRange.startColumn
        let isRightEdge = column == dataRange.endColumn

        // 创建边框侧面
        let borderSide = Border.Side(style: borders.borderStyle, color: .black)

        // 根据位置创建边框
        let border = Border(
            left: isLeftEdge ? borderSide : nil,
            right: isRightEdge ? borderSide : nil,
            top: isTopEdge ? borderSide : nil,
            bottom: isBottomEdge ? borderSide : nil
        )

        let borderStyle = CellStyle(font: nil, fill: nil, alignment: nil, border: border)
        return CellStyle.merge(cellStyle, borderStyle)
    }
}
