//
// ColumnOutPutTypeProtocol.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Protocol for column output type.
///
/// `ColumnOutputTypeProtocol` is a protocol that defines the output type of a column.
/// It provides a way to create a column output type with a default value and a config.
public protocol ColumnOutputTypeProtocol: Sendable, Equatable {
    /// Config of column output type.
    associatedtype Config: ColumnTypeConfig
    /// Config of column output type.
    var config: Config { get }
    /// Cell type of column output type.
    var cellType: Cell.CellType { get }

    /// Create a column output type with default value of nil.
    /// - Parameter value: Value of column output type.
    /// - Parameter config: Config of column output type.
    /// - Returns: Column output type with default value of nil.
    static func withDefaultValue(_ value: Config.ValueType, config: Config) -> Self
}
