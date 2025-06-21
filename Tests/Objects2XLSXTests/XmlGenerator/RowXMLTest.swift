//
// RowXMLTest.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Row XML Test")
struct RowXMLTest {
    @Test("Row without height")
    func rowWithoutHeight() throws {
        let cells = [
            Cell(row: 1, column: 1, value: .stringValue("A1")),
            Cell(row: 1, column: 2, value: .intValue(42)),
            Cell(row: 1, column: 3, value: .doubleValue(3.14)),
        ]

        let row = Row(index: 1, cells: cells)
        let xml = row.generateXML()

        let expected =
            "<row r=\"1\"><c r=\"A1\" t=\"inlineStr\"><is><t>A1</t></is></c><c r=\"B1\"><v>42</v></c><c r=\"C1\"><v>3.14</v></c></row>"

        #expect(xml == expected)
    }

    @Test("Row with custom height")
    func rowWithCustomHeight() throws {
        let cells = [
            Cell(row: 2, column: 1, value: .stringValue("Header")),
            Cell(row: 2, column: 2, value: .stringValue("Value")),
        ]

        let row = Row(index: 2, cells: cells, height: 25.0)
        let xml = row.generateXML()

        let expected =
            "<row r=\"2\" ht=\"25.0\" customHeight=\"1\"><c r=\"A2\" t=\"inlineStr\"><is><t>Header</t></is></c><c r=\"B2\" t=\"inlineStr\"><is><t>Value</t></is></c></row>"

        #expect(xml == expected)
    }

    @Test("Empty row")
    func emptyRow() throws {
        let row = Row(index: 3, cells: [])
        let xml = row.generateXML()

        let expected = "<row r=\"3\"></row>"

        #expect(xml == expected)
    }

    @Test("Row with styled cells")
    func rowWithStyledCells() throws {
        let cells = [
            Cell(row: 4, column: 1, value: .stringValue("Name"), styleID: 1),
            Cell(row: 4, column: 2, value: .stringValue("Age"), styleID: 1),
            Cell(row: 4, column: 3, value: .stringValue("Email"), styleID: 1),
        ]

        let row = Row(index: 4, cells: cells, height: 20.0)
        let xml = row.generateXML()

        let expected =
            "<row r=\"4\" ht=\"20.0\" customHeight=\"1\"><c r=\"A4\" s=\"1\" t=\"inlineStr\"><is><t>Name</t></is></c><c r=\"B4\" s=\"1\" t=\"inlineStr\"><is><t>Age</t></is></c><c r=\"C4\" s=\"1\" t=\"inlineStr\"><is><t>Email</t></is></c></row>"

        #expect(xml == expected)
    }

    @Test("Row with mixed cell types")
    func rowWithMixedCellTypes() throws {
        let cells = [
            Cell(row: 5, column: 1, value: .stringValue("Product"), styleID: 1),
            Cell(row: 5, column: 2, value: .intValue(100), styleID: 2),
            Cell(row: 5, column: 3, value: .doubleValue(19.99), styleID: 2),
            Cell(row: 5, column: 4, value: .booleanValue(true), styleID: 3),
            Cell(row: 5, column: 5, value: .urlValue(URL(string: "https://example.com")!), styleID: 4),
        ]

        let row = Row(index: 5, cells: cells)
        let xml = row.generateXML()

        let expected =
            "<row r=\"5\"><c r=\"A5\" s=\"1\" t=\"inlineStr\"><is><t>Product</t></is></c><c r=\"B5\" s=\"2\"><v>100</v></c><c r=\"C5\" s=\"2\"><v>19.99</v></c><c r=\"D5\" s=\"3\" t=\"b\"><v>1</v></c><c r=\"E5\" s=\"4\" t=\"inlineStr\"><is><t>https://example.com</t></is></c></row>"

        #expect(xml == expected)
    }

    @Test("Row with mixed cell types - realistic scenario")
    func rowWithMixedCellTypesRealistic() throws {
        let cells = [
            Cell(row: 5, column: 1, value: .stringValue("Product"), styleID: 1),
            Cell(row: 5, column: 2, value: .intValue(100)),
            Cell(row: 5, column: 3, value: .doubleValue(19.99)),
            Cell(row: 5, column: 4, value: .booleanValue(true)),
            Cell(row: 5, column: 5, value: .urlValue(URL(string: "https://example.com")!)),
        ]

        let row = Row(index: 5, cells: cells)
        let xml = row.generateXML()

        let expected =
            "<row r=\"5\"><c r=\"A5\" s=\"1\" t=\"inlineStr\"><is><t>Product</t></is></c><c r=\"B5\"><v>100</v></c><c r=\"C5\"><v>19.99</v></c><c r=\"D5\" t=\"b\"><v>1</v></c><c r=\"E5\" t=\"inlineStr\"><is><t>https://example.com</t></is></c></row>"

        #expect(xml == expected)
    }

