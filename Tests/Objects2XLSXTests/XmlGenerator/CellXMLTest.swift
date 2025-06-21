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
        let expected = "<c r=\"A1\" s=\"1\" t=\"s\"><v>0</v></c>"

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
        let expected = "<c r=\"A1\" s=\"1\" t=\"inlineStr\"><is><t>Hello World</t></is></c>"

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
        let expected = "<c r=\"A2\" s=\"2\" t=\"s\"><v>1</v></c>"

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
        let expected = "<c r=\"A2\" s=\"2\" t=\"inlineStr\"><is><t>https://example.com</t></is></c>"

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
        let expected = "<c r=\"A3\" s=\"3\" t=\"b\"><v>1</v></c>"

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

    @Test("Double cell with precise value (non-optional)")
    func doubleCellPreciseValue() throws {
        let cell = Cell(
            row: 5,
            column: 1,
            value: .doubleValue(3.14159),
            styleID: 5)

        let xml = cell.generateXML()
        let expected = "<c r=\"A5\" s=\"5\"><v>3.14159</v></c>"

        #expect(xml == expected)
    }

    @Test("Optional double cell with value")
    func optionalDoubleCellWithValue() throws {
        let cell = Cell(
            row: 5,
            column: 2,
            value: .optionalDouble(2.71828),
            styleID: 5)

        let xml = cell.generateXML()
        let expected = "<c r=\"B5\" s=\"5\"><v>2.71828</v></c>"

        #expect(xml == expected)
    }

    @Test("Optional double cell with nil")
    func optionalDoubleCellWithNil() throws {
        let cell = Cell(
            row: 5,
            column: 3,
            value: .optionalDouble(nil),
            styleID: 5)

        let xml = cell.generateXML()
        let expected = "<c r=\"C5\" s=\"5\"><v></v></c>"

        #expect(xml == expected)
    }

    @Test("Empty cell")
    func emptyCell() throws {
        let cell = Cell(
            row: 5,
            column: 4,
            value: .empty,
            styleID: 5)

        let xml = cell.generateXML()
        let expected = "<c r=\"D5\" s=\"5\"><v></v></c>"

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
        let expected = "<c r=\"A8\" t=\"inlineStr\"><is><t>No Style</t></is></c>"

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
        let expected = "<c r=\"A9\" s=\"8\" t=\"inlineStr\"><is><t></t></is></c>"

        #expect(xml == expected)
    }

    @Test("All cell types with nil values")
    func allCellTypesWithNilValues() throws {
        // 字符串类型 - nil
        let stringCell = Cell(row: 10, column: 1, value: .string(nil))
        let stringXML = stringCell.generateXML()
        let expectedString = "<c r=\"A10\" t=\"inlineStr\"><is><t></t></is></c>"
        #expect(stringXML == expectedString)

        // 整数类型 - nil
        let intCell = Cell(row: 10, column: 2, value: .int(nil))
        let intXML = intCell.generateXML()
        let expectedInt = "<c r=\"B10\"><v></v></c>"
        #expect(intXML == expectedInt)

        // 浮点数类型 - nil (deprecated syntax)
        let doubleCell = Cell(row: 10, column: 3, value: .double(nil))
        let doubleXML = doubleCell.generateXML()
        let expectedDouble = "<c r=\"C10\"><v></v></c>"
        #expect(doubleXML == expectedDouble)

        // 新的精确类型 - optionalDouble with nil
        let optionalDoubleCell = Cell(row: 10, column: 8, value: .optionalDouble(nil))
        let optionalDoubleXML = optionalDoubleCell.generateXML()
        let expectedOptionalDouble = "<c r=\"H10\"><v></v></c>"
        #expect(optionalDoubleXML == expectedOptionalDouble)

        // 空单元格类型
        let emptyCell = Cell(row: 10, column: 9, value: .empty)
        let emptyXML = emptyCell.generateXML()
        let expectedEmpty = "<c r=\"I10\"><v></v></c>"
        #expect(emptyXML == expectedEmpty)

        // 日期类型 - nil
        let dateCell = Cell(row: 10, column: 4, value: .date(nil))
        let dateXML = dateCell.generateXML()
        let expectedDate = "<c r=\"D10\"><v></v></c>"
        #expect(dateXML == expectedDate)

        // 布尔类型 - nil
        let boolCell = Cell(row: 10, column: 5, value: .boolean(nil))
        let boolXML = boolCell.generateXML()
        let expectedBool = "<c r=\"E10\" t=\"b\"><v>0</v></c>"
        #expect(boolXML == expectedBool)

        // URL类型 - nil
        let urlCell = Cell(row: 10, column: 6, value: .url(nil))
        let urlXML = urlCell.generateXML()
        let expectedURL = "<c r=\"F10\" t=\"inlineStr\"><is><t></t></is></c>"
        #expect(urlXML == expectedURL)

        // 百分比类型 - nil
        let percentageCell = Cell(row: 10, column: 7, value: .percentage(nil))
        let percentageXML = percentageCell.generateXML()
        let expectedPercentage = "<c r=\"G10\"><v></v></c>"
        #expect(percentageXML == expectedPercentage)
    }

    @Test("Nil values with styles")
    func nilValuesWithStyles() throws {
        let cell = Cell(
            row: 11,
            column: 1,
            value: .int(nil),
            styleID: 5)

        let xml = cell.generateXML()
        let expected = "<c r=\"A11\" s=\"5\"><v></v></c>"

        #expect(xml == expected)
    }

    @Test("Nil values with shared strings")
    func nilValuesWithSharedStrings() throws {
        let cell = Cell(
            row: 12,
            column: 1,
            value: .string(nil),
            styleID: 3,
            sharedStringID: 0)

        let xml = cell.generateXML()
        let expected = "<c r=\"A12\" s=\"3\" t=\"s\"><v>0</v></c>"

        #expect(xml == expected)
    }

    @Test("Mixed nil and non-nil values in row")
    func mixedNilAndNonNilValues() throws {
        let cells = [
            Cell(row: 13, column: 1, value: .string("Name")),
            Cell(row: 13, column: 2, value: .string(nil)),
            Cell(row: 13, column: 3, value: .int(25)),
            Cell(row: 13, column: 4, value: .int(nil)),
            Cell(row: 13, column: 5, value: .double(3.14)),
            Cell(row: 13, column: 6, value: .double(nil)),
            Cell(row: 13, column: 7, value: .doubleValue(1.618)),
            Cell(row: 13, column: 8, value: .optionalDouble(nil)),
            Cell(row: 13, column: 9, value: .empty),
        ]

        let row = Row(index: 13, cells: cells)
        let xml = row.generateXML()

        let expected =
            "<row r=\"13\"><c r=\"A13\" t=\"inlineStr\"><is><t>Name</t></is></c><c r=\"B13\" t=\"inlineStr\"><is><t></t></is></c><c r=\"C13\"><v>25</v></c><c r=\"D13\"><v></v></c><c r=\"E13\"><v>3.14</v></c><c r=\"F13\"><v></v></c><c r=\"G13\"><v>1.618</v></c><c r=\"H13\"><v></v></c><c r=\"I13\"><v></v></c></row>"

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

        let expectedTrue = "<c r=\"A10\" s=\"9\" t=\"b\"><v>1</v></c>"
        let expectedFalse = "<c r=\"B10\" s=\"9\" t=\"b\"><v>0</v></c>"

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
