//
// CellXMLTest.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Cell XML Generator")
struct CellXMLTest {
    @Test("String cell with shared string")
    func stringCellWithSharedString() throws {
        let cell = Cell(
            row: 1,
            column: 1,
            value: .string("Hello World"),
            styleID: 1,
            sharedStringID: 0)
        print(cell.excelAddress) // @1
        let xml = cell.generateXML()
        let expected = "<c r=\"A1\" s=\"1\"><v>0</v></c>"

        #expect(xml == expected)
    }

    @Test("String cell without shared string")
    func stringCellWithoutSharedString() throws {
        let cell = Cell(
            row: 1,
            column: 1,
            value: .string("Hello World"),
            styleID: 1)

        let xml = cell.generateXML()
        let expected = "<c r=\"A1\" s=\"1\"><is><t>Hello World</t></is></c>"

        #expect(xml == expected)
    }

    @Test("URL cell with shared string")
    func uRLCellWithSharedString() throws {
        let url = URL(string: "https://example.com")!
        let cell = Cell(
            row: 2,
            column: 1,
            value: .url(url),
            styleID: 2,
            sharedStringID: 1)

        let xml = cell.generateXML()
        let expected = "<c r=\"A2\" s=\"2\"><v>1</v></c>"

        #expect(xml == expected)
    }

    @Test("URL cell without shared string")
    func uRLCellWithoutSharedString() throws {
        let url = URL(string: "https://example.com")!
        let cell = Cell(
            row: 2,
            column: 1,
            value: .url(url),
            styleID: 2)

        let xml = cell.generateXML()
        let expected = "<c r=\"A2\" s=\"2\"><is><t>https://example.com</t></is></c>"

        #expect(xml == expected)
    }

    @Test("Boolean cell")
    func booleanCell() throws {
        let cell = Cell(
            row: 3,
            column: 1,
            value: .boolean(true, booleanExpressions: .trueAndFalse),
            styleID: 3)

        let xml = cell.generateXML()
        let expected = "<c r=\"A3\" s=\"3\"><is><t>TRUE</t></is></c>"

        #expect(xml == expected)
    }

    @Test("Integer cell")
    func integerCell() throws {
        let cell = Cell(
            row: 4,
            column: 1,
            value: .int(42),
            styleID: 4)

        let xml = cell.generateXML()
        let expected = "<c r=\"A4\" s=\"4\"><v>42</v></c>"

        #expect(xml == expected)
    }

    @Test("Double cell")
    func doubleCell() throws {
        let cell = Cell(
            row: 5,
            column: 1,
            value: .double(3.14159),
            styleID: 5)

        let xml = cell.generateXML()
        let expected = "<c r=\"A5\" s=\"5\"><v>3.14159</v></c>"

        #expect(xml == expected)
    }

    @Test("Date cell")
    func dateCell() throws {
        let date = Date(timeIntervalSince1970: 0)
        let cell = Cell(
            row: 6,
            column: 1,
            value: .date(date, timeZone: TimeZone(identifier: "UTC")!),
            styleID: 6)

        let xml = cell.generateXML()
        try expectDateXML(xml, expectedAddress: "A6", expectedStyle: "6", expectedDateValue: "25569")
    }

    @Test("Percentage cell")
    func percentageCell() throws {
        let cell = Cell(
            row: 7,
            column: 1,
            value: .percentage(0.75, precision: 2),
            styleID: 7)

        let xml = cell.generateXML()
        let expected = "<c r=\"A7\" s=\"7\"><v>0.75</v></c>"

        #expect(xml == expected)
    }

    @Test("Cell without style")
    func cellWithoutStyle() throws {
        let cell = Cell(
            row: 8,
            column: 1,
            value: .string("No Style"))

        let xml = cell.generateXML()
        let expected = "<c r=\"A8\"><is><t>No Style</t></is></c>"

        #expect(xml == expected)
    }

    @Test("Cell with nil values")
    func cellWithNilValues() throws {
        let cell = Cell(
            row: 9,
            column: 1,
            value: .string(nil),
            styleID: 8)

        let xml = cell.generateXML()
        let expected = "<c r=\"A9\" s=\"8\"><is><t></t></is></c>"

        #expect(xml == expected)
    }

    @Test("Boolean expressions")
    func testBooleanExpressions() throws {
        let trueCell = Cell(
            row: 10,
            column: 1,
            value: .boolean(true, booleanExpressions: .oneAndZero),
            styleID: 9)

        let falseCell = Cell(
            row: 10,
            column: 2,
            value: .boolean(false, booleanExpressions: .yesAndNo),
            styleID: 9)

        let trueXML = trueCell.generateXML()
        let falseXML = falseCell.generateXML()

        let expectedTrue = "<c r=\"A10\" s=\"9\"><is><t>1</t></is></c>"
        let expectedFalse = "<c r=\"B10\" s=\"9\"><is><t>NO</t></is></c>"

        #expect(trueXML == expectedTrue)
        #expect(falseXML == expectedFalse)
    }

    @Test("Cell address generation")
    func cellAddressGeneration() throws {
        let cellA1 = Cell(row: 1, column: 1, value: .string("A1"))
        let cellZ1 = Cell(row: 1, column: 26, value: .string("Z1"))
        let cellAA1 = Cell(row: 1, column: 27, value: .string("AA1"))
        let cellB2 = Cell(row: 2, column: 2, value: .string("B2"))

        #expect(cellA1.excelAddress == "A1")
        #expect(cellZ1.excelAddress == "Z1")
        #expect(cellAA1.excelAddress == "AA1")
        #expect(cellB2.excelAddress == "B2")
    }

    /// 验证包含日期值的 XML
    func expectDateXML(_ xml: String, expectedAddress: String, expectedStyle: String, expectedDateValue: String) throws {
        // 验证基本结构
        #expect(xml.hasPrefix("<c r=\"\(expectedAddress)\" s=\"\(expectedStyle)\"><v>"))
        #expect(xml.hasSuffix("</v></c>"))

        // 提取日期值 - 修正偏移量
        let prefix = "<c r=\"\(expectedAddress)\" s=\"\(expectedStyle)\"><v>"
        let suffix = "</v></c>"

        let startIndex = xml.index(xml.startIndex, offsetBy: prefix.count)
        let endIndex = xml.index(xml.endIndex, offsetBy: -suffix.count)
        let actualDateValue = String(xml[startIndex ..< endIndex])

        // 使用精度比较
        let isEqual = Date.isExcelDateEqual(actualDateValue, expectedDateValue)
        #expect(isEqual, "Date value \(actualDateValue) should be equal to \(expectedDateValue) within tolerance")
    }
}
