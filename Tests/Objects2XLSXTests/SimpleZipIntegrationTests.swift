//
// SimpleZipIntegrationTests.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

struct SimpleZipIntegrationTests {
    @Test func completeXLSXGeneration() async throws {
        let book = Book(style: BookStyle())

        // 添加测试数据
        let testData = [
            TestZipPerson(name: "Alice", age: 25, email: "alice@example.com"),
            TestZipPerson(name: "Bob", age: 30, email: "bob@example.com"),
            TestZipPerson(name: "Charlie", age: 35, email: "charlie@example.com"),
        ]

        let sheet = Sheet<TestZipPerson>(name: "People", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Email", keyPath: \.email)
        }

        book.append(sheet: sheet)

        // 生成 XLSX 文件
        let outputURL = URL(fileURLWithPath: "/tmp/test_complete_xlsx_\(UUID().uuidString).xlsx")
        defer {
            try? FileManager.default.removeItem(at: outputURL)
        }

        try book.write(to: outputURL)

        // 验证文件存在
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "XLSX file should be created")

        // 验证文件大小
        let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
        #expect(fileSize > 1000, "XLSX file should be reasonably sized (>1KB)")

        // 验证是有效的 ZIP 文件
        let fileData = try Data(contentsOf: outputURL)
        let zipSignature = fileData.prefix(4)
        #expect(zipSignature == Data([0x50, 0x4B, 0x03, 0x04]), "Should be a valid ZIP file")

