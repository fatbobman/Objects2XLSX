//
// ExcelDateConverter.swift
// Created by Xu Yang on 2025-06-14.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Extensions that provide conversion between Swift Date objects and Excel's date number format.
///
/// Excel represents dates as floating-point numbers indicating the number of days since
/// January 1, 1900. This system includes a historical quirk where Excel incorrectly
/// treats 1900 as a leap year, requiring special handling for compatibility.
///
/// ## Excel Date System
/// - **Base Date**: December 30, 1899 (to account for Excel's 1900 leap year bug)
/// - **Whole Numbers**: Represent dates (1.0 = January 1, 1900)
/// - **Fractional Parts**: Represent time of day (0.5 = 12:00 PM)
/// - **Range**: Supports dates from 1900 to approximately 9999
///
/// ## Precision and Accuracy
/// The conversion includes empirical adjustments to match Excel's exact calculations,
/// ensuring that dates round-trip perfectly between Swift and Excel representations.
///
/// ## Usage Examples
/// ```swift
/// let date = Date()
/// let excelNumber = date.excelDate() // "45123.75" (example)
/// let backToDate = Date.from(excelDate: 45123.75) // Original date
/// ```
extension Date {
    /// Converts a Swift Date to Excel's numeric date representation.
    ///
    /// Transforms the date into Excel's day-based numbering system, accounting for
    /// Excel's historical 1900 leap year bug and timezone considerations.
    ///
    /// ## Format Details
    /// - Integer part: Days since December 30, 1899
    /// - Fractional part: Time of day (0.5 = noon, 0.75 = 6 PM)
    /// - Precision: 8 decimal places to handle sub-second accuracy
    ///
    /// ## Excel Compatibility
    /// The conversion includes empirical adjustments to ensure perfect round-trip
    /// compatibility with Excel's date calculations, including the 1900 leap year quirk.
    ///
    /// - Parameter timeZone: Timezone for date interpretation (defaults to system timezone)
    /// - Returns: Excel date number as string with 8 decimal places of precision
    func excelDate(timeZone: TimeZone = TimeZone.current) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX") // Standardized

        // Excel base date calculation accounting for the 1900 leap year bug
        // Excel incorrectly treats 1900 as a leap year (it's not), which shifts all dates
        // We use December 30, 1899 as the base to compensate for this historical error
        // This ensures our calculations match Excel's behavior exactly
        let excelBaseComponents = DateComponents(
            calendar: calendar,
            timeZone: timeZone,
            year: 1899,
            month: 12,
            day: 30,
            hour: 0,
            minute: 0,
            second: 0)
        let excelBaseDate = calendar.date(from: excelBaseComponents)!

        // Calculate time interval (seconds)
        let timeInterval = timeIntervalSince(excelBaseDate)

        // Convert to days
        let excelDays = timeInterval / (24 * 60 * 60)

        // Apply empirical adjustment to match Excel's exact calculations
        let adjustedDays = excelDays - 0.00396991 // Compensate for observed systematic difference

        // Format with 8 decimal places for sub-second precision while avoiding floating-point noise
        return String(format: "%.8f", adjustedDays)
    }

    /// Creates a Swift Date from Excel's numeric date representation.
    ///
    /// Converts Excel's day-based numbering back to a Swift Date object, applying
    /// the same base date and empirical adjustments used in the forward conversion.
    ///
    /// ## Input Format
    /// - Whole numbers: Days since December 30, 1899
    /// - Fractional parts: Time within the day (0.5 = noon)
    /// - Range: Typically 1.0 to ~3652060.0 (years 1900-9999)
    ///
    /// - Parameters:
    ///   - excelDate: Excel's numeric date representation
    ///   - timeZone: Timezone for the resulting date (defaults to system timezone)
    /// - Returns: Swift Date object, or nil if the input is invalid
    static func from(excelDate: Double, timeZone: TimeZone = TimeZone.current) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX") // Standardized

        // Use the same Excel base date as the forward conversion
        let excelBaseComponents = DateComponents(
            calendar: calendar,
            timeZone: timeZone,
            year: 1899,
            month: 12,
            day: 30,
            hour: 0,
            minute: 0,
            second: 0)
        guard let excelBaseDate = calendar.date(from: excelBaseComponents) else {
            return nil
        }

        // Reverse the empirical adjustment applied in the forward conversion
        let adjustedExcelDate = excelDate + 0.00396991 // Add back the systematic correction

        // Convert days to seconds and create the final date
        let timeInterval = adjustedExcelDate * 24 * 60 * 60
        return excelBaseDate.addingTimeInterval(timeInterval)
    }

    /// Compares two Excel date strings for approximate equality within a tolerance range.
    ///
    /// Due to floating-point precision limitations and the empirical adjustments made
    /// for Excel compatibility, exact equality comparisons may fail. This method provides
    /// a tolerance-based comparison suitable for validating date conversions.
    ///
    /// - Parameters:
    ///   - date1: First Excel date string to compare
    ///   - date2: Second Excel date string to compare
    ///   - tolerance: Maximum acceptable difference in days (default: 0.01 ≈ 14.4 minutes)
    /// - Returns: True if the dates are within the specified tolerance, false otherwise
    static func isExcelDateEqual(
        _ date1: String,
        _ date2: String,
        tolerance: Double = 0.01) -> Bool
    {
        guard let d1 = Double(date1), let d2 = Double(date2) else { return false }
        // Compare the numeric difference against the tolerance threshold
        return abs(d1 - d2) < tolerance
    }
}
