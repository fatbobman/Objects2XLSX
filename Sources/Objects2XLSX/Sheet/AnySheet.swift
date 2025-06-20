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
    private let _hasHeader: Bool
    private let _makeSheetXML: (BookStyle, StyleRegister, ShareStringRegister) -> SheetXML?
    private let _makeSheetMeta: (Int) -> SheetMeta
    private let _loadData: () -> Void
    private let _estimatedDataRowCount: () -> Int

    public var name: String { _name }
    public var hasHeader: Bool { _hasHeader }

    public init<ObjectType>(_ sheet: Sheet<ObjectType>) {
        _name = sheet.name
        _hasHeader = sheet.hasHeader
        _estimatedDataRowCount = sheet.estimatedDataRowCount
        
        _loadData = {
            sheet.loadData()
        }
        _makeSheetXML = { bookStyle, styleRegister, shareStringRegister in
            // 获取数据
            let objects = sheet.dataProvider?() ?? []
            // 生成 SheetData
            return sheet.makeSheetXML(
                with: objects,
                bookStyle: bookStyle,
                styleRegister: styleRegister,
                shareStringRegistor: shareStringRegister)
        }
        _makeSheetMeta = { sheetId in
            sheet.makeSheetMeta(sheetId: sheetId)
        }
    }

    /// 加载数据（由 Book 显式调用，确保只加载一次）
    public func loadData() {
        _loadData()
    }
    
    /// 生成 SheetXML（假设数据已通过 loadData() 加载）
    func makeSheetXML(
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister) -> SheetXML?
    {
        return _makeSheetXML(bookStyle, styleRegister, shareStringRegister)
    }
    
    /// 构建 SheetMeta（假设数据已通过 loadData() 加载）
    public func makeSheetMeta(sheetId: Int) -> SheetMeta {
        return _makeSheetMeta(sheetId)
    }
    
    /// 预估数据行数
    public func estimatedDataRowCount() -> Int {
        return _estimatedDataRowCount()
    }
}
