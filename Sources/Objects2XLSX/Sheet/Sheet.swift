//
// Sheet.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 A worksheet in an Excel workbook.
 
 A `Sheet` represents a single worksheet within an Excel file, containing structured data
 organized in rows and columns. It provides type-safe data binding through Swift generics
 and supports various customization options including styling, data borders, and layout control.
 
 ## Overview
 
 Sheets are fundamental components of Excel files that:
 - Contain tabular data organized in rows and columns
 - Support custom styling for headers, body cells, and data regions
 - Provide flexible column definitions with conditional rendering
 - Generate appropriate XML for Excel file format
 - Support lazy data loading for performance optimization
 
 ## Thread Safety
 
 **Important**: `Sheet` is not thread-safe. Both `Book` and `Sheet` should be executed
 on the same thread as the `ObjectType` data source:
 
 - For Core Data: Execute in the same context where data was fetched
 - For SwiftData: Execute within the ModelActor where data was obtained
 - For other data sources: Ensure consistent thread usage
 
 ## Usage Example
 
 ```swift
 struct Person {
     let name: String
     let age: Int
     let email: String
 }
 
 let sheet = Sheet(name: "People") {
     Column("Name", keyPath: \.name)
         .width(20)
     Column("Age", keyPath: \.age)
         .width(10)
     Column("Email", keyPath: \.email)
         .width(30)
         .when { !$0.email.isEmpty }
 }
 .dataProvider { fetchPeople() }
 .columnHeaderStyle(CellStyle(font: Font.bold()))
 .dataBorderWithHeader()
 ```
 
 ## Data Flow
 
 1. **Column Definition**: Columns are defined using the `@ColumnBuilder`
 2. **Data Loading**: Data is loaded lazily when XML generation begins
 3. **Column Filtering**: Only relevant columns are included based on first object
 4. **XML Generation**: Sheet data is converted to Excel-compatible XML
 
 - Note: Column filtering helps optimize output by excluding columns with no relevant data
 */
public final class Sheet<ObjectType>: SheetProtocol {
    
    // MARK: - Properties
    
    /**
     The name of the worksheet.
     
     This name appears on the worksheet tab in Excel. Names are automatically
     sanitized to comply with Excel naming requirements (length limits, invalid characters).
     */
    public let name: String
    
    /**
     All column definitions declared for this sheet.
     
     This includes all columns defined in the column builder, even those with
     `when` conditions that evaluate to `false`. During XML generation, only
     active columns (those that should generate based on the first object) are used.
     
     - Note: Column filtering occurs at generation time, not definition time
     */
    public let columns: [AnyColumn<ObjectType>]
    
    /**
     Whether to create a header row with column titles.
     
     When `true`, the first row contains column names. When `false`,
     data rows start immediately from row 1.
     */
    public private(set) var hasHeader: Bool
    
    /**
     The styling configuration for this worksheet.
     
     Contains settings for default dimensions, colors, borders, freeze panes,
     and other visual properties that affect the entire worksheet.
     */
    public private(set) var style: SheetStyle
    
    /**
     The data provider closure for lazy data loading.
     
     This closure is called when XML generation begins, allowing for
     just-in-time data fetching. Useful for performance optimization
     and ensuring data freshness.
     */
    public private(set) var dataProvider: (() -> [ObjectType])?

    /**
     The loaded data objects for this sheet.
     
     Initially `nil` until `loadData()` is called during XML generation.
     Contains the actual objects that will be converted to worksheet rows.
     */
    private(set) var data: [ObjectType]?

    /**
     The total number of rows in the worksheet.
     
     Includes data rows plus one additional row for the header (if enabled).
     Used for calculating worksheet dimensions and data ranges.
     */
    private var rowsCount: Int {
        (data?.count ?? 0) + (hasHeader ? 1 : 0)
    }

    /**
     The number of columns that will be generated.
     
     Based on active columns for the current data set. May be fewer than
     the total defined columns if some have conditional rendering.
     */
    private var columnsCount: Int {
        activeColumns(objects: data ?? []).count
    }

    // MARK: - Initialization
    
