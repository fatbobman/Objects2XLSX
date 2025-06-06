//
// AnyColumn.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 类型擦除的列包装器
public struct AnyColumn<ObjectType> {
    public let id: UUID
    public let name: String
    public let width: Int?
    public let bodyStyle: CellStyle?
    public let headerStyle: CellStyle?

    private let _when: (ObjectType) -> Bool
    private let _generateCell: (ObjectType, Int, Int, Int?) -> Cell

    public init<InputType>(_ column: Column<ObjectType, InputType, some ColumnTypeProtocol>) {
        id = column.id
        name = column.name
        width = column.width
        bodyStyle = column.bodyStyle
        headerStyle = column.headerStyle
        _when = column.when

        // 直接委托给 Column 的 generateCell 方法
        _generateCell = column.generateCell
    }

    public func generateCell(for object: ObjectType, row: Int, column: Int, styleID: Int?) -> Cell {
        _generateCell(object, row, column, styleID)
    }

    public func shouldGenerate(for object: ObjectType) -> Bool {
        _when(object)
    }
}
