//
// StringTypeEnhancementTests.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import Testing
@testable import Objects2XLSX

@Suite("String Type Enhancement Tests")
struct StringTypeEnhancementTests {
    
    struct TestModel: Sendable {
        let name: String
        let description: String?
        let code: String?
    }
    
    @Test("String CellType Cases")
    func stringCellTypeCases() throws {
        // Test non-optional string
        let stringValue = Cell(row: 1, column: 1, value: .stringValue("Hello"))
        let stringXML = stringValue.generateXML()
        #expect(stringXML == "<c r=\"A1\" t=\"inlineStr\"><is><t>Hello</t></is></c>")
        #expect(stringValue.value.valueString == "Hello")
        
        // Test optional string with value
        let optionalString = Cell(row: 1, column: 2, value: .optionalString("World"))
        let optionalXML = optionalString.generateXML()
        #expect(optionalXML == "<c r=\"B1\" t=\"inlineStr\"><is><t>World</t></is></c>")
        #expect(optionalString.value.valueString == "World")
        
        // Test optional string with nil
        let nilString = Cell(row: 1, column: 3, value: .optionalString(nil))
        let nilXML = nilString.generateXML()
        #expect(nilXML == "<c r=\"C1\" t=\"inlineStr\"><is><t></t></is></c>")
        #expect(nilString.value.valueString == "")
        
        // Test with shared string
        let sharedString = Cell(row: 1, column: 4, value: .stringValue("Shared"), sharedStringID: 10)
        let sharedXML = sharedString.generateXML()
        #expect(sharedXML == "<c r=\"D1\" t=\"s\"><v>10</v></c>")
    }
    
    @Test("TextColumnType CellType Selection")
    func textColumnTypeCellType() throws {
        // Non-nil value should use stringValue
        let nonNilConfig = TextColumnConfig(value: "Test")
        let nonNilType = TextColumnType(nonNilConfig)
        
        switch nonNilType.cellType {
        case .stringValue(let value):
            #expect(value == "Test")
        default:
            #expect(Bool(false), "Should use stringValue for non-nil")
        }
        
        // Nil value should use optionalString
        let nilConfig = TextColumnConfig(value: nil)
        let nilType = TextColumnType(nilConfig)
        
        switch nilType.cellType {
        case .optionalString(let value):
            #expect(value == nil)
        default:
            #expect(Bool(false), "Should use optionalString for nil")
        }
    }
    
    @Test("TextColumnType withDefaultValue")
    func textColumnTypeDefaultValue() throws {
        // Test with nil value
        let nilConfig = TextColumnConfig(value: nil)
        let withDefault = TextColumnType.withDefaultValue("Default", config: nilConfig)
        #expect(withDefault.config.value == "Default")
        
        // Test with non-nil value (should preserve original)
        let nonNilConfig = TextColumnConfig(value: "Original")
        let preserveOriginal = TextColumnType.withDefaultValue("Default", config: nonNilConfig)
        #expect(preserveOriginal.config.value == "Original")
    }
    
    @Test("String Column Optional Support")
    func stringColumnOptionalSupport() throws {
        let data = [
            TestModel(name: "Product A", description: "Description A", code: "PA001"),
            TestModel(name: "Product B", description: nil, code: nil),
            TestModel(name: "Product C", description: "Description C", code: "PC003")
        ]
        
        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Non-optional string column
            Column(name: "Name", keyPath: \.name)
            
            // Optional string column without default
            Column(name: "Description", keyPath: \.description)
            
            // Optional string column with default
            Column(name: "Code", keyPath: \.code)
                .defaultValue("N/A")
        }
        
        let columns = sheet.columns
        #expect(columns.count == 3)
        
        // Test that the column generates correct cell values
        let cellValue = columns[2].generateCellValue(for: data[1]) // Product B with nil code
        
        switch cellValue {
        case .stringValue(let value):
            #expect(value == "N/A", "Should use default value for nil")
        default:
            #expect(Bool(false), "Should generate stringValue")
        }
    }
    
    @Test("String Column toString with defaultValue")
    func stringColumnToStringWithDefault() throws {
        let data = [
            TestModel(name: "Product", description: "Desc", code: nil)
        ]
        
        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Optional string with defaultValue and toString
            Column(name: "Code", keyPath: \.code)
                .defaultValue("UNKNOWN")
                .toString { (code: String) in  // Non-optional after defaultValue
                    "CODE: \(code)"
                }
        }
        
        let columns = sheet.columns
        let column = columns[0]
        
        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])
        
        switch cellValue {
        case .stringValue(let value):
            #expect(value == "CODE: UNKNOWN")
        default:
            #expect(Bool(false), "Should generate stringValue with transformed default")
        }
    }
}