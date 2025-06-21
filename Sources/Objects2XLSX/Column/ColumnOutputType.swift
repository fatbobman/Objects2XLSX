//
// ColumnOutputType.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Concrete implementations of column output types for common data types.
///
/// This file provides ready-to-use column output types that handle the most common
/// data conversion scenarios in Excel generation. Each type encapsulates the logic
/// for converting Swift values to appropriate Excel cell representations.

/// Column output type for floating-point numeric values.
///
/// `DoubleColumnType` handles the conversion of `Double` values to Excel's numeric
/// cell format. It preserves the full precision of floating-point numbers and
/// renders them using Excel's default numeric formatting.
///
/// ## Usage Example
/// ```swift
/// Column<Product, Double, DoubleColumnType>(name: "Price", keyPath: \.price)
/// Column<Measurement, Double?, DoubleColumnType>(name: "Weight", keyPath: \.weight)
/// ```
public struct DoubleColumnType: ColumnOutputTypeProtocol {
    /// Configuration containing the Double value and formatting options
    public let config: DoubleColumnConfig

    /// Creates a DoubleColumnType with the specified configuration.
    ///
    /// - Parameter config: Configuration containing the Double value
    public init(_ config: DoubleColumnConfig) {
        self.config = config
    }

    /// Converts the Double value to Excel's numeric cell type.
    ///
    /// Returns an appropriate double cell type that Excel will render as a number
    /// with appropriate precision and formatting.
    /// Uses `.doubleValue()` for non-nil values and `.optionalDouble()` for optional values.
    public var cellType: Cell.CellType {
        if let value = config.value {
            .doubleValue(value)
        } else {
            .optionalDouble(config.value)
        }
    }

    /// Creates a DoubleColumnType with a substituted default value for nil handling.
    ///
    /// This method only substitutes the default value when the original config value is nil.
    /// If the original config has a non-nil value, that value is preserved.
    ///
    /// - Parameters:
    ///   - value: The default Double value to use instead of nil
    ///   - config: Original configuration containing the actual value (may be nil)
    /// - Returns: New DoubleColumnType with original value if non-nil, otherwise default value
    public static func withDefaultValue(_ value: Double, config: DoubleColumnConfig) -> Self {
        DoubleColumnType(DoubleColumnConfig(value: config.value ?? value))
    }
}

/// Column output type for integer numeric values.
///
/// `IntColumnType` handles the conversion of `Int` values to Excel's numeric
/// cell format. Integers are displayed without decimal places and support
/// the full range of Swift's Int type.
///
/// ## Usage Example
/// ```swift
/// Column<Person, Int, IntColumnType>(name: "Age", keyPath: \.age)
/// Column<Order, Int?, IntColumnType>(name: "Quantity", keyPath: \.quantity)
/// ```
public struct IntColumnType: ColumnOutputTypeProtocol {
    /// Configuration containing the Int value and formatting options
    public let config: IntColumnConfig

    /// Creates an IntColumnType with the specified configuration.
    ///
    /// - Parameter config: Configuration containing the Int value
    public init(_ config: IntColumnConfig) {
        self.config = config
    }

    /// Converts the Int value to Excel's numeric cell type.
    ///
    /// Returns an appropriate int cell type that Excel will render as a whole number.
    /// Uses `.intValue()` for non-nil values and `.optionalInt()` for optional values.
    public var cellType: Cell.CellType {
        if let value = config.value {
            .intValue(value)
        } else {
            .optionalInt(config.value)
        }
    }

    /// Creates an IntColumnType with a substituted default value for nil handling.
    ///
    /// This method only substitutes the default value when the original config value is nil.
    /// If the original config has a non-nil value, that value is preserved.
    ///
    /// - Parameters:
    ///   - value: The default Int value to use instead of nil
    ///   - config: Original configuration containing the actual value (may be nil)
    /// - Returns: New IntColumnType with original value if non-nil, otherwise default value
    public static func withDefaultValue(_ value: Int, config: IntColumnConfig) -> Self {
        IntColumnType(IntColumnConfig(value: config.value ?? value))
    }
}

/// Column output type for text string values.
///
/// `TextColumnType` handles the conversion of `String` values to Excel's text
/// cell format. Text values support Unicode content and can be optimized
/// through shared string storage for memory efficiency.
///
/// ## Usage Example
/// ```swift
/// Column<Person, String, TextColumnType>(name: "Full Name", keyPath: \.fullName)
/// Column<Product, String?, TextColumnType>(name: "Description", keyPath: \.description)
/// ```
public struct TextColumnType: ColumnOutputTypeProtocol {
    /// Configuration containing the String value and formatting options
    public let config: TextColumnConfig

