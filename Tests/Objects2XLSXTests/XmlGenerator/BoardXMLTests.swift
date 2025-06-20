//
// BoardXMLTests.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Board XML Generator Tests", .tags(.xml))
struct BorderXMLTests {
    @Test("None Border XML Generation")
    func noneBorderXMLGeneration() async throws {
        let border = Border.none
        let xml = border.xmlContent

        #expect(xml.contains("<border>"), "Expected XML to start with <border>")
        #expect(xml.contains("</border>"), "Expected XML to end with </border>")
        #expect(xml.contains("<left/>"), "Expected empty left border")
        #expect(xml.contains("<right/>"), "Expected empty right border")
        #expect(xml.contains("<top/>"), "Expected empty top border")
        #expect(xml.contains("<bottom/>"), "Expected empty bottom border")
        #expect(xml.contains("<diagonal/>"), "Expected empty diagonal border")
        #expect(!xml.contains("style="), "Expected no style attributes for none border")
    }

    @Test("All Sides Border XML Generation")
    func allSidesBorderXMLGeneration() async throws {
        let border = Border.all(style: .thin, color: .black)
        let xml = border.xmlContent

        #expect(xml.contains("<border>"), "Expected XML to start with <border>")
        #expect(xml.contains("</border>"), "Expected XML to end with </border>")

        // 检查所有边都有样式
        #expect(xml.contains("<left style=\"thin\">"), "Expected left border with thin style")
        #expect(xml.contains("<right style=\"thin\">"), "Expected right border with thin style")
        #expect(xml.contains("<top style=\"thin\">"), "Expected top border with thin style")
        #expect(xml.contains("<bottom style=\"thin\">"), "Expected bottom border with thin style")

        // 检查颜色
        let colorCount = xml.components(separatedBy: "<color rgb=\"FF000000\"/>").count - 1
        #expect(colorCount == 4, "Expected 4 black colors for all sides")

        // 对角线应该为空
        #expect(xml.contains("<diagonal/>"), "Expected empty diagonal border")
    }

    @Test("Custom Single Side Border")
    func customSingleSideBorder() async throws {
        // 只有左边框
        let leftBorder = Border(left: Border.Side(style: .thick, color: .red))
        let leftXML = leftBorder.xmlContent

        #expect(leftXML.contains("<left style=\"thick\">"), "Expected thick left border")
        #expect(leftXML.contains("FFFF0000"), "Expected red color")
        #expect(leftXML.contains("<right/>"), "Expected empty right border")
        #expect(leftXML.contains("<top/>"), "Expected empty top border")
        #expect(leftXML.contains("<bottom/>"), "Expected empty bottom border")

        // 只有顶部边框
        let topBorder = Border(top: Border.Side(style: .double, color: .blue))
        let topXML = topBorder.xmlContent

        #expect(topXML.contains("<top style=\"double\">"), "Expected double top border")
        #expect(topXML.contains("FF0000FF"), "Expected blue color")
        #expect(topXML.contains("<left/>"), "Expected empty left border")
    }