    /**
     Creates a new worksheet with the specified configuration.
     
     - Parameters:
        - name: The worksheet name (will be sanitized for Excel compatibility)
        - nameSanitizer: Function to sanitize the worksheet name
        - hasHeader: Whether to include a header row with column names
        - style: The initial styling configuration for the worksheet
        - dataProvider: Optional closure for lazy data loading
        - columns: Column definitions using the ColumnBuilder DSL
     
     ## Example
     ```swift
     let sheet = Sheet(name: "Sales Data", hasHeader: true) {
         Column("Product", keyPath: \.productName)
             .width(25)
         Column("Revenue", keyPath: \.revenue)
             .width(15)
             .when { $0.revenue > 0 }
     }
     ```
     
     - Note: The `nameSanitizer` ensures Excel compatibility by removing invalid characters
       and limiting length according to Excel specifications.
     */
    public init(
        name: String,
        nameSanitizer: SheetNameSanitizer = .default,
        hasHeader: Bool = true,
        style: SheetStyle = .default,
        dataProvider: (() -> [ObjectType])? = nil,
        @ColumnBuilder<ObjectType> columns: () -> [AnyColumn<ObjectType>])
    {
        self.name = nameSanitizer(name)
        self.columns = columns()
        self.hasHeader = hasHeader
        self.style = style
        self.dataProvider = dataProvider
    }

    // MARK: - Type Erasure
    
    /**
     Converts this strongly-typed sheet to a type-erased AnySheet.
     
     This enables storing sheets of different object types in the same collection
     and is used internally by the `Book` class for managing multiple worksheets.
     
     - Returns: A type-erased version of this sheet
     
     ## Usage
     ```swift
     let sheets: [AnySheet] = [
         peopleSheet.eraseToAnySheet(),
         productSheet.eraseToAnySheet()
     ]
     ```
     */
    public func eraseToAnySheet() -> AnySheet {
        AnySheet(self)
    }

    // MARK: - Internal Methods
    
    /**
     Filters columns based on the first object to determine which should be generated.
     
     This method evaluates the `when` conditions of all columns against the first object
     in the dataset to determine which columns should actually be included in the output.
     
     - Parameter objects: The objects to evaluate against
     - Returns: Array of columns that should be generated
     
     - Note: If no objects are provided, returns an empty array
     - Note: Only the first object is used for evaluation to ensure consistent column structure
     */
    func activeColumns(objects: [ObjectType]) -> [AnyColumn<ObjectType>] {
        guard let firstObject = objects.first else { return [] }
        return columns.filter { $0.shouldGenerate(for: firstObject) }
    }

    /**
     Loads data from the data provider and updates the data range.
     
     This method is called during XML generation to perform lazy data loading.
     After loading, it automatically updates the worksheet's data range for
     proper Excel dimension calculation.
     
     - Note: This method is called internally during the Excel generation process
     */
    func loadData() {
        data = dataProvider?()
        updateDataRange()
    }

    /**
     Automatically calculates and sets the data range for worksheet dimensions.
     
     The data range is used by Excel to determine the worksheet's used area
     and affects features like print areas, data validation, and navigation.
     
     - Note: If the worksheet has no data, the data range is set to `nil`
     */
    func updateDataRange() {
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

    // MARK: - Data Border Configuration
    
    /**
     Configures data region borders for the worksheet.
     
     - Parameters:
        - enabled: Whether to enable data region borders
        - includeHeader: Whether to include the header row in the border region
        - borderStyle: The style of border to apply
     
     - Returns: Self for method chaining
     
     ## Example
     ```swift
     sheet.dataBorder(enabled: true, includeHeader: true, borderStyle: .medium)
     ```
     */
    public func dataBorder(enabled: Bool = true, includeHeader: Bool = true, borderStyle: BorderStyle = .thin) -> Self {
        style.dataBorder = SheetStyle.DataBorderSettings(
            enabled: enabled,
            includeHeader: includeHeader,
            borderStyle: borderStyle)
        return self
    }

    /**
     Enables data region borders that include the header row.
     
     - Parameter borderStyle: The style of border to apply
     - Returns: Self for method chaining
     
     ## Example
     ```swift
     sheet.dataBorderWithHeader(borderStyle: .thick)
     ```
     */
    public func dataBorderWithHeader(borderStyle: BorderStyle = .thin) -> Self {
        style.dataBorder = .withHeader(style: borderStyle)
        return self
    }

    /**
     Enables data region borders that exclude the header row.
     
     - Parameter borderStyle: The style of border to apply
     - Returns: Self for method chaining
     
     ## Example
     ```swift
     sheet.dataBorderWithoutHeader(borderStyle: .dashed)
     ```
     */
    public func dataBorderWithoutHeader(borderStyle: BorderStyle = .thin) -> Self {
        style.dataBorder = .withoutHeader(style: borderStyle)
        return self
    }
}

// MARK: - Style Modifiers

extension Sheet {
    
