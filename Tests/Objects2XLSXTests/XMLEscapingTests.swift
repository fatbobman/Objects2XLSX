//
// XMLEscapingTests.swift
// Tests for XML escaping functionality in cell values
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("XML Escaping Tests")
struct XMLEscapingTests {
    // Test model with potentially problematic characters
    struct TestData: Sendable {
        let name: String
        let description: String?
        let url: URL?
        let isActive: Bool
        let notes: String
    }

    @Test("String values with XML special characters")
    func stringXMLEscaping() throws {
        let data = [
            TestData(
                name: "Test & Demo",
                description: "Description with <tag> and 'quotes'",
                url: URL(string: "https://example.com?param=value&other=test"),
                isActive: true,
                notes: "Notes with \"double quotes\" and < > & symbols")
        ]

        // Create columns for different string types
        let nameColumn = Column<TestData, String, TextColumnType>(name: "Name", keyPath: \.name)
        let descColumn = Column<TestData, String?, TextColumnType>(name: "Description", keyPath: \.description)
        let notesColumn = Column<TestData, String, TextColumnType>(name: "Notes", keyPath: \.notes)

        // Test name column (non-optional string)
        let nameCell = nameColumn.generateCellValue(for: data[0])
        switch nameCell {
            case let .stringValue(value):
                #expect(value == "Test & Demo", "Original value should be preserved")
                let cellType = Cell.CellType.stringValue(value)
                let valueString = cellType.valueString
                #expect(valueString.contains("&amp;"), "& should be escaped to &amp;")
                #expect(!valueString.contains("& "), "Raw & should not exist")
            default:
                Issue.record("Expected stringValue")
        }

        // Test description column (optional string)
        let descCell = descColumn.generateCellValue(for: data[0])
        switch descCell {
            case let .stringValue(value):
                #expect(value == "Description with <tag> and 'quotes'", "Original value should be preserved")
                let cellType = Cell.CellType.stringValue(value)
                let valueString = cellType.valueString
                #expect(valueString.contains("&lt;tag&gt;"), "< and > should be escaped")
                #expect(valueString.contains("&apos;quotes&apos;"), "' should be escaped")
            default:
                Issue.record("Expected stringValue")
        }

        // Test notes with double quotes
        let notesCell = notesColumn.generateCellValue(for: data[0])
        switch notesCell {
            case let .stringValue(value):
                let cellType = Cell.CellType.stringValue(value)
                let valueString = cellType.valueString
                #expect(valueString.contains("&quot;double quotes&quot;"), "\" should be escaped to &quot;")
                #expect(valueString.contains("&lt;"), "< should be escaped")
                #expect(valueString.contains("&gt;"), "> should be escaped")
                #expect(valueString.contains("&amp;"), "& should be escaped")
            default:
                Issue.record("Expected stringValue")
        }
    }

    @Test("URL values with XML special characters")
    func urlXMLEscaping() throws {
        let data = [
            TestData(
                name: "Test",
                description: nil,
                url: URL(string: "https://example.com/path?param1=value&param2=%3Ctest%3E"),
                isActive: true,
                notes: "")
        ]

        let urlColumn = Column<TestData, URL?, URLColumnType>(name: "URL", keyPath: \.url)

        let urlCell = urlColumn.generateCellValue(for: data[0])
        switch urlCell {
            case let .urlValue(url):
                let cellType = Cell.CellType.urlValue(url)
                let valueString = cellType.valueString
                #expect(valueString.contains("&amp;"), "& in URL should be escaped")
                // URLs should preserve URL encoding
                #expect(valueString.contains("%3Ctest%3E"), "< and > in URL should remain URL encoded")
                #expect(!valueString.contains("&param"), "Raw & should not exist in URL")
            default:
                Issue.record("Expected urlValue")
        }
    }

    @Test("Boolean values with XML escaping")
    func booleanXMLEscaping() throws {
        let data = [
            TestData(name: "Test", description: nil, url: nil, isActive: true, notes: "")
        ]

        // Test with custom boolean expressions that might need escaping
        let boolColumn = Column<TestData, Bool, BoolColumnType>(
            name: "Status",
            keyPath: \.isActive,
            booleanExpressions: .custom(true: "Yes & Active", false: "No & Inactive"),
            caseStrategy: .upper)

        let boolCell = boolColumn.generateCellValue(for: data[0])
        switch boolCell {
            case let .booleanValue(value, expressions, strategy):
                let cellType = Cell.CellType.booleanValue(value, booleanExpressions: expressions, caseStrategy: strategy)
                let valueString = cellType.valueString
                #expect(valueString == "YES &amp; ACTIVE", "Boolean custom string should be XML escaped and uppercased")
            default:
                Issue.record("Expected booleanValue")
        }
    }

    @Test("Sheet XML generation with escaped values")
    func sheetXMLWithEscapedValues() throws {
        let employees = [
            TestData(
                name: "John & Jane",
                description: "Team <Lead>",
                url: URL(string: "https://example.com?id=123&type=user"),
                isActive: true,
                notes: "Special \"notes\" with <important> tags")
        ]

        let sheet = Sheet<TestData>(name: "Test & Data", dataProvider: { employees }) {
            Column(name: "Name & Title", keyPath: \.name)
            Column(name: "Description", keyPath: \.description).defaultValue("No <desc>")
            Column(name: "URL", keyPath: \.url)
            Column(name: "Active?", keyPath: \.isActive)
            Column(name: "Notes", keyPath: \.notes)
        }

        let styleRegister = StyleRegister()
        let sharedStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            with: employees,
            bookStyle: BookStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: sharedStringRegister)

        #expect(sheetXML != nil, "Sheet XML should be generated")

        // Check that sheet name is properly sanitized (Sheet names have different rules than cell values)
        #expect(sheet.name == "Test & Data", "Sheet name should preserve &")

        // Check shared strings are properly registered
        let sharedStrings = sharedStringRegister.allStrings
        #expect(sharedStrings.contains("Name & Title"), "Column header should be in shared strings")
        #expect(sharedStrings.contains("John & Jane"), "Cell value should be in shared strings")
        #expect(sharedStrings.contains("Team <Lead>"), "Cell value with < > should be in shared strings")

        // Generate XML and verify it's well-formed
        let xml = sheetXML!.generateXML()
        #expect(!xml.isEmpty, "XML should not be empty")

        // The actual XML escaping happens in the SharedStrings XML generation,
        // but the cell values in sheet XML reference shared string indices
        #expect(xml.contains("t=\"s\""), "Should use shared string references")
    }
}