    @Test("Row with shared strings")
    func rowWithSharedStrings() throws {
        let cells = [
            Cell(row: 6, column: 1, value: .stringValue("Header"), styleID: 1, sharedStringID: 0),
            Cell(row: 6, column: 2, value: .stringValue("Data"), styleID: 1, sharedStringID: 1),
        ]

        let row = Row(index: 6, cells: cells, height: 18.0)
        let xml = row.generateXML()

        let expected =
            "<row r=\"6\" ht=\"18.0\" customHeight=\"1\"><c r=\"A6\" s=\"1\" t=\"s\"><v>0</v></c><c r=\"B6\" s=\"1\" t=\"s\"><v>1</v></c></row>"

        #expect(xml == expected)
    }

    @Test("Row with date cells")
    func rowWithDateCells() throws {
        let date = Date(timeIntervalSince1970: 0) // 1970-01-01 00:00:00 UTC
        let cells = [
            Cell(row: 7, column: 1, value: .stringValue("Date"), styleID: 1),
            Cell(
                row: 7,
                column: 2,
                value: .dateValue(date, timeZone: TimeZone(identifier: "UTC")!),
                styleID: 2),
        ]

        let row = Row(index: 7, cells: cells)
        let xml = row.generateXML()

        // 验证基本结构
        #expect(
            xml
                .hasPrefix(
                    "<row r=\"7\"><c r=\"A7\" s=\"1\" t=\"inlineStr\"><is><t>Date</t></is></c><c r=\"B7\" s=\"2\"><v>"))
        #expect(xml.hasSuffix("</v></c></row>"))

        // 提取并验证日期值
        let dateValuePattern = #"<v>([0-9.]+)</v>"#
        let regex = try! NSRegularExpression(pattern: dateValuePattern)
        let range = NSRange(xml.startIndex ..< xml.endIndex, in: xml)

        if let match = regex.firstMatch(in: xml, range: range),
           let dateValueRange = Range(match.range(at: 1), in: xml)
        {
            let dateValue = String(xml[dateValueRange])
            let expectedDateValue = "25569"
            let isEqual = Date.isExcelDateEqual(dateValue, expectedDateValue)
            #expect(isEqual, "Date value should be equal within tolerance")
        } else {
            #expect(Bool(false), "Failed to extract date value from XML")
        }
    }

    @Test("Row with nil values")
    func rowWithNilValues() throws {
        let cells = [
            Cell(row: 8, column: 1, value: .optionalString(nil)),
            Cell(row: 8, column: 2, value: .optionalInt(nil)),
            Cell(row: 8, column: 3, value: .optionalDouble(nil)),
        ]

        let row = Row(index: 8, cells: cells)
        let xml = row.generateXML()

        let expected =
            "<row r=\"8\"><c r=\"A8\" t=\"inlineStr\"><is><t></t></is></c><c r=\"B8\"><v></v></c><c r=\"C8\"><v></v></c></row>"

        #expect(xml == expected)
    }

    @Test("Row index validation")
    func rowIndexValidation() throws {
        let cells = [Cell(row: 10, column: 1, value: .stringValue("Test"))]

        // 测试不同的行索引
        let row1 = Row(index: 1, cells: cells)
        let row10 = Row(index: 10, cells: cells)
        let row100 = Row(index: 100, cells: cells)

        #expect(row1.generateXML().contains("r=\"1\""))
        #expect(row10.generateXML().contains("r=\"10\""))
        #expect(row100.generateXML().contains("r=\"100\""))
    }

    @Test("Row height precision")
    func rowHeightPrecision() throws {
        let cells = [Cell(row: 9, column: 1, value: .stringValue("Test"))]

        let row = Row(index: 9, cells: cells, height: 15.75)
        let xml = row.generateXML()

        let expected =
            "<row r=\"9\" ht=\"15.75\" customHeight=\"1\"><c r=\"A9\" t=\"inlineStr\"><is><t>Test</t></is></c></row>"

        #expect(xml == expected)
    }
}
