//
// Column+OptionalSupport.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// MARK: - Chainable Configuration Methods for Optional Double Columns

extension Column where InputType == Double?, OutputType == DoubleColumnType {
    /// Sets a default value to use when the source property is nil.
    ///
    /// This method transforms an optional Double column into one that uses a specified
    /// default value instead of empty cells for nil values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Salary", keyPath: \.salary)
    ///     .defaultValue(0.0)  // nil salaries become 0.0
    ///     .bodyStyle(currencyStyle)
    /// ```
    ///
    /// - Parameter defaultValue: The Double value to use when the source is nil
    /// - Returns: A new column that replaces nil values with the default value
    public func defaultValue(_ defaultValue: Double) -> Column<ObjectType, Double?, DoubleColumnType> {
        Column<ObjectType, Double?, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: .defaultValue(defaultValue))
    }
}

// MARK: - Chainable Configuration Methods for Optional String Columns

extension Column where InputType == String?, OutputType == TextColumnType {
    /// Sets a default value to use when the source property is nil.
    ///
    /// This method transforms an optional String column into one that uses a specified
    /// default value instead of empty cells for nil values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Description", keyPath: \.description)
    ///     .defaultValue("N/A")  // nil descriptions become "N/A"
    ///     .bodyStyle(textStyle)
    /// ```
    ///
    /// - Parameter defaultValue: The String value to use when the source is nil
    /// - Returns: A new column that replaces nil values with the default value
    public func defaultValue(_ defaultValue: String) -> Column<ObjectType, String?, TextColumnType> {
        Column<ObjectType, String?, TextColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: .defaultValue(defaultValue))
    }
}

// MARK: - Chainable Configuration Methods for Optional Int Columns

extension Column where InputType == Int?, OutputType == IntColumnType {
    /// Sets a default value to use when the source property is nil.
    ///
    /// This method transforms an optional Int column into one that uses a specified
    /// default value instead of empty cells for nil values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Quantity", keyPath: \.quantity)
    ///     .defaultValue(0)  // nil quantities become 0
    ///     .bodyStyle(numericStyle)
    /// ```
    ///
    /// - Parameter defaultValue: The Int value to use when the source is nil
    /// - Returns: A new column that replaces nil values with the default value
    public func defaultValue(_ defaultValue: Int) -> Column<ObjectType, Int?, IntColumnType> {
        Column<ObjectType, Int?, IntColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: .defaultValue(defaultValue))
    }
}

// MARK: - Chainable Configuration Methods for Optional Date Columns

extension Column where InputType == Date?, OutputType == DateColumnType {
    /// Sets a default value to use when the source property is nil.
    ///
    /// This method transforms an optional Date column into one that uses a specified
    /// default value instead of empty cells for nil values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Created Date", keyPath: \.createdDate)
    ///     .defaultValue(Date())  // nil dates become current date
    ///     .bodyStyle(dateStyle)
    ///
    /// Column(name: "Due Date", keyPath: \.dueDate)
    ///     .defaultValue(Calendar.current.date(byAdding: .day, value: 30, to: Date())!)
    /// ```
    ///
    /// - Parameter defaultValue: The Date value to use when the source is nil
    /// - Returns: A new column that replaces nil values with the default value
    public func defaultValue(_ defaultValue: Date) -> Column<ObjectType, Date?, DateColumnType> {
        Column<ObjectType, Date?, DateColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: .defaultValue(defaultValue))
    }
}

// MARK: - Chainable Configuration Methods for Optional URL Columns

extension Column where InputType == URL?, OutputType == URLColumnType {
    /// Sets a default value to use when the source property is nil.
    ///
    /// This method transforms an optional URL column into one that uses a specified
    /// default value instead of empty cells for nil values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Website", keyPath: \.website)
    ///     .defaultValue(URL(string: "https://example.com")!)  // nil URLs become default URL
    ///     .bodyStyle(linkStyle)
    ///
    /// Column(name: "Homepage", keyPath: \.homepage)
    ///     .defaultValue(URL(string: "https://company.com")!)
    /// ```
    ///
    /// - Parameter defaultValue: The URL value to use when the source is nil
    /// - Returns: A new column that replaces nil values with the default value
    public func defaultValue(_ defaultValue: URL) -> Column<ObjectType, URL?, URLColumnType> {
        Column<ObjectType, URL?, URLColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: .defaultValue(defaultValue))
    }
}