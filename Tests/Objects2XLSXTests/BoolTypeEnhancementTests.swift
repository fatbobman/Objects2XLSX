//
// BoolTypeEnhancementTests.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Bool Type Enhancement Tests")
struct BoolTypeEnhancementTests {
    struct TestModel: Sendable {
        let name: String
        let isActive: Bool
        let optionalActive: Bool?
        let isPremium: Bool?
    }

    @Test("Bool CellType Cases")
    func boolCellTypeCases() throws {
        // Test non-optional Bool
        let boolValue = Cell(row: 1, column: 1, value: .booleanValue(true))
        let boolXML = boolValue.generateXML()
        #expect(boolXML.contains("t=\"b\""))
        #expect(boolXML.contains("<v>1</v>"))
        #expect(boolValue.value.valueString == "1")

        // Test non-optional Bool false
        let boolFalse = Cell(row: 1, column: 2, value: .booleanValue(false, booleanExpressions: .trueAndFalse))
        let falseXML = boolFalse.generateXML()
        #expect(falseXML.contains("t=\"b\""))
        #expect(falseXML.contains("<v>0</v>"))
        #expect(boolFalse.value.valueString == "FALSE")

        // Test optional Bool with value
        let optionalBool = Cell(row: 1, column: 3, value: .optionalBoolean(true, booleanExpressions: .yesAndNo))
        let optionalXML = optionalBool.generateXML()
        #expect(optionalXML.contains("t=\"b\""))
        #expect(optionalXML.contains("<v>1</v>"))
        #expect(optionalBool.value.valueString == "YES")

        // Test optional Bool with nil
        let nilBool = Cell(row: 1, column: 4, value: .optionalBoolean(nil))
        let nilXML = nilBool.generateXML()
        #expect(nilXML.contains("t=\"b\""))
        #expect(nilXML.contains("<v></v>"))
        #expect(nilBool.value.valueString == "")

        // Test different boolean expressions
        let customBool = Cell(row: 1, column: 5, value: .booleanValue(true, booleanExpressions: .custom(true: "Active", false: "Inactive")))
        #expect(customBool.value.valueString == "ACTIVE")
    }

    @Test("BoolColumnType CellType Selection")
    func boolColumnTypeCellType() throws {
        // Non-nil value should use booleanValue
        let nonNilConfig = BoolColumnConfig(value: true, booleanExpressions: .oneAndZero, caseStrategy: .upper)
        let nonNilType = BoolColumnType(nonNilConfig)

        switch nonNilType.cellType {
            case let .booleanValue(value, expressions, strategy):
                #expect(value == true)
                #expect(expressions == .oneAndZero)
                #expect(strategy == .upper)
            default:
                #expect(Bool(false), "Should use booleanValue for non-nil")
        }

        // Nil value should use optionalBoolean
        let nilConfig = BoolColumnConfig(value: nil, booleanExpressions: .yesAndNo, caseStrategy: .lower)
        let nilType = BoolColumnType(nilConfig)

        switch nilType.cellType {
            case let .optionalBoolean(value, expressions, strategy):
                #expect(value == nil)
                #expect(expressions == .yesAndNo)
                #expect(strategy == .lower)
            default:
                #expect(Bool(false), "Should use optionalBoolean for nil")
        }
    }

    @Test("BoolColumnType withDefaultValue")
    func boolColumnTypeDefaultValue() throws {
        let defaultValue = true

        // Test with nil value
        let nilConfig = BoolColumnConfig(value: nil, booleanExpressions: .trueAndFalse, caseStrategy: .firstLetterUpper)
        let withDefault = BoolColumnType.withDefaultValue(defaultValue, config: nilConfig)
        #expect(withDefault.config.value == defaultValue)
        #expect(withDefault.config.booleanExpressions == .trueAndFalse)
        #expect(withDefault.config.caseStrategy == .firstLetterUpper)

        // Test with non-nil value (should preserve original)
        let originalValue = false
        let nonNilConfig = BoolColumnConfig(value: originalValue, booleanExpressions: .oneAndZero, caseStrategy: .upper)
        let preserveOriginal = BoolColumnType.withDefaultValue(defaultValue, config: nonNilConfig)
        #expect(preserveOriginal.config.value == originalValue)
        #expect(preserveOriginal.config.booleanExpressions == .oneAndZero)
        #expect(preserveOriginal.config.caseStrategy == .upper)
    }

