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
    public var style: BookStyle
    public var sheets: [AnySheet]

    let styleRegister: StyleRegister
    let shareStringRegister: ShareStringRegister

    public init(style: BookStyle, sheets: [AnySheet] = []) {
        self.style = style
        self.sheets = sheets
        styleRegister = StyleRegister()
        shareStringRegister = ShareStringRegister()
    }

    public convenience init(style: BookStyle, @SheetBuilder sheets: () -> [AnySheet]) {
        self.init(style: style, sheets: sheets())
    }

    public func append(sheet: AnySheet) {
        sheets.append(sheet)
    }

    public func append(sheets: [AnySheet]) {
        self.sheets.append(contentsOf: sheets)
    }

    public func append<ObjectType>(sheet: Sheet<ObjectType>) {
        sheets.append(sheet.eraseToAnySheet())
    }

    public func append(@SheetBuilder sheets: () -> [AnySheet]) {
        self.sheets.append(contentsOf: sheets())
    }


    public func write(to url: URL) throws(BookError) {
        for (index, sheet) in sheets.enumerated() {
            try makeSheetXML(sheet: sheet, sheetIndex: index + 1) // 是否需要保存信息？
        }

    }

    /// 在对应的 url 中创建 sheetx.xml 文件, 或许应该返回一些用于生成其他 xml 的信息？
    func makeSheetXML(sheet: AnySheet, sheetIndex: Int) throws(BookError)  {
        guard let sheetXML = sheet.makeSheetXML(bookStyle: style, styleRegister: styleRegister, shareStringRegister: shareStringRegister) else {
            throw BookError.dataProviderError("Sheet \(sheet.name) has no data provider")
        }

        // 生成 sheetx.xml 文件

        // 返回需要的信息

    }
}

extension Book {
    public func author(name: String) {
        style.properties.author = name
    }

    public func title(name: String) {
        style.properties.title = name
    }
}

public enum BookError: Error, Sendable {
    case fileWriteError(Error)
    case dataProviderError(String)
}
