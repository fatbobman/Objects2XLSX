//
// ColumnWidthTests.swift
// Created by Xu Yang on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

@testable import Objects2XLSX
import Testing

private struct TestProductWithDesc {
    let id: Int
    let name: String
    let price: Double
    let description: String?
}

@Suite("Column Width Tests")
struct ColumnWidthTests {
    @Test("Column width defined in Column should transfer to SheetStyle")
    func columnWidthTransfer() throws {
        let products = [
            TestProductWithDesc(id: 1, name: "Product A", price: 99.99, description: "A very long description that requires more space"),
            TestProductWithDesc(id: 2, name: "Product B", price: 149.99, description: nil),
            TestProductWithDesc(id: 3, name: "Product C", price: 199.99, description: "Short desc")
        ]

        let columns: [AnyColumn<TestProductWithDesc>] = [
            Column<TestProductWithDesc, Int, IntColumnType>(name: "ID", keyPath: \.id)
                .width(5)
                .eraseToAnyColumn(),
            Column<TestProductWithDesc, String, TextColumnType>(name: "Name", keyPath: \.name)
                .width(20)
                .eraseToAnyColumn(),
            Column<TestProductWithDesc, Double, DoubleColumnType>(name: "Price", keyPath: \.price)
                .width(15)
                .eraseToAnyColumn(),
            Column<TestProductWithDesc, String?, TextColumnType>(name: "Description", keyPath: \.description, mapping: { TextColumnType(TextColumnConfig(value: $0)) }, nilHandling: .keepEmpty)
                .width(40)
                .eraseToAnyColumn()
        ]

        let sheet = Sheet(name: "Products", dataProvider: { products }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        // Verify column widths are set in SheetStyle
        let sheetStyle = sheetXML!.style!
        #expect(sheetStyle.columnWidths[1]?.width == 5.0)
        #expect(sheetStyle.columnWidths[1]?.unit == .characters)
        #expect(sheetStyle.columnWidths[1]?.isCustomWidth == true)

        #expect(sheetStyle.columnWidths[2]?.width == 20.0)
        #expect(sheetStyle.columnWidths[3]?.width == 15.0)
        #expect(sheetStyle.columnWidths[4]?.width == 40.0)

        // Verify XML output contains column definitions
        let xmlContent = sheetXML!.generateXML()
        #expect(xmlContent.contains("<cols>"))
        #expect(xmlContent.contains("<col min=\"1\" max=\"1\" width=\"5.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"2\" max=\"2\" width=\"20.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"3\" max=\"3\" width=\"15.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("<col min=\"4\" max=\"4\" width=\"40.0\" customWidth=\"1\"/>"))
        #expect(xmlContent.contains("</cols>"))
    }

    @Test("Mixed column width sources - Column and SheetStyle")
    func mixedColumnWidthSources() throws {
        let products = [
            TestProductWithDesc(id: 1, name: "Product A", price: 99.99, description: "Description A")
        ]

        let columns: [AnyColumn<TestProductWithDesc>] = [
            Column<TestProductWithDesc, Int, IntColumnType>(name: "ID", keyPath: \.id)
                .width(5) // Width from Column
                .eraseToAnyColumn(),
            Column<TestProductWithDesc, String, TextColumnType>(name: "Name", keyPath: \.name)
                // No width specified in Column
                    .eraseToAnyColumn(),
            Column<TestProductWithDesc, Double, DoubleColumnType>(name: "Price", keyPath: \.price)
                .width(15) // Width from Column
                .eraseToAnyColumn(),
            Column<TestProductWithDesc, String?, TextColumnType>(name: "Description", keyPath: \.description, mapping: { TextColumnType(TextColumnConfig(value: $0)) }, nilHandling: .keepEmpty)
                // No width specified in Column
                    .eraseToAnyColumn()
        ]

        // Set some widths directly in SheetStyle
        var sheetStyle = SheetStyle()
        sheetStyle.columnWidths[2] = SheetStyle.ColumnWidth(width: 25.0, unit: .characters, isCustomWidth: true) // Name column
        sheetStyle.columnWidths[4] = SheetStyle.ColumnWidth(width: 30.0, unit: .characters, isCustomWidth: true) // Description column

        let sheet = Sheet(name: "Products", style: sheetStyle, dataProvider: { products }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        // Verify that Column widths override SheetStyle widths
        let resultStyle = sheetXML!.style!
        #expect(resultStyle.columnWidths[1]?.width == 5.0) // From Column
        #expect(resultStyle.columnWidths[2]?.width == 25.0) // From SheetStyle (not overridden)
        #expect(resultStyle.columnWidths[3]?.width == 15.0) // From Column
        #expect(resultStyle.columnWidths[4]?.width == 30.0) // From SheetStyle (not overridden)
    }

    @Test("Row height customization")
    func rowHeightCustomization() throws {
        let products = [
            TestProductWithDesc(id: 1, name: "Product A", price: 99.99, description: "Description A"),
            TestProductWithDesc(id: 2, name: "Product B", price: 149.99, description: "Description B"),
            TestProductWithDesc(id: 3, name: "Product C", price: 199.99, description: "Description C")
        ]

        let columns: [AnyColumn<TestProductWithDesc>] = [
            Column<TestProductWithDesc, String, TextColumnType>(name: "Name", keyPath: \.name)
                .eraseToAnyColumn(),
            Column<TestProductWithDesc, Double, DoubleColumnType>(name: "Price", keyPath: \.price)
                .eraseToAnyColumn()
        ]

        var sheetStyle = SheetStyle()
        // Set custom row heights
        sheetStyle.rowHeights[1] = 30.0 // Header row
        sheetStyle.rowHeights[2] = 25.0 // First data row
        sheetStyle.rowHeights[3] = 35.0 // Second data row
        // Third data row will use default height
        sheetStyle.defaultRowHeight = 20.0

        let sheet = Sheet(name: "Products", style: sheetStyle, dataProvider: { products }, columns: { columns })

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

        // Check row heights
        #expect(rows[0].height == 30.0) // Header row
        #expect(rows[1].height == 25.0) // First data row
        #expect(rows[2].height == 35.0) // Second data row
        #expect(rows[3].height == 20.0) // Third data row (default)

        // Verify XML output contains row height attributes
        let xmlContent = sheetXML!.generateXML()
        #expect(xmlContent.contains("<row r=\"1\" ht=\"30.0\" customHeight=\"1\">")) // Header
        #expect(xmlContent.contains("<row r=\"2\" ht=\"25.0\" customHeight=\"1\">")) // First data row
        #expect(xmlContent.contains("<row r=\"3\" ht=\"35.0\" customHeight=\"1\">")) // Second data row
        #expect(xmlContent.contains("<row r=\"4\" ht=\"20.0\" customHeight=\"1\">")) // Third data row

        // Verify default row height in sheet format
        #expect(xmlContent.contains("defaultRowHeight=\"20.0\""))
    }

    @Test("Column width with different units")
    func columnWidthWithDifferentUnits() throws {
        let products = [TestProductWithDesc(id: 1, name: "Product", price: 99.99, description: nil)]

        let columns: [AnyColumn<TestProductWithDesc>] = [
            Column<TestProductWithDesc, String, TextColumnType>(name: "Name", keyPath: \.name)
                .width(20) // Default unit is characters
                .eraseToAnyColumn()
        ]

        var sheetStyle = SheetStyle()
        // Note: Currently only .characters unit is supported, not .pixels
        // This test verifies that column widths from Column definitions use .characters unit
        sheetStyle.columnWidths[2] = SheetStyle.ColumnWidth(width: 100.0, unit: .characters, isCustomWidth: true)

        let sheet = Sheet(name: "Products", style: sheetStyle, dataProvider: { products }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        let resultStyle = sheetXML!.style!
        #expect(resultStyle.columnWidths[1]?.width == 20.0)
        #expect(resultStyle.columnWidths[1]?.unit == .characters)
        #expect(resultStyle.columnWidths[2]?.width == 100.0)
        #expect(resultStyle.columnWidths[2]?.unit == .characters)
    }

    @Test("Empty columns don't affect width settings")
    func emptyColumnsWidthHandling() throws {
        let products: [TestProductWithDesc] = []

        let columns: [AnyColumn<TestProductWithDesc>] = [
            Column<TestProductWithDesc, String, TextColumnType>(name: "Name", keyPath: \.name)
                .width(20)
                .eraseToAnyColumn(),
            Column<TestProductWithDesc, Double, DoubleColumnType>(name: "Price", keyPath: \.price)
                .width(15)
                .eraseToAnyColumn()
        ]

        let sheet = Sheet(name: "Products", dataProvider: { products }, columns: { columns })

        let bookStyle = BookStyle()
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: sheet.style,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil)

        // Even with no data, column widths should be preserved
        let resultStyle = sheetXML!.style!
        #expect(resultStyle.columnWidths[1]?.width == 20.0)
        #expect(resultStyle.columnWidths[2]?.width == 15.0)
    }
}