    /// Creates a TextColumnType with the specified configuration.
    ///
    /// - Parameter config: Configuration containing the String value
    public init(_ config: TextColumnConfig) {
        self.config = config
    }

    /// Converts the String value to Excel's text cell type.
    ///
    /// Returns an appropriate string cell type that Excel will render as text.
    /// Uses `.stringValue()` for non-nil values and `.optionalString()` for optional values.
    public var cellType: Cell.CellType {
        if let value = config.value {
            .stringValue(value)
        } else {
            .optionalString(config.value)
        }
    }

    /// Creates a TextColumnType with a substituted default value for nil handling.
    ///
    /// This method only substitutes the default value when the original config value is nil.
    /// If the original config has a non-nil value, that value is preserved.
    ///
    /// - Parameters:
    ///   - value: The default String value to use instead of nil
    ///   - config: Original configuration containing the actual value (may be nil)
    /// - Returns: New TextColumnType with original value if non-nil, otherwise default value
    public static func withDefaultValue(_ value: String, config: TextColumnConfig) -> Self {
        TextColumnType(TextColumnConfig(value: config.value ?? value))
    }
}

/// Column output type for date and time values.
///
/// `DateColumnType` handles the conversion of `Date` values to Excel's numeric
/// date format with proper timezone handling. Dates are converted to Excel's
/// day-based numbering system for accurate date and time representation.
///
/// ## Usage Example
/// ```swift
/// Column<Event, Date, DateColumnType>(name: "Start Date", keyPath: \.startDate)
/// Column<Task, Date?, DateColumnType>(name: "Due Date", keyPath: \.dueDate, timeZone: .utc)
/// ```
public struct DateColumnType: ColumnOutputTypeProtocol {
    /// Configuration containing the Date value and timezone settings
    public let config: DateColumnConfig

    /// Creates a DateColumnType with the specified configuration.
    ///
    /// - Parameter config: Configuration containing the Date value and timezone
    public init(_ config: DateColumnConfig) {
        self.config = config
    }

    /// Converts the Date value to Excel's date cell type.
    ///
    /// Returns an appropriate date cell type that Excel will render with date formatting.
    /// Uses `.dateValue()` for non-nil values and `.optionalDate()` for optional values.
    public var cellType: Cell.CellType {
        if let value = config.value {
            .dateValue(value, timeZone: config.timeZone)
        } else {
            .optionalDate(config.value, timeZone: config.timeZone)
        }
    }

    /// Creates a DateColumnType with a substituted default value for nil handling.
    ///
    /// This method only substitutes the default value when the original config value is nil.
    /// If the original config has a non-nil value, that value is preserved.
    ///
    /// - Parameters:
    ///   - value: The default Date value to use instead of nil
    ///   - config: Original configuration containing the actual value (may be nil)
    /// - Returns: New DateColumnType with original value if non-nil, otherwise default value
    public static func withDefaultValue(_ value: Date, config: DateColumnConfig) -> Self {
        DateColumnType(DateColumnConfig(value: config.value ?? value, timeZone: config.timeZone))
    }
}

/// Column output type for boolean values with customizable text representation.
///
/// `BoolColumnType` handles the conversion of `Bool` values to Excel's text
/// cell format since Excel doesn't have a native boolean type. It supports
/// various boolean representations (TRUE/FALSE, 1/0, Yes/No, etc.) with
/// configurable case formatting.
///
/// ## Usage Example
/// ```swift
/// Column<Task, Bool, BoolColumnType>(name: "Complete", keyPath: \.isComplete)
/// Column<User, Bool?, BoolColumnType>(
///     name: "Active",
///     keyPath: \.isActive,
///     booleanExpressions: .yesAndNo,
///     caseStrategy: .firstLetterUpper
/// )
/// ```
public struct BoolColumnType: ColumnOutputTypeProtocol {
    /// Configuration containing the Bool value and text formatting options
    public let config: BoolColumnConfig

    /// Creates a BoolColumnType with the specified configuration.
    ///
    /// - Parameter config: Configuration containing the Bool value and formatting options
    public init(_ config: BoolColumnConfig) {
        self.config = config
    }

    /// Converts the Bool value to Excel's boolean cell type.
    ///
    /// Returns an appropriate boolean cell type that Excel will render as text.
    /// Uses `.booleanValue()` for non-nil values and `.optionalBoolean()` for optional values.
    public var cellType: Cell.CellType {
        if let value = config.value {
            .booleanValue(
                value,
                booleanExpressions: config.booleanExpressions,
                caseStrategy: config.caseStrategy)
        } else {
            .optionalBoolean(
                config.value,
                booleanExpressions: config.booleanExpressions,
                caseStrategy: config.caseStrategy)
        }
    }

