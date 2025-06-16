//
// TypedNilHandling.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents the handling of nil values for a column type.
///
/// `TypedNilHandling` is a structure that represents the handling of nil values for a column type.
/// It provides a way to handle nil values for a column type with a default value.
public enum TypedNilHandling<V: ColumnOutputTypeProtocol> {
    /// Keep empty values, and Excel will display empty cells.
    case keepEmpty
    /// Use the default value, and Excel will display the default value.
    ///
    /// For example:
    /// - 'none' for String type if the default value is nil.
    /// - true for Bool type if the default value is nil.
    /// - 0 for Int type if the default value is nil.
    /// - 0.0 for Double type if the default value is nil.
    /// - 0.0 for Percentage type if the default value is nil.
    /// - specific date for Date type if the default value is nil.
    /// - specific URL for URL type if the default value is nil.
    ///
    /// - Parameter value: The default value of the column type.
    case defaultValue(V.Config.ValueType)
}
