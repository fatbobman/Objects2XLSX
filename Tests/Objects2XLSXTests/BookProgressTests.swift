//
// BookProgressTests.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Testing
import Foundation
@testable import Objects2XLSX

struct BookProgressTests {
    
    @Test func testProgressStreamBasic() async throws {
        let book = Book(style: BookStyle())
        
        // 添加一个简单的 sheet
        let testData = [TestProgressPerson(name: "Alice", age: 25)]
        let sheet = Sheet<TestProgressPerson>(
            name: "Test Sheet",
            dataProvider: { testData }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        book.append(sheet: sheet)
        
        // 使用简单的数组收集进度，避免 Task 捕获问题
        var receivedProgress: [BookGenerationProgress] = []
        
        // 手动迭代进度流
        let progressIterator = book.progressStream.makeAsyncIterator()
        
        // 在后台执行写入操作
        let writeTask = Task {
            let tempURL = URL(fileURLWithPath: "/tmp/test_progress_basic.xlsx")
            try book.write(to: tempURL)
        }
        
        // 收集进度更新直到完成
        var iterator = progressIterator
        while let progress = await iterator.next() {
            receivedProgress.append(progress)
            if progress.isFinal {
                break
            }
        }
        
        // 等待写入任务完成
        try await writeTask.value
        
        // 验证收到的进度
        #expect(receivedProgress.count > 0, "应该收到进度更新")
        #expect(receivedProgress.first == .started, "第一个进度应该是 started")
        #expect(receivedProgress.last?.isFinal == true, "最后一个进度应该是最终状态")
        
        // 验证包含关键阶段
        let progressDescriptions = receivedProgress.map { $0.description }
        #expect(progressDescriptions.contains { $0.contains("Starting XLSX generation") })
        #expect(progressDescriptions.contains { $0.contains("Creating temporary directory") })
        #expect(progressDescriptions.contains { $0.contains("Processing worksheet") })
        #expect(progressDescriptions.contains { $0.contains("XLSX generation completed") })
        
        print("Received \(receivedProgress.count) progress updates:")
        for (index, progress) in receivedProgress.enumerated() {
            print("\(index + 1). \(progress.description) (\(String(format: "%.1f", progress.progressPercentage * 100))%)")
        }
    }
    
    @Test func testProgressStreamWithMultipleSheets() async throws {
        let book = Book(style: BookStyle())
        
        // 添加多个 sheets
        let testData1 = [TestProgressPerson(name: "Alice", age: 25)]
        let testData2 = [TestProgressPerson(name: "Bob", age: 30)]
        let testData3 = [TestProgressPerson(name: "Charlie", age: 35)]
        
        let sheet1 = Sheet<TestProgressPerson>(name: "People 1", dataProvider: { testData1 }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        let sheet2 = Sheet<TestProgressPerson>(name: "People 2", dataProvider: { testData2 }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        let sheet3 = Sheet<TestProgressPerson>(name: "People 3", dataProvider: { testData3 }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        book.append(sheet: sheet1)
        book.append(sheet: sheet2)
        book.append(sheet: sheet3)
        
        var receivedProgress: [BookGenerationProgress] = []
        let progressIterator = book.progressStream.makeAsyncIterator()
        
        let writeTask = Task {
            let tempURL = URL(fileURLWithPath: "/tmp/test_progress_multiple.xlsx")
            try book.write(to: tempURL)
        }
        
        var iterator = progressIterator
        while let progress = await iterator.next() {
            receivedProgress.append(progress)
            if progress.isFinal {
                break
            }
        }
        
        try await writeTask.value
        
        // 验证精细的 sheet 处理进度
        let sheetProgressUpdates = receivedProgress.compactMap { progress in
            if case .processingSheet(let current, let total, let sheetName) = progress {
                return (current, total, sheetName)
            }
            return nil
        }
        
        #expect(sheetProgressUpdates.count == 3, "应该有3个sheet处理进度更新")
        #expect(sheetProgressUpdates[0].0 == 1 && sheetProgressUpdates[0].1 == 3, "第一个sheet进度应该是(1/3)")
        #expect(sheetProgressUpdates[1].0 == 2 && sheetProgressUpdates[1].1 == 3, "第二个sheet进度应该是(2/3)")
        #expect(sheetProgressUpdates[2].0 == 3 && sheetProgressUpdates[2].1 == 3, "第三个sheet进度应该是(3/3)")
        
        #expect(sheetProgressUpdates[0].2 == "People 1", "第一个sheet名称应该正确")
        #expect(sheetProgressUpdates[1].2 == "People 2", "第二个sheet名称应该正确")
        #expect(sheetProgressUpdates[2].2 == "People 3", "第三个sheet名称应该正确")
        
        print("Sheet processing progress:")
        for (current, total, name) in sheetProgressUpdates {
            print("  Processing sheet (\(current)/\(total)): \(name)")
        }
    }
    
    @Test func testProgressStreamWithError() async throws {
        // 创建一个会导致错误的场景
        let book = Book(style: BookStyle())
        
        // 添加一个 sheet
        let testData = [TestProgressPerson(name: "Test", age: 25)]
        let sheet = Sheet<TestProgressPerson>(name: "Test Sheet", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
        }
        book.append(sheet: sheet)
        
        var receivedProgress: [BookGenerationProgress] = []
        let progressIterator = book.progressStream.makeAsyncIterator()
        
        // 使用一个无效的路径（没有权限的目录）来触发错误
        let invalidURL = URL(fileURLWithPath: "/root/invalid_path/test.xlsx")
        
        let writeTask = Task {
            try book.write(to: invalidURL)
        }
        
        var iterator = progressIterator
        while let progress = await iterator.next() {
            receivedProgress.append(progress)
            if progress.isFinal {
                break
            }
        }
        
        // 预期会抛出错误
        do {
            try await writeTask.value
            #expect(Bool(false), "应该抛出错误但没有抛出")
        } catch is BookError {
            // 预期的错误类型
        } catch {
            #expect(Bool(false), "抛出了意外的错误类型: \(type(of: error))")
        }
        
        // 验证收到了错误状态
        let hasFailedProgress = receivedProgress.contains { progress in
            if case .failed = progress {
                return true
            }
            return false
        }
        
        #expect(hasFailedProgress, "应该收到失败状态的进度更新")
        #expect(receivedProgress.last?.isFailed == true, "最后一个进度应该是失败状态")
        
        print("Error scenario progress updates:")
        for (index, progress) in receivedProgress.enumerated() {
            print("\(index + 1). \(progress.description)")
        }
    }
    
    @Test func testProgressPercentageIncreasing() async throws {
        let book = Book(style: BookStyle())
        
        // 添加两个 sheets
        let testData = [TestProgressPerson(name: "Test", age: 25)]
        for i in 1...2 {
            let sheet = Sheet<TestProgressPerson>(name: "Sheet \(i)", dataProvider: { testData }) {
                Column(name: "Name", keyPath: \.name)
            }
            book.append(sheet: sheet)
        }
        
        var receivedProgress: [BookGenerationProgress] = []
        let progressIterator = book.progressStream.makeAsyncIterator()
        
        let writeTask = Task {
            let tempURL = URL(fileURLWithPath: "/tmp/test_progress_percentage.xlsx")
            try book.write(to: tempURL)
        }
        
        var iterator = progressIterator
        while let progress = await iterator.next() {
            receivedProgress.append(progress)
            if progress.isFinal {
                break
            }
        }
        
        try await writeTask.value
        
        // 验证进度百分比递增
        let percentages = receivedProgress.map { $0.progressPercentage }
        var lastPercentage = 0.0
        var isIncreasing = true
        
        for percentage in percentages {
            if percentage < lastPercentage {
                isIncreasing = false
                break
            }
            lastPercentage = percentage
        }
        
        #expect(isIncreasing, "进度百分比应该单调递增")
        #expect(percentages.first == 0.0, "第一个进度应该是0%")
        #expect(percentages.last == 1.0, "最后一个进度应该是100%")
        
        print("Progress percentages:")
        for (index, progress) in receivedProgress.enumerated() {
            print("\(index + 1). \(String(format: "%.1f", progress.progressPercentage * 100))% - \(progress.description)")
        }
    }
    
    @Test func testProgressStreamExists() async throws {
        let book = Book(style: BookStyle())
        
        // 验证 progressStream 存在且可用
        let stream = book.progressStream
        
        // 验证可以创建迭代器
        let _ = stream.makeAsyncIterator()
        
        print("Progress stream exists and is accessible")
    }
}

// Test data structure
private struct TestProgressPerson: Sendable {
    let name: String
    let age: Int
}