//
// FillXMLTests.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Fill XML Generator Tests")
struct FillXMLTests {
    @Test("None Fill XML Generation")
    func noneFillXMLGeneration() async throws {
        let fill = Fill.none
        let xml = fill.xmlContent

        #expect(xml.contains("<fill>"), "Expected XML to start with <fill>")
        #expect(xml.contains("</fill>"), "Expected XML to end with </fill>")
        #expect(xml.contains("patternType=\"none\""), "Expected patternType to be none")
        #expect(!xml.contains("<fgColor"), "Expected no foreground color for none fill")
        #expect(!xml.contains("<bgColor"), "Expected no background color for none fill")
    }

    @Test("Solid Fill XML Generation")
    func solidFillXMLGeneration() async throws {
        let redFill = Fill.solid(.red)
        let xml = redFill.xmlContent

        #expect(xml.contains("<fill>"), "Expected XML to start with <fill>")
        #expect(xml.contains("</fill>"), "Expected XML to end with </fill>")
        #expect(xml.contains("patternType=\"solid\""), "Expected patternType to be solid")
        #expect(xml.contains("<fgColor rgb="), "Expected foreground color for solid fill")
        #expect(xml.contains("FFFF0000"), "Expected red color in ARGB format")
        #expect(!xml.contains("<bgColor"), "Expected no background color for solid fill")
    }

    @Test("Solid Fill with Different Colors")
    func solidFillWithDifferentColors() async throws {
        // 测试蓝色
        let blueFill = Fill.solid(.blue)
        let blueXML = blueFill.xmlContent
        #expect(blueXML.contains("FF0000FF"), "Expected blue color in ARGB format")

        // 测试绿色
        let greenFill = Fill.solid(.green)
        let greenXML = greenFill.xmlContent
        #expect(greenXML.contains("FF00FF00"), "Expected green color in ARGB format")

        // 测试自定义颜色
        let customColor = Color(red: 128, green: 64, blue: 192, alpha: .medium)
        let customFill = Fill.solid(customColor)
        let customXML = customFill.xmlContent
        #expect(customXML.contains("808040C0"), "Expected custom color in ARGB format")
    }

    @Test("Pattern Fill XML Generation")
    func patternFillXMLGeneration() async throws {
        let patternFill = Fill.pattern(.gray125, foreground: .black, background: .white)
        let xml = patternFill.xmlContent

        #expect(xml.contains("<fill>"), "Expected XML to start with <fill>")
        #expect(xml.contains("</fill>"), "Expected XML to end with </fill>")
        #expect(xml.contains("patternType=\"gray125\""), "Expected patternType to be gray125")
        #expect(xml.contains("<fgColor rgb="), "Expected foreground color for pattern fill")
        #expect(xml.contains("<bgColor rgb="), "Expected background color for pattern fill")
        #expect(xml.contains("FF000000"), "Expected black foreground color")
        #expect(xml.contains("FFFFFFFF"), "Expected white background color")
    }

    @Test("Pattern Fill without Background")
    func patternFillWithoutBackground() async throws {
        let patternFill = Fill.pattern(.darkHorizontal, foreground: .red, background: nil)
        let xml = patternFill.xmlContent

        #expect(xml.contains("patternType=\"darkHorizontal\""), "Expected patternType to be darkHorizontal")
        #expect(xml.contains("<fgColor rgb="), "Expected foreground color")
        #expect(!xml.contains("<bgColor"), "Expected no background color when nil")
        #expect(xml.contains("FFFF0000"), "Expected red foreground color")
    }