    @Test("Bool Column Optional Support")
    func boolColumnOptionalSupport() throws {
        let defaultValue = false

        let data = [
            TestModel(name: "User A", isActive: true, optionalActive: true, isPremium: true),
            TestModel(name: "User B", isActive: false, optionalActive: nil, isPremium: nil),
            TestModel(name: "User C", isActive: true, optionalActive: false, isPremium: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Non-optional Bool column (using full constructor)
            Column(name: "Is Active", keyPath: \.isActive, width: nil, bodyStyle: nil, headerStyle: nil, mapping: { value in
                BoolColumnType(BoolColumnConfig(value: value, booleanExpressions: .trueAndFalse, caseStrategy: .upper))
            }, nilHandling: .keepEmpty)

            // Optional Bool column without default
            Column(name: "Optional Active", keyPath: \.optionalActive)

            // Optional Bool column with default
            Column(name: "Is Premium", keyPath: \.isPremium)
                .defaultValue(defaultValue)
        }

        let columns = sheet.columns
        #expect(columns.count == 3)

        // Test that the column generates correct cell values
        let cellValue = columns[2].generateCellValue(for: data[1]) // User B with nil isPremium

        switch cellValue {
            case let .booleanValue(value, _, _):
                #expect(value == defaultValue, "Should use default value for nil")
            default:
                #expect(Bool(false), "Should generate booleanValue")
        }
    }

    @Test("Bool Column toBoolean with defaultValue")
    func boolColumnToBooleanWithDefault() throws {
        let defaultValue = true

        let data = [
            TestModel(name: "User", isActive: true, optionalActive: nil, isPremium: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Optional Bool with defaultValue and toBoolean
            Column(name: "Is Premium", keyPath: \.isPremium)
                .defaultValue(defaultValue)
                .toBoolean { (isPremium: Bool) in // Non-optional after defaultValue
                    // Invert the boolean value
                    !isPremium
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .booleanValue(value, _, _):
                #expect(value == false, "Should generate inverted default value")
            default:
                #expect(Bool(false), "Should generate booleanValue with transformed default")
        }
    }

    @Test("Bool Column toString transformation")
    func boolColumnToStringTransformation() throws {
        let data = [
            TestModel(name: "User", isActive: true, optionalActive: false, isPremium: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Bool to String transformation
            Column(name: "Activity Status", keyPath: \.isActive)
                .toString { (isActive: Bool) in
                    isActive ? "Currently Active" : "Currently Inactive"
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .stringValue(value):
                #expect(value == "Currently Active")
            default:
                #expect(Bool(false), "Should generate stringValue")
        }
    }

    @Test("String to Bool conversion")
    func stringToBoolConversion() throws {
        struct BoolTestModel: Sendable {
            let status: String
            let optionalStatus: String?
        }

        let data = [
            BoolTestModel(status: "active", optionalStatus: "yes"),
            BoolTestModel(status: "inactive", optionalStatus: nil),
            BoolTestModel(status: "ACTIVE", optionalStatus: "true"),
        ]

        let sheet = Sheet<BoolTestModel>(name: "Test", dataProvider: { data }) {
            // String to Bool conversion
            Column(name: "Is Active", keyPath: \.status)
                .toBoolean { (status: String) in
                    status.lowercased() == "active"
                }

            // Optional String to Bool with nil handling
            Column(name: "Is Confirmed", keyPath: \.optionalStatus)
                .toBoolean { (status: String?) in
                    guard let status else { return nil }
                    return ["yes", "true", "active"].contains(status.lowercased())
                }
        }

        let columns = sheet.columns

        // Test valid status conversion
        let activeStatus = columns[0].generateCellValue(for: data[0])
        switch activeStatus {
            case let .booleanValue(value, _, _):
                #expect(value == true)
            default:
                #expect(Bool(false), "Should generate booleanValue")
        }

        // Test inactive status conversion
        let inactiveStatus = columns[0].generateCellValue(for: data[1])
        switch inactiveStatus {
            case let .booleanValue(value, _, _):
                #expect(value == false)
            default:
                #expect(Bool(false), "Should generate booleanValue")
        }

        // Test optional nil handling
        let nilStatus = columns[1].generateCellValue(for: data[1])
        switch nilStatus {
            case let .optionalBoolean(value, _, _):
                #expect(value == nil)
            default:
                #expect(Bool(false), "Should generate optionalBoolean")
        }

        // Test optional yes conversion
        let yesStatus = columns[1].generateCellValue(for: data[0])
        switch yesStatus {
            case let .booleanValue(value, _, _):
                #expect(value == true)
            default:
                #expect(Bool(false), "Should generate booleanValue")
        }
    }

    @Test("Bool Case Strategy Application")
    func boolCaseStrategyApplication() throws {
        // Test upper case
        let upperBool = Cell(row: 1, column: 1, value: .booleanValue(true, booleanExpressions: .yesAndNo, caseStrategy: .upper))
        #expect(upperBool.value.valueString == "YES")

        // Test lower case
        let lowerBool = Cell(row: 1, column: 2, value: .booleanValue(false, booleanExpressions: .trueAndFalse, caseStrategy: .lower))
        #expect(lowerBool.value.valueString == "false")

        // Test first letter upper
        let titleBool = Cell(row: 1, column: 3, value: .booleanValue(true, booleanExpressions: .yesAndNo, caseStrategy: .firstLetterUpper))
        #expect(titleBool.value.valueString == "Yes")
    }

    @Test("Bool Boolean Expressions")
    func boolBooleanExpressions() throws {
        // Test all boolean expression types
        let expressions: [Cell.BooleanExpressions] = [
            .trueAndFalse,
            .oneAndZero,
            .tAndF,
            .yesAndNo,
            .custom(true: "On", false: "Off")
        ]

        let expectedTrue = ["TRUE", "1", "T", "YES", "ON"]
        let expectedFalse = ["FALSE", "0", "F", "NO", "OFF"]

        for (index, expression) in expressions.enumerated() {
            let trueBool = Cell(row: 1, column: index + 1, value: .booleanValue(true, booleanExpressions: expression, caseStrategy: .upper))
            #expect(trueBool.value.valueString == expectedTrue[index])

            let falseBool = Cell(row: 2, column: index + 1, value: .booleanValue(false, booleanExpressions: expression, caseStrategy: .upper))
            #expect(falseBool.value.valueString == expectedFalse[index])
        }
    }
}