//
// BookProgressSimpleTests.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

struct BookProgressSimpleTests {
    @Test func progressStreamExists() {
        let book = Book(style: BookStyle())

        // 验证 progressStream 存在
        // progressStream 是非可选类型，验证其基本功能
        _ = book.progressStream

        print("Progress stream created successfully")
    }

    @Test func basicProgressFlow() async throws {
        let book = Book(style: BookStyle())

        // 添加一个简单的 sheet
        let testData = [SimpleTestPerson(name: "Alice", age: 25)]
        let sheet = Sheet<SimpleTestPerson>(name: "Test Sheet", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        book.append(sheet: sheet)

        // 验证写入操作能完成
        let tempURL = URL(fileURLWithPath: "/tmp/test_progress_simple.xlsx")

        #expect(throws: Never.self) {
            try book.write(to: tempURL)
        }

        print("Basic progress flow completed successfully")
    }

    @Test func progressStreamCanBeIterated() async throws {
        let book = Book(style: BookStyle())

        // 简单验证迭代器可以创建
        _ = book.progressStream.makeAsyncIterator()

        // 这里不实际执行完整的写入操作，只验证迭代器功能
        print("Progress stream iterator created successfully")
    }
}

// 简单的测试数据结构
private struct SimpleTestPerson: Sendable {
    let name: String
    let age: Int
}
