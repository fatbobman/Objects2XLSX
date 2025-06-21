//
// ShareStringRegisterXMLTests.swift
// Created by Claude on 2025-06-20.
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Shared String Register XML Tests")
struct ShareStringRegisterXMLTests {
    @Test("test Basic XML Generation")
    func basicXMLGeneration() {
        let register = ShareStringRegister()

        // Register some strings
        let id1 = register.register("Hello")
        let id2 = register.register("World")
        let id3 = register.register("Excel")

        // Generate XML
        let xml = register.generateXML()

        // Verify basic structure
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"))
        #expect(xml.contains("<sst xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\""))
        #expect(xml.contains("count=\"3\""))
        #expect(xml.contains("uniqueCount=\"3\""))
        #expect(xml.contains("</sst>"))

        // Verify string content
        #expect(xml.contains("<si><t>Hello</t></si>"))
        #expect(xml.contains("<si><t>World</t></si>"))
        #expect(xml.contains("<si><t>Excel</t></si>"))

        // Verify IDs are assigned correctly
        #expect(id1 == 0)
        #expect(id2 == 1)
        #expect(id3 == 2)

        print("Basic XML generation test completed")
        print("Generated \(xml.count) characters of XML")
    }

    @Test("test Empty Register")
    func emptyRegister() {
        let register = ShareStringRegister()

        let xml = register.generateXML()

        // Verify empty structure
        #expect(xml.contains("count=\"0\""))
        #expect(xml.contains("uniqueCount=\"0\""))
        #expect(!xml.contains("<si>"))

        // Verify complete XML
        let expected = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="0" uniqueCount="0"></sst>
            """
        #expect(xml == expected)

        print("Empty register test completed")
    }

    @Test("test Duplicate Strings")
    func duplicateStrings() {
        let register = ShareStringRegister()

        // Register duplicate strings
        let id1 = register.register("Apple")
        let id2 = register.register("Banana")
        let id3 = register.register("Apple") // Duplicate
        let id4 = register.register("Cherry")
        let id5 = register.register("Banana") // Duplicate

        // Verify IDs for duplicates
        #expect(id1 == id3) // Same ID for "Apple"
        #expect(id2 == id5) // Same ID for "Banana"
        #expect(id4 == 2) // New ID for "Cherry"

        let xml = register.generateXML()

        // Should have 5 total references but only 3 unique strings
        #expect(xml.contains("count=\"5\""))  // Total references: Apple(2) + Banana(1) + Cherry(1) = 5
        #expect(xml.contains("uniqueCount=\"3\""))  // Unique strings: Apple, Banana, Cherry = 3

        // Verify each string appears only once
        let appleCount = xml.components(separatedBy: "<si><t>Apple</t></si>").count - 1
        let bananaCount = xml.components(separatedBy: "<si><t>Banana</t></si>").count - 1
        let cherryCount = xml.components(separatedBy: "<si><t>Cherry</t></si>").count - 1

        #expect(appleCount == 1)
        #expect(bananaCount == 1)
        #expect(cherryCount == 1)

        print("Duplicate strings test completed")
        print("Total unique strings: 3")
    }

    @Test("test Special Characters XML Escaping")
    func specialCharactersXMLEscaping() {
        let register = ShareStringRegister()

        // Register strings with special XML characters
        _ = register.register("Text with & ampersand")
        _ = register.register("Text with < less than")
        _ = register.register("Text with > greater than")
        _ = register.register("Text with \" quotes")
        _ = register.register("Text with ' apostrophe")
        _ = register.register("Mixed <tag> & \"quoted\" text")

        let xml = register.generateXML()

        // Verify proper escaping
        #expect(xml.contains("<si><t>Text with &amp; ampersand</t></si>"))
        #expect(xml.contains("<si><t>Text with &lt; less than</t></si>"))
        #expect(xml.contains("<si><t>Text with &gt; greater than</t></si>"))
        #expect(xml.contains("<si><t>Text with &quot; quotes</t></si>"))
        #expect(xml.contains("<si><t>Text with &apos; apostrophe</t></si>"))
        #expect(xml.contains("<si><t>Mixed &lt;tag&gt; &amp; &quot;quoted&quot; text</t></si>"))

        // Verify no unescaped characters remain
        // Check for raw special characters (excluding those in XML tags)
        let contentBetweenTags = xml.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        #expect(!contentBetweenTags.contains("&") || contentBetweenTags.contains("&amp;"))
        #expect(!contentBetweenTags.contains("<"))
        #expect(!contentBetweenTags.contains(">"))

        print("Special characters escaping test completed")
        print("All XML special characters properly escaped")
    }

    @Test("test Order Preservation")
    func orderPreservation() {
        let register = ShareStringRegister()

        // Register strings in specific order
        let strings = ["First", "Second", "Third", "Fourth", "Fifth"]
        var ids: [Int] = []

        for string in strings {
            ids.append(register.register(string))
        }

        // Verify IDs are sequential
        for (index, id) in ids.enumerated() {
            #expect(id == index)
        }

        let xml = register.generateXML()

        // Verify strings appear in registration order
        let firstPos = xml.range(of: "<si><t>First</t></si>")!.lowerBound
        let secondPos = xml.range(of: "<si><t>Second</t></si>")!.lowerBound
        let thirdPos = xml.range(of: "<si><t>Third</t></si>")!.lowerBound
        let fourthPos = xml.range(of: "<si><t>Fourth</t></si>")!.lowerBound
        let fifthPos = xml.range(of: "<si><t>Fifth</t></si>")!.lowerBound

        #expect(firstPos < secondPos)
        #expect(secondPos < thirdPos)
        #expect(thirdPos < fourthPos)
        #expect(fourthPos < fifthPos)

        print("Order preservation test completed")
        print("All strings maintain registration order")
    }

    @Test("test Batch Registration")
    func batchRegistration() {
        let register = ShareStringRegister()

        // Register initial strings
        _ = register.register("One")
        _ = register.register("Two")

        // Batch register strings
        let batchStrings = ["Three", "Four", "Five", "Two", "Six"] // "Two" is duplicate
        register.registerStrings(batchStrings)

        let xml = register.generateXML()

        // Should have 7 total references but only 6 unique strings (Two is duplicate)
        #expect(xml.contains("count=\"7\""))  // Total references: 7 registrations
        #expect(xml.contains("uniqueCount=\"6\""))  // Unique strings: One, Two, Three, Four, Five, Six = 6

        // Verify all unique strings are present
        #expect(xml.contains("<si><t>One</t></si>"))
        #expect(xml.contains("<si><t>Two</t></si>"))
        #expect(xml.contains("<si><t>Three</t></si>"))
        #expect(xml.contains("<si><t>Four</t></si>"))
        #expect(xml.contains("<si><t>Five</t></si>"))
        #expect(xml.contains("<si><t>Six</t></si>"))

        // Verify string index lookup
        #expect(register.stringIndex(for: "One") == 0)
        #expect(register.stringIndex(for: "Two") == 1)
        #expect(register.stringIndex(for: "Six") == 5)
        #expect(register.stringIndex(for: "NonExistent") == nil)

        print("Batch registration test completed")
        print("Batch registration handles duplicates correctly")
    }

    @Test("test Large Dataset Performance")
    func largeDatasetPerformance() {
        let register = ShareStringRegister()

        // Register a large number of strings
        let stringCount = 1000
        for i in 0 ..< stringCount {
            _ = register.register("String \(i)")
        }

        // Add some duplicates
        for i in 0 ..< 100 {
            _ = register.register("String \(i)") // Duplicates
        }

        let xml = register.generateXML()

        // Verify count: 1000 unique + 100 duplicates = 1100 total references
        let totalReferences = stringCount + 100  // 1000 unique + 100 duplicates
        #expect(xml.contains("count=\"\(totalReferences)\""))  // Total references: 1100
        #expect(xml.contains("uniqueCount=\"\(stringCount)\""))  // Unique strings: 1000

        // Verify structure is valid
        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"))
        #expect(xml.hasSuffix("</sst>"))

        // Verify a sample of strings
        #expect(xml.contains("<si><t>String 0</t></si>"))
        #expect(xml.contains("<si><t>String 500</t></si>"))
        #expect(xml.contains("<si><t>String 999</t></si>"))

        print("Large dataset test completed")
        print("Generated XML for \(stringCount) unique strings")
        print("XML size: \(xml.count) characters")
    }

    @Test("test Unicode and Emoji Support")
    func unicodeAndEmojiSupport() {
        let register = ShareStringRegister()

        // Register strings with various Unicode characters
        _ = register.register("Hello 世界")
        _ = register.register("Привет мир")
        _ = register.register("مرحبا بالعالم")
        _ = register.register("🚀 Rocket Science")
        _ = register.register("Multi-emoji: 😀🎉🌟")
        _ = register.register("Mixed: Hello 你好 👋")

        let xml = register.generateXML()

        // Verify all strings are preserved correctly
        #expect(xml.contains("<si><t>Hello 世界</t></si>"))
        #expect(xml.contains("<si><t>Привет мир</t></si>"))
        #expect(xml.contains("<si><t>مرحبا بالعالم</t></si>"))
        #expect(xml.contains("<si><t>🚀 Rocket Science</t></si>"))
        #expect(xml.contains("<si><t>Multi-emoji: 😀🎉🌟</t></si>"))
        #expect(xml.contains("<si><t>Mixed: Hello 你好 👋</t></si>"))

        #expect(xml.contains("count=\"6\""))
        #expect(xml.contains("uniqueCount=\"6\""))

        print("Unicode and emoji support test completed")
        print("All international characters and emojis preserved correctly")
    }

    @Test("test Generated XML Sample")
    func generatedXMLSample() {
        let register = ShareStringRegister()

        // Create a realistic example
        _ = register.register("Product Name")
        _ = register.register("Price")
        _ = register.register("Quantity")
        _ = register.register("Total")
        _ = register.register("Apple iPhone 15")
        _ = register.register("Samsung Galaxy S24")
        _ = register.register("Google Pixel 8")
        _ = register.register("$999.00")
        _ = register.register("$1199.00")
        _ = register.register("$699.00")

        let xml = register.generateXML()

        // Print the complete XML for inspection
        print("=== Generated sharedStrings.xml Content ===")
        print(xml)
        print("=== End of XML ===")

        // Basic validation
        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"))
        #expect(xml.hasSuffix("</sst>"))
        #expect(xml.contains("xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\""))

        // Verify count
        #expect(xml.contains("count=\"10\""))
        #expect(xml.contains("uniqueCount=\"10\""))

        // Verify proper structure
        let siCount = xml.components(separatedBy: "<si>").count - 1
        let tCount = xml.components(separatedBy: "<t>").count - 1
        #expect(siCount == 10)
        #expect(tCount == 10)

        print("Sample XML generation completed successfully")
        print("Generated shared strings XML with 10 unique strings")
    }
}
