//
// RowHeightTests.swift
// Created by Xu Yang on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

@testable import Objects2XLSX
import Testing

private struct TestItem {
    let id: Int
    let name: String
    let description: String
    let value: Double
}

@Suite("Row Height Tests")
struct RowHeightTests {
    @Test("Default row height")
    func defaultRowHeight() throws {
        let items = [
            TestItem(id: 1, name: "Item A", description: "Description A", value: 100.0),
            TestItem(id: 2, name: "Item B", description: "Description B", value: 200.0),
        ]

        let columns: [AnyColumn<TestItem>] = [
            Column<TestItem, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
            Column<TestItem, Double, DoubleColumnType>(name: "Value", keyPath: \.value)
                .eraseToAnyColumn(),
        ]

        // Create sheet without custom row heights
        let sheet = Sheet(name: "Items", dataProvider: { items }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let rows = sheetXML!.rows
        #expect(rows.count == 3) // 1 header + 2 data rows

        // Check that all rows use default height (15.0)
        #expect(rows[0].height == 15.0) // Header
        #expect(rows[1].height == 15.0) // First data row
        #expect(rows[2].height == 15.0) // Second data row
    }

    @Test("Custom default row height")
    func customDefaultRowHeight() throws {
        let items = [
            TestItem(id: 1, name: "Item A", description: "Description A", value: 100.0),
            TestItem(id: 2, name: "Item B", description: "Description B", value: 200.0),
            TestItem(id: 3, name: "Item C", description: "Description C", value: 300.0),
        ]

        let columns: [AnyColumn<TestItem>] = [
            Column<TestItem, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
            Column<TestItem, String, TextColumnType>(name: "Description", keyPath: \.description)
                .eraseToAnyColumn(),
        ]

        var sheetStyle = SheetStyle()
        sheetStyle.defaultRowHeight = 20.0 // Custom default height

        let sheet = Sheet(name: "Items", style: sheetStyle, dataProvider: { items }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let rows = sheetXML!.rows
        #expect(rows.count == 4) // 1 header + 3 data rows

        // All rows should use custom default height
        for row in rows {
            #expect(row.height == 20.0)
        }
    }

    @Test("Individual row heights override default")
    func individualRowHeights() throws {
        let items = [
            TestItem(id: 1, name: "Item A", description: "Short", value: 100.0),
            TestItem(id: 2, name: "Item B", description: "Very long description that might need more space", value: 200.0),
            TestItem(id: 3, name: "Item C", description: "Normal", value: 300.0),
            TestItem(id: 4, name: "Item D", description: "Another long description with multiple lines of text", value: 400.0),
        ]

        let columns: [AnyColumn<TestItem>] = [
            Column<TestItem, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
            Column<TestItem, String, TextColumnType>(name: "Description", keyPath: \.description)
                .eraseToAnyColumn(),
        ]

        var sheetStyle = SheetStyle()
        sheetStyle.defaultRowHeight = 18.0
        // Set specific row heights (1-based indexing)
        sheetStyle.rowHeights[1] = 30.0 // Header row - taller
        sheetStyle.rowHeights[3] = 40.0 // Row with long description
        sheetStyle.rowHeights[5] = 35.0 // Another row with long description

        let sheet = Sheet(name: "Items", style: sheetStyle, dataProvider: { items }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let rows = sheetXML!.rows
        #expect(rows.count == 5) // 1 header + 4 data rows

        // Check specific row heights
        #expect(rows[0].height == 30.0) // Header (row 1)
        #expect(rows[1].height == 18.0) // Row 2 - default
        #expect(rows[2].height == 40.0) // Row 3 - custom
        #expect(rows[3].height == 18.0) // Row 4 - default
        #expect(rows[4].height == 35.0) // Row 5 - custom

        // Verify XML output contains correct row height attributes
        let xmlContent = sheetXML!.generateXML()
        #expect(xmlContent.contains("<row r=\"1\" ht=\"30.0\" customHeight=\"1\">")) // Header
        #expect(xmlContent.contains("<row r=\"2\" ht=\"18.0\" customHeight=\"1\">")) // Default height
        #expect(xmlContent.contains("<row r=\"3\" ht=\"40.0\" customHeight=\"1\">")) // Custom height
        #expect(xmlContent.contains("<row r=\"4\" ht=\"18.0\" customHeight=\"1\">")) // Default height
        #expect(xmlContent.contains("<row r=\"5\" ht=\"35.0\" customHeight=\"1\">")) // Custom height

        // Verify default row height in sheet format
        #expect(xmlContent.contains("defaultRowHeight=\"18.0\""))
    }

    @Test("Row heights with no header")
    func rowHeightsWithNoHeader() throws {
        let items = [
            TestItem(id: 1, name: "Item A", description: "Description A", value: 100.0),
            TestItem(id: 2, name: "Item B", description: "Description B", value: 200.0),
        ]

        let columns: [AnyColumn<TestItem>] = [
            Column<TestItem, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
            Column<TestItem, Double, DoubleColumnType>(name: "Value", keyPath: \.value)
                .eraseToAnyColumn(),
        ]

        var sheetStyle = SheetStyle()
        sheetStyle.defaultRowHeight = 25.0
        sheetStyle.rowHeights[1] = 30.0 // First data row (no header)
        sheetStyle.rowHeights[2] = 35.0 // Second data row

        let sheet = Sheet(
            name: "Items",
            hasHeader: false, // No header
            style: sheetStyle,
            dataProvider: { items },
            columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let rows = sheetXML!.rows
        #expect(rows.count == 2) // No header, only 2 data rows

        // Check row heights
        #expect(rows[0].height == 30.0) // First data row (row 1)
        #expect(rows[1].height == 35.0) // Second data row (row 2)
    }

    @Test("Row heights preserved with empty data")
    func rowHeightsWithEmptyData() throws {
        let items: [TestItem] = []

        let columns: [AnyColumn<TestItem>] = [
            Column<TestItem, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
            Column<TestItem, String, TextColumnType>(name: "Description", keyPath: \.description)
                .eraseToAnyColumn(),
        ]

        var sheetStyle = SheetStyle()
        sheetStyle.defaultRowHeight = 22.0
        sheetStyle.rowHeights[1] = 40.0 // Header row height should still apply

        let sheet = Sheet(name: "Empty", style: sheetStyle, dataProvider: { items }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let rows = sheetXML!.rows
        #expect(rows.count == 1) // Only header row

        // Header row should use custom height
        #expect(rows[0].height == 40.0)
    }

    @Test("Row heights with large dataset")
    func rowHeightsLargeDataset() throws {
        let itemCount = 100
        let items = (1 ... itemCount).map { i in
            TestItem(
                id: i,
                name: "Item \(i)",
                description: i % 10 == 0 ? "Long description for every 10th item" : "Normal",
                value: Double(i * 10))
        }

        let columns: [AnyColumn<TestItem>] = [
            Column<TestItem, Int, IntColumnType>(name: "ID", keyPath: \.id)
                .eraseToAnyColumn(),
            Column<TestItem, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
            Column<TestItem, String, TextColumnType>(name: "Description", keyPath: \.description)
                .eraseToAnyColumn(),
        ]

        var sheetStyle = SheetStyle()
        sheetStyle.defaultRowHeight = 16.0
        sheetStyle.rowHeights[1] = 25.0 // Header

        // Set custom heights for every 10th row
        for i in 1 ... 10 {
            let rowIndex = i * 10 + 1 // +1 for header offset
            sheetStyle.rowHeights[rowIndex] = 30.0
        }

        let sheet = Sheet(name: "Large Dataset", style: sheetStyle, dataProvider: { items }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let rows = sheetXML!.rows
        #expect(rows.count == itemCount + 1) // +1 for header

        // Check header height
        #expect(rows[0].height == 25.0)

        // Check every 10th data row has custom height
        for i in 1 ... 10 {
            let rowIndex = i * 10 // No +1 here because rows array is 0-based
            #expect(rows[rowIndex].height == 30.0)
        }

        // Check other rows use default height
        #expect(rows[5].height == 16.0) // Random check
        #expect(rows[15].height == 16.0) // Random check
    }

    @Test("Row height precision")
    func rowHeightPrecision() throws {
        let items = [
            TestItem(id: 1, name: "Item", description: "Test", value: 100.0),
        ]

        let columns: [AnyColumn<TestItem>] = [
            Column<TestItem, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
        ]

        var sheetStyle = SheetStyle()
        // Test various decimal precisions
        sheetStyle.rowHeights[1] = 15.5
        sheetStyle.rowHeights[2] = 20.25
        sheetStyle.defaultRowHeight = 18.75

        let sheet = Sheet(name: "Precision", style: sheetStyle, dataProvider: { items }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let rows = sheetXML!.rows

        // Check decimal precision is preserved
        #expect(rows[0].height == 15.5) // Header
        #expect(rows[1].height == 20.25) // Data row

        // Verify XML output contains precise decimal values
        let xmlContent = sheetXML!.generateXML()
        #expect(xmlContent.contains("<row r=\"1\" ht=\"15.5\" customHeight=\"1\">")) // Header with decimal
        #expect(xmlContent.contains("<row r=\"2\" ht=\"20.25\" customHeight=\"1\">")) // Data row with decimal
        #expect(xmlContent.contains("defaultRowHeight=\"18.75\"")) // Default height with decimal
    }
}
