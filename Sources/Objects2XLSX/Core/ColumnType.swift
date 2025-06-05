//
// ColumnType.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct NumberColumnType: ColumnTypeProtocol {
    public let value: Double?
    public init(_ value: Double?) {
        self.value = value
    }

    public var cellType: Cell.CellType {
        .double(value)
    }
}

public struct IntColumnType: ColumnTypeProtocol {
    public let value: Int?
    public init(_ value: Int?) {
        self.value = value
    }

    public var cellType: Cell.CellType {
        .int(value)
    }
}

public struct TextColumnType: ColumnTypeProtocol {
    public let value: String?
    public init(_ value: String?) {
        self.value = value
    }

    public var cellType: Cell.CellType {
        .string(value)
    }
}

public struct DateColumnType: ColumnTypeProtocol {
    public let value: Date?
    public init(_ value: Date?) {
        self.value = value
    }

    public var cellType: Cell.CellType {
        .date(value)
    }
}

public struct BoolColumnType: ColumnTypeProtocol {
    public let value: Bool?
    public init(_ value: Bool?) {
        self.value = value
    }

    public var cellType: Cell.CellType {
        .boolean(value)
    }
}

public struct URLColumnType: ColumnTypeProtocol {
    public let value: URL?
    public init(_ value: URL?) {
        self.value = value
    }

    public var cellType: Cell.CellType {
        .url(value)
    }
}

public struct PercentageColumnType: ColumnTypeProtocol {
    public let value: Double?
    public init(_ value: Double?) {
        self.value = value
    }

    public var cellType: Cell.CellType {
        .double(value)
    }
}
