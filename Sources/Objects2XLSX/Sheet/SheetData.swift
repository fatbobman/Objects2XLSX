//
// SheetData.swift
// Created by Xu Yang on 2025-06-07.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct SheetXML {
    /// 工作表名称（移除非法字符，并不超过 31 个字符）
    public let name: String

    /// 所有行
    public let rows: [Row]

    /// 工作表样式设置
    public let style: SheetStyle?

    public init(name: String, rows: [Row], style: SheetStyle? = nil) {
        self.name = name
        self.rows = rows
        self.style = style
    }

    /// 生成完整的 sheet XML
    public func generateXML() -> String {
        var xml = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
            """

        // 添加 tabColor 属性（如果有）
        if let style, let tabColor = style.tabColor {
            xml += " tabColor=\"\(tabColor.hexString)\""
        }

        xml += ">"

        // 生成其他 XML 内容
        xml += generateWorksheetContent()

        xml += "</worksheet>"
        return xml
    }

    /// 生成工作表内容（不包括根元素属性）
    private func generateWorksheetContent() -> String {
        var xml = ""

        // 添加工作表格式设置（可选）
        if let style {
            xml += generateSheetFormatXML(style)
        }

        // 添加列设置（可选）
        if let style, !style.columnWidths.isEmpty {
            xml += generateColumnsXML(style)
        }

        // 添加冻结窗格设置（可选）
        if let style, let freezePanes = style.freezePanes {
            xml += generateFreezePanesXML(freezePanes)
        }

        // 添加工作表数据
        xml += "<sheetData>"
        for row in rows {
            xml += row.generateXML()
        }
        xml += "</sheetData>"

        return xml
    }

    /// 生成工作表格式 XML
    private func generateSheetFormatXML(_ style: SheetStyle) -> String {
        var xml = "<sheetFormatPr"

        if let defaultRowHeight = style.defaultRowHeight {
            xml += " defaultRowHeight=\"\(defaultRowHeight)\""
        }

        if let defaultColumnWidth = style.defaultColumnWidth {
            xml += " defaultColWidth=\"\(defaultColumnWidth)\""
        }

        xml += "/>"

        // 添加网格线设置
        if !style.showGridlines {
            xml += "<sheetViews><sheetView workbookViewId=\"0\" showGridLines=\"0\"/></sheetViews>"
        }

        return xml
    }

    /// 生成列设置 XML
    private func generateColumnsXML(_ style: SheetStyle) -> String {
        var xml = "<cols>"

        for (index, columnWidth) in style.columnWidths.sorted(by: { $0.key < $1.key }) {
            xml += "<col min=\"\(index + 1)\" max=\"\(index + 1)\" width=\"\(columnWidth.width)\" customWidth=\"1\"/>"
        }

        xml += "</cols>"
        return xml
    }

    /// 生成冻结窗格 XML
    private func generateFreezePanesXML(_ freezePanes: SheetStyle.FreezePanes) -> String {
        var xml = "<sheetViews><sheetView workbookViewId=\"0\""

        // 添加缩放设置
        if let zoom = style?.zoom {
            xml += " zoomScale=\"\(zoom.scale)\""
        }

        xml += ">"

        if freezePanes.freezeTopRow {
            xml += "<pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/>"
        } else if freezePanes.freezeFirstColumn {
            xml += "<pane xSplit=\"1\" topLeftCell=\"B1\" activePane=\"topRight\" state=\"frozen\"/>"
        } else if freezePanes.frozenRows > 0 || freezePanes.frozenColumns > 0 {
            let topLeftCell = "\(columnIndexToExcelColumn(freezePanes.frozenColumns))\(freezePanes.frozenRows + 1)"
            xml += "<pane xSplit=\"\(freezePanes.frozenColumns)\" ySplit=\"\(freezePanes.frozenRows)\" topLeftCell=\"\(topLeftCell)\" activePane=\"topLeft\" state=\"frozen\"/>"
        }

        xml += "</sheetView></sheetViews>"
        return xml
    }
}
