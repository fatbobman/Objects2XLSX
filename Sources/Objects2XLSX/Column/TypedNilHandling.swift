//
// TypedNilHandling.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Defines strategies for handling nil values in column data extraction and processing.
///
/// `TypedNilHandling` provides type-safe approaches to deal with optional data when
/// generating Excel cells. This is particularly important when working with optional
/// properties or nullable database fields that need predictable Excel representation.
///
/// ## Nil Handling Strategies
/// - **keepEmpty**: Preserves nil as empty Excel cells (most common approach)
/// - **defaultValue**: Substitutes a specified default value when data is nil
///
/// ## Type Safety
/// The generic parameter ensures that default values match the expected output type,
/// preventing runtime type mismatches and providing compile-time validation.
///
/// ## Usage Examples
/// ```swift
/// // Keep nil values as empty cells
/// Column<Person, String?, TextColumnType>(
///     name: "Middle Name",
///     keyPath: \.middleName,
///     nilHandling: .keepEmpty
/// )
///
/// // Substitute default value for nil
/// Column<Product, Double?, DoubleColumnType>(
///     name: "Price",
///     keyPath: \.price,
///     nilHandling: .defaultValue(0.0)
/// )
/// ```
public enum TypedNilHandling<V: ColumnOutputTypeProtocol> {
    /// Preserve nil values as empty Excel cells.
    ///
    /// When the extracted data is nil, the resulting Excel cell will be empty.
    /// This is the most natural approach for optional data and maintains the
    /// distinction between "no data" and "zero/empty data".
    ///
    /// **Excel Behavior**: Empty cells in Excel are truly empty and don't affect
    /// calculations, averages, or other functions unless explicitly included.
    case keepEmpty

    /// Substitute a default value when the extracted data is nil.
    ///
    /// When the extracted data is nil, the specified default value will be used
    /// instead, creating a non-empty Excel cell with predictable content.
    ///
    /// ## Common Default Values by Type
    /// - **String**: `""` (empty string) or `"N/A"`, `"Unknown"`
    /// - **Int**: `0` or `-1` (depending on domain meaning)
    /// - **Double**: `0.0` or `Double.nan` for calculations
    /// - **Bool**: `false` or contextually appropriate default
    /// - **Date**: Current date or epoch date
    /// - **URL**: Placeholder URL or empty URL
    /// - **Percentage**: `0.0` for 0% or `Double.nan`
    ///
    /// - Parameter value: The default value to substitute for nil (must match the column's value type)
    case defaultValue(V.Config.ValueType)
}
