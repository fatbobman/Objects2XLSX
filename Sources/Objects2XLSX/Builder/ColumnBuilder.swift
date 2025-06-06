//
// SheetBuilder.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// ```
/// @ColumnBuilder
/// var columns: [AnyColumn<ObjectType>] {
///     Column<ObjectType, InputType, OutputType>(name: "name", keyPath: \.keyPath)
///     Column<ObjectType, InputType, OutputType>(name: "name", keyPath: \.keyPath)
///     if condition {
///         Column<ObjectType, InputType, OutputType>(name: "name", keyPath: \.keyPath)
///     }
/// }
/// ```
@resultBuilder
public enum ColumnBuilder<ObjectType> {
    /// 构建多个列的组合
    public static func buildBlock(_ columns: AnyColumn<ObjectType>...) -> [AnyColumn<ObjectType>] {
        columns
    }

    /// 构建单个列
    public static func buildExpression(_ column: Column<
        ObjectType,
        some Any,
        some ColumnTypeProtocol
    >)
    -> [AnyColumn<ObjectType>] {
        [AnyColumn(column)]
    }

    /// 处理单个表达式
    public static func buildExpression(_ column: AnyColumn<ObjectType>) -> [AnyColumn<ObjectType>] {
        [column]
    }

    /// 构建多个列
    public static func buildExpression(_ columns: [AnyColumn<ObjectType>])
    -> [AnyColumn<ObjectType>] {
        columns
    }

    public static func buildExpression(_ column: Column<
        ObjectType,
        some Any,
        some ColumnTypeProtocol
    >?) -> [AnyColumn<ObjectType>] {
        column.map { [AnyColumn($0)] } ?? []
    }

    /// 处理可选条件（if 语句）
    public static func buildOptional(_ component: [AnyColumn<ObjectType>]?)
    -> [AnyColumn<ObjectType>] {
        component ?? []
    }

    /// 处理条件分支的第一个选择（if-else 中的 if 部分）
    public static func buildEither(first component: [AnyColumn<ObjectType>])
    -> [AnyColumn<ObjectType>] {
        component
    }

    /// 处理条件分支的第二个选择（if-else 中的 else 部分）
    public static func buildEither(second component: [AnyColumn<ObjectType>])
    -> [AnyColumn<ObjectType>] {
        component
    }

    /// 处理数组/循环构建
    public static func buildArray(_ components: [[AnyColumn<ObjectType>]])
    -> [AnyColumn<ObjectType>] {
        components.flatMap(\.self)
    }
}
