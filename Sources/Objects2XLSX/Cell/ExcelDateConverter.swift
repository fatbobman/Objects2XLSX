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
/// A serial has no time zone: it is a calendar date and a clock time. The conversion
/// reads both in the given time zone, so a cell shows the same day and time a user in
/// that zone saw, daylight saving included, and dates round-trip to the millisecond.
///
/// ## Usage Examples
/// ```swift
/// let date = Date()
/// let excelNumber = date.excelDate() // "45123.75" (example)
/// let backToDate = Date.from(excelDate: 45123.75) // Original date
/// ```
extension Date {
    /// Excel's day 0, December 30, 1899. Counting from it rather than from
    /// January 1, 1900 absorbs Excel's treatment of 1900 as a leap year for
    /// every date from March 1, 1900 on.
    private static let excelEpoch = DateComponents(year: 1899, month: 12, day: 30)

    /// A Gregorian calendar in `timeZone`, independent of the user's settings
    private static func excelCalendar(in timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    /// The date as an Excel serial number: whole days since December 30,
    /// 1899, plus the time of day as a fraction, both as read on a clock in
    /// `timeZone`.
    ///
    /// Excel serials have no time zone, so the date is first turned into
    /// the calendar date and wall-clock time it has in `timeZone`. Counting
    /// elapsed seconds instead would be off by the zone's daylight saving
    /// shift for half the year, and by the difference between its 1899
    /// local mean time and today's offset all year.
    ///
    /// - Parameter timeZone: The zone whose calendar date and clock time
    ///   the cell shows (default: the current zone)
    /// - Returns: The serial with eight decimals, e.g. `"45822.50000000"`
    func excelDate(timeZone: TimeZone = TimeZone.current) -> String {
        let local = Date.excelCalendar(in: timeZone)
            .dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)

        // Whole days between two calendar dates, counted in UTC where
        // every day has 24 hours
        let utc = Date.excelCalendar(in: TimeZone(identifier: "UTC")!)
        let epoch = utc.date(from: Date.excelEpoch)!
        let day = utc.date(from: DateComponents(year: local.year, month: local.month, day: local.day))!
        let days = utc.dateComponents([.day], from: epoch, to: day).day!

        let seconds = Double((local.hour ?? 0) * 3600 + (local.minute ?? 0) * 60 + (local.second ?? 0))
            + Double(local.nanosecond ?? 0) / 1_000_000_000
        return String(format: "%.8f", Double(days) + seconds / 86400)
    }

    /// The date an Excel serial number stands for when read in `timeZone`,
    /// the inverse of `excelDate(timeZone:)`.
    ///
    /// - Parameters:
    ///   - excelDate: Days since December 30, 1899, with the time of day as
    ///     a fraction
    ///   - timeZone: The zone the serial's calendar date and clock time are
    ///     in (default: the current zone)
    /// - Returns: The date, or nil when the serial is not finite. A clock
    ///   time skipped by a daylight saving change resolves to the instant
    ///   just after it.
    static func from(excelDate: Double, timeZone: TimeZone = TimeZone.current) -> Date? {
        guard excelDate.isFinite else { return nil }

        let wholeDays = excelDate.rounded(.down)
        // Rounded to the millisecond, so 0.5 days is exactly 12:00:00
        let milliseconds = ((excelDate - wholeDays) * 86_400_000).rounded()

        let utc = excelCalendar(in: TimeZone(identifier: "UTC")!)
        guard let epoch = utc.date(from: excelEpoch),
              let day = utc.date(byAdding: .day, value: Int(wholeDays), to: epoch) else {
            return nil
        }
        var components = utc.dateComponents([.year, .month, .day], from: day)
        let totalSeconds = Int(milliseconds / 1000)
        components.hour = totalSeconds / 3600
        components.minute = totalSeconds % 3600 / 60
        components.second = totalSeconds % 60
        components.nanosecond = Int(milliseconds.truncatingRemainder(dividingBy: 1000)) * 1_000_000

        return excelCalendar(in: timeZone).date(from: components)
    }

    /// Compares two Excel date strings for approximate equality within a tolerance range.
    ///
    /// Due to floating-point precision limitations, exact equality comparisons may fail. This method provides
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
