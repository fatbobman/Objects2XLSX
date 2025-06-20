//
// BookLoggerTests.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Testing
import Foundation
@testable import Objects2XLSX
import SimpleLogger

struct BookLoggerTests {
    
    // 自定义 Logger 用于测试
    final class TestLogger: LoggerManagerProtocol, @unchecked Sendable {
        private var _logMessages: [String] = []
        private let queue = DispatchQueue(label: "TestLogger", attributes: .concurrent)
        
        var logMessages: [String] {
            return queue.sync { _logMessages }
        }
        
        func log(_ message: String, level: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
            queue.async(flags: .barrier) {
                self._logMessages.append("[\(level.rawValue.uppercased())] \(message)")
            }
        }
        
        func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
            log(message, level: .debug, file: file, function: function, line: line)
        }
        
        func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
            log(message, level: .info, file: file, function: function, line: line)
        }
        
        func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
            log(message, level: .warning, file: file, function: function, line: line)
        }
        
        func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
            log(message, level: .error, file: file, function: function, line: line)
        }
    }
    
    @Test func testBookWithCustomLogger() throws {
        let testLogger = TestLogger()
        var style = BookStyle()
        style.properties.title = "Test Document"
        style.properties.author = "Test Author"
        
        // 使用自定义 logger 创建 book
        let book = Book(style: style, logger: testLogger)
        
        // 验证 logger 被正确设置（使用类型检查）
        #expect(book.logger is TestLogger)
        
        // Create temp directory for testing
        let tempDir = URL(fileURLWithPath: "/tmp/test_custom_logger")
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // 验证日志被记录
        #expect(testLogger.logMessages.count > 0)
        #expect(testLogger.logMessages.contains { $0.contains("Created XLSX directory structure") })
        
        print("Custom logger captured \(testLogger.logMessages.count) messages:")
        for message in testLogger.logMessages {
            print("  \(message)")
        }
    }
    
    @Test func testBookWithDefaultLogger() throws {
        // 不提供 logger，使用默认实现
        let book = Book(style: BookStyle())
        
        // 验证默认 logger 被设置
        #expect(type(of: book.logger) != type(of: TestLogger()))
        
        print("Book uses default logger: \(type(of: book.logger))")
    }
    
    @Test func testLoggerCapturingMessages() throws {
        let testLogger = TestLogger()
        let book = Book(style: BookStyle(), logger: testLogger)
        
        // 触发一些日志操作
        let tempDir = URL(fileURLWithPath: "/tmp/test_logger_capture")
        try book.createXLSXDirectoryStructure(at: tempDir)
        
        // 等待异步日志写入完成
        Thread.sleep(forTimeInterval: 0.1)
        
        // 验证日志被捕获
        let messages = testLogger.logMessages
        #expect(messages.count > 0)
        #expect(messages.contains { $0.contains("Created XLSX directory structure") })
        
        print("TestLogger captured \(messages.count) messages:")
        for message in messages {
            print("  \(message)")
        }
    }
}

// Test data structure
private struct TestLoggerPerson: Sendable {
    let name: String
    let age: Int
    let email: String
}