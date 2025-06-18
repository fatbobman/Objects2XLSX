//
// ColumnTypeConfig.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A protocol that defines the configuration of a column type.
///
/// `ColumnTypeConfig` is a protocol that defines the configuration of a column type.
/// This protocol provides a way to create a column type with a default value and a config using type-safe methods.
public protocol ColumnTypeConfig: Equatable, Sendable {
    /// The type of the value of the column type.
    associatedtype ValueType
    /// The value of the column type.
    var value: ValueType? { get }
}

/// A structure that represents the configuration of a column type for Bool values.
///
/// `BoolColumnConfig` is a structure that represents the configuration of a column type for Bool values.
/// It provides a way to create a column type for Bool values with a default value and a config.
public struct BoolColumnConfig: ColumnTypeConfig {
    /// The value of the column type.
    public let value: Bool?
    /// The boolean expressions of the column type.
    public let booleanExpressions: Cell.BooleanExpressions
    /// The case strategy of the column type.
    public let caseStrategy: Cell.CaseStrategy

    /// Creates a BoolColumnConfig with the given value, boolean expressions, and case strategy.
    ///
    /// - Parameter value: The value of the column type.
    /// - Parameter booleanExpressions: The boolean expressions of the column type.
    /// - Parameter caseStrategy: The case strategy of the column type.
    public init(
        value: Bool?,
        booleanExpressions: Cell.BooleanExpressions = .trueAndFalse,
        caseStrategy: Cell.CaseStrategy = .upper)
    {
        self.value = value
        self.booleanExpressions = booleanExpressions
        self.caseStrategy = caseStrategy
    }
}

/// A structure that represents the configuration of a column type for Double values.
///
/// `DoubleColumnConfig` is a structure that represents the configuration of a column type for Double values.
/// It provides a way to create a column type for Double values with a default value.
public struct DoubleColumnConfig: ColumnTypeConfig {
    /// The value of the column type.
    public let value: Double?

    /// Creates a DoubleColumnConfig with the given value.
    ///
    /// - Parameter value: The value of the column type.
    public init(value: Double?) {
        self.value = value
    }
}

/// A structure that represents the configuration of a column type for Int values.
///
/// `IntColumnConfig` is a structure that represents the configuration of a column type for Int values.
/// It provides a way to create a column type for Int values with a default value.
public struct IntColumnConfig: ColumnTypeConfig {
    /// The value of the column type.
    public let value: Int?

    /// Creates an IntColumnConfig with the given value.
    ///
    /// - Parameter value: The value of the column type.
    public init(value: Int?) {
        self.value = value
    }
}

/// A structure that represents the configuration of a column type for String values.
///
/// `TextColumnConfig` is a structure that represents the configuration of a column type for String values.
/// It provides a way to create a column type for String values with a default value.
public struct TextColumnConfig: ColumnTypeConfig {
    /// The value of the column type.
    public let value: String?

    /// Creates a TextColumnConfig with the given value.
    ///
    /// - Parameter value: The value of the column type.
    public init(value: String?) {
        self.value = value
    }
}

/// A structure that represents the configuration of a column type for Date values.
///
/// `DateColumnConfig` is a structure that represents the configuration of a column type for Date values.
/// It provides a way to create a column type for Date values with a default value and a time zone.
public struct DateColumnConfig: ColumnTypeConfig {
    /// The value of the column type.
    public let value: Date?
    /// The time zone of the column type.
    public let timeZone: TimeZone

    /// Creates a DateColumnConfig with the given value and time zone.
    ///
    /// - Parameter value: The value of the column type.
    /// - Parameter timeZone: The time zone of the column type. Defaults to the current time zone.
    public init(value: Date?, timeZone: TimeZone = TimeZone.current) {
        self.value = value
        self.timeZone = timeZone
    }
}

/// A structure that represents the configuration of a column type for URL values.
///
/// `URLColumnConfig` is a structure that represents the configuration of a column type for URL values.
/// It provides a way to create a column type for URL values with a default value.
public struct URLColumnConfig: ColumnTypeConfig {
    /// The value of the column type.
    public let value: URL?

    /// Creates a URLColumnConfig with the given value.
    ///
    /// - Parameter value: The value of the column type.
    public init(value: URL?) {
        self.value = value
    }
}

/// A structure that represents the configuration of a column type for Percentage values.
///
/// `PercentageColumnConfig` is a structure that represents the configuration of a column type for Percentage values.
/// It provides a way to create a column type for Percentage values with a default value and precision.
public struct PercentageColumnConfig: ColumnTypeConfig {
    /// The value of the column type.
    public let value: Double?
    /// The precision of the percentage value.
    public let precision: Int

    /// Creates a PercentageColumnConfig with the given value and precision.
    ///
    /// - Parameter value: The value of the column type.
    /// - Parameter precision: The precision of the percentage value. Defaults to 2.
    public init(value: Double?, precision: Int = 2) {
        self.value = value
        self.precision = precision
    }
}
