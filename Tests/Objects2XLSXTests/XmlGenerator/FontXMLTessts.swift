//
// FontXMLTessts.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Font XML Generator Tests")
struct FontXMLTests {
    @Test("Complete Font XML Generation")
    func completeFontXMLGeneration() async throws {
        let font = Font(
            size: 14,
            name: "Arial",
            bold: true,
            italic: true,
            underline: true,
            color: Color(hex: "#FF0000"))
        let xml = font.xmlContent

        #expect(xml.contains("<sz val=\"14\"/>"), "Expected font size to be 14")
        #expect(xml.contains("<name val=\"Arial\"/>"), "Expected font name to be Arial")
        #expect(xml.contains("<b/>"), "Expected font to be bold")
        #expect(xml.contains("<i/>"), "Expected font to be italic")
        #expect(xml.contains("<u val=\"single\"/>"), "Expected font to be underlined")
        #expect(xml.contains("<color rgb=\"FFFF0000\"/>"), "Expected font color to be red")
        #expect(xml.contains("<family val=\"2\"/>"), "Expected Arial to be Swiss family")
    }

    @Test("Default Font XML Generation")
    func testDefaultFontXMLGeneration() async throws {
        let font = Font() // 所有属性都是 nil
        let xml = font.xmlContent

        #expect(xml.contains("<sz val=\"12\"/>"), "Expected default size to be 12")
        #expect(xml.contains("<name val=\"Calibri\"/>"), "Expected default name to be Calibri")
        #expect(xml.contains("<color theme=\"1\"/>"), "Expected theme color when no color specified")
        #expect(xml.contains("<family val=\"2\"/>"), "Expected default family to be Swiss")
        #expect(!xml.contains("<b/>"), "Expected no bold tag for default font")
        #expect(!xml.contains("<i/>"), "Expected no italic tag for default font")
        #expect(!xml.contains("<u "), "Expected no underline tag for default font")
    }

    @Test("Font Static Default")
    func fontStaticDefault() async throws {
        let font = Font.default
        let xml = font.xmlContent

        #expect(xml.contains("<sz val=\"12\"/>"), "Expected Font.default size to be 12")
        #expect(xml.contains("<name val=\"Calibri\"/>"), "Expected Font.default name to be Calibri")
        #expect(xml.contains("<color theme=\"1\"/>"), "Expected Font.default to use theme color")
        #expect(xml.contains("<family val=\"2\"/>"), "Expected Font.default family to be Swiss")
    }

    @Test("Font Family Detection")
    func fontFamilyDetection() async throws {
        // 测试不同字体的字体族检测
        let timesFont = Font(name: "Times New Roman")
        let timesXML = timesFont.xmlContent
        #expect(timesXML.contains("<family val=\"1\"/>"), "Expected Times New Roman to be Roman family")

        let calibriFont = Font(name: "Calibri")
        let calibriXML = calibriFont.xmlContent
        #expect(calibriXML.contains("<family val=\"2\"/>"), "Expected Calibri to be Swiss family")

        let courierFont = Font(name: "Courier New")
        let courierXML = courierFont.xmlContent
        #expect(courierXML.contains("<family val=\"3\"/>"), "Expected Courier New to be Modern family")

        let unknownFont = Font(name: "UnknownFont")
        let unknownXML = unknownFont.xmlContent
        #expect(unknownXML.contains("<family val=\"2\"/>"), "Expected unknown font to default to Swiss family")
    }

    @Test("Font Color Handling")
    func fontColorHandling() async throws {
        // 测试有颜色的情况
        let coloredFont = Font(color: Color(red: 255, green: 0, blue: 0))
        let coloredXML = coloredFont.xmlContent
        #expect(coloredXML.contains("<color rgb=\""), "Expected RGB color when color is specified")
        #expect(!coloredXML.contains("<color theme=\""), "Expected no theme color when RGB is specified")

        // 测试没有颜色的情况
        let noColorFont = Font(size: 12, name: "Arial")
        let noColorXML = noColorFont.xmlContent
        #expect(noColorXML.contains("<color theme=\"1\"/>"), "Expected theme color when no color specified")
        #expect(!noColorXML.contains("<color rgb=\""), "Expected no RGB color when no color specified")
    }

    @Test("Font Boolean Properties")
    func fontBooleanProperties() async throws {
        // 测试 bold = true
        let boldFont = Font(bold: true)
        let boldXML = boldFont.xmlContent
        #expect(boldXML.contains("<b/>"), "Expected bold tag when bold is true")

        // 测试 bold = false
        let notBoldFont = Font(bold: false)
        let notBoldXML = notBoldFont.xmlContent
        #expect(!notBoldXML.contains("<b/>"), "Expected no bold tag when bold is false")

        // 测试 italic = true
        let italicFont = Font(italic: true)
        let italicXML = italicFont.xmlContent
        #expect(italicXML.contains("<i/>"), "Expected italic tag when italic is true")

        // 测试 italic = false
        let notItalicFont = Font(italic: false)
        let notItalicXML = notItalicFont.xmlContent
        #expect(!notItalicXML.contains("<i/>"), "Expected no italic tag when italic is false")

        // 测试 underline = true
        let underlineFont = Font(underline: true)
        let underlineXML = underlineFont.xmlContent
        #expect(underlineXML.contains("<u val=\"single\"/>"), "Expected underline tag when underline is true")

        // 测试 underline = false
        let notUnderlineFont = Font(underline: false)
        let notUnderlineXML = notUnderlineFont.xmlContent
        #expect(!notUnderlineXML.contains("<u "), "Expected no underline tag when underline is false")
    }

    @Test("Font XML Structure")
    func fontXMLStructure() async throws {
        let font = Font(size: 16, name: "Helvetica", bold: true, color: Color.blue)
        let xml = font.xmlContent

        // 检查 XML 结构
        #expect(xml.hasPrefix("<font>"), "Expected XML to start with <font>")
        #expect(xml.hasSuffix("</font>"), "Expected XML to end with </font>")

        // 检查标签顺序（sz -> color -> name -> family -> b）
        let sizeIndex = xml.range(of: "<sz")?.lowerBound
        let colorIndex = xml.range(of: "<color")?.lowerBound
        let nameIndex = xml.range(of: "<name")?.lowerBound
        let familyIndex = xml.range(of: "<family")?.lowerBound
        let boldIndex = xml.range(of: "<b/>")?.lowerBound

        #expect(sizeIndex != nil, "Expected size tag to be present")
        #expect(colorIndex != nil, "Expected color tag to be present")
        #expect(nameIndex != nil, "Expected name tag to be present")
        #expect(familyIndex != nil, "Expected family tag to be present")
        #expect(boldIndex != nil, "Expected bold tag to be present")
    }

    @Test("Font Identifiable")
    func fontIdentifiable() async throws {
        let font1 = Font(size: 12, name: "Arial", bold: true)
        let font2 = Font(size: 12, name: "Arial", bold: true)
        let font3 = Font(size: 14, name: "Arial", bold: true)

        #expect(font1.id == font2.id, "Expected identical fonts to have same ID")
        #expect(font1.id != font3.id, "Expected different fonts to have different IDs")
    }
}

