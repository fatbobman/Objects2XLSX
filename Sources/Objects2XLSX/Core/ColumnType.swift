//
// ColumnType.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 表示一个 xlsx sheet 的列的类型(除了 Header 行，其他行都是这个类型)
public enum DataType: Equatable, Sendable {
    case text
    case number
    case date
    case boolean
    case url
    case percentage
}

/// 表示空值的处理方式
public enum TypedNilHandling<V: ColumnTypeProtocol> {
    /// 保留空值，Excel中会显示为空单元格
    case keepEmpty
    /// 使用默认值，Excel中会显示为默认值，默认值为 V.ValueType 的默认值
    case useDefault(V.ValueType)
}
