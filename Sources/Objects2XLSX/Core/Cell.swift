//
// Cell.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Cell: Equatable, Sendable {
    public let row: Int
    public let column: Int
    public let value: CellType
    public let styleID: Int?

    /// Excel 格式的单元格地址，如 "A1"
    public var excelAddress: String {
        "\(columnIndexToExcelColumn(column))\(row + 1)"
    }

    /// xml 中 cell 的 value 字段，对应 <v>valueString</v> 标签中的 valueString
    var valueString: String {
        switch value {
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

    public init(row: Int, column: Int, value: CellType, styleID: Int? = nil) {
        self.row = row
        self.column = column
        self.value = value
        self.styleID = styleID
    }
}

extension Cell {
    public enum CellType: Equatable, Sendable {
        case string(String?)
        case double(Double?)
        case int(Int?)
        case date(Date?, timeZone: TimeZone = TimeZone.current)
        case boolean(
            Bool?,
            booleanExpressions: BooleanExpressions = .oneAndZero,
            caseStrategy: CaseStrategy = .upper)
        case url(URL?)
        case percentage(Double?, precision: Int = 2)
    }

    public enum BooleanExpressions: Equatable, Sendable {
        case trueAndFalse
        case tAndF
        case oneAndZero
        case yesAndNo
        case custom(true: String, false: String)

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

    public enum CaseStrategy: Equatable, Sendable {
        case upper
        case lower
        case firstLetterUpper

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
