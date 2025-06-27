//
// SheetToSheetXML.swift
// Created by Xu Yang on 2025-06-19.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Extension providing XML generation functionality for the `Sheet` class.

 This extension contains the core logic for converting a `Sheet` and its data into
 `SheetXML` format, which can then be serialized into Excel-compatible XML.
 The conversion process handles styling, data transformation, and Excel-specific
 formatting requirements.

 ## Key Responsibilities

 - **Data Processing**: Converts Swift objects to Excel cell values
 - **Style Management**: Merges workbook, sheet, and column-level styles
 - **XML Structure**: Creates proper row and cell hierarchies
 - **Excel Compatibility**: Ensures output meets Excel specification requirements

 ## Process Overview

 1. **Style Merging**: Combines styles from book, sheet, and column levels
 2. **Column Processing**: Transfers column widths and determines active columns
 3. **Border Regions**: Sets up data region borders if enabled
 4. **Row Generation**: Creates header and data rows with proper styling
 5. **Cell Creation**: Generates individual cells with values and formatting

 - Note: This extension is used internally during the Excel generation process
 */
extension Sheet {
    // MARK: - Primary XML Generation

    /**
     Generates SheetXML from the provided object data.

     This is the main entry point for converting worksheet data into XML format.
     It processes the objects through active columns and applies appropriate styling
     at all levels (book, sheet, column, and cell).

     - Parameters:
        - objects: The data objects to convert to worksheet rows
        - bookStyle: Workbook-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings

     - Returns: A `SheetXML` object containing the complete worksheet structure, or `nil` on failure

     ## Usage
     ```swift
     let sheetXML = sheet.makeSheetXML(
         with: employees,
         bookStyle: workbookStyle,
         styleRegister: styleRegistry,
         shareStringRegistor: stringRegistry
     )
     ```

     ## Features Handled
     - Automatic column width transfer from column definitions
     - Style hierarchy merging (book → sheet → column → cell)
     - Data region border application
     - Header row generation (if enabled)
     - Type-safe data cell creation
     */
    func makeSheetXML(
        with objects: [ObjectType],
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML?
    {
        makeSheetXML(
            with: objects,
            bookStyle: bookStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegistor,
            overrideSheetStyle: nil)
    }

    /**
     Internal XML generation method with optional style override.

     This private method provides the core XML generation logic with support
     for overriding the sheet's default style. This is useful for advanced
     styling scenarios or when generating multiple variations of the same sheet.

     - Parameters:
        - objects: The data objects to convert to worksheet rows
        - bookStyle: Workbook-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings
        - overrideSheetStyle: Optional style to use instead of the sheet's default style

     - Returns: A `SheetXML` object containing the complete worksheet structure, or `nil` on failure
     */
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
                    isCustomWidth: true)
            }
        }

        // Calculate data region and set up border area (if enabled)
        let dataRowCount = objects.count
        let dataColumnCount = columns.count
        if dataRowCount > 0, dataColumnCount > 0, mergedSheetStyle.dataBorder.enabled {
            mergedSheetStyle = setupDataBorderRegion(
                sheetStyle: mergedSheetStyle,
                dataRowCount: dataRowCount,
                dataColumnCount: dataColumnCount)
        }

        var rows: [Row] = []
        var currentRow = 1 // Current row number

        // Generate header row
        if hasHeader {
            let headerRow = generateHeaderRow(
                columns: columns,
                rowIndex: currentRow,
                bookStyle: bookStyle,
                sheetStyle: mergedSheetStyle,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegistor)
            rows.append(headerRow)
            currentRow += 1
        }

        // Generate data rows
        let dataRows = generateDataRows(
            objects: objects,
            columns: columns,
            startRowIndex: currentRow,
            bookStyle: bookStyle,
            sheetStyle: mergedSheetStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegistor)
        rows.append(contentsOf: dataRows)

        return SheetXML(name: name, rows: rows, style: mergedSheetStyle)
    }

    /**
     Convenience method for generating SheetXML using the data provider.

     This method is a convenience wrapper that uses the sheet's configured
     data provider to obtain objects, then generates XML using the provided
     styling configuration.

     - Parameters:
        - bookStyle: Workbook-level styling configuration
        - sheetStyle: Sheet-level styling configuration to override defaults
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings

     - Returns: A `SheetXML` object, or `nil` if no data provider is configured

     ## Usage
     ```swift
     let sheetXML = sheet.makeSheetXML(
         bookStyle: workbookStyle,
         sheetStyle: customSheetStyle,
         styleRegister: styleRegistry,
         shareStringRegistor: stringRegistry
     )
     ```

     - Note: Returns `nil` if the sheet has no configured data provider
     */
    func makeSheetXML(
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML?
    {
        guard let dataProvider else { return nil }
        let objects = dataProvider()

        return makeSheetXML(
            with: objects,
            bookStyle: bookStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegistor,
            overrideSheetStyle: sheetStyle)
    }

    // MARK: - Style Management

    /**
     Merges workbook and sheet styles with proper precedence.

     This method combines the workbook's default sheet style with the specific
     sheet style, ensuring that sheet-level settings take precedence over
     workbook defaults while maintaining fallback behavior.

     - Parameters:
        - bookStyle: The workbook style containing default sheet styling
        - sheetStyle: The specific sheet style with custom configurations

     - Returns: A merged `SheetStyle` with appropriate precedence handling

     ## Style Precedence
     1. **Sheet Style**: Highest priority - specific sheet configurations
     2. **Book Style**: Default fallback - workbook-wide sheet defaults

     ## Example
     ```swift
     let merged = mergedSheetStyle(bookStyle: book.style, sheetStyle: sheet.style)
     // merged.defaultRowHeight uses sheet value if set, otherwise book default
     ```
     */
    private func mergedSheetStyle(bookStyle: BookStyle, sheetStyle: SheetStyle) -> SheetStyle {
        SheetStyle.merge(base: bookStyle.defaultSheetStyle, additional: sheetStyle) ?? sheetStyle
    }

    /**
     Merges header cell styles from multiple sources with proper precedence.

     This method combines header styles from workbook defaults, sheet configuration,
     and column-specific settings to create the final header cell style.

     - Parameters:
        - bookStyle: Workbook-level styling with default header styles
        - sheetStyle: Sheet-level styling with column header overrides
        - column: Column definition with specific header styling

     - Returns: A merged `CellStyle` for header cells, or `nil` if no styles are defined

     ## Style Precedence
     1. **Column Header Style**: Highest priority - column-specific header styling
     2. **Sheet Header Style**: Medium priority - sheet-wide header styling
     3. **Book Header Style**: Lowest priority - workbook default header styling
     */
    private func mergedHeaderCellStyle(bookStyle: BookStyle, sheetStyle: SheetStyle, column: AnyColumn<ObjectType>) -> CellStyle? {
        let headerStyle = CellStyle.merge(
            bookStyle.defaultHeaderCellStyle,
            sheetStyle.columnHeaderStyle,
            column.headerStyle)
        return headerStyle
    }

    /**
     Merges body cell styles from multiple sources with proper precedence.

     This method combines data cell styles from workbook defaults, sheet configuration,
     and column-specific settings to create the final data cell style.

     - Parameters:
        - bookStyle: Workbook-level styling with default body styles
        - sheetStyle: Sheet-level styling with column body overrides
        - column: Column definition with specific body styling

     - Returns: A merged `CellStyle` for data cells, or `nil` if no styles are defined

     ## Style Precedence
     1. **Column Body Style**: Highest priority - column-specific data styling
     2. **Sheet Body Style**: Medium priority - sheet-wide data styling
     3. **Book Body Style**: Lowest priority - workbook default data styling
     */
    private func mergedBodyCellStyle(bookStyle: BookStyle, sheetStyle: SheetStyle, column: AnyColumn<ObjectType>) -> CellStyle? {
        let bodyStyle = CellStyle.merge(
            bookStyle.defaultBodyCellStyle,
            sheetStyle.columnBodyStyle,
            column.bodyStyle)
        return bodyStyle
    }

    // MARK: - Row Generation

    /**
     Generates the header row for the worksheet.

     Creates a complete header row with cells for each active column, applying
     appropriate styling and registering shared strings for column names.
     The row height is determined by sheet style configuration.

     - Parameters:
        - columns: Active columns that should appear in the worksheet
        - rowIndex: The 1-based row index for the header row
        - bookStyle: Workbook-level styling configuration
        - sheetStyle: Sheet-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings

     - Returns: A complete `Row` object containing all header cells

     ## Features
     - Applies merged header cell styling from all sources
     - Registers column names as shared strings for efficiency
     - Handles custom row heights if configured
     - Ensures proper Excel column indexing (1-based)
     */
    private func generateHeaderRow(
        columns: [AnyColumn<ObjectType>],
        rowIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> Row
    {
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
                shareStringRegistor: shareStringRegistor)
            headerRow.cells.append(headerCell)
        }

        return headerRow
    }

    /**
     Generates a single header cell for a specific column.

     Creates a complete header cell with the column name, proper styling,
     and border application if data borders are enabled. The cell uses
     shared strings for text efficiency.

     - Parameters:
        - column: The column definition for this header cell
        - rowIndex: The 1-based row index for this cell
        - columnIndex: The 1-based column index for this cell
        - bookStyle: Workbook-level styling configuration
        - sheetStyle: Sheet-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings

     - Returns: A complete `Cell` object for the header position

     ## Processing Steps
     1. **Style Merging**: Combines header styles from all sources
     2. **Border Application**: Applies data borders if enabled
     3. **String Registration**: Registers column name as shared string
     4. **Style Registration**: Registers final cell style for reuse
     */
    private func generateHeaderCell(
        column: AnyColumn<ObjectType>,
        rowIndex: Int,
        columnIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> Cell
    {
        // Merge styles from all sources
        var cellStyle = mergedHeaderCellStyle(bookStyle: bookStyle, sheetStyle: sheetStyle, column: column)

        // Apply data borders if enabled
        cellStyle = applyBordersToCell(cellStyle: cellStyle, row: rowIndex, column: columnIndex, borders: sheetStyle.dataBorder, sheetStyle: sheetStyle)

        // Prepare cell value using column name
        let cellValue = Cell.CellType.stringValue(column.name)
        let sharedStringID = shareStringRegistor.register(column.name)

        // Register the final style for reuse
        let styleID = styleRegister.registerCellStyle(cellStyle, cellType: cellValue)

        return Cell(
            row: rowIndex,
            column: columnIndex,
            value: cellValue,
            styleID: styleID,
            sharedStringID: sharedStringID)
    }

    /**
     Generates all data rows for the worksheet.

     Creates complete data rows for each object in the dataset, applying
     appropriate styling and handling type-safe value conversion from
     Swift objects to Excel cell values.

     - Parameters:
        - objects: The data objects to convert to worksheet rows
        - columns: Active columns that should appear in the worksheet
        - startRowIndex: The 1-based row index where data rows begin
        - bookStyle: Workbook-level styling configuration
        - sheetStyle: Sheet-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings

     - Returns: An array of `Row` objects containing all data

     ## Performance Considerations
     - Processes objects sequentially to maintain row order
     - Reuses registered styles for efficiency
     - Batches shared string registration for performance
     */
    private func generateDataRows(
        objects: [ObjectType],
        columns: [AnyColumn<ObjectType>],
        startRowIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> [Row]
    {
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
                shareStringRegistor: shareStringRegistor)
            rows.append(dataRow)
        }

        return rows
    }

    /**
     Generates a single data row for a specific object.

     Creates a complete data row with cells for each active column,
     extracting values from the object using type-safe KeyPath access
     and applying appropriate styling and formatting.

     - Parameters:
        - object: The data object for this row
        - columns: Active columns that should appear in the worksheet
        - rowIndex: The 1-based row index for this row
        - bookStyle: Workbook-level styling configuration
        - sheetStyle: Sheet-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings

     - Returns: A complete `Row` object for this data object

     ## Data Extraction
     - Uses KeyPath-based value extraction for type safety
     - Handles optional values gracefully with nil checking
     - Applies column-specific value transformations
     - Maintains Excel column indexing (1-based)
     */
    private func generateDataRow(
        object: ObjectType,
        columns: [AnyColumn<ObjectType>],
        rowIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> Row
    {
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
                shareStringRegistor: shareStringRegistor)
            dataRow.cells.append(dataCell)
        }

        return dataRow
    }

    /**
     Generates a single data cell for a specific object and column.

     Creates a complete data cell by extracting the value from the object
     using the column's KeyPath, applying appropriate styling, and handling
     shared string registration for text-based values.

     - Parameters:
        - object: The data object containing the value
        - column: The column definition for value extraction and styling
        - rowIndex: The 1-based row index for this cell
        - columnIndex: The 1-based column index for this cell
        - bookStyle: Workbook-level styling configuration
        - sheetStyle: Sheet-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegistor: Registry for managing shared strings

     - Returns: A complete `Cell` object containing the extracted value

     ## Value Processing
     - **Type-Safe Extraction**: Uses KeyPath for safe value access
     - **Format Conversion**: Converts Swift types to Excel-compatible formats
     - **Shared String Optimization**: Registers text and URL values for reuse
     - **Style Application**: Applies merged styles and data borders

     ## Supported Types
     - String values (with shared string registration)
     - Numeric values (integers, doubles, percentages)
     - Date values (converted to Excel date format)
     - Boolean values (converted to Excel boolean format)
     - URL values (with shared string registration)
     */
    private func generateDataCell(
        object: ObjectType,
        column: AnyColumn<ObjectType>,
        rowIndex: Int,
        columnIndex: Int,
        bookStyle: BookStyle,
        sheetStyle: SheetStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> Cell
    {
        // Merge styles from all sources
        var cellStyle = mergedBodyCellStyle(bookStyle: bookStyle, sheetStyle: sheetStyle, column: column)

        // Apply data borders if enabled
        cellStyle = applyBordersToCell(cellStyle: cellStyle, row: rowIndex, column: columnIndex, borders: sheetStyle.dataBorder, sheetStyle: sheetStyle)

        // Generate cell value using column's value extraction logic
        let cellValue = column.generateCellValue(for: object)

        // Handle shared string registration for text-based values
        var sharedStringID: Int?
        switch cellValue {
            case let .stringValue(stringValue):
                sharedStringID = shareStringRegistor.register(stringValue)
            case let .optionalString(stringValue):
                if let actualString = stringValue {
                    sharedStringID = shareStringRegistor.register(actualString)
                }
            case let .urlValue(urlValue):
                sharedStringID = shareStringRegistor.register(urlValue.absoluteString)
            case let .optionalURL(urlValue):
                if let actualURL = urlValue {
                    sharedStringID = shareStringRegistor.register(actualURL.absoluteString)
                }
            case let .booleanValue(boolean, booleanExpressions, caseStrategy):
                // Optimize boolean storage: use SharedString for multi-character expressions
                if booleanExpressions.shouldUseSharedString {
                    let boolText = boolean ? booleanExpressions.trueString : booleanExpressions.falseString
                    let finalText = caseStrategy.apply(to: boolText)
                    sharedStringID = shareStringRegistor.register(finalText)
                }
            case let .optionalBoolean(boolean, booleanExpressions, caseStrategy):
                // Optimize optional boolean storage: use SharedString for multi-character expressions
                if let boolean, booleanExpressions.shouldUseSharedString {
                    let boolText = boolean ? booleanExpressions.trueString : booleanExpressions.falseString
                    let finalText = caseStrategy.apply(to: boolText)
                    sharedStringID = shareStringRegistor.register(finalText)
                }
            default:
                break // Other types don't use shared strings
        }

        // Register the final style for reuse
        let styleID = styleRegister.registerCellStyle(cellStyle, cellType: cellValue)

        return Cell(
            row: rowIndex,
            column: columnIndex,
            value: cellValue,
            styleID: styleID,
            sharedStringID: sharedStringID)
    }

    // MARK: - Border Management

    /**
     Sets up the data border region for the worksheet.

     Configures the worksheet's data range properties to enable border
     application around the data region. This method calculates the
     appropriate start and end positions based on header configuration
     and data dimensions.

     - Parameters:
        - sheetStyle: The current sheet style to update
        - dataRowCount: Number of data rows (excluding header)
        - dataColumnCount: Number of data columns

     - Returns: Updated `SheetStyle` with configured data range

     ## Border Region Logic
     - **Header Included**: Borders start from row 1 when headers are included
     - **Header Excluded**: Borders start from row 2 when headers are excluded
     - **Full Data Coverage**: Borders span all data columns and rows
     - **Excel Indexing**: Uses 1-based indexing for Excel compatibility

     ## Example
     ```swift
     // For a 5-row dataset with header included
     // dataRange will be: startRow=1, endRow=6, startColumn=1, endColumn=columnCount
     ```
     */
    private func setupDataBorderRegion(
        sheetStyle: SheetStyle,
        dataRowCount: Int,
        dataColumnCount: Int) -> SheetStyle
    {
        var updatedStyle = sheetStyle

        // Calculate starting row based on header inclusion
        let startRow = sheetStyle.dataBorder.includeHeader && hasHeader ? 1 : (hasHeader ? 2 : 1)
        let endRow = hasHeader ? dataRowCount + 1 : dataRowCount

        // Set data region for border application
        updatedStyle.dataRange = SheetStyle.DataRange(
            startRow: startRow,
            startColumn: 1,
            endRow: endRow,
            endColumn: dataColumnCount)

        return updatedStyle
    }

    /**
     Applies data borders to individual cell styles based on position.

     Determines whether a cell is on the edge of the data region and applies
     appropriate border styling. This method handles the complex logic of
     border application for different cell positions within the data area.

     - Parameters:
        - cellStyle: The current cell style to enhance with borders
        - row: The 1-based row index of the cell
        - column: The 1-based column index of the cell
        - borders: The data border configuration
        - sheetStyle: The sheet style containing data range information

     - Returns: Updated `CellStyle` with borders applied, or the original style if no borders needed

     ## Border Application Logic
     - **Edge Detection**: Identifies cells on the perimeter of the data region
     - **Selective Borders**: Applies borders only to appropriate edges
     - **Style Merging**: Combines border styles with existing cell styling
     - **Performance**: Short-circuits when borders are disabled or cell is outside region

     ## Border Positions
     - **Top Edge**: Cells in the first row of the data region
     - **Bottom Edge**: Cells in the last row of the data region
     - **Left Edge**: Cells in the first column of the data region
     - **Right Edge**: Cells in the last column of the data region
     - **Corners**: Cells that are on multiple edges receive multiple borders
     */
    private func applyBordersToCell(cellStyle: CellStyle?, row: Int, column: Int, borders: SheetStyle.DataBorderSettings, sheetStyle: SheetStyle) -> CellStyle? {
        guard borders.enabled else { return cellStyle }

        // Check if cell is within the data region
        guard let dataRange = sheetStyle.dataRange else { return cellStyle }

        guard row >= dataRange.startRow, row <= dataRange.endRow,
              column >= dataRange.startColumn, column <= dataRange.endColumn
        else {
            return cellStyle
        }

        // Determine edge positions for this cell
        let isTopEdge = row == dataRange.startRow
        let isBottomEdge = row == dataRange.endRow
        let isLeftEdge = column == dataRange.startColumn
        let isRightEdge = column == dataRange.endColumn

        // Create border side definition with configured style
        let borderSide = Border.Side(style: borders.borderStyle, color: .black)

        // Apply borders only to edges of the data region
        let border = Border(
            left: isLeftEdge ? borderSide : nil,
            right: isRightEdge ? borderSide : nil,
            top: isTopEdge ? borderSide : nil,
            bottom: isBottomEdge ? borderSide : nil)

        let borderStyle = CellStyle(font: nil, fill: nil, alignment: nil, border: border)
        return CellStyle.merge(cellStyle, borderStyle)
    }
}
