//
// AnySheet.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A type-erased sheet that can hold any object type.
public final class AnySheet {
    private let _name: String
    private let _makeSheetData: (StyleRegister, ShareStringRegister) -> SheetXML?

    public var name: String { _name }

    public init<ObjectType>(_ sheet: Sheet<ObjectType>) {
        _name = sheet.name
        _makeSheetData = { styleRegister, shareStringRegister in
            // 获取数据
            let objects = sheet.dataProvider?() ?? []
            // 生成 SheetData
            return sheet.makeSheetData(
                with: objects,
                hasHeader: sheet.hasHeader,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegister)
        }
    }

    /// 生成工作表数据
    func makeSheetData(
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister) -> SheetXML?
    {
        _makeSheetData(styleRegister, shareStringRegister)
    }
}
