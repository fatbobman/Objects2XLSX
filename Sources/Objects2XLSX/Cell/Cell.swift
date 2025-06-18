//
// Cell.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Cell of Sheet.
public struct Cell: Equatable, Sendable {
    /// Row of cell.
    public let row: Int
    /// Column of cell.
    public let column: Int
    /// Value of cell.
    public let value: CellType
    /// Style ID of cell.
    public let styleID: Int?

    /// Address of cell in Excel format, such as "A1".
    public var excelAddress: String {
        "\(columnIndexToExcelColumn(column))\(row + 1)"
    }

    /// Initialize a cell.
    /// - Parameters:
    ///   - row: Row of cell.
    ///   - column: Column of cell.
    ///   - value: Value of cell.
    ///   - styleID: Style ID of cell.
    public init(
        row: Int,
        column: Int,
        value: CellType,
        styleID: Int? = nil)
    {
        self.row = row
        self.column = column
        self.value = value
        self.styleID = styleID
    }
}

extension Cell {
    /// Type of cell value.
    public enum CellType: Equatable, Sendable {
        /// String value.
        /// - Parameter string: String value.
        case string(String?)
        /// Double value.
        /// - Parameter double: Double value.
        case double(Double?)
        /// Int value.
        /// - Parameter int: Int value.
        case int(Int?)
        /// Date value.
        /// - Parameter date: Date value.
        /// - Parameter timeZone: Time zone.
        case date(Date?, timeZone: TimeZone = TimeZone.current)
        /// Boolean value.
        /// - Parameter boolean: Boolean value.
        /// - Parameter booleanExpressions: Boolean expressions.
        /// - Parameter caseStrategy: Case strategy.
        case boolean(
            Bool?,
            booleanExpressions: BooleanExpressions = .oneAndZero,
            caseStrategy: CaseStrategy = .upper)
        /// URL value.
        /// - Parameter url: URL value.
        case url(URL?)
        /// Percentage value.
        /// - Parameter percentage: Percentage value.
        /// - Parameter precision: Precision.
        case percentage(Double?, precision: Int = 2)

        public var valueString: String {
            switch self {
                case let .string(string):
                    string.cellValueString
                case let .double(double):
                    double.cellValueString
                case let .int(int):
                    int.cellValueString
                case let .date(date, timeZone):
                    date.cellValueString(timeZone: timeZone)
                case let .boolean(boolean, booleanExpressions, caseStrategy):
                    boolean.cellValueString(
                        booleanExpressions: booleanExpressions,
                        caseStrategy: caseStrategy)
                case let .url(url):
                    url.cellValueString
                case let .percentage(percentage, precision):
                    percentage.cellValueString(precision: precision)
            }
        }
    }

    /// Boolean expressions.
    public enum BooleanExpressions: Equatable, Sendable {
        /// True and False.
        case trueAndFalse
        /// T and F.
        case tAndF
        /// One and Zero.
        case oneAndZero
        /// Yes and No.
        case yesAndNo
        /// Custom.
        /// - Parameter true: True string.
        /// - Parameter false: False string.
        case custom(true: String, false: String)

        /// True string.
        public var trueString: String {
            switch self {
                case .trueAndFalse:
                    "TRUE"
                case .tAndF:
                    "T"
                case .oneAndZero:
                    "1"
                case .yesAndNo:
                    "YES"
                case let .custom(trueString, _):
                    trueString
            }
        }

        /// False string.
        public var falseString: String {
            switch self {
                case .trueAndFalse:
                    "FALSE"
                case .tAndF:
                    "F"
                case .oneAndZero:
                    "0"
                case .yesAndNo:
                    "NO"
                case let .custom(_, falseString):
                    falseString
            }
        }
    }

    /// Case strategy.
    public enum CaseStrategy: Equatable, Sendable {
        /// Uppercase.
        case upper
        /// Lowercase.
        case lower
        /// First letter uppercase.
        case firstLetterUpper

        /// Apply case strategy to string.
        func apply(to string: String) -> String {
            switch self {
                case .upper:
                    return string.uppercased()
                case .lower:
                    return string.lowercased()
                case .firstLetterUpper:
                    guard !string.isEmpty else {
                        return ""
                    }
                    return string.prefix(1).uppercased() + string.dropFirst().lowercased()
            }
        }
    }
}
