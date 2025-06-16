//
// ColumnOutputType.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct DoubleColumnType: ColumnOutputTypeProtocol {
    public let config: DoubleColumnConfig
    public init(_ config: DoubleColumnConfig) {
        self.config = config
    }

    public var cellType: Cell.CellType {
        .double(config.value)
    }

    public static func withDefaultValue(_ value: Double, config: DoubleColumnConfig) -> Self {
        DoubleColumnType(DoubleColumnConfig(value: value))
    }
}

public struct IntColumnType: ColumnOutputTypeProtocol {
    public let config: IntColumnConfig
    public init(_ config: IntColumnConfig) {
        self.config = config
    }

    public var cellType: Cell.CellType {
        .int(config.value)
    }

    public static func withDefaultValue(_ value: Int, config: IntColumnConfig) -> Self {
        IntColumnType(IntColumnConfig(value: value))
    }
}

public struct TextColumnType: ColumnOutputTypeProtocol {
    public let config: TextColumnConfig
    public init(_ config: TextColumnConfig) {
        self.config = config
    }

    public var cellType: Cell.CellType {
        .string(config.value)
    }

    public static func withDefaultValue(_ value: String, config: TextColumnConfig) -> Self {
        TextColumnType(TextColumnConfig(value: value))
    }
}

public struct DateColumnType: ColumnOutputTypeProtocol {
    public let config: DateColumnConfig
    public init(_ config: DateColumnConfig) {
        self.config = config
    }

    public var cellType: Cell.CellType {
        .date(config.value, timeZone: config.timeZone)
    }

    public static func withDefaultValue(_ value: Date, config: DateColumnConfig) -> Self {
        DateColumnType(DateColumnConfig(value: value, timeZone: config.timeZone))
    }
}

public struct BoolColumnType: ColumnOutputTypeProtocol {
    public let config: BoolColumnConfig

    public init(_ config: BoolColumnConfig) {
        self.config = config
    }

    public var cellType: Cell.CellType {
        .boolean(
            config.value,
            booleanExpressions: config.booleanExpressions,
            caseStrategy: config.caseStrategy)
    }

    public static func withDefaultValue(_ value: Bool, config: BoolColumnConfig) -> Self {
        BoolColumnType(BoolColumnConfig(
            value: value,
            booleanExpressions: config.booleanExpressions,
            caseStrategy: config.caseStrategy))
    }
}

public struct URLColumnType: ColumnOutputTypeProtocol {
    public let config: URLColumnConfig
    public init(_ config: URLColumnConfig) {
        self.config = config
    }

    public var cellType: Cell.CellType {
        .url(config.value)
    }

    public static func withDefaultValue(_ value: URL, config: URLColumnConfig) -> Self {
        URLColumnType(URLColumnConfig(value: value))
    }
}

public struct PercentageColumnType: ColumnOutputTypeProtocol {
    public let config: PercentageColumnConfig
    public init(_ config: PercentageColumnConfig) {
        self.config = config
    }

    public var cellType: Cell.CellType {
        .percentage(config.value, precision: config.precision)
    }

    public static func withDefaultValue(_ value: Double, config: PercentageColumnConfig) -> Self {
        PercentageColumnType(PercentageColumnConfig(value: value, precision: config.precision))
    }
}
