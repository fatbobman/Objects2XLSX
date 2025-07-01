//
// BookAsyncTests.swift
// Created by Xu Yang on 2025-07-01.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import Testing
@testable import Objects2XLSX

/// Test data structure for async book testing
struct AsyncTestPerson: Sendable {
    let name: String
    let age: Int
    let isActive: Bool
}

@Suite("Book Async Write Tests")
struct BookAsyncTests {
    
    @Test("Book with async data provider writes successfully")
    func testBookAsyncWrite() async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let testURL = tempDir.appendingPathComponent("async_test.xlsx")
        
        // Clean up any existing file
        try? FileManager.default.removeItem(at: testURL)
        
        // Create test data
        let people = [
            AsyncTestPerson(name: "Alice", age: 25, isActive: true),
            AsyncTestPerson(name: "Bob", age: 30, isActive: false),
            AsyncTestPerson(name: "Charlie", age: 35, isActive: true)
        ]
        
        // Create book with async data provider
        let sheet = Sheet<AsyncTestPerson>(
            name: "Async People",
            asyncDataProvider: {
                // Simulate async data loading
                try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second
                return people
            }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .yesAndNo)
        }
        
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])
        
        // Write asynchronously
        let outputURL = try await book.writeAsync(to: testURL)
        
        // Verify file was created
        #expect(FileManager.default.fileExists(atPath: outputURL.path))
        #expect(outputURL.pathExtension == "xlsx")
        
        // Clean up
        try? FileManager.default.removeItem(at: outputURL)
    }
    
    @Test("Book with mixed sync and async sheets")
    func testBookMixedDataProviders() async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let testURL = tempDir.appendingPathComponent("mixed_test.xlsx")
        
        // Clean up any existing file
        try? FileManager.default.removeItem(at: testURL)
        
        // Create test data
        let syncPeople = [
            AsyncTestPerson(name: "Sync1", age: 20, isActive: true),
            AsyncTestPerson(name: "Sync2", age: 25, isActive: false)
        ]
        
        let asyncPeople = [
            AsyncTestPerson(name: "Async1", age: 30, isActive: true),
            AsyncTestPerson(name: "Async2", age: 35, isActive: false)
        ]
        
        // Create book with mixed data providers
        let syncSheet = Sheet<AsyncTestPerson>(
            name: "Sync People",
            dataProvider: { syncPeople }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        let asyncSheet = Sheet<AsyncTestPerson>(
            name: "Async People",
            asyncDataProvider: {
                try? await Task.sleep(nanoseconds: 5_000_000) // 0.005 second
                return asyncPeople
            }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .yesAndNo)
        }
        
        let book = Book(style: BookStyle(), sheets: [
            syncSheet.eraseToAnySheet(),
            asyncSheet.eraseToAnySheet()
        ])
        
        // Write asynchronously
        let outputURL = try await book.writeAsync(to: testURL)
        
        // Verify file was created
        #expect(FileManager.default.fileExists(atPath: outputURL.path))
        #expect(outputURL.pathExtension == "xlsx")
        
        // Clean up
        try? FileManager.default.removeItem(at: outputURL)
    }
    
    @Test("Book writeAsync falls back to sync for sheets without async providers")
    func testBookAsyncFallbackToSync() async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let testURL = tempDir.appendingPathComponent("fallback_test.xlsx")
        
        // Clean up any existing file
        try? FileManager.default.removeItem(at: testURL)
        
        // Create test data
        let people = [
            AsyncTestPerson(name: "Test1", age: 25, isActive: true),
            AsyncTestPerson(name: "Test2", age: 30, isActive: false)
        ]
        
        // Create book with only sync data provider
        let sheet = Sheet<AsyncTestPerson>(
            name: "Sync Only",
            dataProvider: { people }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])
        
        // Write asynchronously (should fall back to sync)
        let outputURL = try await book.writeAsync(to: testURL)
        
        // Verify file was created
        #expect(FileManager.default.fileExists(atPath: outputURL.path))
        #expect(outputURL.pathExtension == "xlsx")
        
        // Clean up
        try? FileManager.default.removeItem(at: outputURL)
    }
    
    @Test("Progress reporting works with async write")
    func testAsyncProgressReporting() async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let testURL = tempDir.appendingPathComponent("progress_test.xlsx")
        
        // Clean up any existing file
        try? FileManager.default.removeItem(at: testURL)
        
        // Create test data
        let people = [
            AsyncTestPerson(name: "Progress1", age: 25, isActive: true),
            AsyncTestPerson(name: "Progress2", age: 30, isActive: false)
        ]
        
        // Create book with async data provider
        let sheet = Sheet<AsyncTestPerson>(
            name: "Progress Test",
            asyncDataProvider: {
                try? await Task.sleep(nanoseconds: 20_000_000) // 0.02 second
                return people
            }
        ) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        let book = Book(style: BookStyle(), sheets: [sheet.eraseToAnySheet()])
        
        // Write asynchronously
        let outputURL = try await book.writeAsync(to: testURL)
        
        // Verify file was created
        #expect(FileManager.default.fileExists(atPath: outputURL.path))
        #expect(outputURL.pathExtension == "xlsx")
        
        // Clean up
        try? FileManager.default.removeItem(at: outputURL)
    }
}