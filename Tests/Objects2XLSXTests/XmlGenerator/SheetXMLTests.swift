//
// SheetXMLTests.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Sheet XML Test")
struct SheetXMLTest {
    @Test("Basic sheet XML without style")
    func basicSheetXML() throws {
        let sheetXML = SheetXML(name: "TestSheet", rows: [])
        let xml = sheetXML.generateXML()

        // 验证基本结构
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"))
        #expect(xml.contains("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">"))
        #expect(xml.contains("<sheetData>"))
        #expect(xml.contains("</sheetData>"))
        #expect(xml.contains("</worksheet>"))

        // 验证不包含其他可选元素
        #expect(!xml.contains("<sheetFormatPr"))
        #expect(!xml.contains("<cols>"))
        #expect(!xml.contains("<sheetViews>"))
    }

    @Test("Sheet XML with sheet format properties")
    func sheetXMLWithSheetFormat() throws {
        let style = SheetStyle()
            .defaultRowHeight(20.0)
            .defaultColumnWidth(10.0)
        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        #expect(xml.contains("<sheetFormatPr defaultRowHeight=\"20.0\" defaultColWidth=\"10.0\"/>"))
    }

    @Test("Sheet XML with column widths")
    func sheetXMLWithColumnWidths() throws {
        var style = SheetStyle()
        style.setColumnWidth(SheetStyle.ColumnWidth(width: 15.0, unit: .points, isCustomWidth: true), at: 1)
        style.setColumnWidth(SheetStyle.ColumnWidth(width: 20.0, unit: .points, isCustomWidth: true), at: 3)

        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        #expect(xml.contains("<cols>"))
        #expect(xml.contains("<col min=\"1\" max=\"1\" width=\"15.0\" customWidth=\"1\"/>"))
        #expect(xml.contains("<col min=\"3\" max=\"3\" width=\"20.0\" customWidth=\"1\"/>"))
        #expect(xml.contains("</cols>"))
    }

    @Test("Sheet XML with freeze top row")
    func sheetXMLWithFreezeTopRow() throws {
        let style = SheetStyle().freezePanes(.freezeTopRow())
        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        #expect(xml.contains("<sheetViews>"))
        #expect(xml.contains("<sheetView workbookViewId=\"0\">"))
        #expect(xml.contains("<pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/>"))
        #expect(xml.contains("</sheetView>"))
        #expect(xml.contains("</sheetViews>"))
    }

    @Test("Sheet XML with freeze first column")
    func sheetXMLWithFreezeFirstColumn() throws {
        let style = SheetStyle().freezePanes(.freezeFirstColumn())
        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        #expect(xml.contains("<pane xSplit=\"1\" topLeftCell=\"B1\" activePane=\"topRight\" state=\"frozen\"/>"))
    }

    @Test("Sheet XML with custom freeze panes")
    func sheetXMLWithCustomFreezePanes() throws {
        let style = SheetStyle().freezePanes(.freeze(rows: 3, columns: 2))
        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        #expect(xml.contains("<pane xSplit=\"2\" ySplit=\"3\" topLeftCell=\"C4\" activePane=\"topLeft\" state=\"frozen\"/>"))
    }

    @Test("Sheet XML with zoom")
    func sheetXMLWithZoom() throws {
        let style = SheetStyle()
            .freezePanes(.freezeTopRow())
            .zoom(.custom(150))
        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        #expect(xml.contains("zoomScale=\"150\""))
    }

    @Test("Sheet XML with hidden gridlines")
    func sheetXMLWithHiddenGridlines() throws {
        let style = SheetStyle().showGridlines(false)
        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        #expect(xml.contains("<sheetViews><sheetView workbookViewId=\"0\" showGridLines=\"0\"/></sheetViews>"))
    }

    @Test("Sheet XML with hidden gridlines and freeze panes")
    func sheetXMLWithHiddenGridAndFreeze() throws {
        // 设置隐藏网格线和冻结前两列、前三行
        let style = SheetStyle()
            .showGridlines(false)
            .freezePanes(.freeze(rows: 3, columns: 2))
        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        // 检查 sheetView 属性和 pane 子元素
        #expect(xml.contains("<sheetViews><sheetView workbookViewId=\"0\" showGridLines=\"0\">"))
        #expect(xml.contains("<pane xSplit=\"2\" ySplit=\"3\" topLeftCell=\"C4\" activePane=\"topLeft\" state=\"frozen\"/>"))
        #expect(xml.contains("</sheetView></sheetViews>"))
    }

    @Test("Sheet XML with all properties combined")
    func sheetXMLWithAllProperties() throws {
        var style = SheetStyle()
            .defaultRowHeight(18.0)
            .defaultColumnWidth(12.0)
            .showGridlines(false)
            .freezePanes(.freeze(rows: 2, columns: 1))
            .zoom(.custom(120))

        style.setColumnWidth(SheetStyle.ColumnWidth(width: 15.0, unit: .points, isCustomWidth: true), at: 1)

        let sheetXML = SheetXML(name: "TestSheet", rows: [], style: style)
        let xml = sheetXML.generateXML()

        // 验证所有属性都存在
        #expect(xml.contains("<sheetFormatPr defaultRowHeight=\"18.0\" defaultColWidth=\"12.0\"/>"))
        #expect(xml.contains("<cols>"))
        #expect(xml.contains("<col min=\"1\" max=\"1\" width=\"15.0\" customWidth=\"1\"/>"))
        #expect(xml.contains("</cols>"))
        #expect(xml.contains("<sheetViews>"))
        #expect(xml.contains("showGridLines=\"0\""))
        #expect(xml.contains("zoomScale=\"120\""))
        #expect(xml.contains("<pane xSplit=\"1\" ySplit=\"2\" topLeftCell=\"B3\" activePane=\"topLeft\" state=\"frozen\"/>"))
        #expect(xml.contains("</sheetViews>"))
        #expect(xml.contains("<sheetData>"))
        #expect(xml.contains("</sheetData>"))
    }

    @Test("Sheet XML column index to Excel column conversion")
    func testColumnIndexToExcelColumn() throws {
        // 测试列索引转换功能
        let testCases = [
            (0, "A"),
            (1, "B"),
            (25, "Z"),
            (26, "AA"),
            (27, "AB"),
            (701, "ZZ"),
            (702, "AAA")
        ]

        for (index, expected) in testCases {
            let result = columnIndexToExcelColumn(index)
            #expect(result == expected, "Column index \(index) should convert to \(expected), but got \(result)")
        }
    }
}

// 辅助函数：将列索引转换为 Excel 列名
private func columnIndexToExcelColumn(_ index: Int) -> String {
    var result = ""
    var remaining = index

    while remaining >= 0 {
        result = String(Character(UnicodeScalar(65 + (remaining % 26))!)) + result
        remaining = remaining / 26 - 1
    }

    return result
}
