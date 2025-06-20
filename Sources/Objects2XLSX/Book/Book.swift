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

    var sheetMetas: [SheetMeta] = []

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
        // 创建注册器
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        // 创建临时目录用于构建 XLSX 包结构
        let tempDir = url.deletingPathExtension().appendingPathExtension("temp")
        try createXLSXDirectoryStructure(at: tempDir)
        
        // 流式处理：一次性完成数据加载、元数据收集和XML生成
        var collectedMetas: [SheetMeta] = []

        for (index, sheet) in sheets.enumerated() {
            let sheetId = index + 1

            // 加载数据一次
            sheet.loadData()

            // 生成元数据
            let meta = sheet.makeSheetMeta(sheetId: sheetId)
            collectedMetas.append(meta)

            // 立即生成并写入 XML
            try generateAndWriteSheetXML(
                sheet: sheet,
                meta: meta,
                tempDir: tempDir,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)
        }

        // 使用收集的元数据生成全局文件
        try writeWorkbookXML(to: tempDir, metas: collectedMetas)
        
        // TODO: 打包为 ZIP 文件并重命名为 .xlsx
        // TODO: 清理临时目录
    }

    func generateAndWriteSheetXML(
        sheet: AnySheet,
        meta: SheetMeta,
        tempDir: URL,
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister) throws(BookError)
    {
        guard let sheetXML = sheet.makeSheetXML(
            bookStyle: style,
            styleRegister: styleRegister,
            shareStringRegister: shareStringRegister)
        else {
            throw BookError.dataProviderError("Sheet \(sheet.name) has no data provider")
        }

        // 生成 XML 内容
        let xmlString = sheetXML.generateXML()

        // 验证 XML 内容不为空
        guard !xmlString.isEmpty else {
            throw BookError.xmlGenerationError("Generated XML for sheet '\(sheet.name)' is empty")
        }

        // 将 XML 字符串转换为数据
        guard let xmlData = xmlString.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode XML for sheet '\(sheet.name)' as UTF-8")
        }

        // 创建完整的文件路径
        let sheetFileURL = tempDir.appendingPathComponent(meta.filePath)
        
        // 确保父目录存在
        let parentDir = sheetFileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        } catch {
            throw BookError.fileWriteError(error)
        }
        
        // 写入 XML 文件
        do {
            try xmlData.write(to: sheetFileURL)
        } catch {
            throw BookError.fileWriteError(error)
        }

        // 验证生成的 XML 包含必要的元素
        try validateSheetXML(xmlString: xmlString, meta: meta)
        
        print("✓ Created sheet file: \(meta.filePath)")
        print("  - XML size: \(xmlData.count) bytes")
        print("  - Data range: \(meta.dataRange?.excelRange ?? "None")")
    }

    /// 验证生成的 Sheet XML 是否符合基本要求
    private func validateSheetXML(xmlString: String, meta: SheetMeta) throws(BookError) {
        // 检查基本的 XML 结构
        guard xmlString.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"") else {
            throw BookError.xmlValidationError("Missing XML declaration in sheet '\(meta.name)'")
        }

        guard xmlString.contains("<worksheet") && xmlString.contains("</worksheet>") else {
            throw BookError.xmlValidationError("Missing worksheet tags in sheet '\(meta.name)'")
        }

        // 如果有数据，检查是否包含 sheetData
        if meta.estimatedDataRowCount > 0 || meta.hasHeader {
            guard xmlString.contains("<sheetData>") && xmlString.contains("</sheetData>") else {
                throw BookError.xmlValidationError("Missing sheetData in non-empty sheet '\(meta.name)'")
            }
        }

        print("✓ XML validation passed for sheet '\(meta.name)'")
    }
    
    /// 创建 XLSX 包的目录结构
    func createXLSXDirectoryStructure(at tempDir: URL) throws(BookError) {
        do {
            let fileManager = FileManager.default
            
            // 删除已存在的临时目录
            if fileManager.fileExists(atPath: tempDir.path) {
                try fileManager.removeItem(at: tempDir)
            }
            
            // 创建根目录
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
            
            // 创建必要的子目录
            let directories = [
                "_rels",
                "docProps",
                "xl",
                "xl/_rels",
                "xl/worksheets"
            ]
            
            for dir in directories {
                let dirURL = tempDir.appendingPathComponent(dir)
                try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true)
            }
            
            print("✓ Created XLSX directory structure at: \(tempDir.path)")
            
        } catch {
            throw BookError.fileWriteError(error)
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
    case xmlGenerationError(String)
    case encodingError(String)
    case xmlValidationError(String)
}
