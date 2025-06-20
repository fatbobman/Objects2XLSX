//
// AnySheet.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 A type-erased wrapper for sheets that can hold any object type.

 `AnySheet` enables storing sheets with different object types in the same collection,
 which is essential for the `Book` class to manage multiple worksheets. It preserves
 the functionality of the original typed sheet while hiding the specific object type.

 ## Overview

 Type erasure is necessary because Swift generics don't allow storing different
 generic types in the same collection. `AnySheet` solves this by:

 - Wrapping the typed `Sheet<ObjectType>` functionality
 - Providing a uniform interface for sheet operations
 - Maintaining type safety through closure capture
 - Enabling polymorphic behavior for sheet processing

 ## Usage

 ```swift
 let peopleSheet = Sheet<Person>(name: "People") { ... }
 let productSheet = Sheet<Product>(name: "Products") { ... }

 // Store different sheet types together
 let sheets: [AnySheet] = [
     peopleSheet.eraseToAnySheet(),
     productSheet.eraseToAnySheet()
 ]

 // Process all sheets uniformly
 for sheet in sheets {
     let meta = sheet.makeSheetMeta(sheetId: index)
     // ... process sheet
 }
 ```

 ## Implementation Details

 The type erasure is implemented using closure capture to preserve the original
 sheet's functionality while providing a common interface. All operations delegate
 to the wrapped sheet through stored closures.

 - Note: This class is used internally by the library and rarely needs direct instantiation
 */
public final class AnySheet {
    // MARK: - Private Properties

    /// The name of the worksheet
    private let _name: String

    /// Whether the worksheet has a header row
    private let _hasHeader: Bool

    /// Closure to generate SheetXML from the wrapped sheet
    private let _makeSheetXML: (BookStyle, StyleRegister, ShareStringRegister) -> SheetXML?

    /// Closure to generate SheetMeta from the wrapped sheet
    private let _makeSheetMeta: (Int) -> SheetMeta

    /// Closure to load data from the wrapped sheet
    private let _loadData: () -> Void

    /// Closure to estimate data row count from the wrapped sheet
    private let _estimatedDataRowCount: () -> Int

    // MARK: - Public Properties

    /**
     The name of the worksheet.

     This corresponds to the name that will appear on the worksheet tab in Excel.
     */
    public var name: String { _name }

    /**
     Whether the worksheet includes a header row.

     When `true`, the first row contains column names. When `false`,
     data rows start immediately from row 1.
     */
    public var hasHeader: Bool { _hasHeader }

    // MARK: - Initialization

    /**
     Creates a type-erased wrapper around a typed sheet.

     This initializer captures the sheet's functionality in closures to enable
     type-erased operation while preserving the original behavior.

     - Parameter sheet: The typed sheet to wrap

     ## Implementation

     The initializer captures references to the sheet's methods and properties,
     allowing the `AnySheet` to delegate operations to the original typed sheet
     without exposing the object type.
     */
    public init<ObjectType>(_ sheet: Sheet<ObjectType>) {
        _name = sheet.name
        _hasHeader = sheet.hasHeader
        _estimatedDataRowCount = sheet.estimatedDataRowCount

        _loadData = {
            sheet.loadData()
        }
        _makeSheetXML = { bookStyle, styleRegister, shareStringRegister in
            // Use already loaded data instead of calling dataProvider again
            let objects = sheet.data ?? []
            // Generate SheetXML with the loaded data
            return sheet.makeSheetXML(
                with: objects,
                bookStyle: bookStyle,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegister)
        }
        _makeSheetMeta = { sheetId in
            sheet.makeSheetMeta(sheetId: sheetId)
        }
    }

    // MARK: - Internal Methods

    /**
     Loads data from the wrapped sheet's data provider.

     This method is called explicitly by the `Book` class to ensure data is loaded
     exactly once during the Excel generation process. It delegates to the wrapped
     sheet's `loadData()` method.

     - Note: This method is internal and called by the framework during Excel generation
     */
    func loadData() {
        _loadData()
    }

    /**
     Generates the XML representation of this worksheet.

     This method uses data that has already been loaded via `loadData()`.
     It creates the complete XML structure for the worksheet including headers,
     data rows, and styling information. The method accesses pre-loaded data
     rather than calling the data provider again, ensuring efficient single-pass processing.

     - Parameters:
        - bookStyle: The workbook-level styling configuration
        - styleRegister: Registry for managing and deduplicating styles
        - shareStringRegister: Registry for managing shared strings

     - Returns: A `SheetXML` object containing the complete worksheet XML, or `nil` if generation fails

     - Important: This method assumes data has been pre-loaded through `loadData()`.
       It uses the cached data rather than calling the data provider to avoid duplicate loading.
     - Note: This method is internal and called by the framework during Excel generation
     */
    func makeSheetXML(
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister) -> SheetXML?
    {
        _makeSheetXML(bookStyle, styleRegister, shareStringRegister)
    }

    /**
     Creates metadata information for this worksheet.

     The metadata includes information about the worksheet's structure, dimensions,
     and properties that are needed for the Excel file's internal organization.

     - Parameter sheetId: The unique identifier for this worksheet within the workbook
     - Returns: A `SheetMeta` object containing the worksheet metadata

     - Note: This method assumes data has been loaded via `loadData()`
     */
    public func makeSheetMeta(sheetId: Int) -> SheetMeta {
        _makeSheetMeta(sheetId)
    }

    /**
     Provides an estimate of the number of data rows in the worksheet.

     This method is used for progress reporting and resource planning during
     Excel generation. It may be called before data is actually loaded.

     - Returns: An estimated count of data rows (excluding header)

     - Note: The estimate may not be exact, especially for dynamic data sources
     */
    public func estimatedDataRowCount() -> Int {
        _estimatedDataRowCount()
    }
}
