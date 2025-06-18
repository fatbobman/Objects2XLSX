//
// Row.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Row {
    public let index: Int
    public let cells: [Cell]
    public let height: Double?

    public init(index: Int, cells: [Cell], height: Double? = nil) {
        self.index = index
        self.cells = cells
        self.height = height
    }
}
