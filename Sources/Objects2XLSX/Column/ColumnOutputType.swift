//
// ColumnOutputType.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents a column output type for Double values.
///
/// `DoubleColumnType` is a structure that represents a column output type for Double values.
/// It provides a way to create a column output type for Double values with a default value and a config.
public struct DoubleColumnType: ColumnOutputTypeProtocol {
    /// The config of the column output type.
    public let config: DoubleColumnConfig

    /// Creates a DoubleColumnType with the given config.
    ///
    /// - Parameter config: The config of the column output type.
    public init(_ config: DoubleColumnConfig) {
        self.config = config
    }

    /// The cell type of the column output type.
    public var cellType: Cell.CellType {
        .double(config.value)
    }

    /// Creates a DoubleColumnType with the given default value and config.
    ///
    /// - Parameter value: The default value of the column output type.
    /// - Parameter config: The config of the column output type.
    /// - Returns: A DoubleColumnType with the given default value and config.
    public static func withDefaultValue(_ value: Double, config: DoubleColumnConfig) -> Self {
        DoubleColumnType(DoubleColumnConfig(value: value))
    }
}

/// A structure that represents a column output type for Int values.
///
/// `IntColumnType` is a structure that represents a column output type for Int values.
/// It provides a way to create a column output type for Int values with a default value and a config.
public struct IntColumnType: ColumnOutputTypeProtocol {
    /// The config of the column output type.
    public let config: IntColumnConfig

    /// Creates an IntColumnType with the given config.
    ///
    /// - Parameter config: The config of the column output type.
    public init(_ config: IntColumnConfig) {
        self.config = config
    }

    /// The cell type of the column output type.
    public var cellType: Cell.CellType {
        .int(config.value)
    }

    /// Creates an IntColumnType with the given default value and config.
    ///
    /// - Parameter value: The default value of the column output type.
    /// - Parameter config: The config of the column output type.
    /// - Returns: An IntColumnType with the given default value and config.
    public static func withDefaultValue(_ value: Int, config: IntColumnConfig) -> Self {
        IntColumnType(IntColumnConfig(value: value))
    }
}

/// A structure that represents a column output type for Text values.
///
/// `TextColumnType` is a structure that represents a column output type for Text values.
/// It provides a way to create a column output type for Text values with a default value and a config.
public struct TextColumnType: ColumnOutputTypeProtocol {
    /// The config of the column output type.
    public let config: TextColumnConfig

    /// Creates a TextColumnType with the given config.
    ///
    /// - Parameter config: The config of the column output type.
    public init(_ config: TextColumnConfig) {
        self.config = config
    }

    /// The cell type of the column output type.
    public var cellType: Cell.CellType {
        .string(config.value)
    }

    /// Creates a TextColumnType with the given default value and config.
    ///
    /// - Parameter value: The default value of the column output type.
    /// - Parameter config: The config of the column output type.
    /// - Returns: A TextColumnType with the given default value and config.
    public static func withDefaultValue(_ value: String, config: TextColumnConfig) -> Self {
        TextColumnType(TextColumnConfig(value: value))
    }
}

/// A structure that represents a column output type for Date values.
///
/// `DateColumnType` is a structure that represents a column output type for Date values.
/// It provides a way to create a column output type for Date values with a default value and a config.
public struct DateColumnType: ColumnOutputTypeProtocol {
    /// The config of the column output type.
    public let config: DateColumnConfig

    /// Creates a DateColumnType with the given config.
    ///
    /// - Parameter config: The config of the column output type.
    public init(_ config: DateColumnConfig) {
        self.config = config
    }

    /// The cell type of the column output type.
    public var cellType: Cell.CellType {
        .date(config.value, timeZone: config.timeZone)
    }

    /// Creates a DateColumnType with the given default value and config.
    ///
    /// - Parameter value: The default value of the column output type.
    /// - Parameter config: The config of the column output type.
    /// - Returns: A DateColumnType with the given default value and config.
    public static func withDefaultValue(_ value: Date, config: DateColumnConfig) -> Self {
        DateColumnType(DateColumnConfig(value: value, timeZone: config.timeZone))
    }
}

/// A structure that represents a column output type for Bool values.
///
/// `BoolColumnType` is a structure that represents a column output type for Bool values.
/// It provides a way to create a column output type for Bool values with a default value and a config.
public struct BoolColumnType: ColumnOutputTypeProtocol {
    /// The config of the column output type.
    public let config: BoolColumnConfig

    /// Creates a BoolColumnType with the given config.
    ///
    /// - Parameter config: The config of the column output type.
    public init(_ config: BoolColumnConfig) {
        self.config = config
    }

    /// The cell type of the column output type.
    public var cellType: Cell.CellType {
        .boolean(
            config.value,
            booleanExpressions: config.booleanExpressions,
            caseStrategy: config.caseStrategy)
    }

    /// Creates a BoolColumnType with the given default value and config.
    ///
    /// - Parameter value: The default value of the column output type.
    /// - Parameter config: The config of the column output type.
    /// - Returns: A BoolColumnType with the given default value and config.
    public static func withDefaultValue(_ value: Bool, config: BoolColumnConfig) -> Self {
        BoolColumnType(BoolColumnConfig(
            value: value,
            booleanExpressions: config.booleanExpressions,
            caseStrategy: config.caseStrategy))
    }
}

/// A structure that represents a column output type for URL values.
///
/// `URLColumnType` is a structure that represents a column output type for URL values.
/// It provides a way to create a column output type for URL values with a default value and a config.
public struct URLColumnType: ColumnOutputTypeProtocol {
    /// The config of the column output type.
    public let config: URLColumnConfig

    /// Creates a URLColumnType with the given config.
    ///
    /// - Parameter config: The config of the column output type.
    public init(_ config: URLColumnConfig) {
        self.config = config
    }

    /// The cell type of the column output type.
    public var cellType: Cell.CellType {
        .url(config.value)
    }

    /// Creates a URLColumnType with the given default value and config.
    ///
    /// - Parameter value: The default value of the column output type.
    /// - Parameter config: The config of the column output type.
    /// - Returns: A URLColumnType with the given default value and config.
    public static func withDefaultValue(_ value: URL, config: URLColumnConfig) -> Self {
        URLColumnType(URLColumnConfig(value: value))
    }
}

/// A structure that represents a column output type for Percentage values.
///
/// `PercentageColumnType` is a structure that represents a column output type for Percentage values.
/// It provides a way to create a column output type for Percentage values with a default value and a config.
public struct PercentageColumnType: ColumnOutputTypeProtocol {
    /// The config of the column output type.
    public let config: PercentageColumnConfig

    /// Creates a PercentageColumnType with the given config.
    ///
    /// - Parameter config: The config of the column output type.
    public init(_ config: PercentageColumnConfig) {
        self.config = config
    }

    /// The cell type of the column output type.
    public var cellType: Cell.CellType {
        .percentage(config.value, precision: config.precision)
    }

    /// Creates a PercentageColumnType with the given default value and config.
    ///
    /// - Parameter value: The default value of the column output type.
    /// - Parameter config: The config of the column output type.
    /// - Returns: A PercentageColumnType with the given default value and config.
    public static func withDefaultValue(_ value: Double, config: PercentageColumnConfig) -> Self {
        PercentageColumnType(PercentageColumnConfig(value: value, precision: config.precision))
    }
}
