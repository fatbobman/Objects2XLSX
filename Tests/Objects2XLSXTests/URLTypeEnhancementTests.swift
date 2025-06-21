//
// URLTypeEnhancementTests.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("URL Type Enhancement Tests")
struct URLTypeEnhancementTests {
    struct TestModel: Sendable {
        let name: String
        let website: URL
        let optionalWebsite: URL?
        let homepage: URL?
    }

    @Test("URL CellType Cases")
    func urlCellTypeCases() throws {
        let testURL = URL(string: "https://example.com")!

        // Test non-optional URL
        let urlValue = Cell(row: 1, column: 1, value: .urlValue(testURL))
        let urlXML = urlValue.generateXML()
        #expect(urlXML.contains("<is><t>https://example.com</t></is>"))
        #expect(urlValue.value.valueString == testURL.absoluteString)

        // Test optional URL with value
        let optionalURL = Cell(row: 1, column: 2, value: .optionalURL(testURL))
        let optionalXML = optionalURL.generateXML()
        #expect(optionalXML.contains("<is><t>https://example.com</t></is>"))
        #expect(optionalURL.value.valueString == testURL.absoluteString)

        // Test optional URL with nil
        let nilURL = Cell(row: 1, column: 3, value: .optionalURL(nil))
        let nilXML = nilURL.generateXML()
        #expect(nilXML.contains("<is><t></t></is>"))
        #expect(nilURL.value.valueString == "")

        // Test with shared string
        let sharedURL = Cell(row: 1, column: 4, value: .urlValue(testURL), sharedStringID: 10)
        let sharedXML = sharedURL.generateXML()
        #expect(sharedXML.contains("<c r=\"D1\" t=\"s\"><v>10</v></c>"))
    }

    @Test("URLColumnType CellType Selection")
    func urlColumnTypeCellType() throws {
        let testURL = URL(string: "https://example.com")!

        // Non-nil value should use urlValue
        let nonNilConfig = URLColumnConfig(value: testURL)
        let nonNilType = URLColumnType(nonNilConfig)

        switch nonNilType.cellType {
            case let .urlValue(value):
                #expect(value == testURL)
            default:
                #expect(Bool(false), "Should use urlValue for non-nil")
        }

        // Nil value should use optionalURL
        let nilConfig = URLColumnConfig(value: nil)
        let nilType = URLColumnType(nilConfig)

        switch nilType.cellType {
            case let .optionalURL(value):
                #expect(value == nil)
            default:
                #expect(Bool(false), "Should use optionalURL for nil")
        }
    }

    @Test("URLColumnType withDefaultValue")
    func urlColumnTypeDefaultValue() throws {
        let defaultURL = URL(string: "https://default.com")!

        // Test with nil value
        let nilConfig = URLColumnConfig(value: nil)
        let withDefault = URLColumnType.withDefaultValue(defaultURL, config: nilConfig)
        #expect(withDefault.config.value == defaultURL)

        // Test with non-nil value (should preserve original)
        let originalURL = URL(string: "https://original.com")!
        let nonNilConfig = URLColumnConfig(value: originalURL)
        let preserveOriginal = URLColumnType.withDefaultValue(defaultURL, config: nonNilConfig)
        #expect(preserveOriginal.config.value == originalURL)
    }

