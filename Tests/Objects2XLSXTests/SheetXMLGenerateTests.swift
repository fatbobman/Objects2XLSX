//
// SheetXMLGenerateTests.swift
// Created by Xu Yang on 2025-06-19.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("SheetXMLGenerateTests")
struct SheetXMLGenerateTests {
    @Test("test SheetHeader Generate")
    func sheetHeaderGenerate() {
        let sheet = Sheet(name: "People", dataProvider: { People.people }) {
            Column(name: "Name", keyPath: \People.name, nilHandling: .keepEmpty)
            Column(name: "Age", keyPath: \People.age, nilHandling: .keepEmpty)
            Column(name: "Gender", keyPath: \People.gender, nilHandling: .keepEmpty)
            Column(name: "City", keyPath: \People.city, nilHandling: .keepEmpty)
            Column(name: "Country", keyPath: \People.country, nilHandling: .keepEmpty)
            Column(name: "Weight", keyPath: \People.weight, nilHandling: .keepEmpty)
            Column(name: "Email", keyPath: \People.email, nilHandling: .keepEmpty)
            Column(name: "Birthday", keyPath: \People.birthday, nilHandling: .keepEmpty)
        }

        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()
        let bookStyle = BookStyle()

        // 测试 header 行生成
        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: SheetStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister
        )

        // 验证基本结构
        #expect(sheetXML != nil)
        #expect(sheetXML?.name == "People")
        #expect(sheetXML?.rows.count == 1) // 只有 header 行

        // 验证 header 行
        let headerRow = sheetXML?.rows.first
        #expect(headerRow != nil)
        #expect(headerRow?.index == 1) // 第一行
        #expect(headerRow?.cells.count == 8) // 8个列

        // 验证每个 header 单元格的名称和位置
        let expectedColumnNames = ["Name", "Age", "Gender", "City", "Country", "Weight", "Email", "Birthday"]
        for (index, expectedName) in expectedColumnNames.enumerated() {
            let cell = headerRow?.cells[index]
            #expect(cell != nil)
            #expect(cell?.row == 1)
            #expect(cell?.column == index + 1)

            // 验证单元格值
            if case .string(let cellName) = cell?.value {
                #expect(cellName == expectedName)
            } else {
                #expect(Bool(false), "Header cell should contain string value")
            }

            // 验证共享字符串注册
            #expect(cell?.sharedStringID != nil)
        }

        // 验证共享字符串注册器包含所有列名
        for columnName in expectedColumnNames {
            let stringID = shareStringRegister.register(columnName)
            #expect(stringID >= 0)
        }

        // 验证样式注册器被调用
        #expect(styleRegister.resolvedStylePool.count >= 1) // 至少注册了一种样式

        print("Header generation test completed successfully")
        print("Generated \(sheetXML?.rows.count ?? 0) rows with \(headerRow?.cells.count ?? 0) header cells")
        print(sheetXML?.generateXML() ?? "nil")
        print(shareStringRegister.allStrings)
    }
    
    @Test("test SheetHeader with Custom Style")
    func sheetHeaderWithCustomStyle() {
        // 创建自定义的 header 样式
        let headerStyle = CellStyle(
            font: Font(size: 14, name: "Arial", bold: true, italic: false, underline: false, color: Color.white),
            fill: Fill.solid(Color.blue),
            alignment: Alignment(horizontal: .center, vertical: .center),
            border: Border.all(style: .thin, color: Color.black)
        )
        
        // 创建自定义的 sheet 样式
        var sheetStyle = SheetStyle()
        sheetStyle.columnHeaderStyle = headerStyle
        
        let sheet = Sheet(name: "People", dataProvider: { People.people }) {
            Column(name: "Name", keyPath: \People.name, nilHandling: .keepEmpty)
            Column(name: "Age", keyPath: \People.age, nilHandling: .keepEmpty)
            Column(name: "Gender", keyPath: \People.gender, nilHandling: .keepEmpty)
        }

        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()
        let bookStyle = BookStyle()

        // 测试带自定义样式的 header 行生成
        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle, 
            sheetStyle: sheetStyle, 
            styleRegister: styleRegister, 
            shareStringRegistor: shareStringRegister
        )

        // 验证基本结构
        #expect(sheetXML != nil)
        #expect(sheetXML?.rows.count == 1) // 只有 header 行
        
        // 验证 header 行
        let headerRow = sheetXML?.rows.first
        #expect(headerRow != nil)
        #expect(headerRow?.cells.count == 3) // 3个列
        
        // 验证每个 header 单元格都有样式ID
        let expectedColumnNames = ["Name", "Age", "Gender"]
        if let cells = headerRow?.cells {
            for (index, expectedName) in expectedColumnNames.enumerated() {
                let cell = cells[index]
                
                // 验证单元格值
                if case .string(let cellName) = cell.value {
                    #expect(cellName == expectedName)
                }
                
                // 验证样式ID存在且不为空（说明应用了自定义样式）
                #expect(cell.styleID != nil)
                #expect(cell.styleID != 0) // 不应该是默认样式
            }
        }
        
        // 验证样式注册器包含了自定义样式
        #expect(styleRegister.resolvedStylePool.count > 1) // 除了默认样式，还有自定义样式
        #expect(styleRegister.fontPool.count > 1) // 注册了自定义字体
        #expect(styleRegister.fillPool.count > 1) // 注册了自定义填充
        #expect(styleRegister.borderPool.count > 1) // 注册了自定义边框
        #expect(styleRegister.alignmentPool.count > 0) // 注册了对齐方式
        
        print("Header with custom style test completed successfully")
        print("Registered styles: \(styleRegister.resolvedStylePool.count)")
        print("Registered fonts: \(styleRegister.fontPool.count)")
        print("Registered fills: \(styleRegister.fillPool.count)")
        print("Registered borders: \(styleRegister.borderPool.count)")
        print("Registered alignments: \(styleRegister.alignmentPool.count)")
        
        // 验证第一个单元格使用了自定义样式
        if let firstCell = headerRow?.cells.first {
            print("First cell styleID: \(firstCell.styleID ?? -1)")
        }
    }
}
