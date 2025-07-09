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

extension ColumnOutputTypeProtocol where Self == TextColumnType {
    /// Creates a TextColumnType from a non-optional String value.
    ///
    /// This convenience factory method provides a cleaner syntax for creating
    /// text column types in custom mappings.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Status", keyPath: \.status) { status in
    ///     .string(status.rawValue.uppercased())
    /// }
    /// ```
    ///
    /// - Parameter text: The non-optional String value to display in the cell
    /// - Returns: A configured TextColumnType instance
    public static func string(_ text: String) -> TextColumnType {
        .init(TextColumnConfig(value: text))
    }
}

extension ColumnOutputTypeProtocol where Self == DateColumnType {
    /// Creates a DateColumnType from a non-optional Date value with timezone configuration.
    ///
    /// This convenience factory method simplifies date column creation in custom mappings
    /// while providing timezone control for accurate date representation.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Last Modified", keyPath: \.timestamp) { timestamp in
    ///     .date(timestamp, timeZone: .utc)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - date: The non-optional Date value to display
    ///   - timeZone: The timezone for date interpretation (default: current system timezone)
    /// - Returns: A configured DateColumnType instance
    public static func date(_ date: Date, timeZone: TimeZone = .current) -> DateColumnType {
        .init(DateColumnConfig(value: date, timeZone: timeZone))
    }
}

extension ColumnOutputTypeProtocol where Self == BoolColumnType {
    /// Creates a BoolColumnType from a non-optional Bool value.
    ///
    /// This convenience factory method provides a cleaner syntax for creating
    /// boolean column types in custom mappings. Uses default boolean expressions
    /// and case strategy settings.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Is Premium", keyPath: \.subscriptionLevel) { level in
    ///     .bool(level == .premium)
    /// }
    /// ```
    ///
    /// - Parameter value: The non-optional Bool value to display
    /// - Returns: A configured BoolColumnType instance with default formatting
    public static func bool(_ value: Bool) -> BoolColumnType {
        .init(BoolColumnConfig(value: value))
    }
}

extension ColumnOutputTypeProtocol where Self == URLColumnType {
    /// Creates a URLColumnType from a non-optional URL value.
    ///
    /// This convenience factory method provides a cleaner syntax for creating
    /// URL column types in custom mappings. URLs are displayed as their absolute
    /// string representation.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Documentation", keyPath: \.productId) { id in
    ///     .url(URL(string: "https://docs.example.com/\(id)")!)
    /// }
    /// ```
    ///
    /// - Parameter url: The non-optional URL value to display
    /// - Returns: A configured URLColumnType instance
    public static func url(_ url: URL) -> URLColumnType {
        .init(URLColumnConfig(value: url))
    }
}

extension ColumnOutputTypeProtocol where Self == DoubleColumnType {
    /// Creates a DoubleColumnType from a non-optional Double value.
    ///
    /// This convenience factory method provides a cleaner syntax for creating
    /// numeric column types in custom mappings with floating-point values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Calculated Price", keyPath: \.basePrice) { price in
    ///     .double(price * 1.2)  // Add 20% markup
    /// }
    /// ```
    ///
    /// - Parameter value: The non-optional Double value to display
    /// - Returns: A configured DoubleColumnType instance
    public static func double(_ value: Double) -> DoubleColumnType {
        .init(DoubleColumnConfig(value: value))
    }
}

extension ColumnOutputTypeProtocol where Self == IntColumnType {
    /// Creates an IntColumnType from a non-optional Int value.
    ///
    /// This convenience factory method provides a cleaner syntax for creating
    /// integer column types in custom mappings.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Days Until Due", keyPath: \.dueDate) { date in
    ///     .int(Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0)
    /// }
    /// ```
    ///
    /// - Parameter value: The non-optional Int value to display
    /// - Returns: A configured IntColumnType instance
    public static func int(_ value: Int) -> IntColumnType {
        .init(IntColumnConfig(value: value))
    }
}

extension ColumnOutputTypeProtocol where Self == PercentageColumnType {
    /// Creates a PercentageColumnType from a non-optional Double value with precision control.
    ///
    /// This convenience factory method provides a cleaner syntax for creating
    /// percentage column types in custom mappings. Values should be provided as
    /// decimals (0.5 = 50%).
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Completion", keyPath: \.completed) { completed in
    ///     .percentage(completed / total, precision: 1)  // Shows as "50.0%"
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - value: The non-optional percentage value as decimal (0.5 = 50%)
    ///   - precision: Number of decimal places to display (default: 2)
    /// - Returns: A configured PercentageColumnType instance
    public static func percentage(_ value: Double, precision: Int = 2) -> PercentageColumnType {
        .init(PercentageColumnConfig(value: value, precision: precision))
    }
}

// MARK: - Optional Support

