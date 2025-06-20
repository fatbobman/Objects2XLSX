//
// BookAPITests.swift
// Created by Claude on 2025-06-20.
//

import Testing
import Foundation
@testable import Objects2XLSX

struct BookAPITests {
    
    struct TestPerson: Sendable {
        let name: String
        let age: Int
    }
    
    @Test func testWriteMethodReturnsCorrectURL() async throws {
        let book = Book(style: BookStyle())
        
        let testData = [TestPerson(name: "Alice", age: 25)]
        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        book.append(sheet: sheet)
        
        // Test 1: URL without extension
        let url1 = URL(fileURLWithPath: "/tmp/test_api_output_\(UUID().uuidString)")
        let resultURL1 = try book.write(to: url1)
        defer { try? FileManager.default.removeItem(at: resultURL1) }
        
        #expect(resultURL1.pathExtension == "xlsx", "Should add .xlsx extension")
        #expect(resultURL1.path == url1.path + ".xlsx", "Should append .xlsx to path")
        #expect(FileManager.default.fileExists(atPath: resultURL1.path), "File should exist at returned URL")
        
        print("Test 1 - Input: \(url1.path)")
        print("Test 1 - Output: \(resultURL1.path)")
    }
    
    @Test func testWriteMethodPreservesXLSXExtension() async throws {
        let book = Book(style: BookStyle())
        
        let testData = [TestPerson(name: "Bob", age: 30)]
        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        book.append(sheet: sheet)
        
        // Test 2: URL with .xlsx extension already
        let url2 = URL(fileURLWithPath: "/tmp/test_api_with_ext_\(UUID().uuidString).xlsx")
        let resultURL2 = try book.write(to: url2)
        defer { try? FileManager.default.removeItem(at: resultURL2) }
        
        #expect(resultURL2.path == url2.path, "Should preserve existing .xlsx extension")
        #expect(FileManager.default.fileExists(atPath: resultURL2.path), "File should exist at returned URL")
        
        print("Test 2 - Input: \(url2.path)")
        print("Test 2 - Output: \(resultURL2.path)")
    }
    
    @Test func testWriteMethodReplacesIncorrectExtension() async throws {
        let book = Book(style: BookStyle())
        
        let testData = [TestPerson(name: "Charlie", age: 35)]
        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        book.append(sheet: sheet)
        
        // Test 3: URL with different extension
        let url3 = URL(fileURLWithPath: "/tmp/test_api_wrong_ext_\(UUID().uuidString).xls")
        let resultURL3 = try book.write(to: url3)
        defer { try? FileManager.default.removeItem(at: resultURL3) }
        
        #expect(resultURL3.pathExtension == "xlsx", "Should replace incorrect extension with .xlsx")
        #expect(resultURL3.path == url3.deletingPathExtension().path + ".xlsx", "Should replace .xls with .xlsx")
        #expect(FileManager.default.fileExists(atPath: resultURL3.path), "File should exist at returned URL")
        
        print("Test 3 - Input: \(url3.path)")
        print("Test 3 - Output: \(resultURL3.path)")
    }
    
    @Test func testWriteMethodCreatesParentDirectory() async throws {
        let book = Book(style: BookStyle())
        
        let testData = [TestPerson(name: "David", age: 40)]
        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        book.append(sheet: sheet)
        
        // Test 4: URL with non-existent parent directory
        let parentDir = URL(fileURLWithPath: "/tmp/test_api_subdir_\(UUID().uuidString)")
        let url4 = parentDir.appendingPathComponent("output.xlsx")
        let resultURL4 = try book.write(to: url4)
        defer { 
            try? FileManager.default.removeItem(at: resultURL4)
            try? FileManager.default.removeItem(at: parentDir)
        }
        
        #expect(resultURL4.path == url4.path, "Should return the same path")
        #expect(FileManager.default.fileExists(atPath: parentDir.path), "Parent directory should be created")
        #expect(FileManager.default.fileExists(atPath: resultURL4.path), "File should exist at returned URL")
        
        print("Test 4 - Parent dir: \(parentDir.path)")
        print("Test 4 - Output: \(resultURL4.path)")
    }
    
    @Test func testDiscardableResultAttribute() async throws {
        let book = Book(style: BookStyle())
        
        let testData = [TestPerson(name: "Eve", age: 28)]
        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        book.append(sheet: sheet)
        
        // Test 5: Can call without capturing return value (thanks to @discardableResult)
        let url5 = URL(fileURLWithPath: "/tmp/test_api_discard_\(UUID().uuidString).xlsx")
        defer { try? FileManager.default.removeItem(at: url5) }
        
        // This should compile without warnings thanks to @discardableResult
        try book.write(to: url5)
        
        #expect(FileManager.default.fileExists(atPath: url5.path), "File should be created even when return value is discarded")
        
        print("Test 5 - Discardable result test passed")
    }
}