//
// BookWriteTests.swift
// Created by Claude on 2025-06-20.
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Book Write Tests")
struct BookWriteTests {
    @Test("test generateAndWriteSheetXML Basic Functionality")
    func generateAndWriteSheetXMLBasic() throws {
        // Create test data
        let testData = [
            TestPerson(name: "Alice", age: 30, email: "alice@test.com"),
            TestPerson(name: "Bob", age: 25, email: "bob@test.com"),
        ]

        // Create sheet
        let sheet = Sheet(name: "TestSheet", hasHeader: true, dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Email", keyPath: \.email)
        }

        // Create book
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])

        // Create registers
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        // Load data and create meta
        book.sheets[0].loadData()
        let meta = book.sheets[0].makeSheetMeta(sheetId: 1)

        // Create temp directory for testing
        let tempURL = URL(fileURLWithPath: "/tmp/test_xlsx_basic")
        try book.createXLSXDirectoryStructure(at: tempURL)

        // Test generateAndWriteSheetXML
        #expect(throws: Never.self) {
            try book.generateAndWriteSheetXML(
                sheet: book.sheets[0],
                meta: meta,
                tempDir: tempURL,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)
        }

        // Verify file was created
        let sheetFileURL = tempURL.appendingPathComponent(meta.filePath)
        #expect(FileManager.default.fileExists(atPath: sheetFileURL.path))

        print("Basic generateAndWriteSheetXML test completed successfully")
        print("Sheet: \(meta.name), Rows: \(meta.totalRowCount), Columns: \(meta.activeColumnCount)")
    }

    @Test("test generateAndWriteSheetXML Empty Sheet")
    func generateAndWriteSheetXMLEmpty() throws {
        // Create empty sheet
        let emptySheet = Sheet<TestPerson>(name: "EmptySheet", hasHeader: true, dataProvider: { [] }) {
            Column(name: "Name", keyPath: \.name)
        }

        // Create book
        let book = Book(style: BookStyle(), sheets: [emptySheet.eraseToAnySheet()])

        // Create registers
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        // Load data and create meta
        book.sheets[0].loadData()
        let meta = book.sheets[0].makeSheetMeta(sheetId: 1)

        // Create temp directory for testing
        let tempURL = URL(fileURLWithPath: "/tmp/test_xlsx_empty")
        try book.createXLSXDirectoryStructure(at: tempURL)

        // Test generateAndWriteSheetXML with empty data
        #expect(throws: Never.self) {
            try book.generateAndWriteSheetXML(
                sheet: book.sheets[0],
                meta: meta,
                tempDir: tempURL,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)
        }

        // Verify file was created
        let sheetFileURL = tempURL.appendingPathComponent(meta.filePath)
        #expect(FileManager.default.fileExists(atPath: sheetFileURL.path))

        print("Empty sheet generateAndWriteSheetXML test completed successfully")
        print("Empty sheet has header: \(meta.hasHeader), Data rows: \(meta.estimatedDataRowCount)")
    }

    @Test("test Complete Write Flow")
    func completeWriteFlow() throws {
        // Create test data for multiple sheets
        let people = [
            TestPerson(name: "John", age: 30, email: "john@test.com"),
            TestPerson(name: "Jane", age: 25, email: "jane@test.com"),
        ]

        let products = [
            TestProduct(name: "iPhone", price: 999.0),
            TestProduct(name: "MacBook", price: 1999.0),
            TestProduct(name: "iPad", price: 599.0),
        ]

        // Create sheets
        let peopleSheet = Sheet(name: "People", hasHeader: true, dataProvider: { people }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Email", keyPath: \.email)
        }

        let productsSheet = Sheet(name: "Products", hasHeader: true, dataProvider: { products }) {
            Column(name: "Product", keyPath: \.name)
            Column(name: "Price", keyPath: \.price)
        }

        // Create book
        let book = Book(style: BookStyle(), sheets: [
            peopleSheet.eraseToAnySheet(),
            productsSheet.eraseToAnySheet(),
        ])

        // Test complete write flow
        let outputURL = URL(fileURLWithPath: "/tmp/test_complete.xlsx")

        #expect(throws: Never.self) {
            try book.write(to: outputURL)
        }

        // Verify temp directory was cleaned up (should not exist after successful write)
        let tempDir = outputURL.deletingPathExtension().appendingPathExtension("temp")
        #expect(!FileManager.default.fileExists(atPath: tempDir.path), "Temp directory should be cleaned up after successful write")

        print("Complete write flow test completed successfully")
        print("Processed \(book.sheets.count) sheets")
    }

    @Test("test generateAndWriteSheetXML with Nil DataProvider")
    func generateAndWriteSheetXMLWithNilDataProvider() throws {
        // Create sheet without data provider (nil)
        let sheet = Sheet<TestPerson>(name: "NoDataSheet", hasHeader: true, dataProvider: nil) {
            Column(name: "Name", keyPath: \.name)
        }

        // Create book
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])

        // Create registers
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        // Load data (will be empty due to nil dataProvider)
        book.sheets[0].loadData()
        let meta = book.sheets[0].makeSheetMeta(sheetId: 1)

        // Create temp directory for testing
        let tempURL = URL(fileURLWithPath: "/tmp/test_xlsx_nil_provider")
        try book.createXLSXDirectoryStructure(at: tempURL)

        // Even with nil dataProvider, this should succeed (creates empty sheet with header)
        #expect(throws: Never.self) {
            try book.generateAndWriteSheetXML(
                sheet: book.sheets[0],
                meta: meta,
                tempDir: tempURL,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)
        }

        // Verify file was created
        let sheetFileURL = tempURL.appendingPathComponent(meta.filePath)
        #expect(FileManager.default.fileExists(atPath: sheetFileURL.path))

        // Verify the meta reflects empty data
        #expect(meta.estimatedDataRowCount == 0)
        #expect(meta.hasHeader == true)
        #expect(meta.totalRowCount == 1) // Only header row

        print("Nil dataProvider test completed - empty sheet with header generated successfully")
        print("Sheet meta: data rows=\(meta.estimatedDataRowCount), total rows=\(meta.totalRowCount)")
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
