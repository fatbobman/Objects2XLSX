//
// BookXMLGeneration.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import SimpleLogger

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
            logger.info("Created workbook.xml - Sheet count: \(metas.count), XML size: \(xmlData.count) bytes")
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
            logger.info("Created styles.xml - Fonts: \(styleRegister.fontPool.count), Fills: \(styleRegister.fillPool.count), Borders: \(styleRegister.borderPool.count), Cell styles: \(styleRegister.resolvedStylePool.count), XML size: \(xmlData.count) bytes")
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
            logger.info("Created sharedStrings.xml - Unique strings: \(shareStringRegister.allStrings.count), XML size: \(xmlData.count) bytes")
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
            logger.info("Created [Content_Types].xml - Sheet count: \(sheetCount), XML size: \(xmlData.count) bytes")
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
            logger.info("Created workbook.xml.rels - Sheet relationships: \(metas.count), Total relationships: \(metas.count + 2), XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Root Relationships XML Generation
extension Book {
    /// 生成 _rels/.rels 文件内容（根关系文件）
    func generateRootRelsXML() -> String {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
        <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
        <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
        </Relationships>
        """
        
        return xml
    }
    
    /// 写入 _rels/.rels 文件
    func writeRootRelsXML(to tempDir: URL) throws(BookError) {
        let rootRelsXML = generateRootRelsXML()
        let rootRelsURL = tempDir.appendingPathComponent("_rels/.rels")
        
        guard let xmlData = rootRelsXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode .rels as UTF-8")
        }
        
        do {
            try xmlData.write(to: rootRelsURL)
            logger.info("Created .rels (root relationships) - XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - App Properties XML Generation
extension Book {
    /// 生成 docProps/app.xml 文件内容（应用程序属性）
    func generateAppPropsXML(metas: [SheetMeta]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
        """
        
        // 应用程序信息
        xml += "<Application>Objects2XLSX</Application>"
        xml += "<DocSecurity>0</DocSecurity>"
        xml += "<LinksUpToDate>false</LinksUpToDate>"
        xml += "<SharedDoc>false</SharedDoc>"
        xml += "<HyperlinksChanged>false</HyperlinksChanged>"
        xml += "<AppVersion>1.0</AppVersion>"
        xml += "<Company>Objects2XLSX Library</Company>"
        
        // 工作表名称列表
        if !metas.isEmpty {
            xml += "<TitlesOfParts>"
            xml += "<vt:vector size=\"\(metas.count)\" baseType=\"lpstr\">"
            
            for meta in metas {
                xml += "<vt:lpstr>\(meta.name.xmlEscaped)</vt:lpstr>"
            }
            
            xml += "</vt:vector>"
            xml += "</TitlesOfParts>"
            
            // 各部分的标题数组
            xml += "<HeadingPairs>"
            xml += "<vt:vector size=\"2\" baseType=\"variant\">"
            xml += "<vt:variant>"
            xml += "<vt:lpstr>Worksheets</vt:lpstr>"
            xml += "</vt:variant>"
            xml += "<vt:variant>"
            xml += "<vt:i4>\(metas.count)</vt:i4>"
            xml += "</vt:variant>"
            xml += "</vt:vector>"
            xml += "</HeadingPairs>"
        }
        
        xml += "</Properties>"
        
        return xml
    }
    
    /// 写入 docProps/app.xml 文件
    func writeAppPropsXML(to tempDir: URL, metas: [SheetMeta]) throws(BookError) {
        let appPropsXML = generateAppPropsXML(metas: metas)
        let appPropsURL = tempDir.appendingPathComponent("docProps/app.xml")
        
        guard let xmlData = appPropsXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode app.xml as UTF-8")
        }
        
        do {
            try xmlData.write(to: appPropsURL)
            logger.info("Created app.xml - Application: Objects2XLSX, Worksheets: \(metas.count), XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Core Properties XML Generation
extension Book {
    /// 生成 docProps/core.xml 文件内容（核心属性）
    func generateCorePropsXML() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let timestamp = formatter.string(from: now)
        
        let xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <dc:title>\(style.properties.title?.xmlEscaped ?? "")</dc:title>
        <dc:creator>\(style.properties.author?.xmlEscaped ?? "Objects2XLSX")</dc:creator>
        <cp:lastModifiedBy>\(style.properties.author?.xmlEscaped ?? "Objects2XLSX")</cp:lastModifiedBy>
        <dcterms:created xsi:type="dcterms:W3CDTF">\(timestamp)</dcterms:created>
        <dcterms:modified xsi:type="dcterms:W3CDTF">\(timestamp)</dcterms:modified>
        </cp:coreProperties>
        """
        
        return xml
    }
    
    /// 写入 docProps/core.xml 文件
    func writeCorePropsXML(to tempDir: URL) throws(BookError) {
        let corePropsXML = generateCorePropsXML()
        let corePropsURL = tempDir.appendingPathComponent("docProps/core.xml")
        
        guard let xmlData = corePropsXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode core.xml as UTF-8")
        }
        
        do {
            try xmlData.write(to: corePropsURL)
            logger.info("Created core.xml - Title: \(style.properties.title ?? "(none)"), Author: \(style.properties.author ?? "Objects2XLSX"), XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}