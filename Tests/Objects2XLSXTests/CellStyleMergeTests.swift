//
// CellStyleMergeTests.swift
// Created by Xu Yang on 2025-06-19.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("CellStyleMergeTests")
struct CellStyleMergeTests {
    // MARK: - Basic Merge Tests

    @Test("Basic merge with nil values")
    func basicMergeWithNilValues() {
        // Both nil
        let result1 = CellStyle.merge(base: nil, additional: nil)
        #expect(result1 == nil)

        // Base nil, additional non-nil
        let additional = CellStyle(font: Font.default)
        let result2 = CellStyle.merge(base: nil, additional: additional)
        #expect(result2?.font == Font.default)

        // Base non-nil, additional nil
        let base = CellStyle(fill: Fill.solid(Color.red))
        let result3 = CellStyle.merge(base: base, additional: nil)
        #expect(result3?.fill == Fill.solid(Color.red))
    }

    @Test("Basic merge with both non-nil")
    func basicMergeWithBothNonNil() {
        let base = CellStyle(
            font: Font.default,
            fill: Fill.solid(Color.red))

        let additional = CellStyle(
            font: Font(size: 14, name: "Arial", bold: true),
            alignment: Alignment.center)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged != nil)
        #expect(merged?.font?.size == 14) // additional overrides
        #expect(merged?.font?.name == "Arial") // additional overrides
        #expect(merged?.font?.bold == true) // additional overrides
        #expect(merged?.fill == Fill.solid(Color.red)) // base preserved
        #expect(merged?.alignment == Alignment.center) // additional added
        #expect(merged?.border == nil) // neither has border
    }

    // MARK: - Font Property Tests

    @Test("Font property merge")
    func fontPropertyMerge() {
        let baseFont = Font(size: 12, name: "Calibri", bold: false, color: Color.black)
        let additionalFont = Font(size: 16, name: "Arial", bold: true, color: Color.blue)

        let base = CellStyle(font: baseFont)
        let additional = CellStyle(font: additionalFont)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.font == additionalFont) // additional font overrides base
    }

    @Test("Font nil handling")
    func fontNilHandling() {
        let baseFont = Font.default
        let base = CellStyle(font: baseFont)
        let additional = CellStyle(font: nil)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.font == baseFont) // base font preserved when additional is nil
    }

    // MARK: - Fill Property Tests

    @Test("Fill property merge")
    func fillPropertyMerge() {
        let baseFill = Fill.solid(Color.red)
        let additionalFill = Fill.solid(Color.blue)

        let base = CellStyle(fill: baseFill)
        let additional = CellStyle(fill: additionalFill)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.fill == additionalFill) // additional fill overrides base
    }

    @Test("Fill different types merge")
    func fillDifferentTypesMerge() {
        let baseFill = Fill.solid(Color.red)
        let additionalFill = Fill.gradient(
            .linear(angle: 90.0),
            colors: [Color.blue, Color.green])

        let base = CellStyle(fill: baseFill)
        let additional = CellStyle(fill: additionalFill)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.fill == additionalFill) // gradient overrides solid
    }

    @Test("Fill nil handling")
    func fillNilHandling() {
        let baseFill = Fill.solid(Color.red)
        let base = CellStyle(fill: baseFill)
        let additional = CellStyle(fill: nil)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.fill == baseFill) // base fill preserved when additional is nil
    }

    // MARK: - Alignment Property Tests

    @Test("Alignment property merge")
    func alignmentPropertyMerge() {
        let baseAlignment = Alignment(horizontal: .left, vertical: .top)
        let additionalAlignment = Alignment.center

        let base = CellStyle(alignment: baseAlignment)
        let additional = CellStyle(alignment: additionalAlignment)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.alignment == additionalAlignment) // additional alignment overrides base
    }

    @Test("Alignment complex merge")
    func alignmentComplexMerge() {
        let baseAlignment = Alignment(
            horizontal: .left,
            vertical: .top,
            wrapText: false,
            indent: 0,
            textRotation: 0)

        let additionalAlignment = Alignment(
            horizontal: .center,
            vertical: .center,
            wrapText: true,
            indent: 2,
            textRotation: 45)

        let base = CellStyle(alignment: baseAlignment)
        let additional = CellStyle(alignment: additionalAlignment)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.alignment == additionalAlignment) // entire alignment object replaced
    }

    @Test("Alignment nil handling")
    func alignmentNilHandling() {
        let baseAlignment = Alignment.center
        let base = CellStyle(alignment: baseAlignment)
        let additional = CellStyle(alignment: nil)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.alignment == baseAlignment) // base alignment preserved when additional is nil
    }

    // MARK: - Border Property Tests

    @Test("Border property merge")
    func borderPropertyMerge() {
        let baseBorder = Border.all(style: .thin, color: Color.black)
        let additionalBorder = Border.all(style: .thick, color: Color.red)

        let base = CellStyle(border: baseBorder)
        let additional = CellStyle(border: additionalBorder)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.border == additionalBorder) // additional border overrides base
    }

    @Test("Border different styles merge")
    func borderDifferentStylesMerge() {
        let baseBorder = Border(
            left: Border.Side(style: .thin, color: Color.black),
            right: Border.Side(style: .thin, color: Color.black),
            top: nil,
            bottom: nil,
            diagonal: nil)

        let additionalBorder = Border(
            left: nil,
            right: nil,
            top: Border.Side(style: .thick, color: Color.red),
            bottom: Border.Side(style: .thick, color: Color.red),
            diagonal: nil)

        let base = CellStyle(border: baseBorder)
        let additional = CellStyle(border: additionalBorder)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.border == additionalBorder) // entire border object replaced
    }

    @Test("Border nil handling")
    func borderNilHandling() {
        let baseBorder = Border.all(style: .thin, color: Color.black)
        let base = CellStyle(border: baseBorder)
        let additional = CellStyle(border: nil)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.border == baseBorder) // base border preserved when additional is nil
    }

    // MARK: - Multiple Properties Tests

    @Test("All properties merge")
    func allPropertiesMerge() {
        let base = CellStyle(
            font: Font(size: 12, name: "Calibri", bold: false),
            fill: Fill.solid(Color.red),
            alignment: Alignment(horizontal: .left, vertical: .top),
            border: Border.all(style: .thin, color: Color.black))

        let additional = CellStyle(
            font: Font(size: 16, name: "Arial", bold: true),
            fill: Fill.solid(Color.blue),
            alignment: Alignment.center,
            border: Border.all(style: .thick, color: Color.red))

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.font?.size == 16)
        #expect(merged?.font?.name == "Arial")
        #expect(merged?.font?.bold == true)
        #expect(merged?.fill == Fill.solid(Color.blue))
        #expect(merged?.alignment == Alignment.center)
        #expect(merged?.border == Border.all(style: .thick, color: Color.red))
    }

    @Test("Partial properties merge")
    func partialPropertiesMerge() {
        let base = CellStyle(
            font: Font(size: 12, name: "Calibri"),
            fill: Fill.solid(Color.red),
            alignment: Alignment(horizontal: .left, vertical: .top),
            border: Border.all(style: .thin, color: Color.black))

        let additional = CellStyle(
            font: Font(size: 16, name: "Arial"), // override font
            fill: nil, // keep base fill
            alignment: Alignment.center, // override alignment
            border: nil, // keep base border
        )

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.font?.size == 16) // from additional
        #expect(merged?.font?.name == "Arial") // from additional
        #expect(merged?.fill == Fill.solid(Color.red)) // from base
        #expect(merged?.alignment == Alignment.center) // from additional
        #expect(merged?.border == Border.all(style: .thin, color: Color.black)) // from base
    }

    // MARK: - Multiple Styles Merge Tests

    @Test("Multiple styles merge")
    func multipleStylesMerge() {
        let style1 = CellStyle(font: Font(size: 12, name: "Calibri"))
        let style2 = CellStyle(fill: Fill.solid(Color.red))
        let style3 = CellStyle(alignment: Alignment.center)
        let style4 = CellStyle(border: Border.all(style: .thin, color: Color.black))

        let merged = CellStyle.merge(style1, style2, style3, style4)

        #expect(merged?.font?.size == 12)
        #expect(merged?.font?.name == "Calibri")
        #expect(merged?.fill == Fill.solid(Color.red))
        #expect(merged?.alignment == Alignment.center)
        #expect(merged?.border == Border.all(style: .thin, color: Color.black))
    }

    @Test("Multiple styles with conflicts")
    func multipleStylesWithConflicts() {
        let style1 = CellStyle(font: Font(size: 12, name: "Calibri"), fill: Fill.solid(Color.red))
        let style2 = CellStyle(font: Font(size: 14, name: "Arial"), alignment: Alignment.center)
        let style3 = CellStyle(font: Font(size: 16, name: "Times"), border: Border.all(style: .thin, color: Color.black))

        let merged = CellStyle.merge(style1, style2, style3)

        // Last style wins for conflicting properties
        #expect(merged?.font?.size == 16) // from style3
        #expect(merged?.font?.name == "Times") // from style3
        #expect(merged?.fill == Fill.solid(Color.red)) // from style1
        #expect(merged?.alignment == Alignment.center) // from style2
        #expect(merged?.border == Border.all(style: .thin, color: Color.black)) // from style3
    }

    @Test("Multiple styles with nil values")
    func multipleStylesWithNilValues() {
        let style1 = CellStyle(font: Font(size: 12, name: "Calibri"))
        let nilStyle: CellStyle? = nil
        let style2 = CellStyle(fill: Fill.solid(Color.red))

        let merged = CellStyle.merge(style1, nilStyle, style2)

        #expect(merged?.font?.size == 12)
        #expect(merged?.font?.name == "Calibri")
        #expect(merged?.fill == Fill.solid(Color.red))
        #expect(merged?.alignment == nil)
        #expect(merged?.border == nil)
    }

    // MARK: - Default Style Tests

    @Test("Default style merge")
    func defaultStyleMerge() {
        let customStyle = CellStyle(
            font: Font(size: 16, name: "Arial", bold: true),
            fill: Fill.solid(Color.blue))

        let merged = CellStyle.merge(CellStyle.default, customStyle)

        #expect(merged?.font?.size == 16) // custom overrides default
        #expect(merged?.font?.name == "Arial") // custom overrides default
        #expect(merged?.font?.bold == true) // custom overrides default
        #expect(merged?.fill == Fill.solid(Color.blue)) // custom overrides default
        #expect(merged?.alignment == Alignment.default) // from default
        #expect(merged?.border == Border.none) // from default
    }

    @Test("Merge with default style as additional")
    func mergeWithDefaultStyleAsAdditional() {
        let customStyle = CellStyle(
            font: Font(size: 16, name: "Arial"),
            fill: Fill.solid(Color.blue))

        let merged = CellStyle.merge(customStyle, CellStyle.default)

        // Default style should override custom style
        #expect(merged?.font == Font.default)
        #expect(merged?.fill == Fill.none)
        #expect(merged?.alignment == Alignment.default)
        #expect(merged?.border == Border.none)
    }

    // MARK: - Edge Cases

    @Test("Empty style merge")
    func emptyStyleMerge() {
        let emptyStyle = CellStyle()
        let customStyle = CellStyle(font: Font(size: 16, name: "Arial"))

        let merged = CellStyle.merge(emptyStyle, customStyle)

        #expect(merged?.font?.size == 16)
        #expect(merged?.font?.name == "Arial")
        #expect(merged?.fill == nil)
        #expect(merged?.alignment == nil)
        #expect(merged?.border == nil)
    }

    @Test("Same style merge")
    func sameStyleMerge() {
        let style = CellStyle(
            font: Font(size: 14, name: "Arial"),
            fill: Fill.solid(Color.red),
            alignment: Alignment.center,
            border: Border.all(style: .thin, color: Color.black))

        let merged = CellStyle.merge(style, style)

        #expect(merged == style) // Result should be identical to original
    }

    @Test("Complex font merge")
    func complexFontMerge() {
        let baseFont = Font(
            size: 12,
            name: "Calibri",
            bold: false,
            italic: false,
            underline: false,
            color: Color.black)

        let additionalFont = Font(
            size: 16,
            name: "Arial",
            bold: true,
            italic: true,
            underline: true,
            color: Color.blue)

        let base = CellStyle(font: baseFont)
        let additional = CellStyle(font: additionalFont)

        let merged = CellStyle.merge(base: base, additional: additional)

        #expect(merged?.font?.size == 16)
        #expect(merged?.font?.name == "Arial")
        #expect(merged?.font?.bold == true)
        #expect(merged?.font?.color == Color.blue)
        #expect(merged?.font?.italic == true)
        #expect(merged?.font?.underline == true)
    }
}
