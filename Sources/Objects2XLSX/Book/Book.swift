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

    public init(style: BookStyle, sheets: [AnySheet] = []) {
        self.style = style
        self.sheets = sheets
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
        // 第一阶段：收集所有 sheet 的元数据（轻量级操作）
        let sheetMetas = collectSheetMetas()
        
        // 创建注册器，传递下去
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()
        
        // TODO: 基于 sheetMetas 生成全局 XML 文件
        // let workbookXML = generateWorkbookXML(metas: sheetMetas)
        // let contentTypesXML = generateContentTypesXML(sheetCount: sheetMetas.count)
        // let relsXML = generateRelsXML(metas: sheetMetas)
        
        // TODO: 第二阶段：流式生成每个 sheet 的 XML
        for (index, sheet) in sheets.enumerated() {
            // try generateAndWriteSheet(sheet: sheet, index: index, to: package, ...)
        }
    }
    
    /// 收集所有 sheet 的元数据，用于生成全局 XML 文件
    /// 注意：此方法会为每个 sheet 加载数据一次，然后生成元数据
    private func collectSheetMetas() -> [SheetMeta] {
        return sheets.enumerated().map { index, sheet in
            let sheetId = index + 1
            // 显式加载数据（只加载一次）
            sheet.loadData()
            return sheet.makeSheetMeta(sheetId: sheetId)
        }
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
