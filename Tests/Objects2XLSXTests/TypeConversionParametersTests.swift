//
// TypeConversionParametersTests.swift
// Tests for enhanced type conversion method parameters
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Type Conversion Parameters Tests")
struct TypeConversionParametersTests {
    // Test models
    struct TestProduct: Sendable {
        let name: String
        let dateString: String
        let timestampSeconds: Int
        let statusCode: Int
        let discountRate: Double?
        let isPublished: String
    }

    // MARK: - toDate with timezone parameter

    @Test("toDate with custom timezone - non-optional")
    func toDateWithTimezone() throws {
        let products = [
            TestProduct(
                name: "Product 1",
                dateString: "2025-06-21T12:00:00Z",
                timestampSeconds: 1_702_914_000, // 2023-12-18 17:00:00 UTC
                statusCode: 200,
                discountRate: 0.15,
                isPublished: "yes"),
        ]

        let utcTimeZone = TimeZone(identifier: "UTC")!
        let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo")!

        // Test string to date conversion with UTC timezone
        let dateColumnUTC = Column<TestProduct, String, TextColumnType>(name: "Date", keyPath: \.dateString)
            .toDate(utcTimeZone) { dateStr in
                ISO8601DateFormatter().date(from: dateStr) ?? Date()
            }

        // Test with Tokyo timezone
        let dateColumnTokyo = Column<TestProduct, String, TextColumnType>(name: "Date", keyPath: \.dateString)
            .toDate(tokyoTimeZone) { dateStr in
                ISO8601DateFormatter().date(from: dateStr) ?? Date()
            }

        let cellUTC = dateColumnUTC.generateCellValue(for: products[0])
        let cellTokyo = dateColumnTokyo.generateCellValue(for: products[0])

        // Both should have the same date but different timezones
        switch (cellUTC, cellTokyo) {
            case let (.dateValue(dateUTC, tzUTC), .dateValue(dateTokyo, tzTokyo)):
                #expect(dateUTC == dateTokyo, "Dates should be equal")
                #expect(tzUTC == utcTimeZone, "UTC timezone should be preserved")
                #expect(tzTokyo == tokyoTimeZone, "Tokyo timezone should be preserved")
            default:
                Issue.record("Expected dateValue for both")
        }
    }

    @Test("toDate with timezone - optional values")
    func toDateOptionalWithTimezone() throws {
        let products = [
            TestProduct(
                name: "Product 1",
                dateString: "2025-06-21T12:00:00Z",
                timestampSeconds: 1_702_914_000,
                statusCode: 200,
                discountRate: nil,
                isPublished: "yes"),
        ]

        let nycTimeZone = TimeZone(identifier: "America/New_York")!

        // Test Int to optional Date conversion with NYC timezone
        let timestampColumn = Column<TestProduct, Int, IntColumnType>(name: "Timestamp", keyPath: \.timestampSeconds)
            .toDate(nycTimeZone) { (timestamp: Int?) -> Date? in
                guard let ts = timestamp else { return nil }
                return Date(timeIntervalSince1970: TimeInterval(ts))
            }

        let cell = timestampColumn.generateCellValue(for: products[0])
        switch cell {
            case let .dateValue(date, timeZone):
                #expect(timeZone == nycTimeZone, "NYC timezone should be used")
                #expect(date.timeIntervalSince1970 == 1_702_914_000, "Date should match timestamp")
            default:
                Issue.record("Expected dateValue")
        }
    }

    // MARK: - toBoolean with expression and case parameters

