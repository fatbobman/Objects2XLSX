import XCTest
import Foundation
@testable import Objects2XLSX

final class PersistentZipTestFile: XCTestCase {
    
    struct TestData: Sendable {
        let name: String
        let value: Int
    }
    
    func testCreatePersistentFileForManualVerification() throws {
        // Create test data
        let testData = [
            TestData(name: "Test Item 1", value: 42),
            TestData(name: "Test Item 2", value: 84)
        ]
        
        let sheet = Sheet<TestData>(name: "TestSheet", dataProvider: { testData }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Value", keyPath: \.value)
        }
        
        let book = Book(style: BookStyle(), sheets: [AnySheet(sheet)])
        
        // Create file in project root for manual verification
        let outputURL = URL(fileURLWithPath: "/Users/yangxu/Documents/Develpment/Objects2XLSX/manual_verification_test.xlsx")
        
        print("🧪 Creating test file for manual verification of ZIP structure fix")
        print("   Output: \(outputURL.path)")
        
        // Test with systemTemp working directory (most likely to trigger original issue)
        let resultURL = try book.write(to: outputURL, workingDirectory: WorkingDirectoryLocation.systemTemp)
        
        // Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path))
        let fileSize = try FileManager.default.attributesOfItem(atPath: resultURL.path)[.size] as? Int ?? 0
        XCTAssertGreaterThan(fileSize, 1000)
        
        print("✅ Test file created successfully:")
        print("   📁 Path: \(resultURL.path)")
        print("   📊 Size: \(fileSize) bytes")
        print("   🔍 Manual verification steps:")
        print("      1. unzip -l manual_verification_test.xlsx")
        print("      2. Check that the structure shows:")
        print("         - [Content_Types].xml")
        print("         - _rels/.rels")
        print("         - docProps/...")
        print("         - xl/...")
        print("      3. Verify NO random directory names like '955152B' at the top level")
        print("   🎯 If the fix works, you should see proper XLSX structure without unwanted directory layers")
    }
}