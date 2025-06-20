//
// ColumnOutPutTypeProtocol.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Defines the contract for column output types that convert data to Excel-compatible cell values.
///
/// `ColumnOutputTypeProtocol` establishes the interface between typed column data and Excel's
/// cell value system. Each conforming type represents a specific way of formatting and presenting
/// data in Excel cells, from simple text and numbers to complex date and percentage formats.
///
/// ## Core Responsibilities
/// - **Type Safety**: Associates each output type with a specific configuration type
/// - **Cell Conversion**: Provides transformation to `Cell.CellType` for Excel serialization
/// - **Default Handling**: Supports default value substitution for nil handling strategies
/// - **Configuration Management**: Encapsulates formatting and display options
///
/// ## Implementation Pattern
/// Conforming types typically follow this pattern:
/// ```swift
/// public struct MyColumnType: ColumnOutputTypeProtocol {
///     public let config: MyColumnConfig
///
///     public var cellType: Cell.CellType {
///         // Convert config to appropriate Cell.CellType
///     }
///
///     public static func withDefaultValue(_ value: ValueType, config: MyColumnConfig) -> Self {
///         // Create instance with substituted value
///     }
/// }
/// ```
///
/// ## Provided Implementations
/// The framework includes implementations for common data types:
/// - `TextColumnType` for strings
/// - `DoubleColumnType` and `IntColumnType` for numbers
/// - `DateColumnType` for dates with timezone support
/// - `BoolColumnType` for booleans with configurable representations
/// - `URLColumnType` for web addresses
/// - `PercentageColumnType` for percentage values with precision control
public protocol ColumnOutputTypeProtocol: Sendable, Equatable {
    /// The configuration type that defines formatting and display options for this output type
    associatedtype Config: ColumnTypeConfig

    /// The configuration instance containing formatting parameters and the source value
    var config: Config { get }

    /// Converts this output type to an Excel-compatible cell value for serialization
    var cellType: Cell.CellType { get }

    /// Creates a new instance with a default value, used by nil handling strategies.
    ///
    /// This method enables the substitution of default values when the original data is nil.
    /// It creates a new instance using the provided default value while preserving the
    /// original configuration's formatting and display options.
    ///
    /// - Parameters:
    ///   - value: The default value to substitute for nil
    ///   - config: The original configuration to preserve formatting options
    /// - Returns: New instance with the default value and preserved configuration
    static func withDefaultValue(_ value: Config.ValueType, config: Config) -> Self
}
