//
// AnyColumn.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A type-erased column that can represent any column type.
///
/// `AnyColumn` is a generic structure that allows you to work with columns of different types
/// without knowing their specific type at compile time.
/// It provides a way to store and manipulate columns of different types in a uniform way.
///
/// - Parameters:
///   - ObjectType: The type of object that contains the data to be displayed
public struct AnyColumn<ObjectType> {
    /// The name of the column as it will appear in the Excel sheet
    public let name: String

    /// The width of the column in characters
    public let width: Int?

    /// The style of the column's cells
    public let bodyStyle: CellStyle?

    /// The style of the column's header
    public let headerStyle: CellStyle?

    /// A closure that determines if the column should be generated for a given object
    private let _when: (ObjectType) -> Bool

    /// A closure that generates a cell for a given object at a given row and column
    private let _generateCell: (ObjectType, Int, Int, Int?, Int?, Bool) -> Cell

    /// Creates an `AnyColumn` from a `Column` instance
    ///
    /// - Parameter column: The column to convert to an `AnyColumn`
    public init<InputType>(_ column: Column<ObjectType, InputType, some ColumnOutputTypeProtocol>) {
        name = column.name
        width = column.width
        bodyStyle = column.bodyStyle
        headerStyle = column.headerStyle
        _when = column.when
        _generateCell = column.generateCell
    }

    /// Generates a cell for the given object at the specified position.
    ///
    /// - Parameters:
    ///   - object: The object to generate the cell for
    ///   - row: The row index
    ///   - column: The column index
    ///   - bodyStyleID: Optional style ID for the body cells
    ///   - headerStyleID: Optional style ID for the header cells
    ///   - isHeader: Whether the cell is a header cell
    /// - Returns: The generated cell
    public func generateCell(
        for object: ObjectType,
        row: Int,
        column: Int,
        bodyStyleID: Int? = nil,
        headerStyleID: Int? = nil,
        isHeader: Bool = false) -> Cell
    {
        _generateCell(object, row, column, bodyStyleID, headerStyleID, isHeader)
    }

    /// Checks if the column should be generated for a given object
    ///
    /// - Parameter object: The object to check
    /// - Returns: True if the column should be generated, false otherwise
    public func shouldGenerate(for object: ObjectType) -> Bool {
        _when(object)
    }
}
