//
// Column.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 表示一个 xlsx sheet 的列的声明
public struct Column<ObjectType, InputType, OutputType>: ColumnProtocol
where OutputType: ColumnTypeProtocol {
    /// 列的唯一 ID
    public let id = UUID()
    /// 列的名称
    public let name: String
    /// 列的宽度（字符宽度）
    public let width: Int?
    /// 空值处理方式
    public let nilHandling: TypedNilHandling<OutputType>
    /// 列的风格
    public let bodyStyle: CellStyle?
    /// 列的 header 风格
    public let headerStyle: CellStyle?
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
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        mapping: @escaping (InputType) -> OutputType,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        when: @escaping (ObjectType) -> Bool = { _ in true })
    {
        self.name = name
        self.keyPath = keyPath
        self.width = width
        self.mapping = mapping
        self.bodyStyle = bodyStyle
        self.nilHandling = nilHandling
        self.headerStyle = headerStyle
        conditionalMapping = nil
        filter = nil
        self.when = when
    }

    public static func conditional(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        filter: @escaping (ObjectType) -> Bool,
        then thenMapping: @escaping (InputType) -> OutputType,
        else elseMapping: @escaping (InputType) -> OutputType,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        when: @escaping (ObjectType) -> Bool = { _ in true }) -> Self
    {
        var col = self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: thenMapping,
            nilHandling: nilHandling,
            when: when)
        col.conditionalMapping = { condition, input in
            condition ? thenMapping(input) : elseMapping(input)
        }
        col.filter = filter
        return col
    }
}

extension Column {
    /// 设置列的显示条件，当条件为 true 时，列显示，否则不显示
    /// - Parameter condition: 条件
    /// - Returns: 新的列
    public func when(_ condition: @escaping (ObjectType) -> Bool) -> Self {
        var newSelf = self
        newSelf.when = condition
        return newSelf
    }

    /// 设置列的禁用条件，当条件为 true 时，列不显示
    /// - Parameter condition: 条件
    /// - Returns: 新的列
    public func disable(_ condition: @escaping (ObjectType) -> Bool) -> Self {
        var newSelf = self
        newSelf.when = { !condition($0) }
        return newSelf
    }

    /// 转换为类型擦除的 AnyColumn
    public func eraseToAnyColumn() -> AnyColumn<ObjectType> {
        AnyColumn(self)
    }
}

extension Column where InputType == Double, OutputType == NumberColumnType {
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> NumberColumnType = { .number($0) }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == Int, OutputType == IntColumnType {
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> IntColumnType = { .int($0) }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == String, OutputType == TextColumnType {
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> TextColumnType = { .text($0) }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == Date, OutputType == DateColumnType {
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> DateColumnType = { .date($0) }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == Bool, OutputType == BoolColumnType {
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> BoolColumnType = { .boolean($0) }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == URL, OutputType == URLColumnType {
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> URLColumnType = { .url($0) }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column {
    /// 根据对象，行，列，样式 ID 生成 Cell
    func generateCell(for object: ObjectType, row: Int, column: Int, styleID: Int?) -> Cell {
        let rawValue = object[keyPath: keyPath]
        let outputValue: OutputType = if let conditionalMapping, let filter {
            conditionalMapping(filter(object), rawValue)
        } else {
            mapping(rawValue)
        }

        // 应用 nilHandling 处理并转换为 CellType
        let cellValue = processValueForCell(outputValue)
        return Cell(row: row, column: column, value: cellValue, styleID: styleID)
    }

    /// 根据 nilHandling 的设置处理值，并转换为 Cell.CellType
    func processValueForCell(_ outputValue: OutputType) -> Cell.CellType {
        switch nilHandling {
            case .keepEmpty:
                outputValue.cellType
            case let .defaultValue(defaultValue):
                OutputType(outputValue.value ?? defaultValue).cellType
        }
    }
}