    @Test("URL Column Optional Support")
    func urlColumnOptionalSupport() throws {
        let testURL = URL(string: "https://test.com")!
        let defaultURL = URL(string: "https://default.com")!

        let data = [
            TestModel(name: "Company A", website: testURL, optionalWebsite: testURL, homepage: testURL),
            TestModel(name: "Company B", website: testURL, optionalWebsite: nil, homepage: nil),
            TestModel(name: "Company C", website: testURL, optionalWebsite: testURL, homepage: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Non-optional URL column (using full constructor)
            Column(name: "Website", keyPath: \.website, width: nil, bodyStyle: nil, headerStyle: nil, mapping: { value in
                URLColumnType(URLColumnConfig(value: value))
            }, nilHandling: .keepEmpty)

            // Optional URL column without default
            Column(name: "Optional Website", keyPath: \.optionalWebsite)

            // Optional URL column with default
            Column(name: "Homepage", keyPath: \.homepage)
                .defaultValue(defaultURL)
        }

        let columns = sheet.columns
        #expect(columns.count == 3)

        // Test that the column generates correct cell values
        let cellValue = columns[2].generateCellValue(for: data[1]) // Company B with nil homepage

        switch cellValue {
            case let .urlValue(value):
                #expect(value == defaultURL, "Should use default value for nil")
            default:
                #expect(Bool(false), "Should generate urlValue")
        }
    }

    @Test("URL Column toURL with defaultValue")
    func urlColumnToURLWithDefault() throws {
        let testURL = URL(string: "https://test.com")!
        let defaultURL = URL(string: "https://default.com")!

        let data = [
            TestModel(name: "Company", website: testURL, optionalWebsite: nil, homepage: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // Optional URL with defaultValue and toURL
            Column(name: "Homepage", keyPath: \.homepage)
                .defaultValue(defaultURL)
                .toURL { (url: URL) in // Non-optional after defaultValue
                    // Add path to URL
                    URL(string: url.absoluteString + "/landing")!
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .urlValue(value):
                #expect(value.absoluteString == "https://default.com/landing")
            default:
                #expect(Bool(false), "Should generate urlValue with transformed default")
        }
    }

    @Test("URL Column toString transformation")
    func urlColumnToStringTransformation() throws {
        let testURL = URL(string: "https://example.com/path?param=value")!

        let data = [
            TestModel(name: "Company", website: testURL, optionalWebsite: testURL, homepage: nil),
        ]

        let sheet = Sheet<TestModel>(name: "Test", dataProvider: { data }) {
            // URL to String transformation
            Column(name: "Website Domain", keyPath: \.website)
                .toString { (url: URL) in
                    url.host ?? "Unknown Domain"
                }
        }

        let columns = sheet.columns
        let column = columns[0]

        // Generate cell value for the test data
        let cellValue = column.generateCellValue(for: data[0])

        switch cellValue {
            case let .stringValue(value):
                #expect(value == "example.com")
            default:
                #expect(Bool(false), "Should generate stringValue")
        }
    }

    @Test("String to URL conversion")
    func stringToURLConversion() throws {
        struct UrlTestModel: Sendable {
            let domain: String
            let optionalDomain: String?
        }

        let data = [
            UrlTestModel(domain: "example.com", optionalDomain: "test.com"),
            UrlTestModel(domain: "invalid domain", optionalDomain: nil),
        ]

        let sheet = Sheet<UrlTestModel>(name: "Test", dataProvider: { data }) {
            // String to URL conversion
            Column(name: "Website", keyPath: \.domain)
                .toURL { (domain: String) in
                    URL(string: "https://\(domain)") ?? URL(string: "https://fallback.com")!
                }

            // Optional String to URL with nil handling
            Column(name: "Optional Website", keyPath: \.optionalDomain)
                .toURL { (domain: String?) in
                    guard let domain else { return nil }
                    return URL(string: "https://\(domain)")
                }
        }

        let columns = sheet.columns

        // Test valid domain conversion
        let validURL = columns[0].generateCellValue(for: data[0])
        switch validURL {
            case let .urlValue(value):
                #expect(value.absoluteString == "https://example.com")
            default:
                #expect(Bool(false), "Should generate urlValue")
        }

        // Test invalid domain fallback
        let invalidURL = columns[0].generateCellValue(for: data[1])
        switch invalidURL {
            case let .urlValue(value):
                #expect(value.absoluteString == "https://fallback.com")
            default:
                #expect(Bool(false), "Should generate fallback urlValue")
        }

        // Test nil handling
        let nilURL = columns[1].generateCellValue(for: data[1])
        switch nilURL {
            case let .optionalURL(value):
                #expect(value == nil)
            default:
                #expect(Bool(false), "Should generate optionalURL")
        }
    }
}