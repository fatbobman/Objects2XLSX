//
// SheetMetaTests.swift
// Created by Claude on 2025-06-20.
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Sheet Meta Tests")
struct SheetMetaTests {
    @Test("test SheetMeta Creation")
    func sheetMetaCreation() {
        let dataRange = SheetMeta.DataRangeInfo(
            startRow: 1,
            startColumn: 1,
            endRow: 10,
            endColumn: 5)

        let meta = SheetMeta(
            name: "TestSheet",
            sheetId: 1,
            relationshipId: "rId1",
            hasHeader: true,
            estimatedDataRowCount: 9,
            activeColumnCount: 5,
            dataRange: dataRange)

        #expect(meta.name == "TestSheet")
        #expect(meta.sheetId == 1)
        #expect(meta.relationshipId == "rId1")
        #expect(meta.hasHeader == true)
        #expect(meta.estimatedDataRowCount == 9)
        #expect(meta.activeColumnCount == 5)
        #expect(meta.totalRowCount == 10) // 9 data rows + 1 header
        #expect(meta.filePath == "xl/worksheets/sheet1.xml")

        // Test data range
        #expect(meta.dataRange?.excelRange == "A1:E10")

        print("SheetMeta creation test completed")
        print("Total rows: \(meta.totalRowCount)")
        print("File path: \(meta.filePath)")
        print("Excel range: \(meta.dataRange?.excelRange ?? "None")")
    }

    @Test("test SheetMeta without Header")
    func sheetMetaWithoutHeader() {
        let meta = SheetMeta(
            name: "NoHeaderSheet",
            sheetId: 2,
            relationshipId: "rId2",
            hasHeader: false,
            estimatedDataRowCount: 5,
            activeColumnCount: 3,
            dataRange: nil)

        #expect(meta.hasHeader == false)
        #expect(meta.estimatedDataRowCount == 5)
        #expect(meta.totalRowCount == 5) // No header, so same as data rows
        #expect(meta.filePath == "xl/worksheets/sheet2.xml")
        #expect(meta.dataRange == nil)

        print("SheetMeta without header test completed")
        print("Total rows (no header): \(meta.totalRowCount)")
    }

    @Test("test DataRangeInfo Excel Range Conversion")
    func dataRangeInfoExcelRange() {
        // Test single cell
        let singleCell = SheetMeta.DataRangeInfo(
            startRow: 1, startColumn: 1,
            endRow: 1, endColumn: 1)
        #expect(singleCell.excelRange == "A1:A1")

        // Test multiple columns
        let multiColumn = SheetMeta.DataRangeInfo(
            startRow: 1, startColumn: 1,
            endRow: 5, endColumn: 26)
        #expect(multiColumn.excelRange == "A1:Z5")

        // Test beyond Z column
        let beyondZ = SheetMeta.DataRangeInfo(
            startRow: 2, startColumn: 1,
            endRow: 10, endColumn: 27)
        #expect(beyondZ.excelRange == "A2:AA10")

        // Test large range
        let largeRange = SheetMeta.DataRangeInfo(
            startRow: 1, startColumn: 1,
            endRow: 1000, endColumn: 100)
        #expect(largeRange.excelRange == "A1:CV1000")

        print("Excel range conversion test completed")
        print("Single cell: \(singleCell.excelRange)")
        print("Multi column: \(multiColumn.excelRange)")
        print("Beyond Z: \(beyondZ.excelRange)")
        print("Large range: \(largeRange.excelRange)")
    }

    @Test("test Sheet makeSheetMeta")
    func sheetMakeSheetMeta() {
        // Create test data
        let testObjects = [
            TestPerson(name: "John", age: 30, email: "john@test.com"),
            TestPerson(name: "Jane", age: 25, email: "jane@test.com"),
            TestPerson(name: "Bob", age: 35, email: "bob@test.com")
        ]

        // Create sheet with data provider
        let sheet = Sheet(name: "People", hasHeader: true, dataProvider: { testObjects }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Email", keyPath: \.email)
        }

        // Load data first, then generate SheetMeta
        sheet.loadData()
        let meta = sheet.makeSheetMeta(sheetId: 1)

        #expect(meta.name == "People")
        #expect(meta.sheetId == 1)
        #expect(meta.relationshipId == "rId1")
        #expect(meta.hasHeader == true)
        #expect(meta.estimatedDataRowCount == 3)
        #expect(meta.activeColumnCount == 3)
        #expect(meta.totalRowCount == 4) // 3 data rows + 1 header
        #expect(meta.filePath == "xl/worksheets/sheet1.xml")

        // Check data range
        #expect(meta.dataRange?.startRow == 1)
        #expect(meta.dataRange?.startColumn == 1)
        #expect(meta.dataRange?.endRow == 4)
        #expect(meta.dataRange?.endColumn == 3)
        #expect(meta.dataRange?.excelRange == "A1:C4")

        print("Sheet makeSheetMeta test completed")
        print("Generated meta for sheet: \(meta.name)")
        print("Data rows: \(meta.estimatedDataRowCount)")
        print("Active columns: \(meta.activeColumnCount)")
        print("Excel range: \(meta.dataRange?.excelRange ?? "None")")
    }

