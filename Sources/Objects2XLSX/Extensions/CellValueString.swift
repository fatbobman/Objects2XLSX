//
// CellValueString.swift
// Created by Xu Yang on 2025-06-14.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

extension String? {
    /// Returns the string value or an empty string if nil
    var cellValueString: String {
        self ?? ""
    }
}

extension Double? {
    /// Returns the string representation of the double value or an empty string if nil
    var cellValueString: String {
        guard let value = self else { return "" }
        // 使用更精确的格式化，避免科学计数法
        if value.isInfinite || value.isNaN {
            return ""
        }
        return String(value)
    }

    /// Returns the string representation of the percentage value for Excel storage
    func cellValueString(precision: Int = 2) -> String {
        guard let value = self else { return "" }
        if value.isInfinite || value.isNaN {
            return ""
        }

        // 转换为 Decimal 避免浮点精度问题
        var decimal = Decimal(value)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, precision + 2, .plain)

        return "\(rounded)"
    }
}

extension Int? {
    /// Returns the string representation of the integer value or an empty string if nil
    var cellValueString: String {
        guard let value = self else { return "" }
        return String(value)
    }
}

extension Date? {
    /// Returns the Excel date string representation of the date or an empty string if nil
    func cellValueString(timeZone: TimeZone = TimeZone.current) -> String {
        self?.excelDate(timeZone: timeZone) ?? ""
    }
}

extension Bool? {
    /// Returns the Excel boolean representation (1 for true, 0 for false) or an empty string if nil
    var cellValueString: String {
        guard let value = self else { return "" }
        return value ? "1" : "0"
    }
}

extension URL? {
    /// Returns the absolute string representation of the URL or an empty string if nil
    var cellValueString: String {
        self?.absoluteString ?? ""
    }
}
