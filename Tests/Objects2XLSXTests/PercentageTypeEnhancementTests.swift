//
// PercentageTypeEnhancementTests.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Percentage Type Enhancement Tests")
struct PercentageTypeEnhancementTests {
    struct TestModel: Sendable {
        let name: String
        let successRate: Double
        let optionalGrowthRate: Double?
        let accuracy: Double?
    }

    @Test("Percentage CellType Cases")
    func percentageCellTypeCases() throws {
        // Test non-optional Percentage
        let percentageValue = Cell(row: 1, column: 1, value: .percentageValue(0.75, precision: 2))
        let percentageXML = percentageValue.generateXML()
        #expect(percentageXML.contains("<v>0.75</v>"))
        #expect(percentageValue.value.valueString == "0.75")

        // Test non-optional Percentage with different precision
        let precisePct = Cell(row: 1, column: 2, value: .percentageValue(0.123456, precision: 3))
        let preciseXML = precisePct.generateXML()
        #expect(preciseXML.contains("<v>0.12346</v>"))  // precision 3 + 2 = 5 decimal places
        #expect(precisePct.value.valueString == "0.12346")

        // Test optional Percentage with value
        let optionalPct = Cell(row: 1, column: 3, value: .optionalPercentage(0.5, precision: 1))
        let optionalXML = optionalPct.generateXML()
        #expect(optionalXML.contains("<v>0.5</v>"))
        #expect(optionalPct.value.valueString == "0.5")

        // Test optional Percentage with nil
        let nilPct = Cell(row: 1, column: 4, value: .optionalPercentage(nil, precision: 2))
        let nilXML = nilPct.generateXML()
        #expect(nilXML.contains("<v></v>"))
        #expect(nilPct.value.valueString == "")

        // Test legacy percentage (now use new type-safe enum)
        let newPct = Cell(row: 1, column: 5, value: .percentageValue(0.25, precision: 2))
        #expect(newPct.value.valueString == "0.25")
    }

    @Test("PercentageColumnType CellType Selection")
    func percentageColumnTypeCellType() throws {
        // Non-nil value should use percentageValue
        let nonNilConfig = PercentageColumnConfig(value: 0.85, precision: 2)
        let nonNilType = PercentageColumnType(nonNilConfig)

        switch nonNilType.cellType {
            case let .percentageValue(value, precision):
                #expect(value == 0.85)
                #expect(precision == 2)
            default:
                #expect(Bool(false), "Should use percentageValue for non-nil")
        }

        // Nil value should use optionalPercentage
        let nilConfig = PercentageColumnConfig(value: nil, precision: 3)
        let nilType = PercentageColumnType(nilConfig)

        switch nilType.cellType {
            case let .optionalPercentage(value, precision):
                #expect(value == nil)
                #expect(precision == 3)
            default:
                #expect(Bool(false), "Should use optionalPercentage for nil")
        }
    }

    @Test("PercentageColumnType withDefaultValue")
    func percentageColumnTypeDefaultValue() throws {
        let defaultValue = 0.0

        // Test with nil value
        let nilConfig = PercentageColumnConfig(value: nil, precision: 2)
        let withDefault = PercentageColumnType.withDefaultValue(defaultValue, config: nilConfig)
        #expect(withDefault.config.value == defaultValue)
        #expect(withDefault.config.precision == 2)

        // Test with non-nil value (should preserve original)
        let originalValue = 0.75
        let nonNilConfig = PercentageColumnConfig(value: originalValue, precision: 3)
        let preserveOriginal = PercentageColumnType.withDefaultValue(defaultValue, config: nonNilConfig)
        #expect(preserveOriginal.config.value == originalValue)
        #expect(preserveOriginal.config.precision == 3)
    }

