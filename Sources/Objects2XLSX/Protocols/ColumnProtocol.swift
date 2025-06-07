//
// ColumnProtocol.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 列的协议，定义了列的通用操作
protocol ColumnProtocol<ObjectType> {
    associatedtype ObjectType

    var name: String { get }
    var width: Int? { get }
    var bodyStyle: CellStyle? { get }
    var headerStyle: CellStyle? { get }
    var when: (ObjectType) -> Bool { get }

    /// 生成单元格的闭包，封装了类型相关的操作
    func generateCell(
        for object: ObjectType,
        row: Int,
        column: Int,
        bodyStyleID: Int?,
        headerStyleID: Int?,
        isHeader: Bool) -> Cell
}
