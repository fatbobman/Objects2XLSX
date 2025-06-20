//
// SimpleZipTests.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

struct SimpleZipTests {
    @Test func createEmptyZip() throws {
        let entries: [SimpleZip.Entry] = []
        let zipData = try SimpleZip.create(entries: entries)

        // 空 ZIP 文件应该只包含中央目录结束记录 (22 字节)
        #expect(zipData.count == 22, "Empty ZIP should be 22 bytes")

        // 验证 ZIP 文件签名
        let signature = zipData.prefix(4)
        #expect(signature == Data([0x50, 0x4B, 0x05, 0x06]), "Should start with end of central directory signature")
    }

    @Test func createSingleFileZip() throws {
        let testContent = "Hello, World!".data(using: .utf8)!
        let entry = SimpleZip.Entry(path: "test.txt", data: testContent)

        let zipData = try SimpleZip.create(entries: [entry])

        // 验证 ZIP 文件不为空
        #expect(!zipData.isEmpty, "ZIP data should not be empty")

        // 验证本地文件头签名
        let localHeaderSignature = zipData.prefix(4)
        #expect(localHeaderSignature == Data([0x50, 0x4B, 0x03, 0x04]), "Should start with local file header signature")

        print("Single file ZIP created: \(zipData.count) bytes")
    }

    @Test func createMultipleFilesZip() throws {
        let entries = [
            SimpleZip.Entry(path: "file1.txt", data: "Content 1".data(using: .utf8)!),
            SimpleZip.Entry(path: "dir/file2.txt", data: "Content 2".data(using: .utf8)!),
            SimpleZip.Entry(path: "file3.xml", data: "<?xml version=\"1.0\"?><root/>".data(using: .utf8)!),
        ]

        let zipData = try SimpleZip.create(entries: entries)

        #expect(!zipData.isEmpty, "ZIP data should not be empty")

        // 验证包含正确数量的本地文件头
        let localHeaderCount = countLocalFileHeaders(in: zipData)
        #expect(localHeaderCount == 3, "Should contain 3 local file headers")

        print("Multiple files ZIP created: \(zipData.count) bytes")
    }

    @Test func zipWithSpecialCharacters() throws {
        let entries = [
            SimpleZip.Entry(path: "中文文件.txt", data: "中文内容".data(using: .utf8)!),
            SimpleZip.Entry(path: "file with spaces.txt", data: "Content with spaces".data(using: .utf8)!),
            SimpleZip.Entry(path: "special!@#$%^&*().txt", data: "Special chars".data(using: .utf8)!),
        ]

        let zipData = try SimpleZip.create(entries: entries)

        #expect(!zipData.isEmpty, "ZIP with special characters should be created")

        print("Special characters ZIP created: \(zipData.count) bytes")
    }

    @Test func zipWithLargeFile() throws {
        // 创建一个较大的文件 (1MB)
        let largeData = Data(repeating: 0x41, count: 1024 * 1024) // 1MB of 'A'
        let entry = SimpleZip.Entry(path: "large_file.dat", data: largeData)

        let zipData = try SimpleZip.create(entries: [entry])

        #expect(zipData.count > largeData.count, "ZIP should be larger than original due to headers")

        print("Large file ZIP created: \(zipData.count) bytes")
    }

