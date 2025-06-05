//
// ColumnStyle.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 列的风格
public struct ColumnStyle: Equatable, Sendable, Hashable {
    public let font: Font?
    public let fillColor: Color?
    public let alignment: Alignment?

    public init(font: Font? = nil, fillColor: Color? = nil, alignment: Alignment? = nil) {
        self.font = font
        self.fillColor = fillColor
        self.alignment = alignment
    }
}
