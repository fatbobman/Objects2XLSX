//
// ColumnOutPutTypeProtocol.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Protocol for column type.
/// Output type of column.
public protocol ColumnOutputTypeProtocol: Sendable, Equatable {
    /// Config of column type.
    associatedtype Config: ColumnTypeConfig
    /// Config of column type.
    var config: Config { get }
    /// Cell type.
    var cellType: Cell.CellType { get }

    /// Create a column type with default value.
    /// - Parameter value: Value of column type.
    /// - Parameter config: Config of column type.
    /// - Returns: Column type.
    static func withDefaultValue(_ value: Config.ValueType, config: Config) -> Self
}

// // MARK: - ColumnTypeProtocol Extension

// extension ColumnOutTypeProtocol where Self == NumberColumnType {
//     /// Create a number column type.
//     /// - Parameter value: Value of column type.
//     /// - Returns: Number column type.
//     public static func number(_ value: Double?) -> Self {
//         Self(value)
//     }
// }

// extension ColumnOutTypeProtocol where Self == TextColumnType {
//     /// Create a text column type.
//     /// - Parameter value: Value of column type.
//     /// - Returns: Text column type.
//     public static func text(_ value: String?) -> Self {
//         Self(value)
//     }
// }

// extension ColumnOutTypeProtocol where Self == DateColumnType {
//     /// Create a date column type.
//     /// - Parameter value: Value of column type.
//     /// - Returns: Date column type.
//     public static func date(_ value: Date?) -> Self {
//         Self(value)
//     }
// }

// extension ColumnOutTypeProtocol where Self == BoolColumnType {
//     /// Create a boolean column type.
//     /// - Parameter value: Value of column type.
//     /// - Returns: Boolean column type.
//     public static func boolean(
//         _ value: Bool?,
//         booleanExpressions: Cell.BooleanExpressions = .oneAndZero,
//         caseStrategy: Cell.CaseStrategy = .upper) -> Self
//     {
//         Self(value)
//     }
// }

// extension ColumnOutTypeProtocol where Self == URLColumnType {
//     /// Create a URL column type.
//     /// - Parameter value: Value of column type.
//     /// - Returns: URL column type.
//     public static func url(_ value: URL?) -> URLColumnType {
//         URLColumnType(value)
//     }
// }

// extension ColumnOutTypeProtocol where Self == PercentageColumnType {
//     /// Create a percentage column type.
//     /// - Parameter value: Value of column type.
//     /// - Returns: Percentage column type.
//     public static func percentage(_ value: Double?) -> Self {
//         Self(value)
//     }
// }

// extension ColumnOutTypeProtocol where Self == IntColumnType {
//     /// Create an integer column type.
//     /// - Parameter value: Value of column type.
//     /// - Returns: Integer column type.
//     public static func int(_ value: Int?) -> Self {
//         Self(value)
//     }
// }
