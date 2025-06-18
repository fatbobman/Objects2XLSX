//
// Book.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// 对应 Excel 的 Workbook 对象
public final class Book {
    public var styles: BookStyle
    public var sheets: [AnySheet]

    let styleRegister: StyleRegister
    let shareStringRegister: ShareStringRegister

    public init(styles: BookStyle, sheets: [AnySheet] = []) {
        self.styles = styles
        self.sheets = sheets
        styleRegister = StyleRegister()
        shareStringRegister = ShareStringRegister()
    }

    public func append(sheet: AnySheet) {
        sheets.append(sheet)
    }

    public func append(sheets: [AnySheet]) {
        self.sheets.append(contentsOf: sheets)
    }

    public func write(to url: URL) throws {
        // 生成逻辑
        let data = Data()
        try data.write(to: url)
    }
}
