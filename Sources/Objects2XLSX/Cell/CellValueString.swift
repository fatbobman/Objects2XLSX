//
// CellValueString.swift
// Created by Xu Yang on 2025-06-14.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Extensions that provide Excel-compatible string conversion for various Swift data types.
///
/// These extensions implement the `cellValueString` property and methods that convert
/// Swift values to their appropriate string representations for Excel storage. Each
/// extension handles the specific formatting requirements and edge cases for its data type.
///
/// ## Key Features
/// - **Type Safety**: Extensions ensure only valid values are converted
/// - **Excel Compatibility**: Output matches Excel's expected format requirements
/// - **Error Handling**: Graceful handling of nil values, infinity, and NaN
/// - **Localization**: Consistent formatting regardless of system locale
///
/// ## Usage in Cell Values
/// These extensions are primarily used by `Cell.CellType.valueString` to convert
/// typed values into the string format required by Excel's XML structure.

extension String? {
    /// Converts an optional string to Excel-compatible cell content.
    ///
    /// Provides a safe conversion where nil values become empty strings,
    /// matching Excel's treatment of empty cells.
    ///
    /// - Returns: The string value, or empty string if nil
    var cellValueString: String {
        self ?? ""
    }
}

extension Double? {
    /// Converts an optional double to Excel-compatible numeric string.
    ///
    /// Handles edge cases that Excel cannot represent:
    /// - `nil` values become empty strings (empty cells)
    /// - `infinity` and `NaN` values become empty strings
    /// - Normal values use standard string conversion
    ///
    /// - Returns: String representation suitable for Excel, or empty string for invalid values
    var cellValueString: String {
        guard let value = self else { return "" }
        if value.isInfinite || value.isNaN {
            return ""
        }
        return String(value)
    }

    /// Converts an optional double to Excel-compatible percentage string with specified precision.
    ///
    /// Formats percentage values for Excel storage, handling precision and rounding
    /// according to Excel's decimal handling requirements. Uses `NSDecimalRound`
    /// for consistent precision control.
    ///
    /// - Parameter precision: Number of decimal places to preserve (default: 2)
    /// - Returns: Decimal string representation for percentage formatting
    func cellValueString(precision: Int = 2) -> String {
        guard let value = self else { return "" }
        if value.isInfinite || value.isNaN {
            return ""
        }

        var decimal = Decimal(value)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, precision + 2, .plain)

        return "\(rounded)"
    }
}

extension Int? {
    /// Converts an optional integer to Excel-compatible numeric string.
    ///
    /// Integers have no special edge cases, so this simply converts the value
    /// to its string representation or returns empty string for nil.
    ///
    /// - Returns: String representation of the integer, or empty string if nil
    var cellValueString: String {
        guard let value = self else { return "" }
        return String(value)
    }
}

extension Date {
    /// Converts a date to Excel's numeric date format.
    ///
    /// Uses Excel's date numbering system where dates are represented as the number
    /// of days since January 1, 1900. The conversion includes timezone handling
    /// and matches Excel's specific date calculation requirements.
    ///
    /// - Parameter timeZone: Timezone for date interpretation (defaults to system timezone)
    /// - Returns: Excel date number as string
    func cellValueString(timeZone: TimeZone = TimeZone.current) -> String {
        excelDate(timeZone: timeZone)
    }
}

extension Date? {
    /// Converts an optional date to Excel's numeric date format.
    ///
    /// Uses Excel's date numbering system where dates are represented as the number
    /// of days since January 1, 1900. The conversion includes timezone handling
    /// and matches Excel's specific date calculation requirements.
    ///
    /// - Parameter timeZone: Timezone for date interpretation (defaults to system timezone)
    /// - Returns: Excel date number as string, or empty string if nil
    func cellValueString(timeZone: TimeZone = TimeZone.current) -> String {
        self?.excelDate(timeZone: timeZone) ?? ""
    }
}

extension Bool? {
    /// Converts an optional boolean to customizable text representation for Excel.
    ///
    /// Since Excel doesn't have a native boolean type, boolean values are stored
    /// as text. This method provides flexible text formatting with various common
    /// boolean representations and case transformations.
    ///
    /// ## Examples
    /// ```swift
    /// true.cellValueString() // "1" (default oneAndZero, upper)
    /// false.cellValueString(.trueAndFalse, .lower) // "false"
    /// true.cellValueString(.yesAndNo, .firstLetterUpper) // "Yes"
    /// ```
    ///
    /// - Parameters:
    ///   - booleanExpressions: Text format for true/false values (default: oneAndZero)
    ///   - caseStrategy: Case transformation to apply (default: upper)
    /// - Returns: Formatted boolean text, or empty string if nil
    func cellValueString(
        booleanExpressions: Cell.BooleanExpressions = .oneAndZero,
        caseStrategy: Cell.CaseStrategy = .upper) -> String
    {
        guard let value = self else { return "" }
        return caseStrategy.apply(
            to: value ? booleanExpressions.trueString : booleanExpressions.falseString)
    }
}

extension URL? {
    /// Converts an optional URL to its absolute string representation for Excel.
    ///
    /// URLs are stored as text in Excel cells, using their complete absolute string
    /// representation including scheme, host, path, and query parameters.
    ///
    /// - Returns: Absolute URL string, or empty string if nil
    var cellValueString: String {
        self?.absoluteString ?? ""
    }
}

// MARK: - XML Escaping Extension

extension String {
    /// Escapes XML special characters to prevent parsing errors in Excel XML.
    ///
    /// Converts characters that have special meaning in XML to their entity equivalents,
    /// ensuring that cell content doesn't break the XML structure of the XLSX file.
    ///
    /// ## Escaped Characters
    /// - `&` → `&amp;` (must be first to avoid double-escaping)
    /// - `<` → `&lt;` (prevents XML tag interpretation)
    /// - `>` → `&gt;` (prevents XML tag interpretation)
    /// - `"` → `&quot;` (prevents attribute value termination)
    /// - `'` → `&apos;` (prevents attribute value termination)
    ///
    /// - Returns: String with XML special characters properly escaped
    var xmlEscaped: String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
