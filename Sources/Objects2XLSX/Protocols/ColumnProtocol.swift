//
// ColumnProtocol.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Protocol for column.
/// Define the common operations of column.
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

    /// Generate cell closure, encapsulating type-related operations.
    /// - Parameters:
    ///   - object: Object of column.
    ///   - row: Row of cell.
    ///   - column: Column of cell.
    ///   - bodyStyleID: Style ID of cell.
    ///   - headerStyleID: Style ID of header of cell.
    ///   - isHeader: Whether the cell is header.
    /// - Returns: Cell of column.
    func generateCell(
        for object: ObjectType,
        row: Int,
        column: Int,
        bodyStyleID: Int?,
        headerStyleID: Int?,
        isHeader: Bool) -> Cell
}
