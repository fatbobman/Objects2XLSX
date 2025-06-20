//
// SheetXML.swift
// Created by Xu Yang on 2025-06-07.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 A structure representing the complete XML data for an Excel worksheet.

 `SheetXML` contains all the data and metadata necessary to generate the XML
 content for a single worksheet within an Excel file. It serves as an intermediate
 representation between the high-level `Sheet` objects and the final XML output.

 ## Overview

 This structure encapsulates:
 - The worksheet name (sanitized for Excel compatibility)
 - All row data including headers and data rows
 - Styling information for the entire worksheet
 - Utility methods for XML generation and analysis

 ## XML Generation

 The primary purpose of `SheetXML` is to generate valid Excel worksheet XML
 that conforms to the Office Open XML specification. The generated XML includes:

 - Worksheet properties and formatting
 - Column definitions and custom widths
 - Row data with proper cell references
 - Styling and visual properties

 ## Usage

 ```swift
 let sheetXML = SheetXML(
     name: "Sales Data",
     rows: [headerRow, dataRow1, dataRow2],
     style: sheetStyle
 )

 let xmlContent = sheetXML.generateXML()
 // Write xmlContent to Excel file
 ```

 - Note: This structure is typically created internally by the `Sheet` class
   during the Excel generation process
 */
struct SheetXML {
    // MARK: - Properties

    /**
     The sanitized name of the worksheet.

     This name appears on the worksheet tab in Excel. It has been processed to:
     - Remove invalid characters
     - Ensure it doesn't exceed 31 characters (Excel limit)
     - Comply with Excel naming requirements
     */
    let name: String

    /**
     All rows in the worksheet.

     This includes both header rows (if present) and data rows, arranged in
     the order they should appear in the Excel worksheet. Each row contains
     its own collection of cells with positioning and styling information.
     */
    let rows: [Row]

    /**
     The styling configuration for the entire worksheet.

     Contains settings for default dimensions, colors, borders, freeze panes,
     and other visual properties. When `nil`, default Excel styling is used.
     */
    let style: SheetStyle?

    // MARK: - Initialization

    /**
     Creates a new SheetXML instance with the specified data.

     - Parameters:
        - name: The worksheet name (should already be sanitized)
        - rows: The complete collection of rows for the worksheet
        - style: Optional styling configuration for the worksheet

     ## Example
     ```swift
     let sheetXML = SheetXML(
         name: "Product Data",
         rows: allRows,
         style: customStyle
     )
     ```
     */
    init(name: String, rows: [Row], style: SheetStyle? = nil) {
        self.name = name
        self.rows = rows
        self.style = style
    }

    // MARK: - Computed Properties

    /**
     The total number of cells across all rows in the worksheet.

     This count includes all cells in both header and data rows, useful for
     progress reporting and memory estimation during large data processing.
     */
    var totalCellCount: Int {
        rows.reduce(0) { $0 + $1.cells.count }
    }

    /**
     The maximum number of columns used by any row.

     This value represents the width of the worksheet in terms of columns
     and is used for calculating worksheet dimensions and column settings.
     Returns 0 if the worksheet has no rows.
     */
    var maxColumnCount: Int {
        rows.map(\.cells.count).max() ?? 0
    }

    // MARK: - XML Generation

