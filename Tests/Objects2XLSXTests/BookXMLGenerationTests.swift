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
}