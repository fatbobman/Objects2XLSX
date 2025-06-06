//
// Sheet.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// public struct Sheet<ObjectType> {
//     public let name: String
//     public let columns: [AnyColumn<ObjectType>]
//     public let data: [ObjectType]

//     public init(name: String, columns: [AnyColumn<ObjectType>], data: [ObjectType]) {
//         self.name = name
//         self.columns = columns
//         self.data = data
//     }

//     // 便利构造器，支持直接传入 Column 数组
//     public init<C: Collection>(name: String, columns: C, data: [ObjectType])
//         where C.Element: ColumnProtocol, C.Element.ObjectType == ObjectType
//     {
//         self.name = name
//         self.columns = columns.map { AnyColumn($0) }
//         self.data = data
//     }
// }