    @Test("Percentage Column Optional Support")
    func percentageColumnOptionalSupport() throws {
        let defaultValue = 0.0

        let data = [
            TestModel(name: "Project A", successRate: 0.85, optionalGrowthRate: 0.15, accuracy: 0.95),
            TestModel(name: "Project B", successRate: 0.60, optionalGrowthRate: nil, accuracy: nil),
            TestModel(name: "Project C", successRate: 0.92, optionalGrowthRate: -0.05, accuracy: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Non-optional Percentage column (using full constructor)
            Column(name: "Success Rate", keyPath: \.successRate, width: nil, bodyStyle: nil, headerStyle: nil, mapping: { value in
                PercentageColumnType(PercentageColumnConfig(value: value, precision: 2))
            }, nilHandling: .keepEmpty)

            // Optional Percentage column without default
            Column(name: "Growth Rate", keyPath: \.optionalGrowthRate, precision: 1)

            // Optional Percentage column with default
            Column(name: "Accuracy", keyPath: \.accuracy, precision: 2)
                .defaultValue(defaultValue)
        }

        let columns = sheet.columns
        #expect(columns.count == 3)

        // Test that the column generates correct cell values
        let cellValue = columns[2].generateCellValue(for: data[1]) // Project B with nil accuracy

        switch cellValue {
            case let .percentageValue(value, _):
                #expect(value == defaultValue, "Should use default value for nil")
            case let .optionalPercentage(value, _):
                if value == nil {
                    #expect(Bool(false), "Should not generate optionalPercentage with nil when defaultValue is set")
                } else {
                    #expect(value == defaultValue, "Should use default value for nil")
                }
            default:
                #expect(Bool(false), "Should generate percentageValue, got: \(cellValue)")
        }
    }

    @Test("Percentage Column toPercentage with defaultValue")
    func percentageColumnToPercentageWithDefault() throws {
        let defaultValue = 1.0

        let data = [
            TestModel(name: "Project", successRate: 0.85, optionalGrowthRate: nil, accuracy: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Optional Percentage with defaultValue and toPercentage
            Column(name: "Accuracy", keyPath: \.accuracy)
                .defaultValue(defaultValue)
                .toPercentage { (accuracy: Double) in // Non-optional after defaultValue
                    // Convert to decimal percentage
                    accuracy * 0.9 // Apply 10% discount
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .percentageValue(value, _):
                #expect(value == 0.9, "Should generate modified default value")
            default:
                #expect(Bool(false), "Should generate percentageValue with transformed default")
        }
    }

    @Test("Percentage Column toString transformation")
    func percentageColumnToStringTransformation() throws {
        let data = [
            TestModel(name: "Project", successRate: 0.756, optionalGrowthRate: -0.125, accuracy: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Percentage to String transformation
            Column(name: "Success Description", keyPath: \.successRate)
                .toString { (rate: Double) in
                    let percentage = rate * 100
                    if percentage >= 80 {
                        return "Excellent (\(String(format: "%.1f", percentage))%)"
                    } else if percentage >= 60 {
                        return "Good (\(String(format: "%.1f", percentage))%)"
                    } else {
                        return "Needs Improvement (\(String(format: "%.1f", percentage))%)"
                    }
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .stringValue(value):
                #expect(value == "Good (75.6%)")
            default:
                #expect(Bool(false), "Should generate stringValue")
        }
    }

    @Test("Int to Percentage conversion")
    func intToPercentageConversion() throws {
        struct ScoreModel: Sendable {
            let score: Int
            let optionalBonus: Int?
        }

        let data = [
            ScoreModel(score: 85, optionalBonus: 10),
            ScoreModel(score: 72, optionalBonus: nil),
            ScoreModel(score: 96, optionalBonus: 5),
        ]

        let sheet = Sheet<ScoreModel>(name: "Test", dataProvider: { data }) {
            // Int to Percentage conversion
            Column(name: "Score %", keyPath: \.score)
                .toPercentage { (score: Int) in
                    Double(score) / 100.0 // Convert score to percentage decimal
                }

            // Optional Int to Percentage with nil handling
            Column(name: "Bonus %", keyPath: \.optionalBonus)
                .toPercentage { (bonus: Int?) in
                    guard let bonus else { return nil }
                    return Double(bonus) / 100.0
                }
        }

        let columns = sheet.columns

        // Test valid score conversion
        let scorePercentage = columns[0].generateCellValue(for: data[0])
        switch scorePercentage {
            case let .percentageValue(value, _):
                #expect(value == 0.85)
            default:
                #expect(Bool(false), "Should generate percentageValue")
        }

        // Test nil bonus handling
        let nilBonus = columns[1].generateCellValue(for: data[1])
        switch nilBonus {
            case let .optionalPercentage(value, _):
                #expect(value == nil)
            default:
                #expect(Bool(false), "Should generate optionalPercentage")
        }

        // Test bonus conversion
        let bonusPercentage = columns[1].generateCellValue(for: data[0])
        switch bonusPercentage {
            case let .percentageValue(value, _):
                #expect(value == 0.10)
            default:
                #expect(Bool(false), "Should generate percentageValue")
        }
    }

    @Test("String to Percentage conversion")
    func stringToPercentageConversion() throws {
        struct PercentageModel: Sendable {
            let rateString: String
            let optionalRateString: String?
        }

        let data = [
            PercentageModel(rateString: "75.5%", optionalRateString: "12.8%"),
            PercentageModel(rateString: "invalid", optionalRateString: nil),
            PercentageModel(rateString: "100%", optionalRateString: "0%"),
        ]

        let sheet = Sheet<PercentageModel>(name: "Test", dataProvider: { data }) {
            // String to Percentage conversion
            Column(name: "Rate", keyPath: \.rateString)
                .toPercentage { (rateStr: String) in
                    let cleanStr = rateStr.replacingOccurrences(of: "%", with: "")
                    return (Double(cleanStr) ?? 0.0) / 100.0
                }

            // Optional String to Percentage with nil handling
            Column(name: "Optional Rate", keyPath: \.optionalRateString)
                .toPercentage { (rateStr: String?) in
                    guard let rateStr else { return nil }
                    let cleanStr = rateStr.replacingOccurrences(of: "%", with: "")
                    return (Double(cleanStr) ?? 0.0) / 100.0
                }
        }

        let columns = sheet.columns

        // Test valid string conversion
        let validRate = columns[0].generateCellValue(for: data[0])
        switch validRate {
            case let .percentageValue(value, _):
                #expect(value == 0.755)
            default:
                #expect(Bool(false), "Should generate percentageValue")
        }

        // Test invalid string fallback
        let invalidRate = columns[0].generateCellValue(for: data[1])
        switch invalidRate {
            case let .percentageValue(value, _):
                #expect(value == 0.0)
            default:
                #expect(Bool(false), "Should generate fallback percentageValue")
        }

        // Test nil handling
        let nilRate = columns[1].generateCellValue(for: data[1])
        switch nilRate {
            case let .optionalPercentage(value, _):
                #expect(value == nil)
            default:
                #expect(Bool(false), "Should generate optionalPercentage")
        }
    }

    @Test("Percentage Precision Handling")
    func percentagePrecisionHandling() throws {
        // Test different precision values
        let precisions = [0, 1, 2, 3]
        let testValue = 0.123456

        for precision in precisions {
            let percentageCell = Cell(row: 1, column: 1, value: .percentageValue(testValue, precision: precision))

            switch percentageCell.value {
                case let .percentageValue(value, prec):
                    #expect(value == testValue)
                    #expect(prec == precision)
                default:
                    #expect(Bool(false), "Should be percentageValue")
            }
        }
    }

    @Test("Percentage Constructor with precision")
    func percentageConstructorWithPrecision() throws {
        struct TestData: Sendable {
            let rate: Double?
        }

        let data = [TestData(rate: 0.12345)]

        // Test constructor with custom precision
        let sheet = Sheet<TestData>(name: "Test", dataProvider: { data }) {
            Column(name: "Custom Precision", keyPath: \.rate, precision: 3)
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .percentageValue(value, precision):
                #expect(value == 0.12345)
                #expect(precision == 3)
            default:
                #expect(Bool(false), "Should generate percentageValue with custom precision")
        }
    }
}
