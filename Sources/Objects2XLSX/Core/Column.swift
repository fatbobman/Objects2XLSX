//
// Column.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 表示一个 xlsx sheet 的列的声明
public struct Column<ObjectType, InputType, OutputType> where OutputType: ColumnTypeProtocol {
    /// 列的名称
    public let name: String
    /// 列的宽度（字符宽度）
    public let width: Int?
    /// 空值处理方式
    public let nilHandling: TypedNilHandling<OutputType>
    /// 列的风格
    public let style: ColumnStyle?
    /// 对应的 keyPath
    public let keyPath: KeyPath<ObjectType, InputType>
    /// mapping
    public let mapping: (InputType) -> OutputType
    /// condition
    public var conditionalMapping: ((Bool, InputType) -> OutputType)?
    /// filter
    public var filter: ((ObjectType) -> Bool)?
    /// when
    public var when: (ObjectType) -> Bool

    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        style: ColumnStyle? = nil,
        mapping: @escaping (InputType) -> OutputType,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        when: @escaping (ObjectType) -> Bool = { _ in true })
    {
        self.name = name
        self.keyPath = keyPath
        self.width = width
        self.mapping = mapping
        self.style = style
        self.nilHandling = nilHandling
        conditionalMapping = nil
        filter = nil
        self.when = when
    }
}

extension Column where InputType == Double, OutputType == NumberColumnType {
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        style: ColumnStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> NumberColumnType = { NumberColumnType($0) }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            style: style,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}
