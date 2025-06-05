//
// ColumnTypeProtocol.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public protocol ColumnTypeProtocol: Sendable, Equatable {
    associatedtype ValueType
    var value: ValueType? { get }
    var cellType: Cell.CellType { get }
    init(_ value: ValueType?)
}

// MARK: - ColumnTypeProtocol Extension

extension ColumnTypeProtocol where Self == NumberColumnType {
    public static func number(_ value: Double?) -> Self {
        Self(value)
    }
}

extension ColumnTypeProtocol where Self == TextColumnType {
    public static func text(_ value: String?) -> Self {
        Self(value)
    }
}

extension ColumnTypeProtocol where Self == DateColumnType {
    public static func date(_ value: Date?) -> Self {
        Self(value)
    }
}

extension ColumnTypeProtocol where Self == BoolColumnType {
    public static func boolean(_ value: Bool?) -> Self {
        Self(value)
    }
}

extension ColumnTypeProtocol where Self == URLColumnType {
    public static func url(_ value: URL?) -> URLColumnType {
        URLColumnType(value)
    }
}

extension ColumnTypeProtocol where Self == PercentageColumnType {
    public static func percentage(_ value: Double?) -> Self {
        Self(value)
    }
}

extension ColumnTypeProtocol where Self == IntColumnType {
    public static func int(_ value: Int?) -> Self {
        Self(value)
    }
}