extension ColumnOutputTypeProtocol where Self == TextColumnType {
    /// Creates a TextColumnType from an optional String value.
    ///
    /// This convenience factory method handles optional String values in custom mappings.
    /// Nil values are preserved and can be handled by Column's nilHandling mechanism.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Notes", keyPath: \.metadata) { metadata in
    ///     .string(metadata["notes"])  // Returns String?
    /// }
    /// .defaultValue("No notes")
    /// ```
    ///
    /// - Parameter text: The optional String value to display
    /// - Returns: A configured TextColumnType instance that preserves nil
    public static func string(_ text: String?) -> TextColumnType {
        .init(TextColumnConfig(value: text))
    }
}

extension ColumnOutputTypeProtocol where Self == DoubleColumnType {
    /// Creates a DoubleColumnType from an optional Double value.
    ///
    /// This convenience factory method handles optional numeric values in custom mappings.
    /// Nil values are preserved and can be handled by Column's nilHandling mechanism.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Discount", keyPath: \.couponCode) { code in
    ///     .double(discountMap[code])  // Returns Double?
    /// }
    /// .defaultValue(0.0)
    /// ```
    ///
    /// - Parameter value: The optional Double value to display
    /// - Returns: A configured DoubleColumnType instance that preserves nil
    public static func double(_ value: Double?) -> DoubleColumnType {
        .init(DoubleColumnConfig(value: value))
    }
}

extension ColumnOutputTypeProtocol where Self == IntColumnType {
    /// Creates an IntColumnType from an optional Int value.
    ///
    /// This convenience factory method handles optional integer values in custom mappings.
    /// Nil values are preserved and can be handled by Column's nilHandling mechanism.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Priority", keyPath: \.tags) { tags in
    ///     .int(tags.first { $0.type == .priority }?.value)  // Returns Int?
    /// }
    /// .defaultValue(0)
    /// ```
    ///
    /// - Parameter value: The optional Int value to display
    /// - Returns: A configured IntColumnType instance that preserves nil
    public static func int(_ value: Int?) -> IntColumnType {
        .init(IntColumnConfig(value: value))
    }
}

extension ColumnOutputTypeProtocol where Self == DateColumnType {
    /// Creates a DateColumnType from an optional Date value with timezone configuration.
    ///
    /// This convenience factory method handles optional date values in custom mappings.
    /// Nil values are preserved and can be handled by Column's nilHandling mechanism.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Completed At", keyPath: \.status) { status in
    ///     .date(status.isCompleted ? status.completionDate : nil, timeZone: .utc)
    /// }
    /// .defaultValue(Date())
    /// ```
    ///
    /// - Parameters:
    ///   - date: The optional Date value to display
    ///   - timeZone: The timezone for date interpretation (default: current system timezone)
    /// - Returns: A configured DateColumnType instance that preserves nil
    public static func date(_ date: Date?, timeZone: TimeZone = .current) -> DateColumnType {
        .init(DateColumnConfig(value: date, timeZone: timeZone))
    }
}

extension ColumnOutputTypeProtocol where Self == BoolColumnType {
    /// Creates a BoolColumnType from an optional Bool value.
    ///
    /// This convenience factory method handles optional boolean values in custom mappings.
    /// Nil values are preserved and can be handled by Column's nilHandling mechanism.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Verified", keyPath: \.profile) { profile in
    ///     .bool(profile?.isVerified)  // Returns Bool?
    /// }
    /// .defaultValue(false)
    /// ```
    ///
    /// - Parameter value: The optional Bool value to display
    /// - Returns: A configured BoolColumnType instance that preserves nil
    public static func bool(_ value: Bool?) -> BoolColumnType {
        .init(BoolColumnConfig(value: value))
    }
}

extension ColumnOutputTypeProtocol where Self == URLColumnType {
    /// Creates a URLColumnType from an optional URL value.
    ///
    /// This convenience factory method handles optional URL values in custom mappings.
    /// Nil values are preserved and can be handled by Column's nilHandling mechanism.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Profile Link", keyPath: \.username) { username in
    ///     .url(URL(string: "https://example.com/\(username)"))  // Might fail
    /// }
    /// .defaultValue(URL(string: "https://example.com")!)
    /// ```
    ///
    /// - Parameter url: The optional URL value to display
    /// - Returns: A configured URLColumnType instance that preserves nil
    public static func url(_ url: URL?) -> URLColumnType {
        .init(URLColumnConfig(value: url))
    }
}

extension ColumnOutputTypeProtocol where Self == PercentageColumnType {
    /// Creates a PercentageColumnType from an optional Double value with precision control.
    ///
    /// This convenience factory method handles optional percentage values in custom mappings.
    /// Nil values are preserved and can be handled by Column's nilHandling mechanism.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Success Rate", keyPath: \.metrics) { metrics in
    ///     .percentage(metrics?.successRate, precision: 1)  // Returns Double?
    /// }
    /// .defaultValue(0.0)  // Shows as "0.0%"
    /// ```
    ///
    /// - Parameters:
    ///   - value: The optional percentage value as decimal (0.5 = 50%)
    ///   - precision: Number of decimal places to display (default: 2)
    /// - Returns: A configured PercentageColumnType instance that preserves nil
    public static func percentage(_ value: Double?, precision: Int = 2) -> PercentageColumnType {
        .init(PercentageColumnConfig(value: value, precision: precision))
    }
}