    @Test func invalidPath() {
        let entry = SimpleZip.Entry(path: "../../../etc/passwd", data: "malicious".data(using: .utf8)!)

        #expect(throws: SimpleZip.ZipError.self) {
            try SimpleZip.create(entries: [entry])
        }
    }

    @Test func emptyPath() {
        let entry = SimpleZip.Entry(path: "", data: "content".data(using: .utf8)!)

        #expect(throws: SimpleZip.ZipError.self) {
            try SimpleZip.create(entries: [entry])
        }
    }

    @Test func testCreateFromDirectory() async throws {
        // 创建临时目录和文件
        let tempDir = URL(fileURLWithPath: "/tmp/test_zip_\(UUID().uuidString)")
        let fileManager = FileManager.default

        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // 清理函数
        defer {
            try? fileManager.removeItem(at: tempDir)
        }

        // 创建测试文件
        let file1 = tempDir.appendingPathComponent("test1.txt")
        let file2 = tempDir.appendingPathComponent("subdir").appendingPathComponent("test2.txt")

        try fileManager.createDirectory(at: file2.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "Content 1".write(to: file1, atomically: true, encoding: .utf8)
        try "Content 2".write(to: file2, atomically: true, encoding: .utf8)

        // 创建 ZIP
        let zipURL = URL(fileURLWithPath: "/tmp/test_output_\(UUID().uuidString).zip")
        defer {
            try? fileManager.removeItem(at: zipURL)
        }

        try SimpleZip.createFromDirectory(directoryURL: tempDir, outputURL: zipURL)

        // 验证 ZIP 文件已创建
        #expect(fileManager.fileExists(atPath: zipURL.path), "ZIP file should be created")

        let zipData = try Data(contentsOf: zipURL)
        #expect(!zipData.isEmpty, "ZIP file should not be empty")

        print("Directory ZIP created: \(zipData.count) bytes")
    }

    @Test func xLSXLikeStructure() throws {
        // 模拟 XLSX 文件结构
        let entries = [
            SimpleZip.Entry(path: "[Content_Types].xml", data: "<?xml version=\"1.0\"?><Types/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "_rels/.rels", data: "<?xml version=\"1.0\"?><Relationships/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "docProps/app.xml", data: "<?xml version=\"1.0\"?><Properties/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "docProps/core.xml", data: "<?xml version=\"1.0\"?><cp:coreProperties/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "xl/workbook.xml", data: "<?xml version=\"1.0\"?><workbook/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "xl/_rels/workbook.xml.rels", data: "<?xml version=\"1.0\"?><Relationships/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "xl/styles.xml", data: "<?xml version=\"1.0\"?><styleSheet/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "xl/sharedStrings.xml", data: "<?xml version=\"1.0\"?><sst/>".data(using: .utf8)!),
            SimpleZip.Entry(path: "xl/worksheets/sheet1.xml", data: "<?xml version=\"1.0\"?><worksheet/>".data(using: .utf8)!),
        ]

        let zipData = try SimpleZip.create(entries: entries)

        #expect(!zipData.isEmpty, "XLSX-like ZIP should be created")

        // 验证包含正确数量的文件
        let localHeaderCount = countLocalFileHeaders(in: zipData)
        #expect(localHeaderCount == entries.count, "Should contain correct number of files")

        print("XLSX-like ZIP created: \(zipData.count) bytes")
    }

    @Test func cRC32Calculation() throws {
        // 测试已知数据的 CRC32
        let testData = "123456789".data(using: .utf8)!
        let entry = SimpleZip.Entry(path: "test.txt", data: testData)

        let zipData = try SimpleZip.create(entries: [entry])

        // ZIP 应该包含 CRC32 校验和
        #expect(zipData.count > 30, "ZIP should contain CRC32 data")

        print("CRC32 test ZIP created: \(zipData.count) bytes")
    }

    @Test func dateTimeEncoding() throws {
        let specificDate = Date(timeIntervalSince1970: 1_640_995_200) // 2022-01-01 00:00:00 UTC
        let entry = SimpleZip.Entry(path: "dated_file.txt", data: "content".data(using: .utf8)!, modificationDate: specificDate)

        let zipData = try SimpleZip.create(entries: [entry])

        #expect(!zipData.isEmpty, "ZIP with specific date should be created")

        print("Date encoding ZIP created: \(zipData.count) bytes")
    }
}

// MARK: - Helper Functions

extension SimpleZipTests {
    /// 计算 ZIP 数据中本地文件头的数量
    private func countLocalFileHeaders(in data: Data) -> Int {
        let signature = Data([0x50, 0x4B, 0x03, 0x04])
        var count = 0
        var searchIndex = 0

        while searchIndex < data.count - 4 {
            let range = searchIndex ..< (searchIndex + 4)
            let slice = data.subdata(in: range)
            if slice == signature {
                count += 1
                searchIndex += 4
            } else {
                searchIndex += 1
            }
        }

        return count
    }
}
