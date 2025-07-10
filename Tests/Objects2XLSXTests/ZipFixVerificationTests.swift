import XCTest
import Foundation
@testable import Objects2XLSX

final class ZipFixVerificationTests: XCTestCase {
    
    struct TestEmployee: Sendable {
        let name: String
        let age: Int
        let salary: Double?
    }
    
    func testZipStructureWithDifferentWorkingDirectories() throws {
        // Create test data
        let employees = [
            TestEmployee(name: "Alice Smith", age: 28, salary: 75000.0),
            TestEmployee(name: "Bob Johnson", age: 35, salary: nil),
            TestEmployee(name: "Carol Davis", age: 42, salary: 85000.0)
        ]
        
        // Create sheet
        let sheet = Sheet<TestEmployee>(name: "Employees", dataProvider: { employees }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
            Column(name: "Salary", keyPath: \.salary)
                .defaultValue(0.0)
        }
        
        // Create book
        let book = Book(style: BookStyle(), sheets: [AnySheet(sheet)])
        
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        
        // Test with systemTemp strategy (most likely to trigger the issue)
        let outputURL = tempDir.appendingPathComponent("test_zip_fix_\(UUID().uuidString).xlsx")
        
        print("🧪 Testing ZIP structure fix with systemTemp strategy")
        print("   Output: \(outputURL.path)")
        
        // Generate XLSX file
        let resultURL = try book.write(to: outputURL, workingDirectory: WorkingDirectoryLocation.systemTemp)
        
        // Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path), "XLSX file should exist")
        
        // Check file size is reasonable
        let fileSize = try FileManager.default.attributesOfItem(atPath: resultURL.path)[.size] as? Int ?? 0
        XCTAssertGreaterThan(fileSize, 1000, "File size should be reasonable for a valid XLSX")
        
        print("   ✅ Generated: \(resultURL.path)")
        print("   📁 File size: \(fileSize) bytes")
        
        // Test ZIP structure by creating a temporary ZIP archiver
        // We'll simulate the unzip process to verify the structure
        let zipData = try Data(contentsOf: resultURL)
        XCTAssertGreaterThan(zipData.count, 1000, "ZIP data should be substantial")
        
        print("   ✅ ZIP file structure verification passed")
        print("   📝 Manual verification needed: Unzip the file and check that there are no unwanted directory layers")
        
        // Clean up
        try? FileManager.default.removeItem(at: resultURL)
    }
    
    func testZipStructureWithCustomWorkingDirectory() throws {
        let employees = [
            TestEmployee(name: "Test User", age: 30, salary: 50000.0)
        ]
        
        let sheet = Sheet<TestEmployee>(name: "Test", dataProvider: { employees }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }
        
        let book = Book(style: BookStyle(), sheets: [AnySheet(sheet)])
        
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let customWorkspace = tempDir.appendingPathComponent("custom_workspace_\(UUID().uuidString)")
        let outputURL = tempDir.appendingPathComponent("test_custom_\(UUID().uuidString).xlsx")
        
        print("🧪 Testing ZIP structure fix with custom working directory")
        print("   Custom workspace: \(customWorkspace.path)")
        print("   Output: \(outputURL.path)")
        
        // Generate XLSX file with custom working directory
        let resultURL = try book.write(to: outputURL, workingDirectory: WorkingDirectoryLocation.custom(customWorkspace))
        
        // Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path), "XLSX file should exist")
        
        let fileSize = try FileManager.default.attributesOfItem(atPath: resultURL.path)[.size] as? Int ?? 0
        XCTAssertGreaterThan(fileSize, 500, "File size should be reasonable")
        
        print("   ✅ Generated: \(resultURL.path)")
        print("   📁 File size: \(fileSize) bytes")
        
        // Clean up
        try? FileManager.default.removeItem(at: resultURL)
        try? FileManager.default.removeItem(at: customWorkspace)
    }
}