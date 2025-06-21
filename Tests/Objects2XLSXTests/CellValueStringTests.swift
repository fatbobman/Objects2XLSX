//
// CellValueStringTests.swift
// Created by Xu Yang on 2025-06-14.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("CellValueString Tests")
struct CellValueStringTests {
    @Test("String cell value string")
    func stringCellValueString() throws {
        let cell = Cell(row: 0, column: 0, value: .string("Hello"))
        #expect(cell.value.valueString == "Hello", "String cell value should match")

        let nilCell = Cell(row: 0, column: 1, value: .string(nil))
        #expect(nilCell.value.valueString == "", "Nil string cell value should be empty")
    }

    @Test("Double cell value string")
    func doubleCellValueString() throws {
        let cell = Cell(row: 0, column: 0, value: .double(123.456))
        #expect(cell.value.valueString == "123.456", "Double cell value should match")

        let nilCell = Cell(row: 0, column: 1, value: .double(nil))
        #expect(nilCell.value.valueString == "", "Nil double cell value should be empty")

        let infinityCell = Cell(row: 0, column: 2, value: .double(.infinity))
        #expect(infinityCell.value.valueString == "", "Double infinity cell value should match")

        let isNanCell = Cell(row: 0, column: 3, value: .double(.nan))
        #expect(isNanCell.value.valueString == "", "Double NaN cell value should match")
    }

    @Test("Precise double cell value string")
    func preciseDoubleCellValueString() throws {
        // Test new doubleValue enum case
        let doubleValueCell = Cell(row: 0, column: 0, value: .doubleValue(789.123))
        #expect(doubleValueCell.value.valueString == "789.123", "DoubleValue cell value should match")

        // Test new optionalDouble enum case with value
        let optionalDoubleCell = Cell(row: 0, column: 1, value: .optionalDouble(456.789))
        #expect(optionalDoubleCell.value.valueString == "456.789", "OptionalDouble with value should match")

        // Test new optionalDouble enum case with nil
        let optionalDoubleNilCell = Cell(row: 0, column: 2, value: .optionalDouble(nil))
        #expect(optionalDoubleNilCell.value.valueString == "", "OptionalDouble with nil should be empty")

        // Test new empty enum case
        let emptyCell = Cell(row: 0, column: 3, value: .empty)
        #expect(emptyCell.value.valueString == "", "Empty cell value should be empty")

        // Test edge cases with new enum types
        let optionalInfinityCell = Cell(row: 0, column: 4, value: .optionalDouble(.infinity))
        #expect(optionalInfinityCell.value.valueString == "", "OptionalDouble infinity should be empty")

        let optionalNanCell = Cell(row: 0, column: 5, value: .optionalDouble(.nan))
        #expect(optionalNanCell.value.valueString == "", "OptionalDouble NaN should be empty")
    }

    @Test("Int cell value string")
    func intCellValueString() throws {
        let cell = Cell(row: 0, column: 0, value: .int(42))
        #expect(cell.value.valueString == "42", "Int cell value should match")

        let nilCell = Cell(row: 0, column: 1, value: .int(nil))
        #expect(nilCell.value.valueString == "", "Nil int cell value should be empty")
    }

    @Test("Date cell value string")
    func dateCellValueString() throws {
        let date = Date(timeIntervalSince1970: 1_622_505_600) // June 1, 2021
        let cell = Cell(row: 0, column: 0, value: .date(date))
        #expect(
            cell.value.valueString == date.excelDate(),
            "Date cell value should match Excel date format")

        let nilCell = Cell(row: 0, column: 1, value: .date(nil))
        #expect(nilCell.value.valueString == "", "Nil date cell value should be empty")
    }

    @Test("Bool cell value string")
    func boolCellValueString() throws {
        let oneCell = Cell(row: 0, column: 0, value: .boolean(true))
        #expect(oneCell.value.valueString == "1", "True cell value should match")

        let zeroCell = Cell(row: 0, column: 1, value: .boolean(false))
        #expect(zeroCell.value.valueString == "0", "False cell value should match")

        let trueCell = Cell(
            row: 0,
            column: 0,
            value: .boolean(true, booleanExpressions: .trueAndFalse, caseStrategy: .upper))
        #expect(trueCell.value.valueString == "TRUE", "True cell value should match")

        let falseCell = Cell(
            row: 0,
            column: 0,
            value: .boolean(false, booleanExpressions: .trueAndFalse, caseStrategy: .lower))
        #expect(falseCell.value.valueString == "false", "False cell value should match")

        let falseFirstLetterUpperCell = Cell(
            row: 0,
            column: 0,
            value: .boolean(
                false,
                booleanExpressions: .trueAndFalse,
                caseStrategy: .firstLetterUpper))
        #expect(falseFirstLetterUpperCell.value.valueString == "False", "False cell value should match")

        let tCell = Cell(
            row: 0,
            column: 0,
            value: .boolean(true, booleanExpressions: .tAndF, caseStrategy: .lower))
        #expect(tCell.value.valueString == "t", "True cell value should match")

        let fCell = Cell(row: 0, column: 0, value: .boolean(false, booleanExpressions: .tAndF))
        #expect(fCell.value.valueString == "F", "False cell value should match")

        let nilCell = Cell(row: 0, column: 2, value: .boolean(nil))
        #expect(nilCell.value.valueString == "", "Nil bool cell value should be empty")
    }

    @Test("Percentage cell value string")
    func percentageCellValueString() throws {
        let cell = Cell(row: 0, column: 0, value: .percentage(0.25))
        #expect(cell.value.valueString == "0.25", "Percentage cell value should match")

        let nilCell = Cell(row: 0, column: 1, value: .percentage(nil))
        #expect(nilCell.value.valueString == "", "Nil percentage cell value should be empty")

        let precisionCell = Cell(row: 0, column: 2, value: .percentage(0.25232, precision: 2))
        #expect(
            precisionCell.value.valueString == "0.2523",
            "Percentage cell value with precision should match")

        let infinityCell = Cell(row: 0, column: 3, value: .percentage(.infinity))
        #expect(infinityCell.value.valueString == "", "Percentage infinity cell value should match")

        let isNanCell = Cell(row: 0, column: 4, value: .percentage(.nan))
        #expect(isNanCell.value.valueString == "", "Percentage NaN cell value should match")
    }

    @Test("URL cell value string")
    func urlCellValueString() throws {
        let url = URL(string: "https://example.com")!
        let cell = Cell(row: 0, column: 0, value: .url(url))
        #expect(cell.value.valueString == url.absoluteString, "URL cell value should match")

        let nilCell = Cell(row: 0, column: 1, value: .url(nil))
        #expect(nilCell.value.valueString == "", "Nil URL cell value should be empty")
    }
}
