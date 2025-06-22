//
// TabColorWorkbookTests.swift
// Created by Claude on 2025-06-22.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

/// Tests to verify tab color is properly included in workbook.xml for Excel compatibility.
struct TabColorWorkbookTests {
    
    struct Person: Sendable {
        let name: String
        let age: Int
    }
    
    @Test func tabColorInWorkbookXML() throws {
        let people = [
            Person(name: "Alice", age: 25),
            Person(name: "Bob", age: 30)
        ]
        
        // Create a sheet with tab color
        let sheetStyle = SheetStyle()
            .tabColor(.blue)
        
        let sheet = Sheet<Person>(
            name: "People", 
            style: sheetStyle,
            dataProvider: { people }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        // Load data and create meta
        sheet.loadData()
        let meta = sheet.makeSheetMeta(sheetId: 1)
        
        // Verify meta contains tab color
        #expect(meta.tabColor != nil)
        #expect(meta.tabColor == Color.blue)
        
        // Test workbook XML generation
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])
        let workbookXML = book.generateWorkbookXML(metas: [meta])
        
        // Verify XML contains tab color attribute
        #expect(workbookXML.contains("tabColor"))
        #expect(workbookXML.contains("tabColor=\"\(Color.blue.argbHexString)\""))
        
        print("Generated workbook XML with tab color:")
        print("TabColor value: \(Color.blue.argbHexString)")
        
        // Verify the sheet element structure
        let expectedSheetElement = "<sheet name=\"People\" sheetId=\"1\" r:id=\"rId1\" tabColor=\"\(Color.blue.argbHexString)\"/>"
        #expect(workbookXML.contains(expectedSheetElement))
    }
    
    @Test func multipleTabColorsInWorkbookXML() throws {
        let people = [Person(name: "Alice", age: 25)]
        let products = [Person(name: "Product A", age: 100)] // Reusing Person for simplicity
        
        // Create sheets with different tab colors
        let sheet1 = Sheet<Person>(
            name: "People", 
            style: SheetStyle().tabColor(.red),
            dataProvider: { people }
        ) {
            Column(name: "Name", keyPath: \.name)
        }
        
        let sheet2 = Sheet<Person>(
            name: "Products", 
            style: SheetStyle().tabColor(.green),
            dataProvider: { products }
        ) {
            Column(name: "Name", keyPath: \.name)
        }
        
        // Load data and create metas
        sheet1.loadData()
        sheet2.loadData()
        let meta1 = sheet1.makeSheetMeta(sheetId: 1)
        let meta2 = sheet2.makeSheetMeta(sheetId: 2)
        
        let book = Book(style: BookStyle(), sheets: [
            sheet1.eraseToAnySheet(),
            sheet2.eraseToAnySheet()
        ])
        let workbookXML = book.generateWorkbookXML(metas: [meta1, meta2])
        
        // Verify both tab colors are present
        #expect(workbookXML.contains("tabColor=\"\(Color.red.argbHexString)\""))
        #expect(workbookXML.contains("tabColor=\"\(Color.green.argbHexString)\""))
        
        print("Generated workbook XML with multiple tab colors:")
        print("Red: \(Color.red.argbHexString)")
        print("Green: \(Color.green.argbHexString)")
    }
    
    @Test func noTabColorInWorkbookXML() throws {
        let people = [Person(name: "Alice", age: 25)]
        
        // Create sheet without tab color
        let sheet = Sheet<Person>(
            name: "People", 
            dataProvider: { people }
        ) {
            Column(name: "Name", keyPath: \.name)
        }
        
        sheet.loadData()
        let meta = sheet.makeSheetMeta(sheetId: 1)
        
        // Verify meta has no tab color
        #expect(meta.tabColor == nil)
        
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])
        let workbookXML = book.generateWorkbookXML(metas: [meta])
        
        // Verify XML does NOT contain tab color attribute
        #expect(!workbookXML.contains("tabColor"))
        
        // Verify the sheet element structure without tab color
        let expectedSheetElement = "<sheet name=\"People\" sheetId=\"1\" r:id=\"rId1\"/>"
        #expect(workbookXML.contains(expectedSheetElement))
    }
    
    @Test func customHexTabColor() throws {
        let people = [Person(name: "Alice", age: 25)]
        
        // Create sheet with custom hex color
        let customColor = Color(hex: "FF5733") // Orange color
        let sheet = Sheet<Person>(
            name: "People", 
            style: SheetStyle().tabColor(customColor),
            dataProvider: { people }
        ) {
            Column(name: "Name", keyPath: \.name)
        }
        
        sheet.loadData()
        let meta = sheet.makeSheetMeta(sheetId: 1)
        
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])
        let workbookXML = book.generateWorkbookXML(metas: [meta])
        
        // Verify custom color is present
        #expect(workbookXML.contains("tabColor=\"\(customColor.argbHexString)\""))
        
        print("Custom hex color test:")
        print("Input hex: FF5733")
        print("ARGB hex output: \(customColor.argbHexString)")
    }
    
    @Test func endToEndXLSXGeneration() throws {
        let people = [
            Person(name: "Alice", age: 25),
            Person(name: "Bob", age: 30)
        ]
        
        // Create sheet with tab color
        let sheet = Sheet<Person>(
            name: "Employees", 
            style: SheetStyle().tabColor(.blue),
            dataProvider: { people }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])
        
        // Generate XLSX file
        let tempURL = URL(fileURLWithPath: "/tmp/test_tab_color_\(UUID().uuidString).xlsx")
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        let outputURL = try book.write(to: tempURL)
        
        // Verify file was created
        #expect(FileManager.default.fileExists(atPath: outputURL.path))
        
        // Verify file size is reasonable
        let attributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
        let fileSize = attributes[FileAttributeKey.size] as? Int ?? 0
        #expect(fileSize > 1000) // Should be at least 1KB for a valid XLSX
        
        print("End-to-end test completed:")
        print("Generated XLSX file: \(outputURL.path)")
        print("File size: \(fileSize) bytes")
        print("Tab color should appear as blue in Excel")
    }
}