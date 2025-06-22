//
// SheetMeta.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Lightweight metadata for worksheets containing essential information for XML generation.

 `SheetMeta` provides a compact representation of worksheet properties needed for
 generating various Excel file components without requiring the full `SheetXML` data.
 This approach prevents memory issues when processing large datasets.

 ## Overview

 The metadata includes:
 - Basic worksheet identification (name, ID, file paths)
 - Structural information (row/column counts, data ranges)
 - Relationship identifiers for Excel file organization
 - Layout properties (header presence, dimensions)

 ## Usage

 ```swift
 let meta = sheet.makeSheetMeta(sheetId: 1)
 print("Worksheet: \(meta.name)")
 print("Data range: \(meta.dataRange?.excelRange ?? "None")")
 print("File path: \(meta.filePath)")
 ```

 ## Memory Efficiency

 Unlike `SheetXML` which contains all row and cell data, `SheetMeta` only stores
 summary information. This makes it suitable for:
 - Early planning phases of Excel generation
 - Progress reporting and estimation
 - Cross-referencing between workbook components

 - Note: This structure is typically created by calling `makeSheetMeta(sheetId:)` on a `Sheet`
 */
public struct SheetMeta: Sendable {
    // MARK: - Properties

    /**
     The sanitized name of the worksheet.

     This name has been processed to comply with Excel requirements and
     appears on the worksheet tab in Excel.
     */
    public let name: String

    /**
     The unique identifier for this worksheet within the workbook.

     Sheet IDs start from 1 and are used for internal Excel file organization
     and cross-referencing between different XML components.
     */
    public let sheetId: Int

    /**
     The relationship identifier used in workbook.xml.rels.

     Follows the pattern "rId1", "rId2", etc. and establishes the connection
     between the workbook and individual worksheet files.
     */
    public let relationshipId: String

    /**
     Whether the worksheet includes a header row.

     This affects row counting, data range calculation, and XML generation.
     When `true`, the first row contains column names.
     */
    public let hasHeader: Bool

    /**
     The estimated number of data rows (excluding header).

     This count may be an estimate if calculated before full data loading,
     useful for progress reporting and resource planning.
     */
    public let estimatedDataRowCount: Int

    /**
     The number of active columns that will be generated.

     Based on column filtering and conditional rendering rules,
     this represents the actual width of the generated worksheet.
     */
    public let activeColumnCount: Int

    /**
     The total number of rows including header (if present).

     Calculated as `estimatedDataRowCount + (hasHeader ? 1 : 0)`.
     */
    public let totalRowCount: Int

    /**
     Data range information for Excel dimension calculation.

     Defines the used area of the worksheet in Excel's coordinate system.
     `nil` if the worksheet has no data.
     */
    public let dataRange: DataRangeInfo?

    /**
     The file path within the XLSX package structure.

     Follows Excel's standard path pattern: "xl/worksheets/sheet{id}.xml".
     */
    public let filePath: String


    /**
     Information about the data range in Excel coordinates.

     Represents the rectangular area of the worksheet that contains data,
     used for Excel's dimension calculations and navigation features.
     */
    public struct DataRangeInfo: Sendable {
        /**
         The starting row number (1-based Excel indexing).
         */
        public let startRow: Int

        /**
         The starting column number (1-based Excel indexing).
         */
        public let startColumn: Int

        /**
         The ending row number (1-based Excel indexing).
         */
        public let endRow: Int

        /**
         The ending column number (1-based Excel indexing).
         */
        public let endColumn: Int

        /**
         The data range in Excel's A1 notation format.

         Converts the numeric coordinates to Excel's letter-number notation.

         ## Examples
         - A range from (1,1) to (3,10) becomes "A1:C10"
         - A range from (2,5) to (8,26) becomes "E2:Z8"

         - Returns: A string in Excel range format (e.g., "A1:C10")
         */
        public var excelRange: String {
            let startCol = columnIndexToExcelColumn(startColumn)
            let endCol = columnIndexToExcelColumn(endColumn)
            return "\(startCol)\(startRow):\(endCol)\(endRow)"
        }
    }