    @Test("test AnySheet makeSheetMeta")
    func anySheetMakeSheetMeta() {
        // Create test data
        let testObjects = [
            TestPerson(name: "Alice", age: 28, email: "alice@test.com"),
            TestPerson(name: "Charlie", age: 32, email: "charlie@test.com")
        ]

        // Create sheet and convert to AnySheet
        let sheet = Sheet(name: "Team", hasHeader: true, dataProvider: { testObjects }) {
            Column(name: "Full Name", keyPath: \.name)
            Column(name: "Years", keyPath: \.age)
        }

        let anySheet = sheet.eraseToAnySheet()

        // Test basic properties
        #expect(anySheet.name == "Team")
        #expect(anySheet.hasHeader == true)
        #expect(anySheet.estimatedDataRowCount() == 0) // Not loaded yet

        // Load data first, then generate SheetMeta
        anySheet.loadData()
        let meta = anySheet.makeSheetMeta(sheetId: 2)

        #expect(meta.name == "Team")
        #expect(meta.sheetId == 2)
        #expect(meta.relationshipId == "rId2")
        #expect(meta.hasHeader == true)
        #expect(meta.estimatedDataRowCount == 2)
        #expect(meta.activeColumnCount == 2)
        #expect(meta.totalRowCount == 3) // 2 data rows + 1 header
        #expect(meta.filePath == "xl/worksheets/sheet2.xml")
        #expect(meta.dataRange?.excelRange == "A1:B3")

        print("AnySheet makeSheetMeta test completed")
        print("AnySheet name: \(anySheet.name)")
        print("Meta generated for sheet ID: \(meta.sheetId)")
        print("Excel range: \(meta.dataRange?.excelRange ?? "None")")
    }

    @Test("test Book collectSheetMetas")
    func bookCollectSheetMetas() {
        // Create test data
        let people = [
            TestPerson(name: "Person1", age: 20, email: "p1@test.com"),
            TestPerson(name: "Person2", age: 25, email: "p2@test.com")
        ]

        let products = [
            TestProduct(name: "Product1", price: 10.0),
            TestProduct(name: "Product2", price: 20.0),
            TestProduct(name: "Product3", price: 30.0)
        ]

        // Create sheets
        let peopleSheet = Sheet(name: "People", hasHeader: true, dataProvider: { people }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }

        let productsSheet = Sheet(name: "Products", hasHeader: false, dataProvider: { products }) {
            Column(name: "Product Name", keyPath: \.name)
            Column(name: "Price", keyPath: \.price)
        }

        // Create book
        let book = Book(style: BookStyle(), sheets: [
            peopleSheet.eraseToAnySheet(),
            productsSheet.eraseToAnySheet()
        ])

        // For testing, we'll test through the sheets directly since collectSheetMetas() is private
        // In real usage, this would be called internally by write()
        // Load data first, then generate metas
        book.sheets[0].loadData()
        book.sheets[1].loadData()
        let sheet1Meta = book.sheets[0].makeSheetMeta(sheetId: 1)
        let sheet2Meta = book.sheets[1].makeSheetMeta(sheetId: 2)

        // Verify first sheet (People)
        #expect(sheet1Meta.name == "People")
        #expect(sheet1Meta.sheetId == 1)
        #expect(sheet1Meta.hasHeader == true)
        #expect(sheet1Meta.estimatedDataRowCount == 2)
        #expect(sheet1Meta.activeColumnCount == 2)
        #expect(sheet1Meta.totalRowCount == 3)
        #expect(sheet1Meta.relationshipId == "rId1")

        // Verify second sheet (Products)
        #expect(sheet2Meta.name == "Products")
        #expect(sheet2Meta.sheetId == 2)
        #expect(sheet2Meta.hasHeader == false)
        #expect(sheet2Meta.estimatedDataRowCount == 3)
        #expect(sheet2Meta.activeColumnCount == 2)
        #expect(sheet2Meta.totalRowCount == 3) // No header
        #expect(sheet2Meta.relationshipId == "rId2")

        print("Book collectSheetMetas test completed")
        print("Sheet 1: \(sheet1Meta.name), rows: \(sheet1Meta.totalRowCount)")
        print("Sheet 2: \(sheet2Meta.name), rows: \(sheet2Meta.totalRowCount)")
    }

    @Test("test Empty Sheet Meta")
    func emptySheetMeta() {
        // Create sheet with no data
        let emptySheet = Sheet<TestPerson>(name: "Empty", hasHeader: true, dataProvider: { [] }) {
            Column(name: "Name", keyPath: \.name)
        }

        // Load data first, then generate SheetMeta
        emptySheet.loadData()
        let meta = emptySheet.makeSheetMeta(sheetId: 1)

        #expect(meta.name == "Empty")
        #expect(meta.estimatedDataRowCount == 0)
        #expect(meta.activeColumnCount == 0) // No active columns for empty data
        #expect(meta.totalRowCount == 1) // Only header row
        #expect(meta.dataRange == nil) // No data range for empty sheet

        print("Empty sheet meta test completed")
        print("Empty sheet total rows: \(meta.totalRowCount)")
        print("Active columns: \(meta.activeColumnCount)")
    }
}

// Test helper structs
private struct TestPerson {
    let name: String
    let age: Int
    let email: String
}

private struct TestProduct {
    let name: String
    let price: Double
}
