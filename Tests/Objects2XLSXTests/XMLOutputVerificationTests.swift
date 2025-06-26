//
// XMLOutputVerificationTests.swift
// Created by Xu Yang on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

@testable import Objects2XLSX
import Testing

private struct TestRecord {
    let id: Int
    let title: String
    let status: String
    let priority: Double
}

@Suite("XML Output Verification Tests")
struct XMLOutputVerificationTests {
    @Test("Column widths generate correct XML cols elements")
    func columnWidthsXMLGeneration() throws {
        let records = [
            TestRecord(id: 1, title: "Task A", status: "Active", priority: 1.0),
            TestRecord(id: 2, title: "Task B", status: "Pending", priority: 2.5)
        ]

        let columns: [AnyColumn<TestRecord>] = [
            Column<TestRecord, Int, IntColumnType>(name: "ID", keyPath: \.id)
                .width(6)
                .eraseToAnyColumn(),
            Column<TestRecord, String, TextColumnType>(name: "Title", keyPath: \.title)
                .width(25)
                .eraseToAnyColumn(),
            Column<TestRecord, String, TextColumnType>(name: "Status", keyPath: \.status)
                .width(12)
                .eraseToAnyColumn(),
            Column<TestRecord, Double, DoubleColumnType>(name: "Priority", keyPath: \.priority)
                .width(10)
                .eraseToAnyColumn()
        ]

        let sheet = Sheet(name: "Records", dataProvider: { records }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let xmlContent = sheetXML!.generateXML()

        // Verify <cols> section exists
        #expect(xmlContent.contains("<cols>"))
        #expect(xmlContent.contains("</cols>"))

        // Verify individual column definitions (1-based indexing)
        #expect(xmlContent.contains("<col min=\"1\" max=\"1\" width=\"6.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"2\" max=\"2\" width=\"25.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"3\" max=\"3\" width=\"12.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"4\" max=\"4\" width=\"10.0\" customWidth=\"1\"/>"))

        // Verify columns are properly ordered
        let colsStartIndex = xmlContent.range(of: "<cols>")!.upperBound
        let colsEndIndex = xmlContent.range(of: "</cols>")!.lowerBound
        let colsContent = String(xmlContent[colsStartIndex ..< colsEndIndex])

        // Check order by finding positions
        let col1Pos = colsContent.range(of: "min=\"1\"")?.lowerBound
        let col2Pos = colsContent.range(of: "min=\"2\"")?.lowerBound
        let col3Pos = colsContent.range(of: "min=\"3\"")?.lowerBound
        let col4Pos = colsContent.range(of: "min=\"4\"")?.lowerBound

        #expect(col1Pos != nil && col2Pos != nil && col3Pos != nil && col4Pos != nil)
        #expect(col1Pos! < col2Pos!)
        #expect(col2Pos! < col3Pos!)
        #expect(col3Pos! < col4Pos!)
    }

    @Test("Row heights generate correct XML row elements with ht attributes")
    func rowHeightsXMLGeneration() throws {
        let records = [
            TestRecord(id: 1, title: "Short task", status: "Active", priority: 1.0),
            TestRecord(id: 2, title: "Medium length task description", status: "Pending", priority: 2.0),
            TestRecord(id: 3, title: "Very long task description that requires multiple lines and takes up more space", status: "Complete", priority: 3.0)
        ]

        let columns: [AnyColumn<TestRecord>] = [
            Column<TestRecord, String, TextColumnType>(name: "Title", keyPath: \.title)
                .eraseToAnyColumn(),
            Column<TestRecord, String, TextColumnType>(name: "Status", keyPath: \.status)
                .eraseToAnyColumn()
        ]

        var sheetStyle = SheetStyle()
        sheetStyle.defaultRowHeight = 16.0
        sheetStyle.rowHeights[1] = 28.0 // Header - bigger
        sheetStyle.rowHeights[2] = 18.0 // First data row - slightly bigger
        sheetStyle.rowHeights[4] = 32.0 // Third data row - much bigger for long text
        // Second data row (row 3) will use default height

        let sheet = Sheet(name: "Records", style: sheetStyle, dataProvider: { records }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let xmlContent = sheetXML!.generateXML()

        // Verify <sheetData> section exists
        #expect(xmlContent.contains("<sheetData>"))
        #expect(xmlContent.contains("</sheetData>"))

        // Verify individual row elements with height attributes
        #expect(xmlContent.contains("<row r=\"1\" ht=\"28.0\" customHeight=\"1\">")) // Header
        #expect(xmlContent.contains("<row r=\"2\" ht=\"18.0\" customHeight=\"1\">")) // First data
        #expect(xmlContent.contains("<row r=\"3\" ht=\"16.0\" customHeight=\"1\">")) // Second data (default)
        #expect(xmlContent.contains("<row r=\"4\" ht=\"32.0\" customHeight=\"1\">")) // Third data

        // Verify default row height in sheetFormatPr
        #expect(xmlContent.contains("<sheetFormatPr"))
        #expect(xmlContent.contains("defaultRowHeight=\"16.0\""))

        // Verify all rows are closed properly
        #expect(xmlContent.contains("</row>"))

        // Count row elements to ensure we have the expected number
        let rowOpenTags = xmlContent.components(separatedBy: "<row r=")
        #expect(rowOpenTags.count == 5) // Original string + 4 rows
    }

    @Test("Combined column widths and row heights in XML")
    func combinedWidthsAndHeightsXMLGeneration() throws {
        let records = [
            TestRecord(id: 1, title: "Task One", status: "Active", priority: 1.0),
            TestRecord(id: 2, title: "Task Two", status: "Pending", priority: 2.0)
        ]

        let columns: [AnyColumn<TestRecord>] = [
            Column<TestRecord, Int, IntColumnType>(name: "ID", keyPath: \.id)
                .width(8)
                .eraseToAnyColumn(),
            Column<TestRecord, String, TextColumnType>(name: "Title", keyPath: \.title)
                .width(30)
                .eraseToAnyColumn(),
            Column<TestRecord, Double, DoubleColumnType>(name: "Priority", keyPath: \.priority)
                .width(15)
                .eraseToAnyColumn()
        ]

        var sheetStyle = SheetStyle()
        sheetStyle.defaultRowHeight = 20.0
        sheetStyle.defaultColumnWidth = 10.0
        sheetStyle.rowHeights[1] = 35.0 // Header
        sheetStyle.rowHeights[2] = 25.0 // First data row

        let sheet = Sheet(name: "Combined", style: sheetStyle, dataProvider: { records }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let xmlContent = sheetXML!.generateXML()

        // Verify sheet format properties
        #expect(xmlContent.contains("<sheetFormatPr"))
        #expect(xmlContent.contains("defaultRowHeight=\"20.0\""))
        #expect(xmlContent.contains("defaultColWidth=\"10.0\""))

        // Verify column definitions
        #expect(xmlContent.contains("<cols>"))
        #expect(xmlContent.contains("<col min=\"1\" max=\"1\" width=\"8.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"2\" max=\"2\" width=\"30.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"3\" max=\"3\" width=\"15.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("</cols>"))

        // Verify row definitions
        #expect(xmlContent.contains("<sheetData>"))
        #expect(xmlContent.contains("<row r=\"1\" ht=\"35.0\" customHeight=\"1\">")) // Header
        #expect(xmlContent.contains("<row r=\"2\" ht=\"25.0\" customHeight=\"1\">")) // First data
        #expect(xmlContent.contains("<row r=\"3\" ht=\"20.0\" customHeight=\"1\">")) // Second data (default)
        #expect(xmlContent.contains("</sheetData>"))

        // Verify XML structure order (sheetFormatPr should come before cols, cols before sheetData)
        let sheetFormatPos = xmlContent.range(of: "<sheetFormatPr")?.lowerBound
        let colsPos = xmlContent.range(of: "<cols>")?.lowerBound
        let sheetDataPos = xmlContent.range(of: "<sheetData>")?.lowerBound

        #expect(sheetFormatPos != nil && colsPos != nil && sheetDataPos != nil)
        #expect(sheetFormatPos! < colsPos!)
        #expect(colsPos! < sheetDataPos!)
    }

    @Test("XML output without custom dimensions uses defaults")
    func defaultDimensionsXMLGeneration() throws {
        let records = [
            TestRecord(id: 1, title: "Task", status: "Active", priority: 1.0)
        ]

        let columns: [AnyColumn<TestRecord>] = [
            Column<TestRecord, String, TextColumnType>(name: "Title", keyPath: \.title)
                .eraseToAnyColumn()
            // No width specified
        ]

        // Use default SheetStyle without custom heights or widths
        let sheet = Sheet(name: "Defaults", dataProvider: { records }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let xmlContent = sheetXML!.generateXML()

        // Should have default format but no custom cols section
        #expect(xmlContent.contains("<sheetFormatPr"))
        #expect(xmlContent.contains("defaultRowHeight=\"15.0\"")) // Default
        #expect(xmlContent.contains("defaultColWidth=\"8.43\"")) // Default

        // Should NOT have cols section since no custom widths
        #expect(!xmlContent.contains("<cols>"))

        // Rows should have default height with explicit ht attribute
        #expect(xmlContent.contains("<row r=\"1\" ht=\"15.0\" customHeight=\"1\">")) // Header with default
        #expect(xmlContent.contains("<row r=\"2\" ht=\"15.0\" customHeight=\"1\">")) // Data with default
    }

    @Test("XML escaping in dimensions")
    func xmlEscapingInDimensions() throws {
        let records = [
            TestRecord(id: 1, title: "Test", status: "Active", priority: 1.0)
        ]

        let columns: [AnyColumn<TestRecord>] = [
            Column<TestRecord, String, TextColumnType>(name: "Title", keyPath: \.title)
                .width(20)
                .eraseToAnyColumn()
        ]

        var sheetStyle = SheetStyle()
        // Test edge case decimal values
        sheetStyle.defaultRowHeight = 15.123456789
        sheetStyle.rowHeights[1] = 25.987654321

        let sheet = Sheet(name: "Escaping", style: sheetStyle, dataProvider: { records }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let xmlContent = sheetXML!.generateXML()

        // Verify decimal precision handling
        #expect(xmlContent.contains("defaultRowHeight=\"15.123456789\""))
        #expect(xmlContent.contains("ht=\"25.987654321\""))
        #expect(xmlContent.contains("width=\"20.0\"")) // Integer width converted to double

        // Verify XML is well-formed (basic check)
        #expect(xmlContent.contains("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"))
        #expect(xmlContent.hasPrefix("<?xml"))
        #expect(xmlContent.hasSuffix("</worksheet>"))
    }
}
