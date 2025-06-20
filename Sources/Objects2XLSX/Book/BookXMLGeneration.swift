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

// MARK: - Content Types XML Generation
extension Book {
    /// 生成 [Content_Types].xml 文件内容
    func generateContentTypesXML(sheetCount: Int) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
        """
        
        // 添加默认类型
        xml += "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>"
        xml += "<Default Extension=\"xml\" ContentType=\"application/xml\"/>"
        
        // 添加覆盖类型 - 必需的文件
        xml += "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>"
        xml += "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
        xml += "<Override PartName=\"/xl/sharedStrings.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml\"/>"
        xml += "<Override PartName=\"/docProps/core.xml\" ContentType=\"application/vnd.openxmlformats-package.core-properties+xml\"/>"
        xml += "<Override PartName=\"/docProps/app.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.extended-properties+xml\"/>"
        
        // 为每个工作表添加覆盖类型
        if sheetCount > 0 {
            for i in 1...sheetCount {
                xml += "<Override PartName=\"/xl/worksheets/sheet\(i).xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
            }
        }
        
        xml += "</Types>"
        
        return xml
    }
    
    /// 写入 [Content_Types].xml 文件
    func writeContentTypesXML(to tempDir: URL, sheetCount: Int) throws(BookError) {
        let contentTypesXML = generateContentTypesXML(sheetCount: sheetCount)
        let contentTypesURL = tempDir.appendingPathComponent("[Content_Types].xml")
        
        guard let xmlData = contentTypesXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode [Content_Types].xml as UTF-8")
        }
        
        do {
            try xmlData.write(to: contentTypesURL)
            print("✓ Created [Content_Types].xml")
            print("  - Sheet count: \(sheetCount)")
            print("  - XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Workbook Relationships XML Generation
extension Book {
    /// 生成 xl/_rels/workbook.xml.rels 文件内容
    func generateWorkbookRelsXML(metas: [SheetMeta]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        """
        
        var relationshipId = 1
        
        // 添加工作表关系
        for meta in metas {
            xml += "<Relationship Id=\"rId\(relationshipId)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet\(meta.sheetId).xml\"/>"
            relationshipId += 1
        }
        
        // 添加样式关系
        xml += "<Relationship Id=\"rId\(relationshipId)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>"
        relationshipId += 1
        
        // 添加共享字符串关系
        xml += "<Relationship Id=\"rId\(relationshipId)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings\" Target=\"sharedStrings.xml\"/>"
        
        xml += "</Relationships>"
        
        return xml
    }
    
    /// 写入 xl/_rels/workbook.xml.rels 文件
    func writeWorkbookRelsXML(to tempDir: URL, metas: [SheetMeta]) throws(BookError) {
        let workbookRelsXML = generateWorkbookRelsXML(metas: metas)
        let workbookRelsURL = tempDir.appendingPathComponent("xl/_rels/workbook.xml.rels")
        
        guard let xmlData = workbookRelsXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode workbook.xml.rels as UTF-8")
        }
        
        do {
            try xmlData.write(to: workbookRelsURL)
            print("✓ Created workbook.xml.rels")
            print("  - Sheet relationships: \(metas.count)")
            print("  - Total relationships: \(metas.count + 2)") // sheets + styles + sharedStrings
            print("  - XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}