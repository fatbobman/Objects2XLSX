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
