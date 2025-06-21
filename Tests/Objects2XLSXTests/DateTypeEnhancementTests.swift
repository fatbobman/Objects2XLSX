//
// DateTypeEnhancementTests.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Date Type Enhancement Tests")
struct DateTypeEnhancementTests {
    struct TestModel: Sendable {
        let name: String
        let createdDate: Date
        let modifiedDate: Date?
        let expiryDate: Date?
    }

    @Test("Date CellType Cases")
    func dateCellTypeCases() throws {
        let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
        let testTimeZone = TimeZone(secondsFromGMT: 0)!

        // Test non-optional date
        let dateValue = Cell(row: 1, column: 1, value: .dateValue(testDate, timeZone: testTimeZone))
        let dateXML = dateValue.generateXML()
        #expect(dateXML.contains("<v>"))
        #expect(dateValue.value.valueString == testDate.cellValueString(timeZone: testTimeZone))

        // Test optional date with value
        let optionalDate = Cell(row: 1, column: 2, value: .optionalDate(testDate, timeZone: testTimeZone))
        let optionalXML = optionalDate.generateXML()
        #expect(optionalXML.contains("<v>"))
        #expect(optionalDate.value.valueString == testDate.cellValueString(timeZone: testTimeZone))

        // Test optional date with nil
        let nilDate = Cell(row: 1, column: 3, value: .optionalDate(nil, timeZone: testTimeZone))
        let nilXML = nilDate.generateXML()
        #expect(nilXML.contains("<v></v>"))
        #expect(nilDate.value.valueString == "")
    }

    @Test("DateColumnType CellType Selection")
    func dateColumnTypeCellType() throws {
        let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
        let testTimeZone = TimeZone(secondsFromGMT: 0)!

        // Non-nil value should use dateValue
        let nonNilConfig = DateColumnConfig(value: testDate, timeZone: testTimeZone)
        let nonNilType = DateColumnType(nonNilConfig)

        switch nonNilType.cellType {
            case let .dateValue(value, timeZone):
                #expect(value == testDate)
                #expect(timeZone == testTimeZone)
            default:
                #expect(Bool(false), "Should use dateValue for non-nil")
        }

        // Nil value should use optionalDate
        let nilConfig = DateColumnConfig(value: nil, timeZone: testTimeZone)
        let nilType = DateColumnType(nilConfig)

        switch nilType.cellType {
            case let .optionalDate(value, timeZone):
                #expect(value == nil)
                #expect(timeZone == testTimeZone)
            default:
                #expect(Bool(false), "Should use optionalDate for nil")
        }
    }

    @Test("DateColumnType withDefaultValue")
    func dateColumnTypeDefaultValue() throws {
        let defaultDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
        let testTimeZone = TimeZone(secondsFromGMT: 0)!

        // Test with nil value
        let nilConfig = DateColumnConfig(value: nil, timeZone: testTimeZone)
        let withDefault = DateColumnType.withDefaultValue(defaultDate, config: nilConfig)
        #expect(withDefault.config.value == defaultDate)
        #expect(withDefault.config.timeZone == testTimeZone)

        // Test with non-nil value (should preserve original)
        let originalDate = Date(timeIntervalSince1970: 1672531200) // 2023-01-01 00:00:00 UTC
        let nonNilConfig = DateColumnConfig(value: originalDate, timeZone: testTimeZone)
        let preserveOriginal = DateColumnType.withDefaultValue(defaultDate, config: nonNilConfig)
        #expect(preserveOriginal.config.value == originalDate)
        #expect(preserveOriginal.config.timeZone == testTimeZone)
    }

    @Test("Date Column Optional Support")
    func dateColumnOptionalSupport() throws {
        let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
        let defaultDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC

        let data = [
            TestModel(name: "Item A", createdDate: testDate, modifiedDate: testDate, expiryDate: testDate),
            TestModel(name: "Item B", createdDate: testDate, modifiedDate: nil, expiryDate: nil),
            TestModel(name: "Item C", createdDate: testDate, modifiedDate: testDate, expiryDate: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Non-optional date column
            Column(name: "Created", keyPath: \.createdDate)

            // Optional date column without default
            Column(name: "Modified", keyPath: \.modifiedDate)

            // Optional date column with default
            Column(name: "Expiry", keyPath: \.expiryDate)
                .defaultValue(defaultDate)
        }

        let columns = sheet.columns
        #expect(columns.count == 3)

        // Test that the column generates correct cell values
        let cellValue = columns[2].generateCellValue(for: data[1]) // Item B with nil expiry

        switch cellValue {
            case let .dateValue(value, _):
                #expect(value == defaultDate, "Should use default value for nil")
            default:
                #expect(Bool(false), "Should generate dateValue")
        }
    }

    @Test("Date Column toDate with defaultValue")
    func dateColumnToDateWithDefault() throws {
        let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
        let defaultDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC

        let data = [
            TestModel(name: "Item", createdDate: testDate, modifiedDate: nil, expiryDate: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Optional date with defaultValue and toDate
            Column(name: "Expiry", keyPath: \.expiryDate)
                .defaultValue(defaultDate)
                .toDate { (date: Date) in // Non-optional after defaultValue
                    // Add 30 days
                    Calendar.current.date(byAdding: .day, value: 30, to: date) ?? date
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .dateValue(value, _):
                let expectedDate = Calendar.current.date(byAdding: .day, value: 30, to: defaultDate)!
                let tolerance: TimeInterval = 1.0 // 1 second tolerance
                #expect(abs(value.timeIntervalSince(expectedDate)) < tolerance)
            default:
                #expect(Bool(false), "Should generate dateValue with transformed default")
        }
    }

    @Test("Date Column toString transformation")
    func dateColumnToStringTransformation() throws {
        let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC

        let data = [
            TestModel(name: "Item", createdDate: testDate, modifiedDate: testDate, expiryDate: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Date to String transformation
            Column(name: "Created Date Text", keyPath: \.createdDate)
                .toString { (date: Date) in
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter.string(from: date)
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .stringValue(value):
                #expect(value.contains("2022"), "Should contain year 2022")
            default:
                #expect(Bool(false), "Should generate stringValue")
        }
    }
}