//
// ColumnType.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 表示空值的处理方式
public enum TypedNilHandling<V: ColumnTypeProtocol> {
    /// 保留空值，Excel中会显示为空单元格
    case keepEmpty
    /// 使用默认值，Excel中会显示为默认值，默认值为 V.ValueType 的默认值
    case defaultValue(V.ValueType)
}
