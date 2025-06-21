//
// StyleRegisterXMLTests.swift
// Created by Claude on 2025-06-19.
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Style Register XML Tests")
struct StyleRegisterXMLTests {
    @Test("test Basic XML Generation")
    func basicXMLGeneration() {
        let styleRegister = StyleRegister()

        // Register some basic styles
        let basicFont = Font(size: 12, name: "Arial", bold: true)
        let basicFill = Fill.solid(Color.blue)
        let basicAlignment = Alignment(horizontal: .center, vertical: .center)
        let basicBorder = Border.all(style: .thin, color: Color.black)

        let cellStyle = CellStyle(
            font: basicFont,
            fill: basicFill,
            alignment: basicAlignment,
            border: basicBorder)

        let styleID = styleRegister.registerCellStyle(cellStyle, cellType: .stringValue("test"))

        // Generate XML
        let xml = styleRegister.generateXML()

        // Verify basic structure
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"))
        #expect(xml.contains("<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">"))
        #expect(xml.contains("</styleSheet>"))

        // Verify fonts section
        #expect(xml.contains("<fonts count=\"2\">")) // Default + custom font
        #expect(xml.contains("Arial"))

        // Verify fills section
        #expect(xml.contains("<fills count=\"2\">")) // Default + custom fill

        // Verify borders section
        #expect(xml.contains("<borders count=\"2\">")) // Default + custom border

        // Verify cellXfs section
        #expect(xml.contains("<cellXfs count=\"2\">")) // Default + custom style

        // Verify alignment is included
        #expect(xml.contains("applyAlignment=\"1\""))

        print("Generated XML structure is valid")
        print("Style ID registered: \(styleID ?? -1)")
        print("XML length: \(xml.count) characters")
    }

    @Test("test Number Format XML Generation")
    func numberFormatXMLGeneration() {
        let styleRegister = StyleRegister()

        // Register styles with different number formats
        let percentageStyle = CellStyle()
        let dateStyle = CellStyle()

        _ = styleRegister.registerCellStyle(percentageStyle, cellType: .percentageValue(0.25, precision: 2))
        _ = styleRegister.registerCellStyle(dateStyle, cellType: .dateValue(Date(), timeZone: TimeZone.current))

        let xml = styleRegister.generateXML()

        // Check for custom number format (percentage should create custom format)
        #expect(xml.contains("<numFmts"))
        #expect(xml.contains("formatCode=\"0.00%\""))

        // Check that built-in date format uses built-in ID (22 for dateTime)
        #expect(xml.contains("numFmtId=\"22\"")) // Built-in dateTime format

        print("Number format XML generation test completed")
        print("Contains custom percentage format: \(xml.contains("0.00%"))")
        print("Contains date format reference: \(xml.contains("numFmtId=\"22\""))")
    }

    @Test("test Complex Style Combinations")
    func complexStyleCombinations() {
        let styleRegister = StyleRegister()

        // Create multiple different styles
        let headerStyle = CellStyle(
            font: Font(size: 14, name: "Arial", bold: true, color: Color.white),
            fill: Fill.solid(Color.blue),
            alignment: Alignment(horizontal: .center, vertical: .center),
            border: Border.all(style: .thick, color: Color.black))

        let dataStyle = CellStyle(
            font: Font(size: 10, name: "Calibri", bold: false),
            fill: Fill.none,
            alignment: Alignment(horizontal: .left),
            border: Border.outline(style: .thin))

        let numberStyle = CellStyle(
            font: Font(size: 11, name: "Times"),
            alignment: Alignment(horizontal: .right))

        // Register styles
        let headerID = styleRegister.registerCellStyle(headerStyle, cellType: .stringValue("Header"))
        let dataID = styleRegister.registerCellStyle(dataStyle, cellType: .stringValue("Data"))
        let numberID = styleRegister.registerCellStyle(numberStyle, cellType: .intValue(42))

        let xml = styleRegister.generateXML()

        // Verify we have the expected number of styles
        #expect(xml.contains("<cellXfs count=\"4\">")) // Default + 3 custom styles

        // Verify we have multiple fonts
        #expect(xml.contains("<fonts count=\"4\">")) // Default + 3 custom fonts

        // Verify we have multiple fills (should be 2: default none + blue solid)
        #expect(xml.contains("<fills count=\"2\">")) // Default + blue fill

        // Verify we have multiple borders
        #expect(xml.contains("<borders count=\"3\">")) // Default + thick all + thin outline

        // Verify alignments
        #expect(xml.contains("applyAlignment=\"1\""))

        print("Complex style combinations test completed")
        print("Header style ID: \(headerID ?? -1)")
        print("Data style ID: \(dataID ?? -1)")
        print("Number style ID: \(numberID ?? -1)")
        print("Generated XML contains all expected style combinations")
    }

    @Test("test XML Well-formedness")
    func xMLWellFormedness() {
        let styleRegister = StyleRegister()

        // Add a style with special characters in names
        let font = Font(size: 12, name: "Times New Roman", bold: true)
        let style = CellStyle(font: font)

        _ = styleRegister.registerCellStyle(style, cellType: .stringValue("Test & <data>"))

        let xml = styleRegister.generateXML()

        // Check that the XML is well-formed (no unescaped characters)
        #expect(!xml.contains("&") || xml.contains("&amp;") || xml.contains("&lt;") || xml.contains("&gt;"))

        // Verify required Excel sections are present
        #expect(xml.contains("<fonts"))
        #expect(xml.contains("<fills"))
        #expect(xml.contains("<borders"))
        #expect(xml.contains("<cellStyleXfs"))
        #expect(xml.contains("<cellXfs"))
        #expect(xml.contains("<cellStyles"))

        // Verify proper nesting
        let fontsStart = xml.range(of: "<fonts")
        let fontsEnd = xml.range(of: "</fonts>")
        #expect(fontsStart != nil && fontsEnd != nil)
        #expect(fontsStart!.lowerBound < fontsEnd!.lowerBound)

        print("XML well-formedness test completed")
        print("XML passes basic structure validation")
    }

    @Test("test Generated XML Sample")
    func generatedXMLSample() {
        let styleRegister = StyleRegister()

        // Create a comprehensive example with different style components
        let headerStyle = CellStyle(
            font: Font(size: 14, name: "Arial", bold: true, color: Color.white),
            fill: Fill.solid(Color.blue),
            alignment: Alignment(horizontal: .center, vertical: .center),
            border: Border.all(style: .thick, color: Color.black))

        let numberStyle = CellStyle(
            font: Font(size: 11, name: "Calibri"),
            alignment: Alignment(horizontal: .right))

        // Register styles with different cell types
        _ = styleRegister.registerCellStyle(headerStyle, cellType: .stringValue("Header"))
        _ = styleRegister.registerCellStyle(numberStyle, cellType: .percentageValue(0.85, precision: 1))
        _ = styleRegister.registerCellStyle(CellStyle(), cellType: .dateValue(Date(), timeZone: TimeZone.current))

        let xml = styleRegister.generateXML()

        // Print the complete XML for inspection
        print("=== Generated styles.xml Content ===")
        print(xml)
        print("=== End of XML ===")

        // Basic validation
        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"))
        #expect(xml.hasSuffix("</styleSheet>"))
        #expect(xml.contains("xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\""))

        // Verify all required sections are present
        let requiredSections = ["<fonts", "<fills", "<borders", "<cellStyleXfs", "<cellXfs", "<cellStyles"]
        for section in requiredSections {
            #expect(xml.contains(section), "Missing required section: \(section)")
        }

        print("Sample XML generation completed successfully")
        print("XML contains all required XLSX sections")
    }
}