    @Test("Different Pattern Types")
    func differentPatternTypes() async throws {
        let patterns: [PatternType] = [
            .gray125, .gray0625, .darkHorizontal, .darkVertical,
            .darkDown, .darkUp, .darkGrid, .darkTrellis,
        ]

        for pattern in patterns {
            let fill = Fill.pattern(pattern, foreground: .black, background: .white)
            let xml = fill.xmlContent

            #expect(
                xml.contains("patternType=\"\(pattern.rawValue)\""),
                "Expected patternType to be \(pattern.rawValue)")
            #expect(xml.contains("<fgColor"), "Expected foreground color for \(pattern.rawValue)")
            #expect(xml.contains("<bgColor"), "Expected background color for \(pattern.rawValue)")
        }
    }

    @Test("Gradient Fill XML Generation")
    func gradientFillXMLGeneration() async throws {
        let gradientFill = Fill.gradient(.linear(angle: 90), colors: [.red, .blue])
        let xml = gradientFill.xmlContent

        #expect(xml.contains("<fill>"), "Expected XML to start with <fill>")
        #expect(xml.contains("</fill>"), "Expected XML to end with </fill>")
        #expect(xml.contains("<gradientFill"), "Expected gradientFill tag")
        #expect(xml.contains("degree=\"90.0\""), "Expected linear gradient angle") // 修正
        #expect(xml.contains("<stop position=\"0.0\">"), "Expected first gradient stop") // 修正
        #expect(xml.contains("<stop position=\"1.0\">"), "Expected last gradient stop") // 修正
        #expect(xml.contains("FFFF0000"), "Expected red color in first stop")
        #expect(xml.contains("FF0000FF"), "Expected blue color")
    }

    @Test("Radial Gradient Fill")
    func radialGradientFill() async throws {
        let radialFill = Fill.gradient(.radial, colors: [.white, .black, .gray])
        let xml = radialFill.xmlContent

        #expect(xml.contains("<gradientFill"), "Expected gradientFill tag")
        #expect(xml.contains("type=\"path\""), "Expected radial gradient type")
        #expect(xml.contains("<stop position=\"0.0\">"), "Expected first stop at position 0")
        #expect(xml.contains("<stop position=\"0.5\">"), "Expected middle stop at position 0.5")
        #expect(xml.contains("<stop position=\"1.0\">"), "Expected last stop at position 1")
    }

    @Test("Fill Convenience Methods")
    func fillConvenienceMethods() async throws {
        // 测试便利构造方法
        let solidRed = Fill.solid(.red)
        let solidRedFromRGB = Fill.solid(red: 255, green: 0, blue: 0)
        let solidRedFromHex = Fill.solid(hex: "#FF0000")

        // 这些应该生成相同的 XML（除了可能的精度差异）
        let xml1 = solidRed.xmlContent
        let xml2 = solidRedFromRGB.xmlContent
        let xml3 = solidRedFromHex.xmlContent

        #expect(xml1.contains("FFFF0000"), "Expected red from Color.red")
        #expect(xml2.contains("FFFF0000"), "Expected red from RGB values")
        #expect(xml3.contains("FFFF0000"), "Expected red from hex string")
    }

    @Test("Fill Identifiable")
    func fillIdentifiable() async throws {
        let fill1 = Fill.solid(.red)
        let fill2 = Fill.solid(.red)
        let fill3 = Fill.solid(.blue)
        let fill4 = Fill.none
        let fill5 = Fill.none

        #expect(fill1.id == fill2.id, "Expected identical solid fills to have same ID")
        #expect(fill1.id != fill3.id, "Expected different colored fills to have different IDs")
        #expect(fill4.id == fill5.id, "Expected identical none fills to have same ID")
        #expect(fill1.id != fill4.id, "Expected solid fill and none fill to have different IDs")
    }

    @Test("Fill XML Structure Validation")
    func fillXMLStructureValidation() async throws {
        let fills: [Fill] = [
            .none,
            .solid(.green),
            .pattern(.gray125, foreground: .black, background: .white),
            .gradient(.linear(angle: 45), colors: [.red, .yellow, .blue]),
        ]

        for fill in fills {
            let xml = fill.xmlContent

            // 基本结构检查
            #expect(xml.hasPrefix("<fill>"), "Expected XML to start with <fill> for \(fill)")
            #expect(xml.hasSuffix("</fill>"), "Expected XML to end with </fill> for \(fill)")

            // 检查是否有有效的填充类型
            let hasValidFillType = xml.contains("<patternFill") || xml.contains("<gradientFill")
            #expect(hasValidFillType, "Expected valid fill type for \(fill)")

            // 检查 XML 格式正确性（简单验证）
            let openTags = xml.components(separatedBy: "<").count - 1
            let closeTags = xml.components(separatedBy: "</").count - 1
            #expect(openTags >= closeTags, "Expected proper XML tag structure for \(fill)")
        }
    }

    @Test("Fill Default Values")
    func fillDefaultValues() async throws {
        let defaultFills = Fill.defaultFills

        #expect(defaultFills.count == 2, "Expected exactly 2 default fills")
        #expect(defaultFills[0] == .none, "Expected first default fill to be none")
        #expect(defaultFills[1] == .none, "Expected second default fill to be none")

        for (index, fill) in defaultFills.enumerated() {
            let xml = fill.xmlContent
            #expect(
                xml.contains("patternType=\"none\""),
                "Expected default fill \(index) to be none pattern")
        }
    }

    @Test("Fill Edge Cases")
    func fillEdgeCases() async throws {
        // 测试透明色
        let transparentFill = Fill.solid(Color(red: 255, green: 0, blue: 0, alpha: .transparent))
        let transparentXML = transparentFill.xmlContent
        #expect(transparentXML.contains("00FF0000"), "Expected transparent red color")

        // 测试单色渐变
        let singleColorGradient = Fill.gradient(.linear(angle: 0), colors: [.blue])
        let singleXML = singleColorGradient.xmlContent
        #expect(singleXML.contains("<stop position=\"0.0\">"), "Expected single gradient stop")

        // 测试多色渐变
        let multiColorGradient = Fill.gradient(
            .linear(angle: 180),
            colors: [.red, .green, .blue, .yellow])
        let multiXML = multiColorGradient.xmlContent
        #expect(multiXML.contains("<stop position=\"0.0\">"), "Expected first stop")
        #expect(multiXML.contains("<stop position=\"0.33333"), "Expected second stop")
        #expect(multiXML.contains("<stop position=\"0.66666"), "Expected third stop")
        #expect(multiXML.contains("<stop position=\"1.0\">"), "Expected last stop")
    }
}
