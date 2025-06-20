//
// BookXMLGenerationTests.swift
// Created by Claude on 2025-06-20.
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Book XML Generation Tests")
struct BookXMLGenerationTests {
    @Test("test generateWorkbookXML Basic")
    func testGenerateWorkbookXMLBasic() {
        // Create test metas
        let metas = [
            SheetMeta(
                name: "Sheet1",
                sheetId: 1,
                relationshipId: "rId1",
                hasHeader: true,
                estimatedDataRowCount: 10,
                activeColumnCount: 3,
                dataRange: nil
            ),
            SheetMeta(
                name: "Sheet2",
                sheetId: 2,
                relationshipId: "rId2",
                hasHeader: false,
                estimatedDataRowCount: 5,
                activeColumnCount: 2,
                dataRange: nil
            )
        ]
        
        // Create book and generate XML
        let book = Book(style: BookStyle())
        let xml = book.generateWorkbookXML(metas: metas)
        
        // Verify XML structure
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\""))
        #expect(xml.contains("<workbook"))
        #expect(xml.contains("xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\""))
        #expect(xml.contains("</workbook>"))
        
        // Verify bookViews
        #expect(xml.contains("<bookViews>"))
        #expect(xml.contains("<workbookView"))
        #expect(xml.contains("</bookViews>"))
        
        // Verify sheets
        #expect(xml.contains("<sheets>"))
        #expect(xml.contains("</sheets>"))
        
        // Verify individual sheet entries
        #expect(xml.contains("<sheet name=\"Sheet1\" sheetId=\"1\" r:id=\"rId1\"/>"))
        #expect(xml.contains("<sheet name=\"Sheet2\" sheetId=\"2\" r:id=\"rId2\"/>"))
        
        print("Generated workbook.xml:")
        print(xml)
    }
    
    @Test("test generateWorkbookXML with Special Characters")
    func testGenerateWorkbookXMLWithSpecialCharacters() {
        // Create meta with special characters in name
        let metas = [
            SheetMeta(
                name: "Sales & Marketing",
                sheetId: 1,
                relationshipId: "rId1",
                hasHeader: true,
                estimatedDataRowCount: 0,
                activeColumnCount: 0,
                dataRange: nil
            ),
            SheetMeta(
                name: "Data < 2024",
                sheetId: 2,
                relationshipId: "rId2",
                hasHeader: true,
                estimatedDataRowCount: 0,
                activeColumnCount: 0,
                dataRange: nil
            )
        ]
        
        let book = Book(style: BookStyle())
        let xml = book.generateWorkbookXML(metas: metas)
        
        // Verify special characters are escaped
        #expect(xml.contains("Sales &amp; Marketing"))
        #expect(xml.contains("Data &lt; 2024"))
        
        print("Workbook XML with escaped characters:")
        print(xml)
    }
    
    @Test("test writeWorkbookXML File Creation")
    func testWriteWorkbookXMLFileCreation() throws {
        // Create test metas
        let metas = [
            SheetMeta(
                name: "TestSheet",
                sheetId: 1,
                relationshipId: "rId1",
                hasHeader: true,
                estimatedDataRowCount: 5,
                activeColumnCount: 2,
                dataRange: nil
            )
        ]
        
        // Create temp directory
        let tempDir = URL(fileURLWithPath: "/tmp/test_workbook_xml")
        let book = Book(style: BookStyle())
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // Write workbook.xml
        #expect(throws: Never.self) {
            try book.writeWorkbookXML(to: tempDir, metas: metas)
        }
        
        // Verify file exists
        let workbookURL = tempDir.appendingPathComponent("xl/workbook.xml")
        #expect(FileManager.default.fileExists(atPath: workbookURL.path))
        
        // Read and verify content
        let content = try String(contentsOf: workbookURL, encoding: .utf8)
        #expect(content.contains("<sheet name=\"TestSheet\""))
        
        print("Successfully created workbook.xml at: \(workbookURL.path)")
    }
    
    @Test("test generateWorkbookXML Empty Sheets")
    func testGenerateWorkbookXMLEmptySheets() {
        let metas: [SheetMeta] = []
        
        let book = Book(style: BookStyle())
        let xml = book.generateWorkbookXML(metas: metas)
        
        // Should still have valid structure with empty sheets
        #expect(xml.contains("<sheets>"))
        #expect(xml.contains("</sheets>"))
        #expect(xml.contains("<sheets></sheets>"))
        
        print("Empty workbook XML:")
        print(xml)
    }
    
    @Test("test writeStylesXML File Creation")
    func testWriteStylesXMLFileCreation() throws {
        // Create temp directory
        let tempDir = URL(fileURLWithPath: "/tmp/test_styles_xml")
        let book = Book(style: BookStyle())
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // Create style register with some styles
        let styleRegister = StyleRegister()
        let cellStyle = CellStyle(
            font: Font(size: 12, name: "Arial"),
            fill: .solid(.blue),
            alignment: Alignment(horizontal: .center, vertical: .center)
        )
        _ = styleRegister.registerCellStyle(cellStyle, cellType: .string("test"))
        
        // Write styles.xml
        #expect(throws: Never.self) {
            try book.writeStylesXML(to: tempDir, styleRegister: styleRegister)
        }
        
        // Verify file exists
        let stylesURL = tempDir.appendingPathComponent("xl/styles.xml")
        #expect(FileManager.default.fileExists(atPath: stylesURL.path))
        
        // Read and verify content
        let content = try String(contentsOf: stylesURL, encoding: .utf8)
        #expect(content.contains("<?xml version=\"1.0\" encoding=\"UTF-8\""))
        #expect(content.contains("<styleSheet"))
        #expect(content.contains("</styleSheet>"))
        
        print("Successfully created styles.xml at: \(stylesURL.path)")
    }
    
    @Test("test writeSharedStringsXML File Creation")
    func testWriteSharedStringsXMLFileCreation() throws {
        // Create temp directory
        let tempDir = URL(fileURLWithPath: "/tmp/test_sharedstrings_xml")
        let book = Book(style: BookStyle())
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // Create share string register with some strings
        let shareStringRegister = ShareStringRegister()
        _ = shareStringRegister.register("Hello World")
        _ = shareStringRegister.register("Test String")
        _ = shareStringRegister.register("Excel & XML")
        
        // Write sharedStrings.xml
        #expect(throws: Never.self) {
            try book.writeSharedStringsXML(to: tempDir, shareStringRegister: shareStringRegister)
        }
        
        // Verify file exists
        let sharedStringsURL = tempDir.appendingPathComponent("xl/sharedStrings.xml")
        #expect(FileManager.default.fileExists(atPath: sharedStringsURL.path))
        
        // Read and verify content
        let content = try String(contentsOf: sharedStringsURL, encoding: .utf8)
        #expect(content.contains("<?xml version=\"1.0\" encoding=\"UTF-8\""))
        #expect(content.contains("<sst"))
        #expect(content.contains("</sst>"))
        #expect(content.contains("Hello World"))
        #expect(content.contains("Excel &amp; XML"))
        
        print("Successfully created sharedStrings.xml at: \(sharedStringsURL.path)")
    }
    
    @Test("test generateContentTypesXML Basic")
    func testGenerateContentTypesXMLBasic() {
        let book = Book(style: BookStyle())
        let xml = book.generateContentTypesXML(sheetCount: 3)
        
        // Verify XML structure
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\""))
        #expect(xml.contains("<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"))
        #expect(xml.contains("</Types>"))
        
        // Verify default types
        #expect(xml.contains("<Default Extension=\"rels\""))
        #expect(xml.contains("<Default Extension=\"xml\""))
        
        // Verify override types for core files
        #expect(xml.contains("<Override PartName=\"/xl/workbook.xml\""))
        #expect(xml.contains("<Override PartName=\"/xl/styles.xml\""))
        #expect(xml.contains("<Override PartName=\"/xl/sharedStrings.xml\""))
        #expect(xml.contains("<Override PartName=\"/docProps/core.xml\""))
        #expect(xml.contains("<Override PartName=\"/docProps/app.xml\""))
        
        // Verify sheet overrides
        #expect(xml.contains("<Override PartName=\"/xl/worksheets/sheet1.xml\""))
        #expect(xml.contains("<Override PartName=\"/xl/worksheets/sheet2.xml\""))
        #expect(xml.contains("<Override PartName=\"/xl/worksheets/sheet3.xml\""))
        
        print("Generated Content Types XML:")
        print(xml)
    }
    
    @Test("test generateContentTypesXML No Sheets")
    func testGenerateContentTypesXMLNoSheets() {
        let book = Book(style: BookStyle())
        let xml = book.generateContentTypesXML(sheetCount: 0)
        
        // Should still have core files but no sheet overrides
        #expect(xml.contains("<Override PartName=\"/xl/workbook.xml\""))
        #expect(!xml.contains("<Override PartName=\"/xl/worksheets/sheet"))
        
        print("Content Types XML with no sheets:")
        print(xml)
    }
    
    @Test("test writeContentTypesXML File Creation")
    func testWriteContentTypesXMLFileCreation() throws {
        // Create temp directory
        let tempDir = URL(fileURLWithPath: "/tmp/test_content_types_xml")
        let book = Book(style: BookStyle())
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // Write [Content_Types].xml
        #expect(throws: Never.self) {
            try book.writeContentTypesXML(to: tempDir, sheetCount: 2)
        }
        
        // Verify file exists
        let contentTypesURL = tempDir.appendingPathComponent("[Content_Types].xml")
        #expect(FileManager.default.fileExists(atPath: contentTypesURL.path))
        
        // Read and verify content
        let content = try String(contentsOf: contentTypesURL, encoding: .utf8)
        #expect(content.contains("<Types"))
        #expect(content.contains("</Types>"))
        #expect(content.contains("sheet1.xml"))
        #expect(content.contains("sheet2.xml"))
        
        print("Successfully created [Content_Types].xml at: \(contentTypesURL.path)")
    }
    
    @Test("test generateWorkbookRelsXML Basic")
    func testGenerateWorkbookRelsXMLBasic() {
        // Create test metas
        let metas = [
            SheetMeta(
                name: "Sheet1",
                sheetId: 1,
                relationshipId: "rId1",
                hasHeader: true,
                estimatedDataRowCount: 10,
                activeColumnCount: 3,
                dataRange: nil
            ),
            SheetMeta(
                name: "Sheet2",
                sheetId: 2,
                relationshipId: "rId2",
                hasHeader: false,
                estimatedDataRowCount: 5,
                activeColumnCount: 2,
                dataRange: nil
            )
        ]
        
        let book = Book(style: BookStyle())
        let xml = book.generateWorkbookRelsXML(metas: metas)
        
        // Verify XML structure
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\""))
        #expect(xml.contains("<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"))
        #expect(xml.contains("</Relationships>"))
        
        // Verify sheet relationships
        #expect(xml.contains("<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/>"))
        #expect(xml.contains("<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet2.xml\"/>"))
        
        // Verify styles and sharedStrings relationships
        #expect(xml.contains("<Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>"))
        #expect(xml.contains("<Relationship Id=\"rId4\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings\" Target=\"sharedStrings.xml\"/>"))
        
        print("Generated Workbook Rels XML:")
        print(xml)
    }
    
    @Test("test generateWorkbookRelsXML No Sheets")
    func testGenerateWorkbookRelsXMLNoSheets() {
        let metas: [SheetMeta] = []
        
        let book = Book(style: BookStyle())
        let xml = book.generateWorkbookRelsXML(metas: metas)
        
        // Should still have styles and sharedStrings relationships
        #expect(xml.contains("<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\""))
        #expect(xml.contains("<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings\""))
        #expect(!xml.contains("worksheet"))
        
        print("Workbook Rels XML with no sheets:")
        print(xml)
    }
    
    @Test("test writeWorkbookRelsXML File Creation")
    func testWriteWorkbookRelsXMLFileCreation() throws {
        // Create test meta
        let metas = [
            SheetMeta(
                name: "TestSheet",
                sheetId: 1,
                relationshipId: "rId1",
                hasHeader: true,
                estimatedDataRowCount: 5,
                activeColumnCount: 2,
                dataRange: nil
            )
        ]
        
        // Create temp directory
        let tempDir = URL(fileURLWithPath: "/tmp/test_workbook_rels")
        let book = Book(style: BookStyle())
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // Write workbook.xml.rels
        #expect(throws: Never.self) {
            try book.writeWorkbookRelsXML(to: tempDir, metas: metas)
        }
        
        // Verify file exists
        let workbookRelsURL = tempDir.appendingPathComponent("xl/_rels/workbook.xml.rels")
        #expect(FileManager.default.fileExists(atPath: workbookRelsURL.path))
        
        // Read and verify content
        let content = try String(contentsOf: workbookRelsURL, encoding: .utf8)
        #expect(content.contains("<Relationships"))
        #expect(content.contains("</Relationships>"))
        #expect(content.contains("rId1"))
        #expect(content.contains("worksheet"))
        #expect(content.contains("styles"))
        #expect(content.contains("sharedStrings"))
        
        print("Successfully created workbook.xml.rels at: \(workbookRelsURL.path)")
    }
    
    @Test("test generateRootRelsXML")
    func testGenerateRootRelsXML() {
        let book = Book(style: BookStyle())
        let xml = book.generateRootRelsXML()
        
        // Verify XML structure
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\""))
        #expect(xml.contains("<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"))
        #expect(xml.contains("</Relationships>"))
        
        // Verify the three core relationships
        #expect(xml.contains("<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>"))
        #expect(xml.contains("<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties\" Target=\"docProps/core.xml\"/>"))
        #expect(xml.contains("<Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties\" Target=\"docProps/app.xml\"/>"))
        
        print("Generated Root Rels XML:")
        print(xml)
    }
    
    @Test("test writeRootRelsXML File Creation")
    func testWriteRootRelsXMLFileCreation() throws {
        // Create temp directory
        let tempDir = URL(fileURLWithPath: "/tmp/test_root_rels")
        let book = Book(style: BookStyle())
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // Write _rels/.rels
        #expect(throws: Never.self) {
            try book.writeRootRelsXML(to: tempDir)
        }
        
        // Verify file exists
        let rootRelsURL = tempDir.appendingPathComponent("_rels/.rels")
        #expect(FileManager.default.fileExists(atPath: rootRelsURL.path))
        
        // Read and verify content
        let content = try String(contentsOf: rootRelsURL, encoding: .utf8)
        #expect(content.contains("<Relationships"))
        #expect(content.contains("</Relationships>"))
        #expect(content.contains("officeDocument"))
        #expect(content.contains("core-properties"))
        #expect(content.contains("extended-properties"))
        
        // Verify all three relationships exist
        #expect(content.contains("rId1"))
        #expect(content.contains("rId2"))
        #expect(content.contains("rId3"))
        
        print("Successfully created .rels at: \(rootRelsURL.path)")
    }
}