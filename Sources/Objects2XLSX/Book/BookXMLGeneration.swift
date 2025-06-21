//
// BookXMLGeneration.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import SimpleLogger

/*
 XLSX XML Generation Overview
 ===========================

 This file contains methods that generate all required XML files for a complete XLSX package.
 Each method transforms specific input data into standardized OOXML (Office Open XML) format:

 1. WORKSHEET FILES (xl/worksheets/sheet*.xml)
    - Input: Sheet data, cell values, styles, formulas
    - Output: Individual worksheet XML with actual spreadsheet content

 2. WORKBOOK FILE (xl/workbook.xml)
    - Input: Sheet metadata (names, IDs, relationships)
    - Output: Main workbook structure defining all worksheets

 3. STYLES FILE (xl/styles.xml)
    - Input: StyleRegister with fonts, fills, borders, cell formats
    - Output: Centralized style definitions for the entire workbook

 4. SHARED STRINGS (xl/sharedStrings.xml)
    - Input: ShareStringRegister with deduplicated text values
    - Output: Optimized string storage referenced by worksheet cells

 5. CONTENT TYPES ([Content_Types].xml)
    - Input: Sheet count and file structure information
    - Output: MIME type definitions for all package components

 6. RELATIONSHIPS (xl/_rels/workbook.xml.rels, _rels/.rels)
    - Input: Sheet metadata and component references
    - Output: Relationship mappings between package components

 7. DOCUMENT PROPERTIES (docProps/core.xml, docProps/app.xml)
    - Input: BookStyle properties, sheet metadata, timestamps
    - Output: Document metadata including author, title, creation date

 All methods follow the OOXML specification to ensure Excel compatibility.
 */

// MARK: - Sheet XML Generation

// Generates individual worksheet XML files (xl/worksheets/sheet1.xml, sheet2.xml, etc.)
// These files contain the actual cell data, formulas, and formatting for each worksheet

extension Book {
    /// Generates and writes individual worksheet XML files (xl/worksheets/sheet*.xml)
    ///
    /// Input data sources:
    /// - sheet: Contains actual data rows, column definitions, and sheet-level styling
    /// - meta: Provides sheet metadata including name, ID, file path, and data range
    /// - styleRegister: Collects and assigns style IDs for fonts, fills, borders, and cell formats
    /// - shareStringRegister: Registers text values for shared string optimization
    ///
    /// Output: Creates worksheet XML file containing cell data, styling, and structure
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

        logger.info("Created sheet file: \(meta.filePath) - XML size: \(xmlData.count) bytes, Data range: \(meta.dataRange?.excelRange ?? "None")")
    }

    /// Validates generated worksheet XML against basic OOXML requirements
    /// Ensures the XML contains proper structure and required elements for Excel compatibility
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
            guard xmlString.contains("<sheetData>"), xmlString.contains("</sheetData>") else {
                throw BookError.xmlValidationError("Missing sheetData in non-empty sheet '\(meta.name)'")
            }
        }

        logger.debug("XML validation passed for sheet '\(meta.name)'")
    }
}

// MARK: - Workbook XML Generation

// Generates xl/workbook.xml - the main workbook file that defines the structure of the XLSX
// Uses: Sheet metadata (names, IDs, relationship references) to create the workbook definition

