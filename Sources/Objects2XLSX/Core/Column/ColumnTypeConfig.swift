//
// ColumnTypeConfig.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// 定义配置协议
public protocol ColumnTypeConfig: Equatable, Sendable {
    associatedtype ValueType
    var value: ValueType? { get }
}

public struct BoolColumnConfig: ColumnTypeConfig {
    public let value: Bool?
    public let booleanExpressions: Cell.BooleanExpressions
    public let caseStrategy: Cell.CaseStrategy

    public init(
        value: Bool?,
        booleanExpressions: Cell.BooleanExpressions = .trueAndFalse,
        caseStrategy: Cell.CaseStrategy = .upper)
    {
        self.value = value
        self.booleanExpressions = booleanExpressions
        self.caseStrategy = caseStrategy
    }
}

public struct DoubleColumnConfig: ColumnTypeConfig {
    public let value: Double?

    public init(value: Double?) {
        self.value = value
    }
}

public struct IntColumnConfig: ColumnTypeConfig {
    public let value: Int?

    public init(value: Int?) {
        self.value = value
    }
}

public struct TextColumnConfig: ColumnTypeConfig {
    public let value: String?

    public init(value: String?) {
        self.value = value
    }
}

public struct DateColumnConfig: ColumnTypeConfig {
    public let value: Date?
    public let timeZone: TimeZone

    public init(value: Date?, timeZone: TimeZone = TimeZone.current) {
        self.value = value
        self.timeZone = timeZone
    }
}

public struct URLColumnConfig: ColumnTypeConfig {
    public let value: URL?

    public init(value: URL?) {
        self.value = value
    }
}

public struct PercentageColumnConfig: ColumnTypeConfig {
    public let value: Double?
    public let precision: Int

    public init(value: Double?, precision: Int = 2) {
        self.value = value
        self.precision = precision
    }
}
