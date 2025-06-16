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