    /**
     Sets the default row height for data rows in the worksheet.
     
     This affects all data rows (excluding the header) unless specific row heights
     are set individually. The height is measured in points (1/72 of an inch).
     
     - Parameter height: The default row height in points
     
     ## Example
     ```swift
     sheet.rowBodyHeight(18.0) // Slightly taller than default
     ```
     
     - Note: This does not affect the header row height, which can be set separately
     */
    public func rowBodyHeight(_ height: Double) {
        style.defaultRowHeight = height
    }

    /**
     Sets the height for the header row.
     
     - Parameter height: The header row height in points
     
     ## Example
     ```swift
     sheet.columnHeaderHeight(25.0) // Taller header for emphasis
     ```
     
     - Note: This only applies when `hasHeader` is `true`
     */
    public func columnHeaderHeight(_ height: Double) {
        style.rowHeights[0] = height
    }

    /**
     Sets the default column width for the entire worksheet.
     
     This affects all columns unless specific column widths are set individually
     through column definitions or style settings.
     
     - Parameter width: The default column width in Excel's character units
     
     ## Example
     ```swift
     sheet.columnWidth(12) // Slightly wider than default
     ```
     
     - Note: Excel measures column width in character units (based on default font)
     */
    public func columnWidth(_ width: Int) {
        style.defaultColumnWidth = Double(width)
    }

    /**
     Sets the styling for all column headers in the worksheet.
     
     This style is applied to the header row cells and can include font,
     fill, alignment, and border properties.
     
     - Parameter style: The cell style to apply to headers
     
     ## Example
     ```swift
     sheet.columnHeaderStyle(
         CellStyle(
             font: Font.bold().size(12),
             fill: Fill.solid(.lightGray),
             alignment: Alignment.center()
         )
     )
     ```
     */
    public func columnHeaderStyle(_ style: CellStyle) {
        self.style.columnHeaderStyle = style
    }

    /**
     Sets the default styling for all data cells in the worksheet.
     
     This style is applied to data row cells and can include font,
     fill, alignment, and border properties.
     
     - Parameter style: The cell style to apply to data cells
     
     ## Example
     ```swift
     sheet.columnBodyStyle(
         CellStyle(
             font: Font.regular().size(10),
             alignment: Alignment.left()
         )
     )
     ```
     */
    public func columnBodyStyle(_ style: CellStyle) {
        self.style.columnBodyStyle = style
    }

    /**
     Sets the data provider for the worksheet.
     
     The data provider is a closure that returns the objects to be displayed
     in the worksheet. It's called lazily during Excel generation.
     
     - Parameter dataProvider: A closure that returns an array of objects
     
     ## Example
     ```swift
     sheet.dataProvider {
         // Fetch fresh data each time
         return database.fetchAllUsers()
     }
     ```
     
     - Note: The closure is called on the same thread as the Excel generation
     */
    public func dataProvider(_ dataProvider: @escaping () -> [ObjectType]) {
        self.dataProvider = dataProvider
    }

    /**
     Controls whether the worksheet includes a header row.
     
     - Parameter show: `true` to include headers, `false` to start with data rows
     
     ## Example
     ```swift
     sheet.showHeader(false) // Data-only worksheet
     ```
     */
    public func showHeader(_ show: Bool) {
        hasHeader = show
    }

    /**
     Replaces the current worksheet styling with new settings.
     
     - Parameter style: The new sheet style configuration
     
     ## Example
     ```swift
     let customStyle = SheetStyle()
         .defaultRowHeight(20.0)
         .showGridlines(false)
         .tabColor(.blue)
     
     sheet.sheetStyle(customStyle)
     ```
     */
    public func sheetStyle(_ style: SheetStyle) {
        self.style = style
    }
}

// MARK: - Utility Functions

/**
 Converts a 1-based column index to Excel column name notation.
 
 Excel uses alphabetical column names (A, B, C, ..., Z, AA, AB, etc.)
 instead of numeric indices. This function performs the conversion.
 
 - Parameter index: The 1-based column index (1 = A, 2 = B, etc.)
 - Returns: The Excel column name string
 
 ## Examples
 ```swift
 columnIndexToExcelColumn(1)   // "A"
 columnIndexToExcelColumn(26)  // "Z"
 columnIndexToExcelColumn(27)  // "AA"
 columnIndexToExcelColumn(702) // "ZZ"
 ```
 
 - Important: This function expects 1-based indexing as used by Excel,
   not 0-based indexing common in programming.
 */
func columnIndexToExcelColumn(_ index: Int) -> String {
    var result = ""
    var num = index - 1

    repeat {
        result = String(Character(UnicodeScalar(65 + num % 26)!)) + result
        num = num / 26 - 1
    } while num >= 0

    return result
}

// MARK: - Sendable Conformance

extension Sheet: @unchecked Sendable where ObjectType: Sendable {}
