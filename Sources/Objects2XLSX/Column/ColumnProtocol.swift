//
// ColumnProtocol.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Protocol for column.
///
/// `ColumnProtocol` is a protocol that defines the column of a Excel sheet.
/// It provides a way to create a column with a name, width, body style, header style, and when condition.
protocol ColumnProtocol<ObjectType> {
    /// Object type.
    associatedtype ObjectType

    /// Name of column.
    var name: String { get }
    /// Width of column.
    var width: Int? { get }
    /// Cell style except header of column.
    var bodyStyle: CellStyle? { get }
    /// Cell style of header of column.
    var headerStyle: CellStyle? { get }
    /// When condition of column. If the condition is true, the column will be displayed.
    /// - Parameter object: Object of column.
    /// - Returns: When condition of column.
    var when: (ObjectType) -> Bool { get }

    /// Generate cell value closure, encapsulating type-related operations.
    /// - Parameters:
    ///   - object: Object of column.
    /// - Returns: Cell value of column.
    func generateCellValue(
        for object: ObjectType) -> Cell.CellType
}