    /// Creates a BoolColumnType with a substituted default value for nil handling.
    ///
    /// This method only substitutes the default value when the original config value is nil.
    /// If the original config has a non-nil value, that value is preserved.
    ///
    /// - Parameters:
    ///   - value: The default Bool value to use instead of nil
    ///   - config: Original configuration containing the actual value (may be nil)
    /// - Returns: New BoolColumnType with original value if non-nil, otherwise default value
    public static func withDefaultValue(_ value: Bool, config: BoolColumnConfig) -> Self {
        BoolColumnType(BoolColumnConfig(
            value: config.value ?? value,
            booleanExpressions: config.booleanExpressions,
            caseStrategy: config.caseStrategy))
    }
}

/// Column output type for URL values stored as text.
///
/// `URLColumnType` handles the conversion of `URL` values to Excel's text
/// cell format using their absolute string representation. URLs are stored
/// as text and can benefit from shared string optimization.
///
/// ## Usage Example
/// ```swift
/// Column<Website, URL, URLColumnType>(name: "Homepage", keyPath: \.url)
/// Column<Article, URL?, URLColumnType>(name: "Source", keyPath: \.sourceURL)
/// ```
public struct URLColumnType: ColumnOutputTypeProtocol {
    /// Configuration containing the URL value and formatting options
    public let config: URLColumnConfig

    /// Creates a URLColumnType with the specified configuration.
    ///
    /// - Parameter config: Configuration containing the URL value
    public init(_ config: URLColumnConfig) {
        self.config = config
    }

    /// Converts the URL value to Excel's URL cell type.
    ///
    /// Returns an appropriate URL cell type that Excel will render as text.
    /// Uses `.urlValue()` for non-nil values and `.optionalURL()` for optional values.
    public var cellType: Cell.CellType {
        if let value = config.value {
            .urlValue(value)
        } else {
            .optionalURL(config.value)
        }
    }

    /// Creates a URLColumnType with a substituted default value for nil handling.
    ///
    /// This method only substitutes the default value when the original config value is nil.
    /// If the original config has a non-nil value, that value is preserved.
    ///
    /// - Parameters:
    ///   - value: The default URL value to use instead of nil
    ///   - config: Original configuration containing the actual value (may be nil)
    /// - Returns: New URLColumnType with original value if non-nil, otherwise default value
    public static func withDefaultValue(_ value: URL, config: URLColumnConfig) -> Self {
        URLColumnType(URLColumnConfig(value: config.value ?? value))
    }
}

/// Column output type for percentage values with configurable precision.
///
/// `PercentageColumnType` handles the conversion of `Double` values to Excel's
/// percentage format. Values should be provided as decimals (0.5 = 50%) and
/// the precision parameter controls the number of decimal places displayed.
///
/// ## Usage Example
/// ```swift
/// Column<Score, Double, PercentageColumnType>(name: "Accuracy", keyPath: \.accuracy, precision: 1)
/// Column<Report, Double?, PercentageColumnType>(name: "Growth", keyPath: \.growthRate, precision: 2)
/// ```
public struct PercentageColumnType: ColumnOutputTypeProtocol {
    /// Configuration containing the percentage value and precision settings
    public let config: PercentageColumnConfig

    /// Creates a PercentageColumnType with the specified configuration.
    ///
    /// - Parameter config: Configuration containing the percentage value and precision
    public init(_ config: PercentageColumnConfig) {
        self.config = config
    }

    /// Converts the percentage value to Excel's percentage cell type.
    ///
    /// Returns an appropriate percentage cell type that Excel will render with percentage formatting.
    /// Uses `.percentageValue()` for non-nil values and `.optionalPercentage()` for optional values.
    public var cellType: Cell.CellType {
        if let value = config.value {
            .percentageValue(value, precision: config.precision)
        } else {
            .optionalPercentage(config.value, precision: config.precision)
        }
    }

    /// Creates a PercentageColumnType with a substituted default value for nil handling.
    ///
    /// This method only substitutes the default value when the original config value is nil.
    /// If the original config has a non-nil value, that value is preserved.
    ///
    /// - Parameters:
    ///   - value: The default percentage value to use instead of nil (as decimal)
    ///   - config: Original configuration containing the actual value (may be nil)
    /// - Returns: New PercentageColumnType with original value if non-nil, otherwise default value
    public static func withDefaultValue(_ value: Double, config: PercentageColumnConfig) -> Self {
        PercentageColumnType(PercentageColumnConfig(value: config.value ?? value, precision: config.precision))
    }
}
