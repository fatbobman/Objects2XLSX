//
// NumberFormat.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Represents the number format of a cell, including built-in and custom formats.
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

    /// A unique string identifier for the format, used for hashing and comparison.
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

    /// The Excel format code string for this number format, if applicable.
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

    /// The built-in Excel number format ID for this format if available.
    var builtinId: Int? {
        switch self {
            case .date:
                14 // Excel built-in date format
            case .dateTime:
                22 // Excel built-in date-time format
            default:
                nil
        }
    }
}
