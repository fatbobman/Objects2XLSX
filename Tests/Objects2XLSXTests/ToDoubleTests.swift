//
// ToDoubleTests.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("toDouble Method Tests")
struct ToDoubleTests {
    struct TestModel: Sendable {
        let name: String
        let priceString: String
        let optionalPriceString: String?
        let count: Int
        let optionalCount: Int?
        let score: Double
        let optionalScore: Double?
    }

    @Test("toDouble from String")
    func toDoubleFromString() throws {
        let data = [
            TestModel(
                name: "Item1",
                priceString: "19.99",
                optionalPriceString: "29.99",
                count: 10,
                optionalCount: 20,
                score: 4.5,
                optionalScore: 3.5),
            TestModel(
                name: "Item2",
                priceString: "invalid",
                optionalPriceString: nil,
                count: 5,
                optionalCount: nil,
                score: 5.0,
                optionalScore: nil)
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // String to Double - handle parsing errors
            Column(name: "Price", keyPath: \.priceString)
                .toDouble { (priceStr: String) in
                    Double(priceStr) ?? 0.0
                }

            // Optional String to Double with nil handling
            Column(name: "Optional Price", keyPath: \.optionalPriceString)
                .toDouble { (priceStr: String?) in
                    guard let priceStr else { return nil }
                    return Double(priceStr)
                }

            // Optional String with defaultValue
            Column(name: "Price with Default", keyPath: \.optionalPriceString)
                .defaultValue("0.0")
                .toDouble { (priceStr: String) in // Non-optional!
                    Double(priceStr) ?? 0.0
                }
        }

        let columns = sheet.columns
        #expect(columns.count == 3)

        // Test String to Double
        let priceValue1 = columns[0].generateCellValue(for: data[0])
        switch priceValue1 {
            case let .doubleValue(value):
                #expect(value == 19.99)
            default:
                #expect(Bool(false), "Should generate doubleValue")
        }

        // Test invalid string conversion
        let priceValue2 = columns[0].generateCellValue(for: data[1])
        switch priceValue2 {
            case let .doubleValue(value):
                #expect(value == 0.0, "Invalid string should convert to 0.0")
            default:
                #expect(Bool(false), "Should generate doubleValue")
        }

        // Test optional String to Double with nil
        let optionalPrice2 = columns[1].generateCellValue(for: data[1])
        switch optionalPrice2 {
            case let .optionalDouble(value):
                #expect(value == nil, "Should handle nil optional")
            default:
                #expect(Bool(false), "Should generate optionalDouble")
        }

        // Test optional String with defaultValue
        let defaultPrice2 = columns[2].generateCellValue(for: data[1])
        switch defaultPrice2 {
            case let .doubleValue(value):
                #expect(value == 0.0, "Should use default value")
            default:
                #expect(Bool(false), "Should generate doubleValue")
        }
    }

    @Test("toDouble from Int")
    func toDoubleFromInt() throws {
        let data = [
            TestModel(
                name: "Item",
                priceString: "10",
                optionalPriceString: nil,
                count: 42,
                optionalCount: 100,
                score: 1.0,
                optionalScore: nil)
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Int to Double
            Column(name: "Count as Double", keyPath: \.count)
                .toDouble { (count: Int) in
                    Double(count)
                }

            // Optional Int to Double
            Column(name: "Optional Count", keyPath: \.optionalCount)
                .toDouble { (count: Int?) in
                    count.map { Double($0) }
                }

            // Optional Int with defaultValue
            Column(name: "Count with Default", keyPath: \.optionalCount)
                .defaultValue(0)
                .toDouble { (count: Int) in
                    Double(count) * 1.5
                }
        }

        let columns = sheet.columns

        // Test Int to Double
        let countDouble = columns[0].generateCellValue(for: data[0])
        switch countDouble {
            case let .doubleValue(value):
                #expect(value == 42.0)
            default:
                #expect(Bool(false), "Should generate doubleValue")
        }

        // Test optional Int with transformation
        let transformedCount = columns[2].generateCellValue(for: data[0])
        switch transformedCount {
            case let .doubleValue(value):
                #expect(value == 150.0, "Should apply transformation (100 * 1.5)")
            default:
                #expect(Bool(false), "Should generate doubleValue")
        }
    }

    @Test("toDouble chaining")
    func toDoubleChaining() throws {
        let data = [
            TestModel(
                name: "Item",
                priceString: "10.5",
                optionalPriceString: nil,
                count: 10,
                optionalCount: nil,
                score: 4.5,
                optionalScore: nil)
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Chain toDouble with styling
            Column(name: "Styled Price", keyPath: \.priceString)
                .toDouble { Double($0) ?? 0.0 }
                .width(15)
                .bodyStyle(CellStyle(
                    font: Font(bold: true),
                    alignment: Alignment(horizontal: .right)))
        }

        let columns = sheet.columns
        let column = columns[0]

        // Verify chaining works
        #expect(column.width == 15)
        #expect(column.bodyStyle != nil)

        // Verify value generation
        let cellValue = column.generateCellValue(for: data[0])
        switch cellValue {
            case let .doubleValue(value):
                #expect(value == 10.5)
            default:
                #expect(Bool(false), "Should generate doubleValue")
        }
    }
}