    /**
     Generates the complete worksheet XML content.

     This method creates the full XML representation of the worksheet that conforms
     to the Office Open XML specification. The generated XML includes all necessary
     elements for Excel to properly display and interact with the worksheet data.

     ## XML Structure

     The generated XML follows this hierarchical structure:
     ```xml
     <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
     <worksheet xmlns="...">
         <sheetFormatPr defaultRowHeight="..." defaultColWidth="..."/>
         <sheetViews>...</sheetViews>
         <cols>...</cols>
         <sheetData>
             <row r="1">...</row>
             <!-- more rows -->
         </sheetData>
     </worksheet>
     ```

     ## Features Included

     - XML declaration and namespace
     - Tab color (if specified in style)
     - Sheet formatting properties
     - View settings (freeze panes, zoom, gridlines)
     - Column definitions and custom widths
     - Complete row and cell data

     - Returns: A complete XML string representing the worksheet

     ## Compliance

     The generated XML complies with the Office Open XML File Formats specification
     and is compatible with Microsoft Excel and other spreadsheet applications.

     - Important: This method assumes all data has been properly validated and
       formatted before calling. Invalid data may result in corrupt Excel files.
     */
    public func generateXML() -> String {
        var xml = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
            """

        // Add tab color attribute if specified
        if let style, let tabColor = style.tabColor {
            xml += " tabColor=\"\(tabColor.argbHexString)\""
        }

        xml += ">"

        // Generate other XML content
        xml += generateWorksheetContent()

        xml += "</worksheet>"
        return xml
    }

    /**
     Generates the main content of the worksheet (excluding root element attributes).

     This private method assembles the various components of the worksheet XML
     in the correct order as required by the Excel specification. The order
     of elements is important for compatibility.

     ## Generated Elements (in order)

     1. **Sheet Format Properties**: Default row height, column width
     2. **Sheet Views**: Freeze panes, zoom, gridlines, view settings
     3. **Column Definitions**: Custom column widths and properties
     4. **Sheet Data**: All rows and cells with their content

     - Returns: The inner XML content of the worksheet element

     - Note: This method assumes the style and rows have been properly configured
     */
    private func generateWorksheetContent() -> String {
        var xml = ""

        // Add worksheet format settings (optional)
        if let style {
            xml += generateSheetFormatXML(style)
        }

        // Add sheetViews settings (freeze panes, zoom, gridlines, etc.)
        if let style {
            xml += generateSheetViewsXML(style)
        }

        // Add column settings (optional)
        if let style, !style.columnWidths.isEmpty {
            xml += generateColumnsXML(style)
        }

        // Add worksheet data
        xml += "<sheetData>"
        for row in rows {
            xml += row.generateXML()
        }
        xml += "</sheetData>"

        return xml
    }

    /**
     Generates sheet view XML including freeze panes, zoom, and gridline settings.

     This method combines multiple view-related settings into a single `<sheetViews>`
     element as required by Excel. It handles various visual display options that
     affect how users interact with the worksheet.

     ## Generated Features

     - **Freeze Panes**: Top row, first column, or custom row/column combinations
     - **Zoom Level**: Custom zoom scaling for the worksheet view
     - **Gridlines**: Show or hide worksheet gridlines
     - **View Properties**: Standard worksheet view configuration

     ## XML Examples

     Basic view with hidden gridlines:
     ```xml
     <sheetViews><sheetView workbookViewId="0" showGridLines="0"/></sheetViews>
     ```

     View with freeze panes:
     ```xml
     <sheetViews>
         <sheetView workbookViewId="0">
             <pane xSplit="2" ySplit="1" topLeftCell="C2" activePane="topLeft" state="frozen"/>
         </sheetView>
     </sheetViews>
     ```

     - Parameter style: The sheet style containing view configuration
     - Returns: Complete `<sheetViews>` XML element
     */
    private func generateSheetViewsXML(_ style: SheetStyle) -> String {
        var attributes = "workbookViewId=\"0\""
        if !style.showGridlines {
            attributes += " showGridLines=\"0\""
        }
        if let zoom = style.zoom {
            attributes += " zoomScale=\"\(zoom.scale)\""
        }

        var innerXML = ""
        if let freezePanes = style.freezePanes {
            if freezePanes.freezeTopRow {
                innerXML += "<pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/>"
            } else if freezePanes.freezeFirstColumn {
                innerXML += "<pane xSplit=\"1\" topLeftCell=\"B1\" activePane=\"topRight\" state=\"frozen\"/>"
            } else if freezePanes.frozenRows > 0 || freezePanes.frozenColumns > 0 {
                let topLeftCell = "\(columnIndexToExcelColumn(freezePanes.frozenColumns + 1))\(freezePanes.frozenRows + 1)"
                innerXML += "<pane xSplit=\"\(freezePanes.frozenColumns)\" ySplit=\"\(freezePanes.frozenRows)\" topLeftCell=\"\(topLeftCell)\" activePane=\"topLeft\" state=\"frozen\"/>"
            }
        }

        if innerXML.isEmpty {
            return "<sheetViews><sheetView \(attributes)/></sheetViews>"
        } else {
            return "<sheetViews><sheetView \(attributes)>\(innerXML)</sheetView></sheetViews>"
        }
    }

    /**
     Generates sheet format properties XML.

     This method creates the `<sheetFormatPr>` element that defines default
     dimensions for the worksheet. These defaults apply to all rows and columns
     unless specifically overridden.

     ## Generated XML

     ```xml
     <sheetFormatPr defaultRowHeight="15.0" defaultColWidth="8.43"/>
     ```

     ## Properties Included

     - **defaultRowHeight**: Default height for all rows (in points)
     - **defaultColWidth**: Default width for all columns (in character units)

     - Parameter style: The sheet style containing format properties
     - Returns: Complete `<sheetFormatPr>` XML element

     - Note: Excel measures row height in points and column width in character units
     */
    private func generateSheetFormatXML(_ style: SheetStyle) -> String {
        var xml = "<sheetFormatPr"

        xml += " defaultRowHeight=\"\(style.defaultRowHeight)\""
        xml += " defaultColWidth=\"\(style.defaultColumnWidth)\""

        xml += "/>"

        return xml
    }

    /**
     Generates column definitions XML for custom column widths.

     This method creates the `<cols>` element containing individual `<col>`
     definitions for columns that have custom widths. Only columns with
     non-default widths are included.

     ## Generated XML

     ```xml
     <cols>
         <col min="1" max="1" width="15.0" customWidth="1"/>
         <col min="3" max="3" width="25.0" customWidth="1"/>
     </cols>
     ```

     ## Attributes

     - **min/max**: The column range (currently always the same for single columns)
     - **width**: The column width in Excel's character units
     - **customWidth**: Set to "1" to indicate this is a custom width

     - Parameter style: The sheet style containing column width definitions
     - Returns: Complete `<cols>` XML element with all custom column definitions

     - Note: Columns are sorted by index to ensure consistent output order
     */
    private func generateColumnsXML(_ style: SheetStyle) -> String {
        var xml = "<cols>"

        for (index, columnWidth) in style.columnWidths.sorted(by: { $0.key < $1.key }) {
            xml += "<col min=\"\(index)\" max=\"\(index)\" width=\"\(columnWidth.width)\" customWidth=\"1\"/>"
        }

        xml += "</cols>"
        return xml
    }
}