    // MARK: - Initialization

    /**
     Creates a new SheetMeta instance with the specified properties.

     - Parameters:
        - name: The sanitized worksheet name
        - sheetId: The unique worksheet identifier (1-based)
        - relationshipId: The relationship ID for Excel file organization
        - hasHeader: Whether the worksheet includes a header row
        - estimatedDataRowCount: The estimated number of data rows
        - activeColumnCount: The number of active columns to be generated
        - dataRange: Optional data range information

     The total row count and file path are calculated automatically based on the provided parameters.
     */
    public init(
        name: String,
        sheetId: Int,
        relationshipId: String,
        hasHeader: Bool,
        estimatedDataRowCount: Int,
        activeColumnCount: Int,
        dataRange: DataRangeInfo?)
    {
        self.name = name
        self.sheetId = sheetId
        self.relationshipId = relationshipId
        self.hasHeader = hasHeader
        self.estimatedDataRowCount = estimatedDataRowCount
        self.activeColumnCount = activeColumnCount
        totalRowCount = estimatedDataRowCount + (hasHeader ? 1 : 0)
        self.dataRange = dataRange
        filePath = "xl/worksheets/sheet\(sheetId).xml"
    }
}

// MARK: - Sheet Extensions

extension Sheet {
    /**
     Creates metadata for this worksheet for use in workbook-level XML generation.

     This method generates a lightweight representation of the worksheet containing
     essential information needed for various Excel file components. It should be
     called after data has been loaded via `loadData()`.

     - Parameter sheetId: The unique identifier to assign to this worksheet
     - Returns: A `SheetMeta` instance containing worksheet metadata

     ## Usage
     ```swift
     sheet.loadData() // Ensure data is loaded first
     let meta = sheet.makeSheetMeta(sheetId: 1)
     ```

     - Important: This method assumes data has been pre-loaded through `loadData()`.
       Calling it before data loading may result in incorrect row/column counts.
     */
    public func makeSheetMeta(sheetId: Int) -> SheetMeta {
        let dataRowCount = data?.count ?? 0
        let activeColumns = activeColumns(objects: data ?? [])
        let activeColumnCount = activeColumns.count

        // Build data range information
        let dataRange: SheetMeta.DataRangeInfo? = if totalRowCount > 0, activeColumnCount > 0 {
            SheetMeta.DataRangeInfo(
                startRow: 1,
                startColumn: 1,
                endRow: totalRowCount,
                endColumn: activeColumnCount)
        } else {
            nil
        }

        return SheetMeta(
            name: name,
            sheetId: sheetId,
            relationshipId: "rId\(sheetId)",
            hasHeader: hasHeader,
            estimatedDataRowCount: dataRowCount,
            activeColumnCount: activeColumnCount,
            dataRange: dataRange)
    }

    /**
     The total number of rows including header (if present).

     Calculated as the sum of data rows and one header row (if enabled).
     This count is used for worksheet dimension calculations.
     */
    public var totalRowCount: Int {
        (data?.count ?? 0) + (hasHeader ? 1 : 0)
    }

    /**
     Provides an estimate of data row count without triggering data loading.

     This method is useful for early estimation and progress planning during
     Excel generation. It returns the actual count if data is already loaded,
     or 0 if data hasn't been loaded yet.

     - Returns: The estimated number of data rows (excluding header)

     ## Implementation Notes

     - If data is already loaded, returns the actual count
     - If data provider exists but data isn't loaded, returns 0 (unknown)
     - For more accurate estimation, consider implementing a dedicated count provider

     - Note: This method does not trigger data loading to avoid performance impacts
     */
    public func estimatedDataRowCount() -> Int {
        // If data is already loaded, return actual count
        if let data {
            return data.count
        }

        // If there's a data provider, we could potentially call it to get count
        // For now, simplified approach returns 0 indicating unknown
        // In production, consider adding a dedicated countProvider for better estimation
        return 0
    }
}
