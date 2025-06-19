//
// SheetStyleMergeTests.swift
// Created by Xu Yang on 2025-06-19.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("SheetStyleMergeTests")
struct SheetStyleMergeTests {
    @Test("Basic merge functionality")
    func basicMerge() {
        let baseStyle = SheetStyle(
            defaultColumnWidth: 10.0,
            defaultRowHeight: 20.0,
            showGridlines: false)

        let additionalStyle = SheetStyle(
            defaultColumnWidth: 15.0,
            showGridlines: false, // 与默认值不同才会覆盖
            showZeros: false)

        let merged = SheetStyle.merge(base: baseStyle, additional: additionalStyle)

        #expect(merged != nil)
        #expect(merged?.defaultColumnWidth == 15.0) // additional 覆盖 base
        #expect(merged?.defaultRowHeight == 20.0) // base 的值保留（additional 使用默认值）
        #expect(merged?.showGridlines == false) // additional 覆盖 base
        #expect(merged?.showZeros == false) // additional 的值（与默认值不同）
    }

    @Test("Merge with nil values")
    func mergeWithNilValues() {
        let style = SheetStyle(defaultColumnWidth: 12.0)

        // base 为 nil
        let result1 = SheetStyle.merge(base: nil, additional: style)
        #expect(result1?.defaultColumnWidth == 12.0)

        // additional 为 nil
        let result2 = SheetStyle.merge(base: style, additional: nil)
        #expect(result2?.defaultColumnWidth == 12.0)

        // 两个都为 nil
        let result3 = SheetStyle.merge(base: nil, additional: nil)
        #expect(result3 == nil)
    }

    @Test("Multiple styles merge")
    func multipleStylesMerge() {
        let style1 = SheetStyle(defaultColumnWidth: 8.0, showGridlines: false)
        let style2 = SheetStyle(defaultRowHeight: 16.0, showZeros: false)
        let style3 = SheetStyle(defaultColumnWidth: 12.0, showFormulas: true)

        let merged = SheetStyle.merge(style1, style2, style3)

        #expect(merged != nil)
        #expect(merged?.defaultColumnWidth == 12.0) // style3 的值（最高优先级）
        #expect(merged?.defaultRowHeight == 16.0) // style2 的值
        #expect(merged?.showGridlines == false) // style1 的值
        #expect(merged?.showZeros == false) // style2 的值
        #expect(merged?.showFormulas == true) // style3 的值
    }

    @Test("Dictionary properties merge")
    func dictionaryPropertiesMerge() {
        var baseStyle = SheetStyle()
        baseStyle.columnWidths[1] = SheetStyle.ColumnWidth(width: 10.0, unit: .points, isCustomWidth: true)
        baseStyle.rowHeights[1] = 20.0

        var additionalStyle = SheetStyle()
        additionalStyle.columnWidths[2] = SheetStyle.ColumnWidth(width: 15.0, unit: .characters, isCustomWidth: false)
        additionalStyle.rowHeights[1] = 25.0 // 覆盖同一行
        additionalStyle.rowHeights[2] = 30.0

        let merged = SheetStyle.merge(base: baseStyle, additional: additionalStyle)

        #expect(merged != nil)
        #expect(merged?.columnWidths.count == 2)
        #expect(merged?.columnWidths[1]?.width == 10.0) // base 的值
        #expect(merged?.columnWidths[2]?.width == 15.0) // additional 的值
        #expect(merged?.rowHeights.count == 2)
        #expect(merged?.rowHeights[1] == 25.0) // additional 覆盖 base
        #expect(merged?.rowHeights[2] == 30.0) // additional 的值
    }

    @Test("All boolean properties merge")
    func allBooleanPropertiesMerge() {
        let baseStyle = SheetStyle(
            showRowAndColumnHeadings: false,
            showOutlineSymbols: false,
            showPageBreaks: true)

        let additionalStyle = SheetStyle(
            showRowAndColumnHeadings: true,
            showOutlineSymbols: true,
            showPageBreaks: false)

        let merged = SheetStyle.merge(base: baseStyle, additional: additionalStyle, forceOverride: true)

        #expect(merged?.showRowAndColumnHeadings == true)
        #expect(merged?.showOutlineSymbols == true)
        #expect(merged?.showPageBreaks == false)
    }

    @Test("Optional properties merge")
    func optionalPropertiesMerge() {
        var baseStyle = SheetStyle()
        baseStyle.tabColor = Color.red
        baseStyle.freezePanes = SheetStyle.FreezePanes.freezeTopRow()
        baseStyle.zoom = SheetStyle.Zoom.custom(150)
        baseStyle.dataRange = SheetStyle.DataRange(startRow: 1, startColumn: 1, endRow: 10, endColumn: 5)

        var additionalStyle = SheetStyle()
        additionalStyle.tabColor = Color.blue
        additionalStyle.zoom = SheetStyle.Zoom.custom(200)

        let merged = SheetStyle.merge(base: baseStyle, additional: additionalStyle)

        #expect(merged?.tabColor == Color.blue) // additional 覆盖
        #expect(merged?.freezePanes?.freezeTopRow == true) // base 保留
        #expect(merged?.zoom?.scale == 200) // additional 覆盖
        #expect(merged?.dataRange?.startRow == 1) // base 保留
    }

    @Test("Borders merge")
    func bordersMerge() {
        var baseStyle = SheetStyle()
        baseStyle.borders = [
            SheetStyle.BorderRegion(startRow: 1, startColumn: 1, endRow: 5, endColumn: 5, border: Border.all(style: .thin)),
        ]

        var additionalStyle = SheetStyle()
        additionalStyle.borders = [
            SheetStyle.BorderRegion(startRow: 6, startColumn: 6, endRow: 10, endColumn: 10, border: Border.all(style: .thick)),
        ]

        let merged = SheetStyle.merge(base: baseStyle, additional: additionalStyle)

        #expect(merged?.borders.count == 2) // 累加
        #expect(merged?.borders[0].border == Border.all(style: .thin))
        #expect(merged?.borders[1].border == Border.all(style: .thick))
    }

    @Test("CellStyle properties merge")
    func cellStylePropertiesMerge() {
        var baseStyle = SheetStyle()
        baseStyle.columnHeaderStyle = CellStyle(fill: Fill.solid(Color.red))
        baseStyle.columnBodyStyle = CellStyle(fill: Fill.solid(Color.green))

        var additionalStyle = SheetStyle()
        additionalStyle.columnHeaderStyle = CellStyle(fill: Fill.solid(Color.blue))

        let merged = SheetStyle.merge(base: baseStyle, additional: additionalStyle)

        #expect(merged?.columnHeaderStyle?.fill == Fill.solid(Color.blue)) // additional 覆盖
        #expect(merged?.columnBodyStyle?.fill == Fill.solid(Color.green)) // base 保留
    }
}
