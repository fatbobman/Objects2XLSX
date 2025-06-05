//
// ColumnTypeProtocol.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public protocol ColumnTypeProtocol {
    associatedtype ValueType
    static var dataType: DataType { get }
    // var value: ValueType { get }
}

public struct NumberColumnType: ColumnTypeProtocol {
    public typealias ValueType = Double
    public static let dataType = DataType.number
    public let value: ValueType
    public init(_ value: ValueType) {
        self.value = value
    }
}

public struct TextColumnType: ColumnTypeProtocol {
    public typealias ValueType = String
    public static let dataType = DataType.text
}

public struct DateColumnType: ColumnTypeProtocol {
    public typealias ValueType = Date
    public static let dataType = DataType.date
}

public struct BoolColumnType: ColumnTypeProtocol {
    public typealias ValueType = Bool
    public static let dataType = DataType.boolean
}

public struct URLColumnType: ColumnTypeProtocol {
    public typealias ValueType = URL
    public static let dataType = DataType.url
}

public struct PercentageColumnType: ColumnTypeProtocol {
    public typealias ValueType = Double
    public static let dataType = DataType.percentage
}
