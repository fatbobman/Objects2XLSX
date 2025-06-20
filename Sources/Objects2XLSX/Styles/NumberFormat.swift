//
// NumberFormat.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Comprehensive number formatting system for Excel cells.

 `NumberFormat` provides type-safe access to Excel's number formatting capabilities,
 supporting both built-in Excel formats and custom format specifications. This
 enumeration covers the most commonly used number formats while maintaining
 extensibility for future format types.

 ## Overview

 Excel's number formatting system controls how numeric values are displayed
 in cells, affecting presentation without changing the underlying data. This
 implementation provides Swift-native access to Excel's formatting while
 ensuring compatibility with Excel's format codes and built-in formats.

 ## Supported Formats

 ### Basic Formats
 - **general**: Excel's default format (automatic type detection)
 - **percentage**: Percentage display with customizable decimal precision

 ### Date and Time Formats
 - **date**: Standard date format (yyyy-mm-dd)
 - **time**: Standard time format (hh:mm:ss)
 - **dateTime**: Combined date and time format

 ### Advanced Formats (Future Extensions)
 - **currency**: Currency formatting with locale support
 - **scientific**: Scientific notation for large/small numbers

 ## Usage Examples

 ### Basic Number Formatting
 ```swift
 let generalFormat = NumberFormat.general
 let percentFormat = NumberFormat.percentage(precision: 2)  // 0.00%
 let dateFormat = NumberFormat.date
 ```

 ### Custom Precision
 ```swift
 let lowPrecisionPercent = NumberFormat.percentage(precision: 0)    // 0%
 let highPrecisionPercent = NumberFormat.percentage(precision: 4)   // 0.0000%
 ```

 ## Excel Integration

 Number formats integrate seamlessly with Excel:
 - Built-in format IDs are used when available for maximum compatibility
 - Custom format codes follow Excel's format string specification
 - Format application preserves data while changing display
 - Generated XML follows Excel's numberFormat specification

 ## Format Codes

 The underlying Excel format codes are:
 - **General**: No specific code (Excel default)
 - **Percentage**: "0.00%" pattern with variable precision
 - **Date**: "yyyy-mm-dd" ISO format
 - **Time**: "hh:mm:ss" 24-hour format
 - **DateTime**: "yyyy-mm-dd hh:mm:ss" combined format

 - Note: Format appearance may vary based on Excel version and system locale
 */
public enum NumberFormat: Equatable, Sendable, Hashable, Identifiable {
    /// General format (default).
    case general
    /// Percentage format with specified decimal precision.
    case percentage(precision: Int)
    /// Date format.
    case date
    /// Time format.
    case time
    /// Date and time format.
    case dateTime
    /// Currency format (future extension).
    case currency
    /// Scientific notation format (future extension).
    case scientific

    /// Unique string identifier for the format.
    ///
    /// This identifier is used for hashing, comparison, and internal format
    /// management. Each format type generates a consistent identifier that
    /// includes relevant parameters (like precision for percentages).
    public var id: String {
        switch self {
            case .general:
                "General"
            case let .percentage(precision):
                "Percentage(\(precision))"
            case .date:
                "Date"
            case .time:
                "Time"
            case .dateTime:
                "DateTime"
            case .currency:
                "Currency"
            case .scientific:
                "Scientific"
        }
    }

    /// Excel format code string for custom number formats.
    ///
    /// This property returns the Excel format string that defines how numbers
    /// should be displayed. Built-in formats may return `nil` and rely on
    /// their `builtinId` instead.
    ///
    /// - Returns: Excel format code string, or `nil` for built-in formats
    var formatCode: String? {
        switch self {
            case .general:
                nil // Use Excel default
            case let .percentage(precision):
                "0.\(String(repeating: "0", count: precision))%"
            case .date:
                "yyyy-mm-dd"
            case .time:
                "hh:mm:ss"
            case .dateTime:
                "yyyy-mm-dd hh:mm:ss"
            case .currency:
                "\"$\"#,##0.00"
            case .scientific:
                "0.00E+00"
        }
    }

    /// Built-in Excel format ID for predefined number formats.
    ///
    /// Excel has a set of predefined number formats with specific IDs that
    /// provide optimized performance and guaranteed compatibility. When available,
    /// these IDs are preferred over custom format codes.
    ///
    /// - Returns: Excel built-in format ID, or `nil` for custom formats
    var builtinId: Int? {
        switch self {
            case .date:
                14 // Excel built-in date format (m/d/yyyy)
            case .dateTime:
                22 // Excel built-in date-time format (m/d/yyyy h:mm)
            default:
                nil
        }
    }
}
