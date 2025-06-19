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
/// You can create an `AnyColumn` from a `Column` instance using the `init` method.
///
/// ```swift
/// let column = Column<MyObject, Double, DoubleColumnType>(name: "My Column", keyPath: \.myDoubleProperty)
/// let anyColumn = AnyColumn(column)
/// ```
///
/// You can also create an `AnyColumn` from a `Column` instance using the `eraseToAnyColumn` method.
///
/// ```swift
/// let column = Column<MyObject, Double, DoubleColumnType>(name: "My Column", keyPath: \.myDoubleProperty)
/// let anyColumn = column.eraseToAnyColumn()
/// ```
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
    private let _generateCellValue: (ObjectType) -> Cell.CellType

    /// Creates an `AnyColumn` from a `Column` instance
    ///
    /// - Parameter column: The column to convert to an `AnyColumn`
    public init<InputType>(_ column: Column<ObjectType, InputType, some ColumnOutputTypeProtocol>) {
        name = column.name
        width = column.width
        bodyStyle = column.bodyStyle
        headerStyle = column.headerStyle
        _when = column.when
        _generateCellValue = column.generateCellValue
    }

    /// Generates a cell value for the given object.
    ///
    /// - Parameters:
    ///   - object: The object to generate the cell value for
    /// - Returns: The generated cell value
    public func generateCellValue(
        for object: ObjectType) -> Cell.CellType
    {
        _generateCellValue(object)
    }

    /// Checks if the column should be generated for a given object
    ///
    /// - Parameter object: The object to check
    /// - Returns: True if the column should be generated, false otherwise
    public func shouldGenerate(for object: ObjectType) -> Bool {
        _when(object)
    }
}
