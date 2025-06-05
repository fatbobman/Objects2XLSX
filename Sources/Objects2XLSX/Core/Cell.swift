//
// Cell.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Cell: Equatable, Sendable {
    public let row: Int
    public let column: Int
    public let position: String
    public let value: CellType
    public let styleID: Int?

    /// xml 中 cell 的 value 字段，对应 <v>valueString</v> 标签中的 valueString
    var valueString: String {
        switch value {
            case let .string(string):
                string ?? ""
            case let .double(double):
                double?.description ?? ""
            case let .int(int):
                int?.description ?? ""
            case let .date(date):
                date?.description ?? ""
            case let .boolean(boolean):
                boolean?.description ?? ""
            case let .url(url):
                url?.absoluteString ?? ""
        }
    }

    /// 将列索引转换为列名，例如 0 转换为 A，26 转换为 AA
    static func columnName(for index: Int) -> String {
        var name = ""
        var i = index
        repeat {
            let remainder = i % 26
            name = String(UnicodeScalar(remainder + 65)!) + name
            i = i / 26 - 1
        } while i >= 0
        return name
    }

    public init(row: Int, column: Int, value: CellType, styleID: Int? = nil) {
        self.row = row
        self.column = column
        position = "\(Self.columnName(for: column))\(row + 1)"
        self.value = value
        self.styleID = styleID
    }
}

extension Cell {
    public enum CellType: Equatable, Sendable {
        case string(String?)
        case double(Double?)
        case int(Int?)
        case date(Date?)
        case boolean(Bool?)
        case url(URL?)
    }
}
