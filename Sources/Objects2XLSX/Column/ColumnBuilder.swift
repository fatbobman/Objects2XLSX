//
// ColumnBuilder.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A Swift result builder that enables declarative syntax for constructing column arrays.
///
/// `ColumnBuilder` implements the result builder pattern to provide clean, readable syntax
/// for defining Excel columns. It handles the complexity of type erasure automatically,
/// allowing you to mix different column types while maintaining type safety.
///
/// ## Supported Syntax
/// - **Multiple columns**: Direct listing of column definitions
/// - **Conditional columns**: `if` statements for dynamic column inclusion
/// - **Conditional branches**: `if-else` statements for alternative column sets
/// - **Loops**: `for` loops and array mapping for programmatic column generation
/// - **Optional columns**: Automatic handling of nil column expressions
///
/// ## Usage Example
/// ```swift
/// @ColumnBuilder<Person>
/// var personColumns: [AnyColumn<Person>] {
///     Column<Person, String, TextColumnType>(name: "Name", keyPath: \.fullName)
///     Column<Person, Double, DoubleColumnType>(name: "Salary", keyPath: \.salary)
///
///     if includeContactInfo {
///         Column<Person, String, TextColumnType>(name: "Email", keyPath: \.email)
///         Column<Person, String, TextColumnType>(name: "Phone", keyPath: \.phone)
///     }
///
///     if isAdminView {
///         Column<Person, Date, DateColumnType>(name: "Hire Date", keyPath: \.hireDate)
///     } else {
///         Column<Person, String, TextColumnType>(name: "Department", keyPath: \.department)
///     }
/// }
/// ```
///
/// ## Integration with Sheet
/// The resulting `[AnyColumn<ObjectType>]` array can be used directly with Sheet
/// initializers or passed to column-building functions.
@resultBuilder
public enum ColumnBuilder<ObjectType> {
    /// Combines multiple column arrays into a single flattened array.
    ///
    /// This method handles the core composition of column builder expressions,
    /// flattening nested arrays and combining multiple column definitions.
    ///
    /// - Parameter components: Variable number of column arrays to combine
    /// - Returns: Flattened array containing all columns in declaration order
    public static func buildBlock(_ components: [AnyColumn<ObjectType>]...) -> [AnyColumn<ObjectType>] {
        components.flatMap(\.self)
    }

    /// Converts a strongly-typed column to a type-erased column array.
    ///
    /// Handles individual column expressions in the builder, performing automatic
    /// type erasure to enable heterogeneous column collections.
    ///
    /// - Parameter column: A typed column with any input/output type combination
    /// - Returns: Single-element array containing the type-erased column
    public static func buildExpression(_ column: Column<
        ObjectType,
        some Any,
        some ColumnOutputTypeProtocol
    >)
    -> [AnyColumn<ObjectType>] {
        [AnyColumn(column)]
    }

    /// Wraps a single type-erased column in an array for builder consistency.
    ///
    /// Handles expressions that already return `AnyColumn` instances, ensuring
    /// uniform array-based processing throughout the builder pipeline.
    ///
    /// - Parameter column: An already type-erased column
    /// - Returns: Single-element array containing the column
    public static func buildExpression(_ column: AnyColumn<ObjectType>) -> [AnyColumn<ObjectType>] {
        [column]
    }

    /// Passes through pre-built column arrays without modification.
    ///
    /// Handles expressions that return arrays of columns, such as the result
    /// of mapping operations or other programmatic column generation.
    ///
    /// - Parameter columns: An array of type-erased columns
    /// - Returns: The same array without modification
    public static func buildExpression(_ columns: [AnyColumn<ObjectType>])
    -> [AnyColumn<ObjectType>] {
        columns
    }

    /// Handles optional column expressions, converting nil to empty arrays.
    ///
    /// Enables conditional column inclusion where expressions might evaluate to nil.
    /// This is particularly useful for dynamic column configuration based on
    /// optional properties or runtime conditions.
    ///
    /// - Parameter column: Optional typed column that might be nil
    /// - Returns: Single-element array if column exists, empty array if nil
    public static func buildExpression(_ column: Column<
        ObjectType,
        some Any,
        some ColumnOutputTypeProtocol
    >?) -> [AnyColumn<ObjectType>] {
        column.map { [AnyColumn($0)] } ?? []
    }

    /// Handles optional components from `if` statements without `else` clauses.
    ///
    /// When an `if` condition evaluates to false and no `else` branch exists,
    /// this method provides an empty array to maintain builder consistency.
    ///
    /// - Parameter component: Optional column array from conditional expression
    /// - Returns: The array if present, empty array if nil
    public static func buildOptional(_ component: [AnyColumn<ObjectType>]?)
    -> [AnyColumn<ObjectType>] {
        component ?? []
    }

    /// Handles the `if` branch of `if-else` conditional expressions.
    ///
    /// When an `if-else` condition evaluates to true, this method passes through
    /// the columns from the `if` branch unchanged.
    ///
    /// - Parameter component: Column array from the true branch
    /// - Returns: The same column array without modification
    public static func buildEither(first component: [AnyColumn<ObjectType>])
    -> [AnyColumn<ObjectType>] {
        component
    }

    /// Handles the `else` branch of `if-else` conditional expressions.
    ///
    /// When an `if-else` condition evaluates to false, this method passes through
    /// the columns from the `else` branch unchanged.
    ///
    /// - Parameter component: Column array from the false branch
    /// - Returns: The same column array without modification
    public static func buildEither(second component: [AnyColumn<ObjectType>])
    -> [AnyColumn<ObjectType>] {
        component
    }

    /// Flattens arrays from loop expressions and programmatic column generation.
    ///
    /// Handles `for` loops and other expressions that produce arrays of column arrays,
    /// flattening them into a single array while preserving order.
    ///
    /// - Parameter components: Array of column arrays from loop or mapping expressions
    /// - Returns: Flattened array containing all columns in original order
    public static func buildArray(_ components: [[AnyColumn<ObjectType>]])
    -> [AnyColumn<ObjectType>] {
        components.flatMap(\.self)
    }

    /// Produces the final column array result from the builder expression.
    ///
    /// This method is called last in the builder pipeline, providing an opportunity
    /// for final processing or validation. Currently implemented as a pass-through.
    ///
    /// - Parameter component: The combined column array from all builder expressions
    /// - Returns: The final column array ready for use
    public static func buildFinalResult(_ component: [AnyColumn<ObjectType>])
    -> [AnyColumn<ObjectType>] {
        component
    }
}