    @Test("toBoolean with custom expressions and case")
    func toBooleanWithParameters() throws {
        let products = [
            TestProduct(
                name: "Product 1",
                dateString: "",
                timestampSeconds: 0,
                statusCode: 200,
                discountRate: 0.15,
                isPublished: "yes"),
            TestProduct(
                name: "Product 2",
                dateString: "",
                timestampSeconds: 0,
                statusCode: 404,
                discountRate: nil,
                isPublished: "no"),
        ]

        // Test with yesAndNo + firstLetterUpper
        let publishedColumn = Column<TestProduct, String, TextColumnType>(name: "Published", keyPath: \.isPublished)
            .toBoolean(
                booleanExpressions: .yesAndNo,
                caseStrategy: .firstLetterUpper)
            { str in
                str.lowercased() == "yes"
            }

        let cell1 = publishedColumn.generateCellValue(for: products[0])
        switch cell1 {
            case let .booleanValue(value, expressions, strategy):
                #expect(value == true, "Should be true for 'yes'")
                #expect(expressions == .yesAndNo, "Should use yesAndNo expressions")
                #expect(strategy == .firstLetterUpper, "Should use firstLetterUpper strategy")
                let cellType = Cell.CellType.booleanValue(value, booleanExpressions: expressions, caseStrategy: strategy)
                #expect(cellType.valueString == "Yes", "Should output 'Yes' with firstLetterUpper")
            default:
                Issue.record("Expected booleanValue")
        }

        // Test with custom expressions
        let statusColumn = Column<TestProduct, Int, IntColumnType>(name: "Status", keyPath: \.statusCode)
            .toBoolean(
                booleanExpressions: .custom(true: "SUCCESS", false: "FAILED"),
                caseStrategy: .lower)
            { code in
                code >= 200 && code < 300
            }

        let statusCell1 = statusColumn.generateCellValue(for: products[0])
        switch statusCell1 {
            case let .booleanValue(value, expressions, strategy):
                #expect(value == true, "200 should be success")
                let cellType = Cell.CellType.booleanValue(value, booleanExpressions: expressions, caseStrategy: strategy)
                #expect(cellType.valueString == "success", "Should output 'success' with lower case")
            default:
                Issue.record("Expected booleanValue")
        }

        let statusCell2 = statusColumn.generateCellValue(for: products[1])
        switch statusCell2 {
            case let .booleanValue(value, expressions, strategy):
                #expect(value == false, "404 should be failed")
                let cellType = Cell.CellType.booleanValue(value, booleanExpressions: expressions, caseStrategy: strategy)
                #expect(cellType.valueString == "failed", "Should output 'failed' with lower case")
            default:
                Issue.record("Expected booleanValue")
        }
    }

    @Test("toBoolean optional with parameters")
    func toBooleanOptionalWithParameters() throws {
        let products = [
            TestProduct(
                name: "Product 1",
                dateString: "",
                timestampSeconds: 0,
                statusCode: 200,
                discountRate: 0.15,
                isPublished: "yes"),
            TestProduct(
                name: "Product 2",
                dateString: "",
                timestampSeconds: 0,
                statusCode: 404,
                discountRate: nil,
                isPublished: "no"),
        ]

        // Test optional discount to boolean
        let hasDiscountColumn = Column<TestProduct, Double?, DoubleColumnType>(name: "Has Discount", keyPath: \.discountRate)
            .toBoolean(
                booleanExpressions: .trueAndFalse,
                caseStrategy: .upper)
            { (discount: Double?) -> Bool? in
                guard let d = discount else { return nil }
                return d > 0
            }

        let cell1 = hasDiscountColumn.generateCellValue(for: products[0])
        switch cell1 {
            case let .booleanValue(value, expressions, strategy):
                #expect(value == true, "0.15 discount should be true")
                #expect(expressions == .trueAndFalse, "Should use trueAndFalse expressions")
                let cellType = Cell.CellType.booleanValue(value, booleanExpressions: expressions, caseStrategy: strategy)
                #expect(cellType.valueString == "TRUE", "Should output 'TRUE' with upper case")
            default:
                Issue.record("Expected booleanValue")
        }

        let cell2 = hasDiscountColumn.generateCellValue(for: products[1])
        switch cell2 {
            case let .optionalBoolean(value, _, _):
                #expect(value == nil, "nil discount should result in nil boolean")
            default:
                Issue.record("Expected optionalBoolean with nil")
        }
    }

    // MARK: - toPercentage with precision parameter

