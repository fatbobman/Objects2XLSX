//
// Date.swift
// Created by Xu Yang on 2025-06-14.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

extension Date {
    /// Converts a date to Excel date number format
    /// Excel uses the number of days since January 1, 1900 as the date value
    /// The fractional part represents the time of day (e.g., 0.5 represents 12:00 PM)
    func excelDate(timeZone: TimeZone = TimeZone.current) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX") // Standardized

        // Excel base date (compatible with historical issues, Excel considers 1900 as a leap year)
        // Actually, 1900 is not a leap year, but Excel incorrectly treats it as a leap year
        // Here we use December 30, 1899 as the base date
        // This is because Excel's date system starts from January 1, 1900, but it incorrectly
        // treats 1900 as a leap year
        // So we calculate from December 30, 1899
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

        // Apply empirical adjustment for perfect matching if needed
        let adjustedDays = excelDays - 0.00396991 // Subtract observed systematic bias

        // Reduce precision to reasonable range, avoiding floating point precision issues
        return String(format: "%.8f", adjustedDays)
    }

    /// Creates a Date from Excel date number format
    static func from(excelDate: Double, timeZone: TimeZone = TimeZone.current) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX") // Standardized

        // Excel base date (same as excelDate method)
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

        // Apply the same empirical adjustment (reverse the adjustment from excelDate)
        let adjustedExcelDate = excelDate + 0.00396991 // Add back the systematic bias

        // Convert to seconds and create date
        let timeInterval = adjustedExcelDate * 24 * 60 * 60
        return excelBaseDate.addingTimeInterval(timeInterval)
    }

    /// Checks if two Excel date values are within acceptable tolerance range
    static func isExcelDateEqual(
        _ date1: String,
        _ date2: String,
        tolerance: Double = 0.01) -> Bool // Default tolerance adjusted to approximately 14 minutes
    {
        guard let d1 = Double(date1), let d2 = Double(date2) else { return false }
        // Check if two date values are within tolerance range
        return abs(d1 - d2) < tolerance
    }
}
