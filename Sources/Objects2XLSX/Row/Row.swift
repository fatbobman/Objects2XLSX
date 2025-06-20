//
// Row.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Represents a row in an Excel worksheet.
 
 A `Row` contains an ordered collection of cells and metadata about the row itself,
 including its position in the worksheet and optional height customization.
 
 ## Overview
 
 Rows are fundamental building blocks of Excel worksheets. Each row:
 - Has a unique 1-based index position within the worksheet
 - Contains zero or more cells arranged horizontally
 - Can have a custom height or use the worksheet's default height
 - Generates appropriate XML for the Excel file format
 
 ## Usage Example
 
 ```swift
 // Create a row with cells and custom height
 let cells = [
     Cell(row: 1, column: 1, value: .string("Name"), styleID: nil),
     Cell(row: 1, column: 2, value: .string("Age"), styleID: nil)
 ]
 let headerRow = Row(index: 1, cells: cells, height: 25.0)
 
 // Create a row with default height
 let dataRow = Row(index: 2, cells: [
     Cell(row: 2, column: 1, value: .string("John"), styleID: nil),
     Cell(row: 2, column: 2, value: .int(30), styleID: nil)
 ])
 ```
 
 ## XML Generation
 
 Rows generate XML in the format expected by Excel:
 ```xml
 <row r="1" ht="25.0" customHeight="1">
     <c r="A1" t="inlineStr"><is><t>Name</t></is></c>
     <c r="B1" t="inlineStr"><is><t>Age</t></is></c>
 </row>
 ```
 
 - Note: Row indices in Excel are 1-based, not 0-based
 - Height is specified in points when custom height is used
 - The `customHeight` attribute indicates non-default height
 */
public struct Row {
    
    // MARK: - Properties
    
    /**
     The 1-based row index in the worksheet.
     
     This corresponds to the row number as displayed in Excel (1, 2, 3, etc.).
     Must be positive and unique within the worksheet.
     
     - Note: Excel uses 1-based indexing for rows, unlike many programming languages that use 0-based indexing.
     */
    public let index: Int
    
    /**
     The cells contained in this row.
     
     Cells are arranged in column order and should have column indices that correspond
     to their position. Not all columns need to have cells - sparse rows are supported.
     
     - Note: This array can be modified after row creation to add or remove cells.
     */
    public var cells: [Cell]
    
    /**
     The custom height of the row in points.
     
     When `nil`, the row uses the worksheet's default row height.
     When specified, this overrides the default height for this specific row.
     
     - Note: Excel measures row height in points (1/72 of an inch).
     - Typical default row height is around 15 points.
     */
    public let height: Double?
    
    // MARK: - Initialization
    
    /**
     Creates a new row with the specified properties.
     
     - Parameters:
        - index: The 1-based row index in the worksheet
        - cells: The cells to include in this row
        - height: Optional custom height in points. If `nil`, uses worksheet default.
     
     ## Example
     ```swift
     let row = Row(
         index: 1,
         cells: [
             Cell(row: 1, column: 1, value: .string("Header"), styleID: 1)
         ],
         height: 20.0
     )
     ```
     */
    public init(index: Int, cells: [Cell], height: Double? = nil) {
        self.index = index
        self.cells = cells
        self.height = height
    }
}

// MARK: - XML Generation

extension Row {
    
    /**
     Generates the XML representation of this row for Excel files.
     
     This method creates the XML structure that Excel expects for row data,
     including the row index, optional height information, and all contained cells.
     
     ## XML Structure
     
     The generated XML follows this pattern:
     ```xml
     <row r="1" [ht="25.0" customHeight="1"]>
         <!-- Cell XML goes here -->
     </row>
     ```
     
     ## Attributes
     
     - `r`: The 1-based row index
     - `ht`: Row height in points (only present if custom height is set)
     - `customHeight`: Set to "1" when custom height is specified
     
     ## Cell Ordering
     
     Cells are included in the order they appear in the `cells` array.
     The XML generator does not automatically sort cells by column position,
     so ensure cells are in the correct order before calling this method.
     
     - Returns: A complete XML string representing this row and its cells
     
     ## Example Output
     
     For a row with custom height:
     ```xml
     <row r="1" ht="25.0" customHeight="1">
         <c r="A1" t="inlineStr"><is><t>Header</t></is></c>
         <c r="B1" t="inlineStr"><is><t>Value</t></is></c>
     </row>
     ```
     
     For a row with default height:
     ```xml
     <row r="2">
         <c r="A2" t="inlineStr"><is><t>Data</t></is></c>
     </row>
     ```
     
     - Important: The generated XML must be well-formed and valid according to
       the Office Open XML specification for Excel files.
     */
    public func generateXML() -> String {
        var xml = "<row r=\"\(index)\""

        if let height {
            xml += " ht=\"\(height)\" customHeight=\"1\""
        }

        xml += ">"

        for cell in cells {
            xml += cell.generateXML()
        }

        xml += "</row>"
        return xml
    }
}