        print("Complete XLSX file generated: \(outputURL.path) - Size: \(fileSize) bytes")
    }

    @Test func xLSXWithMultipleSheets() async throws {
        let book = Book(style: BookStyle())

        // 添加多个工作表
        let people = [TestZipPerson(name: "Alice", age: 25, email: "alice@example.com")]
        let products = [TestZipProduct(name: "Laptop", price: 999.99, inStock: true)]

        let peopleSheet = Sheet<TestZipPerson>(name: "People", dataProvider: { people }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Email", keyPath: \.email)
        }

        let productsSheet = Sheet<TestZipProduct>(name: "Products", dataProvider: { products }) {
            Column(name: "Product", keyPath: \.name)
            Column(name: "Price", keyPath: \.price)
            Column(name: "In Stock", keyPath: \.inStock)
        }

        book.append(sheet: peopleSheet)
        book.append(sheet: productsSheet)

        let outputURL = URL(fileURLWithPath: "/tmp/test_multi_sheet_\(UUID().uuidString).xlsx")
        defer {
            try? FileManager.default.removeItem(at: outputURL)
        }

        try book.write(to: outputURL)

        // 验证文件创建
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Multi-sheet XLSX should be created")

        let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
        #expect(fileSize > 2000, "Multi-sheet XLSX should be larger")

        print("Multi-sheet XLSX generated: \(fileSize) bytes")
    }

    @Test func xLSXWithCustomStyles() async throws {
        let book = Book(style: BookStyle())

        let testData = [TestZipPerson(name: "Styled Alice", age: 25, email: "alice@styled.com")]

        let sheet = Sheet<TestZipPerson>(name: "Styled Sheet", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
                .headerStyle(CellStyle(font: Font(bold: true)))
                .bodyStyle(CellStyle(alignment: Alignment(horizontal: .left)))
            Column(name: "Age", keyPath: \.age)
                .headerStyle(CellStyle(font: Font(bold: true)))
                .bodyStyle(CellStyle(alignment: Alignment(horizontal: .center)))
            Column(name: "Email", keyPath: \.email)
                .headerStyle(CellStyle(font: Font(bold: true)))
                .bodyStyle(CellStyle(alignment: Alignment(horizontal: .left)))
        }

        book.append(sheet: sheet)

        let outputURL = URL(fileURLWithPath: "/tmp/test_styled_xlsx_\(UUID().uuidString).xlsx")
        defer {
            try? FileManager.default.removeItem(at: outputURL)
        }

        try book.write(to: outputURL)

        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Styled XLSX should be created")

        let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
        print("Styled XLSX generated: \(fileSize) bytes")
    }

    @Test func xLSXWithLargeDataset() async throws {
        let book = Book(style: BookStyle())

        let testData = Array(0 ..< 100).map { i in
            TestZipPerson(name: "Person \(i)", age: 20 + (i % 50), email: "person\(i)@test.com")
        }

        let sheet = Sheet<TestZipPerson>(name: "Large Dataset", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Email", keyPath: \.email)
        }

        book.append(sheet: sheet)

        let outputURL = URL(fileURLWithPath: "/tmp/test_large_xlsx_\(UUID().uuidString).xlsx")
        defer {
            try? FileManager.default.removeItem(at: outputURL)
        }

        try book.write(to: outputURL)

        // 验证 XLSX 文件
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Large dataset XLSX should be created")

        let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
        #expect(fileSize > 5000, "Large dataset should create substantial file")

        print("Large dataset XLSX: \(fileSize) bytes")
    }

    @Test func xLSXWithEmptySheet() async throws {
        let book = Book(style: BookStyle())

        // 空数据集
        let emptyData: [TestZipPerson] = []

        let sheet = Sheet<TestZipPerson>(name: "Empty Sheet", dataProvider: { emptyData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }

        book.append(sheet: sheet)

        let outputURL = URL(fileURLWithPath: "/tmp/test_empty_xlsx_\(UUID().uuidString).xlsx")
        defer {
            try? FileManager.default.removeItem(at: outputURL)
        }

        try book.write(to: outputURL)

        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Empty sheet XLSX should be created")

        let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
        #expect(fileSize > 500, "Even empty XLSX should have basic structure")

        print("Empty sheet XLSX generated: \(fileSize) bytes")
    }

    @Test func zipFileStructure() async throws {
        let book = Book(style: BookStyle())

        let testData = [TestZipPerson(name: "Test User", age: 30, email: "test@example.com")]
        let sheet = Sheet<TestZipPerson>(name: "Test", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
        }

        book.append(sheet: sheet)

        let outputURL = URL(fileURLWithPath: "/tmp/test_zip_structure_\(UUID().uuidString).xlsx")
        defer {
            try? FileManager.default.removeItem(at: outputURL)
        }

        try book.write(to: outputURL)

        // 验证 ZIP 文件结构
        let zipData = try Data(contentsOf: outputURL)

        // 验证 ZIP 文件签名
        #expect(zipData.count > 100, "ZIP file should be substantial")

        // 验证 ZIP 文件头签名
        let localHeaderSignature = zipData.prefix(4)
        #expect(localHeaderSignature == Data([0x50, 0x4B, 0x03, 0x04]), "Should start with local file header signature")

        // 验证包含 ZIP 结构的各个部分
        let zipBytes = Array(zipData)
        var hasLocalHeaders = false
        var hasCentralDirectory = false
        var hasEndRecord = false

        // 查找本地文件头签名
        for i in 0 ..< (zipBytes.count - 4) {
            let signature = Array(zipBytes[i ..< (i + 4)])
            if signature == [0x50, 0x4B, 0x03, 0x04] {
                hasLocalHeaders = true
            } else if signature == [0x50, 0x4B, 0x01, 0x02] {
                hasCentralDirectory = true
            } else if signature == [0x50, 0x4B, 0x05, 0x06] {
                hasEndRecord = true
            }
        }

        #expect(hasLocalHeaders, "Should contain local file headers")
        #expect(hasCentralDirectory, "Should contain central directory")
        #expect(hasEndRecord, "Should contain end of central directory record")

        print("ZIP structure validation passed for file: \(zipData.count) bytes")
    }
}

// MARK: - Test Data Structures

private struct TestZipPerson: Sendable {
    let name: String
    let age: Int
    let email: String
}

private struct TestZipProduct: Sendable {
    let name: String
    let price: Double
    let inStock: Bool
}