    @Test("toPercentage with custom precision")
    func toPercentageWithPrecision() throws {
        let products = [
            TestProduct(
                name: "Product 1",
                dateString: "",
                timestampSeconds: 0,
                statusCode: 200,
                discountRate: 0.12345,
                isPublished: "yes"),
        ]

        // Test with precision 1
        let discountColumn1 = Column<TestProduct, Double?, DoubleColumnType>(name: "Discount", keyPath: \.discountRate)
            .defaultValue(0.0)
            .toPercentage(1) { (discount: Double) -> Double in
                discount
            }

        // Test with precision 3
        let discountColumn3 = Column<TestProduct, Double?, DoubleColumnType>(name: "Discount", keyPath: \.discountRate)
            .defaultValue(0.0)
            .toPercentage(3) { (discount: Double) -> Double in
                discount
            }

        let cell1 = discountColumn1.generateCellValue(for: products[0])
        switch cell1 {
            case let .percentageValue(value, precision):
                #expect(value == 0.12345, "Original value should be preserved")
                #expect(precision == 1, "Precision should be 1")
                let cellType = Cell.CellType.percentageValue(value, precision: precision)
                let valueString = cellType.valueString
                // With precision 1, we expect 3 decimal places total (precision + 2)
                #expect(valueString == "0.123", "Should round to 3 decimal places for precision 1")
            default:
                Issue.record("Expected percentageValue")
        }

        let cell3 = discountColumn3.generateCellValue(for: products[0])
        switch cell3 {
            case let .percentageValue(value, precision):
                #expect(value == 0.12345, "Original value should be preserved")
                #expect(precision == 3, "Precision should be 3")
                let cellType = Cell.CellType.percentageValue(value, precision: precision)
                let valueString = cellType.valueString
                // With precision 3, we expect 5 decimal places total (precision + 2)
                #expect(valueString == "0.12345", "Should preserve all 5 decimal places for precision 3")
            default:
                Issue.record("Expected percentageValue")
        }
    }

    @Test("toPercentage optional with precision")
    func toPercentageOptionalWithPrecision() throws {
        let products = [
            TestProduct(
                name: "Product 1",
                dateString: "",
                timestampSeconds: 85,
                statusCode: 200,
                discountRate: nil,
                isPublished: "yes"),
        ]

        // Convert status code to percentage (85/100)
        let scoreColumn = Column<TestProduct, Int, IntColumnType>(name: "Score", keyPath: \.timestampSeconds)
            .toPercentage(0) { (score: Int?) -> Double? in
                guard let s = score else { return nil }
                return Double(s) / 100.0
            }

        let cell = scoreColumn.generateCellValue(for: products[0])
        switch cell {
            case let .percentageValue(value, precision):
                #expect(value == 0.85, "85 should become 0.85 (85%)")
                #expect(precision == 0, "Precision should be 0")
                let cellType = Cell.CellType.percentageValue(value, precision: precision)
                let valueString = cellType.valueString
                // With precision 0, we expect 2 decimal places total (precision + 2)
                #expect(valueString == "0.85", "Should show 0.85 for precision 0")
            default:
                Issue.record("Expected percentageValue")
        }
    }

    @Test("Integration test with all parameters")
    func integrationWithAllParameters() throws {
        let data = [
            TestProduct(
                name: "Test Product",
                dateString: "2025-06-21T15:30:00Z",
                timestampSeconds: 1,
                statusCode: 200,
                discountRate: 0.2567,
                isPublished: "yes"),
        ]

        let sheet = Sheet<TestProduct>(name: "Products", dataProvider: { data }) {
            // Date with timezone
            Column(name: "Date", keyPath: \.dateString)
                .toDate(TimeZone(identifier: "UTC")!) { dateStr in
                    ISO8601DateFormatter().date(from: dateStr) ?? Date()
                }

            // Boolean with custom expressions
            Column(name: "Published", keyPath: \.isPublished)
                .toBoolean(
                    booleanExpressions: .yesAndNo,
                    caseStrategy: .firstLetterUpper)
                { str in
                    str.lowercased() == "yes"
                }

            // Percentage with precision
            Column<TestProduct, Double?, PercentageColumnType>(
                name: "Discount",
                keyPath: \.discountRate,
                precision: 2)
                .defaultValue(0.0)
        }

        let styleRegister = StyleRegister()
        let sharedStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            with: data,
            bookStyle: BookStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: sharedStringRegister)

        #expect(sheetXML != nil, "Sheet should generate successfully with all parameter types")
    }
}
