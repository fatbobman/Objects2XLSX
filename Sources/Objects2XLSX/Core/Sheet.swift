//
// Sheet.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Sheet<ObjectType> {
    public let name: String
    public let columns: [AnyColumn<ObjectType>]

    public init(
        name: String,
        nameSanitizer: SheetNameSanitizer = .default,
        columns: [AnyColumn<ObjectType>])
    {
        self.name = nameSanitizer(name)
        self.columns = columns
    }

    public init(
        name: String,
        nameSanitizer: SheetNameSanitizer = .default,
        @ColumnBuilder<ObjectType> columns: () -> [AnyColumn<ObjectType>])
    {
        self.name = nameSanitizer(name)
        self.columns = columns()
    }
}

