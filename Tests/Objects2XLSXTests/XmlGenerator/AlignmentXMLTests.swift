//
// AlignmentXMLTests.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("AlignmentXMLTests", .tags(.xml))
struct AlignmentXMLTests {
    @Test("Empty Alignment XML Generation")
    func emptyAlignmentXMLGeneration() async throws {
        let alignment = Alignment()
        let xml = alignment.xmlContent

        #expect(xml.isEmpty, "Expected empty XML for alignment with no properties")
    }

    @Test("Horizontal Alignment XML Generation")
    func horizontalAlignmentXMLGeneration() async throws {
        let alignments: [HorizontalAlignment] = [
            .general, .left, .center, .right, .fill, .justify, .centerContinuous, .distributed,
        ]

        for horizontalAlign in alignments {
            let alignment = Alignment(horizontal: horizontalAlign)
            let xml = alignment.xmlContent

            #expect(
                xml.contains("horizontal=\"\(horizontalAlign.rawValue)\""),
                "Expected horizontal alignment \(horizontalAlign.rawValue)")
            #expect(xml.hasPrefix("<alignment "), "Expected alignment tag")
            #expect(xml.hasSuffix("/>"), "Expected self-closing tag")
            #expect(!xml.contains("vertical="), "Expected no vertical alignment")
        }
    }

    @Test("Vertical Alignment XML Generation")
    func verticalAlignmentXMLGeneration() async throws {
        let alignments: [VerticalAlignment] = [
            .top, .center, .bottom, .justify, .distributed,
        ]

        for verticalAlign in alignments {
            let alignment = Alignment(vertical: verticalAlign)
            let xml = alignment.xmlContent

            #expect(
                xml.contains("vertical=\"\(verticalAlign.rawValue)\""),
                "Expected vertical alignment \(verticalAlign.rawValue)")
            #expect(xml.hasPrefix("<alignment "), "Expected alignment tag")
            #expect(xml.hasSuffix("/>"), "Expected self-closing tag")
            #expect(!xml.contains("horizontal="), "Expected no horizontal alignment")
        }
    }

    @Test("Combined Horizontal and Vertical Alignment")
    func combinedAlignment() async throws {
        let alignment = Alignment(horizontal: .center, vertical: .center)
        let xml = alignment.xmlContent

        #expect(xml.contains("horizontal=\"center\""), "Expected center horizontal alignment")
        #expect(xml.contains("vertical=\"center\""), "Expected middle vertical alignment")
        #expect(xml.contains("<alignment "), "Expected alignment tag")
        #expect(xml.hasSuffix("/>"), "Expected self-closing tag")
    }

    @Test("Wrap Text Alignment")
    func wrapTextAlignment() async throws {
        // 只有换行
        let wrapOnly = Alignment(wrapText: true)
        let wrapXML = wrapOnly.xmlContent

        #expect(wrapXML.contains("wrapText=\"1\""), "Expected wrapText attribute")
        #expect(!wrapXML.contains("horizontal="), "Expected no horizontal alignment")
        #expect(!wrapXML.contains("vertical="), "Expected no vertical alignment")

        // 换行设为 false 时不应该出现
        let noWrap = Alignment(wrapText: false)
        let noWrapXML = noWrap.xmlContent

        #expect(noWrapXML.isEmpty, "Expected empty XML when wrapText is false")

        // 组合换行和对齐
        let combinedWrap = Alignment(horizontal: .left, vertical: .top, wrapText: true)
        let combinedXML = combinedWrap.xmlContent

        #expect(combinedXML.contains("horizontal=\"left\""), "Expected left alignment")
        #expect(combinedXML.contains("vertical=\"top\""), "Expected top alignment")
        #expect(combinedXML.contains("wrapText=\"1\""), "Expected wrapText attribute")
    }

    @Test("Indent Alignment")
    func indentAlignment() async throws {
        // 左对齐 + 缩进（有效）
        let leftIndent = Alignment(horizontal: .left, indent: 3)
        let leftXML = leftIndent.xmlContent

        #expect(leftXML.contains("horizontal=\"left\""), "Expected left alignment")
        #expect(leftXML.contains("indent=\"3\""), "Expected indent level 3")

        // 右对齐 + 缩进（有效）
        let rightIndent = Alignment(horizontal: .right, indent: 2)
        let rightXML = rightIndent.xmlContent

        #expect(rightXML.contains("horizontal=\"right\""), "Expected right alignment")
        #expect(rightXML.contains("indent=\"2\""), "Expected indent level 2")

        // 居中 + 缩进（无效，缩进应该被忽略）
        let centerIndent = Alignment(horizontal: .center, indent: 5)
        let centerXML = centerIndent.xmlContent

        #expect(centerXML.contains("horizontal=\"center\""), "Expected center alignment")
        #expect(!centerXML.contains("indent="), "Expected no indent for center alignment")

        // 分散对齐 + 缩进（有效）
        let distributedIndent = Alignment(horizontal: .distributed, indent: 1)
        let distributedXML = distributedIndent.xmlContent

        #expect(distributedXML.contains("horizontal=\"distributed\""), "Expected distributed alignment")
        #expect(distributedXML.contains("indent=\"1\""), "Expected indent level 1")
    }

    @Test("Indent Validation")
    func indentValidation() async throws {
        // 负数缩进
        let negativeIndent = Alignment(horizontal: .left, indent: -5)
        let negativeXML = negativeIndent.xmlContent

        #expect(!negativeXML.contains("indent="), "Expected no indent for negative value")

        // 零缩进
        let zeroIndent = Alignment(horizontal: .left, indent: 0)
        let zeroXML = zeroIndent.xmlContent

        #expect(!zeroXML.contains("indent="), "Expected no indent for zero value")

        // 超大缩进（应该被限制到250）
        let largeIndent = Alignment(horizontal: .left, indent: 300)
        let largeXML = largeIndent.xmlContent

        #expect(largeXML.contains("indent=\"250\""), "Expected indent to be capped at 250")

        // 边界值测试
        let maxIndent = Alignment(horizontal: .left, indent: 250)
        let maxXML = maxIndent.xmlContent

        #expect(maxXML.contains("indent=\"250\""), "Expected max indent 250")
    }

    @Test("Text Rotation Alignment")
    func textRotationAlignment() async throws {
        // 正常角度范围
        let validAngles = [-90, -45, 0, 45, 90]

        for angle in validAngles {
            let alignment = Alignment(textRotation: angle)
            let xml = alignment.xmlContent

            #expect(
                xml.contains("textRotation=\"\(angle)\""),
                "Expected textRotation \(angle)")
        }

        // 垂直文本（特殊值255）
        let verticalText = Alignment(textRotation: 255)
        let verticalXML = verticalText.xmlContent

        #expect(
            verticalXML.contains("textRotation=\"255\""),
            "Expected vertical text rotation 255")
    }

    @Test("Text Rotation Validation")
    func textRotationValidation() async throws {
        // 超出范围的角度
        let invalidAngles = [-100, 100, 180, -180, 360]

        for angle in invalidAngles {
            let alignment = Alignment(textRotation: angle)
            let xml = alignment.xmlContent

            #expect(
                !xml.contains("textRotation="),
                "Expected no textRotation for invalid angle \(angle)")
        }
    }

    @Test("Complete Alignment Properties")
    func completeAlignmentProperties() async throws {
        let fullAlignment = Alignment(
            horizontal: .center,
            vertical: .center,
            wrapText: true,
            indent: 2, // 会被忽略，因为center不支持缩进
            textRotation: 45)
        let xml = fullAlignment.xmlContent

        #expect(xml.contains("horizontal=\"center\""), "Expected center horizontal")
        #expect(xml.contains("vertical=\"center\""), "Expected middle vertical")
        #expect(xml.contains("wrapText=\"1\""), "Expected wrap text")
        #expect(!xml.contains("indent="), "Expected no indent for center alignment")
        #expect(xml.contains("textRotation=\"45\""), "Expected 45 degree rotation")
    }

    @Test("Alignment Convenience Methods")
    func alignmentConvenienceMethods() async throws {
        // 测试预定义的便利方法
        let center = Alignment.center
        let centerXML = center.xmlContent
        #expect(centerXML.contains("horizontal=\"center\""), "Expected center horizontal")
        #expect(centerXML.contains("vertical=\"center\""), "Expected center vertical")

        let topLeft = Alignment.topLeft
        let topLeftXML = topLeft.xmlContent
        #expect(topLeftXML.contains("horizontal=\"left\""), "Expected left horizontal")
        #expect(topLeftXML.contains("vertical=\"top\""), "Expected top vertical")

        let bottomRight = Alignment.bottomRight
        let bottomRightXML = bottomRight.xmlContent
        #expect(bottomRightXML.contains("horizontal=\"right\""), "Expected right horizontal")
        #expect(bottomRightXML.contains("vertical=\"bottom\""), "Expected bottom vertical")

        let leftWrap = Alignment.leftWrap
        let leftWrapXML = leftWrap.xmlContent
        #expect(leftWrapXML.contains("horizontal=\"left\""), "Expected left horizontal")
        #expect(leftWrapXML.contains("wrapText=\"1\""), "Expected wrap text")

        let centerWrap = Alignment.centerWrap
        let centerWrapXML = centerWrap.xmlContent
        #expect(centerWrapXML.contains("horizontal=\"center\""), "Expected center horizontal")
        #expect(centerWrapXML.contains("vertical=\"center\""), "Expected center vertical")
        #expect(centerWrapXML.contains("wrapText=\"1\""), "Expected wrap text")

        let verticalText = Alignment.verticalText
        let verticalTextXML = verticalText.xmlContent
        #expect(verticalTextXML.contains("textRotation=\"255\""), "Expected vertical text")
    }

    @Test("Alignment Factory Methods")
    func alignmentFactoryMethods() async throws {
        // 测试缩进工厂方法
        let indented = Alignment.leftIndented(5)
        let indentedXML = indented.xmlContent
        #expect(indentedXML.contains("horizontal=\"left\""), "Expected left alignment")
        #expect(indentedXML.contains("indent=\"5\""), "Expected indent level 5")

        // 测试旋转工厂方法
        let rotated = Alignment.rotated(30)
        let rotatedXML = rotated.xmlContent
        #expect(rotatedXML.contains("textRotation=\"30\""), "Expected 30 degree rotation")

        // 测试无效旋转
        let invalidRotated = Alignment.rotated(200)
        let invalidXML = invalidRotated.xmlContent
        #expect(invalidXML.isEmpty, "Expected empty XML for invalid rotation")
    }

    @Test("Alignment Identifiable")
    func alignmentIdentifiable() async throws {
        let alignment1 = Alignment(horizontal: .center, vertical: .center)
        let alignment2 = Alignment(horizontal: .center, vertical: .center)
        let alignment3 = Alignment(horizontal: .left, vertical: .center)
        let alignment4 = Alignment()
        let alignment5 = Alignment()

        #expect(alignment1.id == alignment2.id, "Expected identical alignments to have same ID")
        #expect(alignment1.id != alignment3.id, "Expected different alignments to have different IDs")
        #expect(alignment4.id == alignment5.id, "Expected empty alignments to have same ID")
        #expect(alignment1.id != alignment4.id, "Expected different alignment configs to have different IDs")
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @Test("Alignment XML Structure Validation")
    func alignmentXMLStructureValidation() async throws {
        let alignments: [Alignment] = [
            Alignment(),
            .center,
            .topLeft,
            .leftWrap,
            .verticalText,
            .leftIndented(3),
            .rotated(45),
            Alignment(horizontal: .center, vertical: .center, wrapText: true, textRotation: 30),
        ]

        for alignment in alignments {
            let xml = alignment.xmlContent

            if !xml.isEmpty {
                // 检查XML结构
                #expect(xml.hasPrefix("<alignment "), "Expected XML to start with <alignment ")
                #expect(xml.hasSuffix("/>"), "Expected XML to be self-closing")

                // 检查属性格式
                let attributePattern = /\w+="[^"]*"/
                let matches = xml.matches(of: attributePattern)
                #expect(!matches.isEmpty, "Expected at least one attribute")
            }
        }
    }

    @Test("Alignment Edge Cases")
    func alignmentEdgeCases() async throws {
        // 测试边界值
        let maxIndentAlignment = Alignment(horizontal: .left, indent: Int.max)
        let maxIndentXML = maxIndentAlignment.xmlContent
        #expect(maxIndentXML.contains("indent=\"250\""), "Expected indent capped at 250")

        let minRotationAlignment = Alignment(textRotation: Int.min)
        let minRotationXML = minRotationAlignment.xmlContent
        #expect(!minRotationXML.contains("textRotation="), "Expected invalid rotation to be ignored")

        // 测试组合边界情况
        let mixedValidInvalid = Alignment(
            horizontal: .center, // 有效
            indent: -10, // 无效（负数且center不支持）
            textRotation: 500 // 无效（超出范围）
        )
        let mixedXML = mixedValidInvalid.xmlContent
        #expect(mixedXML.contains("horizontal=\"center\""), "Expected valid horizontal alignment")
        #expect(!mixedXML.contains("indent="), "Expected invalid indent to be ignored")
        #expect(!mixedXML.contains("textRotation="), "Expected invalid rotation to be ignored")
    }
}
