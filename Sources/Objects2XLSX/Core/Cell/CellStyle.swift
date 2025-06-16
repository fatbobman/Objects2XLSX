//
// CellStyle.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents a cell ofstyle in an Excel sheet.
public struct CellStyle: Equatable, Sendable, Hashable {
    /// The font of the cell style.
    public let font: Font?
    /// The fill color of the cell style.
    public let fillColor: Fill?
    /// The alignment of the cell style.
    public let alignment: Alignment?

    /// Creates a cell style with the given font, fill color, and alignment.
    ///
    /// - Parameter font: The font of the cell style.
    /// - Parameter fillColor: The fill color of the cell style.
    /// - Parameter alignment: The alignment of the cell style.
    public init(font: Font? = nil, fillColor: Fill? = nil, alignment: Alignment? = nil) {
        self.font = font
        self.fillColor = fillColor
        self.alignment = alignment
    }
}