extension Book {
    /// Generates xl/workbook.xml content based on sheet metadata
    /// Creates the main workbook structure defining all worksheets and their properties
    func generateWorkbookXML(metas: [SheetMeta]) -> String {
        var xml = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
            """

        // 添加 fileVersion（标识创建应用和版本）
        xml += "<fileVersion appName=\"Objects2XLSX\" lastEdited=\"7\" lowestEdited=\"4\" rupBuild=\"1\"/>"
        
        // 添加 workbookPr（工作簿属性）
        xml += "<workbookPr defaultThemeVersion=\"166925\"/>"

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
        
        // 添加 calcPr（计算属性 - 这是最重要的缺失元素）
        xml += "<calcPr calcId=\"171027\"/>"
        
        xml += "</workbook>"

        return xml
    }

    /// Writes xl/workbook.xml file containing workbook structure and sheet references
    /// Input data: Array of SheetMeta containing sheet names, IDs, and relationship IDs
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

// Generates xl/styles.xml - contains all formatting definitions used throughout the workbook
// Uses: StyleRegister containing all collected fonts, fills, borders, and cell styles from all sheets

extension Book {
    /// Writes xl/styles.xml file containing all formatting definitions
    /// Input data: StyleRegister with collected fonts, fills, borders, and resolved cell styles
    func writeStylesXML(to tempDir: URL, styleRegister: StyleRegister) throws(BookError) {
        let stylesXML = styleRegister.generateXML()
        let stylesURL = tempDir.appendingPathComponent("xl/styles.xml")

        guard let xmlData = stylesXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode styles.xml as UTF-8")
        }

        do {
            try xmlData.write(to: stylesURL)
            logger
                .info(
                    "Created styles.xml - Fonts: \(styleRegister.fontPool.count), Fills: \(styleRegister.fillPool.count), Borders: \(styleRegister.borderPool.count), Cell styles: \(styleRegister.resolvedStylePool.count), XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Shared Strings XML Writing

// Generates xl/sharedStrings.xml - contains all unique text strings used in cells for optimization
// Uses: ShareStringRegister containing deduplicated text values from all worksheets

extension Book {
    /// Writes xl/sharedStrings.xml file containing all unique text strings
    /// Input data: ShareStringRegister with deduplicated strings and their reference IDs
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

// Generates [Content_Types].xml - defines MIME types for all files in the XLSX package
// Uses: Sheet count to register the correct number of worksheet content types

extension Book {
    /// Generates [Content_Types].xml content defining MIME types for all XLSX package files
    /// Input data: Number of sheets to register worksheet content types
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
        xml += "<Override PartName=\"/xl/theme/theme1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.theme+xml\"/>"
        xml += "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
        xml += "<Override PartName=\"/xl/sharedStrings.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml\"/>"
        xml += "<Override PartName=\"/docProps/core.xml\" ContentType=\"application/vnd.openxmlformats-package.core-properties+xml\"/>"
        xml += "<Override PartName=\"/docProps/app.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.extended-properties+xml\"/>"

        // 为每个工作表添加覆盖类型
        if sheetCount > 0 {
            for i in 1 ... sheetCount {
                xml += "<Override PartName=\"/xl/worksheets/sheet\(i).xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
            }
        }

        xml += "</Types>"

        return xml
    }

    /// Writes [Content_Types].xml file defining MIME types for the entire XLSX package
    /// Input data: Sheet count to determine how many worksheet content types to register
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

// Generates xl/_rels/workbook.xml.rels - defines relationships between workbook and its components
// Uses: Sheet metadata to create relationships to worksheets, plus fixed relationships to styles and shared strings

extension Book {
    /// Generates xl/_rels/workbook.xml.rels content defining workbook component relationships
    /// Input data: SheetMeta array to create worksheet relationships, plus styles and shared strings
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

        // 添加主题关系
        xml += "<Relationship Id=\"rId\(relationshipId)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme\" Target=\"theme/theme1.xml\"/>"
        relationshipId += 1

        // 添加共享字符串关系
        xml += "<Relationship Id=\"rId\(relationshipId)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings\" Target=\"sharedStrings.xml\"/>"

        xml += "</Relationships>"

        return xml
    }

    /// Writes xl/_rels/workbook.xml.rels file containing workbook component relationships
    /// Input data: Sheet metadata for worksheet relationships, creates links to styles.xml and sharedStrings.xml
    func writeWorkbookRelsXML(to tempDir: URL, metas: [SheetMeta]) throws(BookError) {
        let workbookRelsXML = generateWorkbookRelsXML(metas: metas)
        let workbookRelsURL = tempDir.appendingPathComponent("xl/_rels/workbook.xml.rels")

        guard let xmlData = workbookRelsXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode workbook.xml.rels as UTF-8")
        }

        do {
            try xmlData.write(to: workbookRelsURL)
            logger.info("Created workbook.xml.rels - Sheet relationships: \(metas.count), Total relationships: \(metas.count + 3), XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Root Relationships XML Generation

// Generates _rels/.rels - the root relationships file that links to main document components
// Uses: Fixed relationships to workbook.xml, core.xml, and app.xml (no dynamic data)

extension Book {
    /// Generates _rels/.rels content with fixed relationships to main XLSX components
    /// Input data: None (uses fixed relationships to workbook, core properties, and app properties)
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

    /// Writes _rels/.rels file containing root package relationships
    /// Input data: None (creates fixed relationships to workbook.xml, core.xml, and app.xml)
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

// Generates docProps/app.xml - contains application-specific document properties
// Uses: Sheet metadata (names) to create worksheet title lists and application information

extension Book {
    /// Generates docProps/app.xml content with application properties and worksheet information
    /// Input data: SheetMeta array to extract worksheet names and count for document properties
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

    /// Writes docProps/app.xml file containing application properties and worksheet metadata
    /// Input data: Sheet metadata for worksheet names and count, plus fixed application information
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

// MARK: - Theme XML Generation

// Generates xl/theme/theme1.xml - contains theme definitions for colors, fonts, and effects
// Uses: Fixed theme content that provides default Office theme for Excel compatibility

extension Book {
    /// Generates xl/theme/theme1.xml content with default Office theme
    /// Input data: None (uses standard Office theme definitions for Excel compatibility)
    func generateThemeXML() -> String {
        let xml = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office Theme">
            <a:themeElements>
            <a:clrScheme name="Office">
            <a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1>
            <a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1>
            <a:dk2><a:srgbClr val="0E2841"/></a:dk2>
            <a:lt2><a:srgbClr val="E8E8E8"/></a:lt2>
            <a:accent1><a:srgbClr val="156082"/></a:accent1>
            <a:accent2><a:srgbClr val="E97132"/></a:accent2>
            <a:accent3><a:srgbClr val="196B24"/></a:accent3>
            <a:accent4><a:srgbClr val="0F9ED5"/></a:accent4>
            <a:accent5><a:srgbClr val="A02B93"/></a:accent5>
            <a:accent6><a:srgbClr val="4EA72E"/></a:accent6>
            <a:hlink><a:srgbClr val="467886"/></a:hlink>
            <a:folHlink><a:srgbClr val="96607D"/></a:folHlink>
            </a:clrScheme>
            <a:fontScheme name="Office">
            <a:majorFont>
            <a:latin typeface="Calibri Light" panose="020F0302020204030204"/>
            <a:ea typeface=""/>
            <a:cs typeface=""/>
            </a:majorFont>
            <a:minorFont>
            <a:latin typeface="Calibri" panose="020F0502020204030204"/>
            <a:ea typeface=""/>
            <a:cs typeface=""/>
            </a:minorFont>
            </a:fontScheme>
            <a:fmtScheme name="Office">
            <a:fillStyleLst>
            <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
            <a:gradFill rotWithShape="1">
            <a:gsLst>
            <a:gs pos="0"><a:schemeClr val="phClr"><a:lumMod val="110000"/><a:satMod val="105000"/><a:tint val="67000"/></a:schemeClr></a:gs>
            <a:gs pos="50000"><a:schemeClr val="phClr"><a:lumMod val="105000"/><a:satMod val="103000"/><a:tint val="73000"/></a:schemeClr></a:gs>
            <a:gs pos="100000"><a:schemeClr val="phClr"><a:lumMod val="105000"/><a:satMod val="109000"/><a:tint val="81000"/></a:schemeClr></a:gs>
            </a:gsLst>
            <a:lin ang="5400000" scaled="0"/>
            </a:gradFill>
            <a:gradFill rotWithShape="1">
            <a:gsLst>
            <a:gs pos="0"><a:schemeClr val="phClr"><a:satMod val="103000"/><a:lumMod val="102000"/><a:tint val="94000"/></a:schemeClr></a:gs>
            <a:gs pos="50000"><a:schemeClr val="phClr"><a:satMod val="110000"/><a:lumMod val="100000"/><a:shade val="100000"/></a:schemeClr></a:gs>
            <a:gs pos="100000"><a:schemeClr val="phClr"><a:lumMod val="99000"/><a:satMod val="120000"/><a:shade val="78000"/></a:schemeClr></a:gs>
            </a:gsLst>
            <a:lin ang="5400000" scaled="0"/>
            </a:gradFill>
            </a:fillStyleLst>
            <a:lnStyleLst>
            <a:ln w="12700" cap="flat" cmpd="sng" algn="ctr">
            <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
            <a:prstDash val="solid"/>
            <a:miter lim="800000"/>
            </a:ln>
            <a:ln w="19050" cap="flat" cmpd="sng" algn="ctr">
            <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
            <a:prstDash val="solid"/>
            <a:miter lim="800000"/>
            </a:ln>
            <a:ln w="25400" cap="flat" cmpd="sng" algn="ctr">
            <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
            <a:prstDash val="solid"/>
            <a:miter lim="800000"/>
            </a:ln>
            </a:lnStyleLst>
            <a:effectStyleLst>
            <a:effectStyle><a:effectLst/></a:effectStyle>
            <a:effectStyle><a:effectLst/></a:effectStyle>
            <a:effectStyle><a:effectLst/></a:effectStyle>
            </a:effectStyleLst>
            <a:bgFillStyleLst>
            <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
            <a:solidFill><a:schemeClr val="phClr"><a:tint val="95000"/><a:satMod val="170000"/></a:schemeClr></a:solidFill>
            <a:gradFill rotWithShape="1">
            <a:gsLst>
            <a:gs pos="0"><a:schemeClr val="phClr"><a:tint val="93000"/><a:satMod val="150000"/><a:shade val="98000"/><a:lumMod val="102000"/></a:schemeClr></a:gs>
            <a:gs pos="50000"><a:schemeClr val="phClr"><a:tint val="98000"/><a:satMod val="130000"/><a:shade val="90000"/><a:lumMod val="103000"/></a:schemeClr></a:gs>
            <a:gs pos="100000"><a:schemeClr val="phClr"><a:shade val="63000"/><a:satMod val="120000"/></a:schemeClr></a:gs>
            </a:gsLst>
            <a:lin ang="5400000" scaled="0"/>
            </a:gradFill>
            </a:bgFillStyleLst>
            </a:fmtScheme>
            </a:themeElements>
            </a:theme>
            """

        return xml
    }

    /// Writes xl/theme/theme1.xml file containing theme definitions
    /// Input data: None (creates standard Office theme for Excel compatibility)
    func writeThemeXML(to tempDir: URL) throws(BookError) {
        let themeXML = generateThemeXML()
        let themeURL = tempDir.appendingPathComponent("xl/theme/theme1.xml")

        guard let xmlData = themeXML.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode theme1.xml as UTF-8")
        }

        do {
            try xmlData.write(to: themeURL)
            logger.info("Created theme1.xml - Office Theme, XML size: \(xmlData.count) bytes")
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Core Properties XML Generation

// Generates docProps/core.xml - contains core document metadata like title, author, creation date
// Uses: BookStyle properties (title, author) and current timestamp for document metadata

extension Book {
    /// Generates docProps/core.xml content with core document properties
    /// Input data: BookStyle properties (title, author) and current date for creation/modification timestamps
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

    /// Writes docProps/core.xml file containing core document metadata
    /// Input data: Book style properties (title, author) and current timestamp for document metadata
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
