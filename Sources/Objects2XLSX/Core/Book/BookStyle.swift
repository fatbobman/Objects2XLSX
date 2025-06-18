//
// BookStyle.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct BookStyle {
    // 保留默认样式作为 fallback
    public var defaultBodyCellStyle: CellStyle? {
        defaultSheetStyle?.columnBodyStyle ?? _defaultBodyCellStyle
    }

    public var defaultHeaderCellStyle: CellStyle? {
        defaultSheetStyle?.columnHeaderStyle ?? _defaultHeaderCellStyle
    }

    public var defaultSheetStyle: SheetStyle? {
        _defaultSheetStyle
    }

    let _defaultSheetStyle: SheetStyle?
    let _defaultBodyCellStyle: CellStyle?
    let _defaultHeaderCellStyle: CellStyle?

    // 文档属性
    public var properties: DocumentProperties = .init()

    public init(
        sheetStyle: SheetStyle? = nil,
        bodyCellStyle: CellStyle? = nil,
        headerCellStyle: CellStyle? = nil,
        documentProperties: DocumentProperties = .init())
    {
        _defaultSheetStyle = sheetStyle
        _defaultBodyCellStyle = bodyCellStyle
        _defaultHeaderCellStyle = headerCellStyle
        properties = documentProperties
    }
}
