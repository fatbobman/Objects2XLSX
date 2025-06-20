//
// BookXMLGeneration.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// MARK: - Workbook XML Generation
extension Book {
    /// 生成 xl/workbook.xml 文件内容
    func generateWorkbookXML(metas: [SheetMeta]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        """
        
        // 添加 bookViews（可选，但建议包含）
        xml += "<bookViews>"
        xml += "<workbookView xWindow=\"0\" yWindow=\"0\" windowWidth=\"16384\" windowHeight=\"8192\"/>"
        xml += "</bookViews>"
        
        // 添加 sheets 节点
        xml += "<sheets>"
        
        // 为每个工作表添加 sheet 节点
        for meta in metas {
            xml += "<sheet name=\"\(meta.name.xmlEscaped)\" sheetId=\"\(meta.sheetId)\" r:id=\"\(meta.relationshipId)\"/>"
        }
        
        xml += "</sheets>"
        xml += "</workbook>"
        
        return xml
    }
    
    /// 写入 workbook.xml 文件
    func writeWorkbookXML(to tempDir: URL, metas: [SheetMeta]) throws(BookError) {
        let workbookXML = generateWorkbookXML(metas: metas)
        let workbookURL = tempDir.appendingPathComponent("xl/workbook.xml")
        
        guard let xmlData = workbookXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode workbook.xml as UTF-8")
        }
        
        do {
            try xmlData.write(to: workbookURL)
            print("✓ Created workbook.xml")
            print("  - Sheet count: \(metas.count)")
            print("  - XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Styles XML Writing
extension Book {
    /// 写入 styles.xml 文件
    func writeStylesXML(to tempDir: URL, styleRegister: StyleRegister) throws(BookError) {
        let stylesXML = styleRegister.generateXML()
        let stylesURL = tempDir.appendingPathComponent("xl/styles.xml")
        
        guard let xmlData = stylesXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode styles.xml as UTF-8")
        }
        
        do {
            try xmlData.write(to: stylesURL)
            print("✓ Created styles.xml")
            print("  - Fonts: \(styleRegister.fontPool.count)")
            print("  - Fills: \(styleRegister.fillPool.count)")
            print("  - Borders: \(styleRegister.borderPool.count)")
            print("  - Cell styles: \(styleRegister.resolvedStylePool.count)")
            print("  - XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Shared Strings XML Writing
extension Book {
    /// 写入 sharedStrings.xml 文件
    func writeSharedStringsXML(to tempDir: URL, shareStringRegister: ShareStringRegister) throws(BookError) {
        let sharedStringsXML = shareStringRegister.generateXML()
        let sharedStringsURL = tempDir.appendingPathComponent("xl/sharedStrings.xml")
        
        guard let xmlData = sharedStringsXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode sharedStrings.xml as UTF-8")
        }
        
        do {
            try xmlData.write(to: sharedStringsURL)
            print("✓ Created sharedStrings.xml")
            print("  - Unique strings: \(shareStringRegister.allStrings.count)")
            print("  - XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}