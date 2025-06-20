//
// AnyColumn.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A type-erased wrapper that enables heterogeneous collections of columns with different generic types.
///
/// `AnyColumn` solves the problem of storing columns with different `InputType` and `OutputType`
/// parameters in the same collection. While `Column<ObjectType, InputType, OutputType>` provides
/// strong compile-time type safety, `AnyColumn` enables runtime flexibility for building dynamic
/// column configurations.
///
/// ## Type Erasure Benefits
/// - **Heterogeneous Collections**: Store columns of different types in arrays
/// - **Dynamic Configuration**: Build column sets based on runtime conditions
/// - **Simplified APIs**: Expose uniform interfaces without exposing generic complexity
/// - **Builder Pattern Support**: Enable result builders for column construction
///
/// ## Performance Considerations
/// Type erasure uses function closures to preserve functionality while hiding types.
/// This adds minimal runtime overhead compared to direct generic column usage.
///
/// ## Usage Examples
/// ```swift
/// // Direct creation from typed column
/// let numberColumn = Column<Person, Double, DoubleColumnType>(name: "Salary", keyPath: \.salary)
/// let anyColumn = AnyColumn(numberColumn)
///
/// // Using the convenience method
/// let textColumn = Column<Person, String, TextColumnType>(name: "Name", keyPath: \.name)
/// let erased = textColumn.eraseToAnyColumn()
///
/// // Building heterogeneous collections
/// let columns: [AnyColumn<Person>] = [
///     numberColumn.eraseToAnyColumn(),
///     textColumn.eraseToAnyColumn()
/// ]
/// ```
///
/// ## Integration with Sheet
/// Sheets work with `AnyColumn` arrays to support mixed column types while maintaining
/// type safety for the object type being processed.
///
/// - Parameter ObjectType: The type of object that provides data for column cells
public struct AnyColumn<ObjectType> {
    /// The display name for this column in the Excel sheet header row
    public let name: String

    /// Optional column width in Excel character units (nil = auto-width)
    public let width: Int?

    /// Optional styling for data cells in this column (nil = inherit from sheet/book)
    public let bodyStyle: CellStyle?

    /// Optional styling for the header cell of this column (nil = inherit from sheet/book)
    public let headerStyle: CellStyle?

    /// Type-erased closure that determines conditional column visibility per object
    private let _when: (ObjectType) -> Bool

    /// Type-erased closure that extracts and converts object data to Excel cell values
    private let _generateCellValue: (ObjectType) -> Cell.CellType

    /// Creates a type-erased column from a strongly-typed column instance.
    ///
    /// This initializer performs type erasure by capturing the column's functionality
    /// in closures while hiding the specific `InputType` and `OutputType` parameters.
    /// The resulting `AnyColumn` maintains full functionality but can be stored alongside
    /// other type-erased columns in homogeneous collections.
    ///
    /// - Parameter column: The typed column to wrap with type erasure
    public init<InputType>(_ column: Column<ObjectType, InputType, some ColumnOutputTypeProtocol>) {
        name = column.name
        width = column.width
        bodyStyle = column.bodyStyle
        headerStyle = column.headerStyle
        _when = column.when
        _generateCellValue = column.generateCellValue
    }

    /// Extracts and converts data from the object into an Excel-compatible cell value.
    ///
    /// This method applies the column's key path extraction, data mapping, and formatting
    /// logic to produce a `Cell.CellType` suitable for Excel serialization. The type-erased
    /// closure preserves all the original column's data processing capabilities.
    ///
    /// - Parameter object: The data object to extract column value from
    /// - Returns: Excel-compatible cell value with appropriate type and formatting
    public func generateCellValue(
        for object: ObjectType) -> Cell.CellType
    {
        _generateCellValue(object)
    }

    /// Evaluates whether this column should be included for the given object.
    ///
    /// Columns can be conditionally displayed based on object properties or state.
    /// This method applies the column's visibility logic to determine if the column
    /// should appear in the Excel sheet when processing this specific object.
    ///
    /// - Parameter object: The data object to evaluate for column visibility
    /// - Returns: `true` if the column should be included, `false` to hide it
    public func shouldGenerate(for object: ObjectType) -> Bool {
        _when(object)
    }
}