    @Test("Different Border Styles")
    func differentBorderStyles() async throws {
        let styles: [BorderStyle] = [
            .thin, .medium, .thick, .dashed, .dotted, .double,
            .hair, .mediumDashed, .dashDot, .mediumDashDot,
        ]

        for style in styles {
            let border = Border(left: Border.Side(style: style, color: .black))
            let xml = border.xmlContent

            #expect(
                xml.contains("style=\"\(style.rawValue)\""),
                "Expected style \(style.rawValue)")
            #expect(
                xml.contains("<color rgb=\"FF000000\"/>"),
                "Expected black color for \(style.rawValue)")
        }
    }

    @Test("Different Border Colors")
    func differentBorderColors() async throws {
        let colors: [(Color, String, String)] = [
            (.red, "red", "FFFF0000"),
            (.green, "green", "FF00FF00"),
            (.blue, "blue", "FF0000FF"),
            (.black, "black", "FF000000"),
            (.white, "white", "FFFFFFFF"),
        ]

        for (color, name, expectedHex) in colors {
            let border = Border(left: Border.Side(style: .thin, color: color))
            let xml = border.xmlContent

            #expect(xml.contains(expectedHex), "Expected \(name) color as \(expectedHex)")
        }
    }

    @Test("Outline Border")
    func outlineBorder() async throws {
        let border = Border.outline(style: .medium, color: .gray)
        let xml = border.xmlContent

        // 所有四边都应该有相同的样式
        #expect(xml.contains("<left style=\"medium\">"), "Expected medium left border")
        #expect(xml.contains("<right style=\"medium\">"), "Expected medium right border")
        #expect(xml.contains("<top style=\"medium\">"), "Expected medium top border")
        #expect(xml.contains("<bottom style=\"medium\">"), "Expected medium bottom border")

        // 检查灰色（假设是 #808080）
        let grayCount = xml.components(separatedBy: "color rgb=").count - 1
        #expect(grayCount == 4, "Expected 4 gray colors for outline")
    }

    @Test("Horizontal and Vertical Borders")
    func horizontalAndVerticalBorders() async throws {
        // 水平边框（上下）
        let horizontalBorder = Border.horizontal(style: .dashed, color: .red)
        let hXML = horizontalBorder.xmlContent

        #expect(hXML.contains("<top style=\"dashed\">"), "Expected dashed top border")
        #expect(hXML.contains("<bottom style=\"dashed\">"), "Expected dashed bottom border")
        #expect(hXML.contains("<left/>"), "Expected empty left border")
        #expect(hXML.contains("<right/>"), "Expected empty right border")

        // 垂直边框（左右）
        let verticalBorder = Border.vertical(style: .dotted, color: .blue)
        let vXML = verticalBorder.xmlContent

        #expect(vXML.contains("<left style=\"dotted\">"), "Expected dotted left border")
        #expect(vXML.contains("<right style=\"dotted\">"), "Expected dotted right border")
        #expect(vXML.contains("<top/>"), "Expected empty top border")
        #expect(vXML.contains("<bottom/>"), "Expected empty bottom border")
    }

    @Test("Diagonal Border")
    func testDiagonalBorder() async throws {
        let diagonalBorder = Border(diagonal: Border.Side(style: .thin, color: .green))
        let xml = diagonalBorder.xmlContent

        #expect(xml.contains("<diagonal style=\"thin\">"), "Expected thin diagonal border")
        #expect(xml.contains("FF00FF00"), "Expected green color for diagonal")
        #expect(xml.contains("<left/>"), "Expected empty left border")
        #expect(xml.contains("<right/>"), "Expected empty right border")
        #expect(xml.contains("<top/>"), "Expected empty top border")
        #expect(xml.contains("<bottom/>"), "Expected empty bottom border")
    }

    @Test("Mixed Border Styles")
    func mixedBorderStyles() async throws {
        let mixedBorder = Border(
            left: Border.Side(style: .thick, color: .red),
            right: Border.Side(style: .thin, color: .blue),
            top: Border.Side(style: .double, color: .green),
            bottom: Border.Side(style: .dashed, color: .black),
            diagonal: Border.Side(style: .dotted, color: .gray))
        let xml = mixedBorder.xmlContent

        #expect(xml.contains("<left style=\"thick\">"), "Expected thick left border")
        #expect(xml.contains("<right style=\"thin\">"), "Expected thin right border")
        #expect(xml.contains("<top style=\"double\">"), "Expected double top border")
        #expect(xml.contains("<bottom style=\"dashed\">"), "Expected dashed bottom border")
        #expect(xml.contains("<diagonal style=\"dotted\">"), "Expected dotted diagonal border")

        #expect(xml.contains("FFFF0000"), "Expected red color")
        #expect(xml.contains("FF0000FF"), "Expected blue color")
        #expect(xml.contains("FF00FF00"), "Expected green color")
        #expect(xml.contains("FF000000"), "Expected black color")
    }

    @Test("Border Identifiable")
    func borderIdentifiable() async throws {
        let border1 = Border.all(style: .thin, color: .black)
        let border2 = Border.all(style: .thin, color: .black)
        let border3 = Border.all(style: .thick, color: .black)
        let border4 = Border.all(style: .thin, color: .red)

        #expect(border1.id == border2.id, "Expected identical borders to have same ID")
        #expect(border1.id != border3.id, "Expected different style borders to have different IDs")
        #expect(border1.id != border4.id, "Expected different color borders to have different IDs")
    }

    @Test("Border XML Structure Validation")
    func borderXMLStructureValidation() async throws {
        let borders: [Border] = [
            .none,
            .all(style: .thin, color: .black),
            .outline(style: .medium, color: .blue),
            .horizontal(style: .dashed, color: .red),
            .vertical(style: .dotted, color: .green),
            Border(diagonal: Border.Side(style: .double, color: .gray)),
        ]

        for border in borders {
            let xml = border.xmlContent

            // 基本结构检查
            #expect(xml.hasPrefix("<border"), "Expected XML to start with <border")
            #expect(xml.hasSuffix("</border>"), "Expected XML to end with </border>")

            // 检查必需的子元素
            #expect(xml.contains("<left"), "Expected left element")
            #expect(xml.contains("<right"), "Expected right element")
            #expect(xml.contains("<top"), "Expected top element")
            #expect(xml.contains("<bottom"), "Expected bottom element")
            #expect(xml.contains("<diagonal"), "Expected diagonal element")
        }
    }

    @Test("Border Side Properties")
    func borderSideProperties() async throws {
        let side = Border.Side(style: .medium, color: .red)

        #expect(side.style == .medium, "Expected medium style")
        #expect(side.color == .red, "Expected red color")

        // 测试默认颜色
        let defaultSide = Border.Side(style: .thin)
        #expect(defaultSide.color == .black, "Expected default color to be black")

        // 测试 Identifiable
        let side1 = Border.Side(style: .thin, color: .black)
        let side2 = Border.Side(style: .thin, color: .black)
        let side3 = Border.Side(style: .thick, color: .black)

        #expect(side1.id == side2.id, "Expected identical sides to have same ID")
        #expect(side1.id != side3.id, "Expected different sides to have different IDs")
    }

    @Test("Border Convenience Methods Coverage")
    func borderConvenienceMethodsCoverage() async throws {
        // 测试所有便利方法
        let none = Border.none
        let all = Border.all(style: .thin, color: .black)
        let outline = Border.outline(style: .medium, color: .blue)
        let horizontal = Border.horizontal(style: .dashed, color: .red)
        let vertical = Border.vertical(style: .dotted, color: .green)

        // 验证 none
        #expect(none.left == nil, "Expected none border to have no left")
        #expect(none.right == nil, "Expected none border to have no right")
        #expect(none.top == nil, "Expected none border to have no top")
        #expect(none.bottom == nil, "Expected none border to have no bottom")

        // 验证 all
        #expect(all.left?.style == .thin, "Expected all border left to be thin")
        #expect(all.right?.style == .thin, "Expected all border right to be thin")
        #expect(all.top?.style == .thin, "Expected all border top to be thin")
        #expect(all.bottom?.style == .thin, "Expected all border bottom to be thin")

        // 验证 horizontal
        #expect(horizontal.top?.style == .dashed, "Expected horizontal top to be dashed")
        #expect(horizontal.bottom?.style == .dashed, "Expected horizontal bottom to be dashed")
        #expect(horizontal.left == nil, "Expected horizontal left to be nil")
        #expect(horizontal.right == nil, "Expected horizontal right to be nil")

        // 验证 vertical
        #expect(vertical.left?.style == .dotted, "Expected vertical left to be dotted")
        #expect(vertical.right?.style == .dotted, "Expected vertical right to be dotted")
        #expect(vertical.top == nil, "Expected vertical top to be nil")
        #expect(vertical.bottom == nil, "Expected vertical bottom to be nil")

        // 验证 outline
        #expect(outline.left?.style == .medium, "Expected outline left to be medium")
        #expect(outline.right?.style == .medium, "Expected outline right to be medium")
        #expect(outline.top?.style == .medium, "Expected outline top to be medium")
        #expect(outline.bottom?.style == .medium, "Expected outline bottom to be medium")
        #expect(outline.diagonal == nil, "Expected outline diagonal to be nil")
    }
}
