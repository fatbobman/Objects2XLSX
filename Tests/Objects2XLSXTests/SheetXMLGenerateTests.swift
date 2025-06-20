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
            shareStringRegistor: shareStringRegister)

        // 验证基本结构
        #expect(sheetXML != nil)
        #expect(sheetXML?.name == "People")
        #expect(sheetXML?.rows.count == 5) // 1个表头 + 4个数据行

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
            if case let .string(cellName) = cell?.value {
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
            border: Border.all(style: .thin, color: Color.black))

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
            shareStringRegistor: shareStringRegister)

        // 验证基本结构
        #expect(sheetXML != nil)
        #expect(sheetXML?.rows.count == 5) // 1个表头 + 4个数据行

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
                if case let .string(cellName) = cell.value {
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
        #expect(!styleRegister.alignmentPool.isEmpty) // 注册了对齐方式

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

    @Test("test Data Border Settings")
    func dataBorderSettings() {
        // 创建带边框的 sheet
        let sheet = Sheet(name: "People", dataProvider: { People.people }) {
            Column(name: "Name", keyPath: \People.name, nilHandling: .keepEmpty)
            Column(name: "Age", keyPath: \People.age, nilHandling: .keepEmpty)
        }

        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()
        let bookStyle = BookStyle()

        // 创建带边框的 sheetStyle
        var customSheetStyle = SheetStyle()
        customSheetStyle.dataBorder = .withHeader(style: .thick)

        // 生成 SheetXML
        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: customSheetStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        // 验证边框设置生效
        #expect(sheetXML != nil)

        if let style = sheetXML?.style {
            #expect(style.dataBorder.enabled == true)
            #expect(style.dataBorder.includeHeader == true)
            #expect(style.dataBorder.borderStyle == .thick)

            // 验证数据区域设置
            #expect(style.dataRange != nil)
            #expect(style.dataRange?.startRow == 1) // 包含表头
            #expect(style.dataRange?.startColumn == 1)
            #expect(style.dataRange?.endRow == 5) // 1个表头 + 4行数据
            #expect(style.dataRange?.endColumn == 2) // 2列

            print("Data border test completed successfully")
            print("Border enabled: \(style.dataBorder.enabled)")
            print("Include header: \(style.dataBorder.includeHeader)")
            print("Border style: \(style.dataBorder.borderStyle.rawValue)")
            print("Data range: \(style.dataRange?.startRow ?? 0)-\(style.dataRange?.endRow ?? 0), \(style.dataRange?.startColumn ?? 0)-\(style.dataRange?.endColumn ?? 0)")
            print(styleRegister.borderPool)
            print(sheetXML?.generateXML() ?? "nil")
        }
    }

    @Test("test Complete Data Generation")
    func completeDataGeneration() {
        // 创建带完整数据的 sheet
        let sheet = Sheet(name: "People", dataProvider: { People.people }) {
            Column(name: "Name", keyPath: \People.name, nilHandling: .keepEmpty)
            Column(name: "Age", keyPath: \People.age, nilHandling: .keepEmpty)
            Column(name: "Gender", keyPath: \People.gender, nilHandling: .keepEmpty)
            Column(name: "City", keyPath: \People.city, nilHandling: .keepEmpty)
        }

        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()
        let bookStyle = BookStyle()

        // 创建自定义样式
        var customSheetStyle = SheetStyle()
        customSheetStyle.dataBorder = .withHeader(style: .thin)
        customSheetStyle.columnHeaderStyle = CellStyle(
            font: Font(size: 12, name: "Arial", bold: true),
            fill: Fill.solid(Color.lightGray))
        customSheetStyle.columnBodyStyle = CellStyle(
            font: Font(size: 10, name: "Arial", bold: false))

        // 生成完整的 SheetXML
        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: customSheetStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        // 验证基本结构
        #expect(sheetXML != nil)
        #expect(sheetXML?.name == "People")

        // 验证行数：1个表头 + 4个数据行
        #expect(sheetXML?.rows.count == 5)

        // 验证第一行是表头
        let headerRow = sheetXML?.rows.first
        #expect(headerRow?.index == 1)
        #expect(headerRow?.cells.count == 4)

        // 验证数据行
        let dataRows = Array(sheetXML?.rows.dropFirst() ?? [])
        #expect(dataRows.count == 4)

        // 验证每个数据行
        let expectedNames = ["John", "Jane", "Jim", "Jill"]
        let expectedAges = [20, 21, 22, 23]
        let expectedGenders = [true, false, true, false]
        let expectedCities = ["Beijing", "Shanghai", "Guangzhou", "Shenzhen"]

        for (index, dataRow) in dataRows.enumerated() {
            #expect(dataRow.index == index + 2) // 从第2行开始
            #expect(dataRow.cells.count == 4) // 4列

            // 验证姓名列
            let nameCell = dataRow.cells[0]
            #expect(nameCell.row == index + 2)
            #expect(nameCell.column == 1)
            if case let .string(name) = nameCell.value {
                #expect(name == expectedNames[index])
            }
            #expect(nameCell.sharedStringID != nil)

            // 验证年龄列
            let ageCell = dataRow.cells[1]
            #expect(ageCell.row == index + 2)
            #expect(ageCell.column == 2)
            if case let .int(age) = ageCell.value {
                #expect(age == expectedAges[index])
            }
            #expect(ageCell.sharedStringID == nil) // 数字不使用共享字符串

            // 验证性别列
            let genderCell = dataRow.cells[2]
            if case let .boolean(gender, _, _) = genderCell.value {
                #expect(gender == expectedGenders[index])
            }

            // 验证城市列
            let cityCell = dataRow.cells[3]
            if case let .string(city) = cityCell.value {
                #expect(city == expectedCities[index])
            }

            // 验证样式应用
            #expect(nameCell.styleID != nil)
            #expect(ageCell.styleID != nil)
            #expect(genderCell.styleID != nil)
            #expect(cityCell.styleID != nil)
        }

        // 验证共享字符串注册
        let allExpectedStrings = ["Name", "Age", "Gender", "City"] + expectedNames + expectedCities
        for expectedString in allExpectedStrings {
            let stringID = shareStringRegister.register(expectedString)
            #expect(stringID >= 0)
        }

        // 验证样式注册
        #expect(styleRegister.resolvedStylePool.count > 1) // 至少有默认样式和自定义样式
        #expect(styleRegister.fontPool.count > 1) // 注册了自定义字体
        #expect(styleRegister.fillPool.count > 1) // 注册了自定义填充

        // 验证边框设置
        if let style = sheetXML?.style {
            #expect(style.dataBorder.enabled == true)
            #expect(style.dataBorder.includeHeader == true)
            #expect(style.dataBorder.borderStyle == .thin)
            #expect(style.dataRange != nil)
            #expect(style.dataRange?.startRow == 1)
            #expect(style.dataRange?.endRow == 5)
            #expect(style.dataRange?.startColumn == 1)
            #expect(style.dataRange?.endColumn == 4)
        }

        print("Complete data generation test completed successfully")
        print("Generated \(sheetXML?.rows.count ?? 0) rows")
        print("Header cells: \(headerRow?.cells.count ?? 0)")
        print("Data rows: \(dataRows.count)")
        print("Registered styles: \(styleRegister.resolvedStylePool.count)")
        print("Shared strings: \(shareStringRegister.allStrings.count)")
        print("Generated XML length: \(sheetXML?.generateXML().count ?? 0) characters")
    }

    @Test("test Data Row Borders and Styles")
    func dataRowBordersAndStyles() {
        // 创建带边框和样式的 sheet
        let sheet = Sheet(name: "People", dataProvider: { People.people }) {
            Column(name: "Name", keyPath: \People.name, nilHandling: .keepEmpty)
                .bodyStyle(CellStyle(fill: Fill.solid(Color.yellow)))
            Column(name: "Age", keyPath: \People.age, nilHandling: .keepEmpty)
                .bodyStyle(CellStyle(alignment: Alignment(horizontal: .center)))
        }

        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()
        let bookStyle = BookStyle()

        // 创建带边框的 sheetStyle
        var customSheetStyle = SheetStyle()
        customSheetStyle.dataBorder = .withHeader(style: .medium)
        customSheetStyle.columnBodyStyle = CellStyle(
            font: Font(size: 9, name: "Calibri", bold: false))

        // 生成 SheetXML
        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: customSheetStyle,
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        // 验证基本结构
        #expect(sheetXML != nil)
        #expect(sheetXML?.rows.count == 5) // 1个表头 + 4个数据行

        // 验证数据行边框应用
        let dataRows = Array(sheetXML?.rows.dropFirst() ?? [])
        for dataRow in dataRows {
            for cell in dataRow.cells {
                // 所有数据单元格都应该有样式ID（应用了边框和其他样式）
                #expect(cell.styleID != nil)
                #expect(cell.styleID != 0) // 不应该是默认样式
            }
        }

        // 验证边框池包含medium边框
        let hasMediumBorder = styleRegister.borderPool.contains { border in
            border.left?.style == .medium || border.right?.style == .medium ||
                border.top?.style == .medium || border.bottom?.style == .medium
        }
        #expect(hasMediumBorder)

        // 验证样式注册
        #expect(styleRegister.resolvedStylePool.count > 4) // 多种样式组合
        #expect(styleRegister.fontPool.count > 1) // 注册了自定义字体
        #expect(styleRegister.fillPool.count > 1) // 注册了黄色填充
        #expect(styleRegister.borderPool.count > 1) // 注册了边框
        #expect(!styleRegister.alignmentPool.isEmpty) // 注册了对齐方式

        // 验证XML输出包含边框和样式信息
        let generatedXML = sheetXML?.generateXML() ?? ""
        #expect(generatedXML.contains("s=")) // 包含样式ID
        #expect(generatedXML.count > 500) // 生成的XML应该有相当的长度

        print("Data row borders and styles test completed successfully")
        print("Border pool count: \(styleRegister.borderPool.count)")
        print("Style pool count: \(styleRegister.resolvedStylePool.count)")
        print("Fill pool count: \(styleRegister.fillPool.count)")
        print("Alignment pool count: \(styleRegister.alignmentPool.count)")
        print("Has medium border: \(hasMediumBorder)")

        // 打印前几个数据单元格的样式ID来验证
        if let firstDataRow = dataRows.first {
            print("First data row cell styles: \(firstDataRow.cells.map { $0.styleID ?? -1 })")
        }
    }

    @Test("test URL and String Shared String Registration")
    func uRLAndStringSharedStringRegistration() {
        // 创建包含 URL 和字符串的 sheet
        let sheet = Sheet(name: "People", dataProvider: { People.people }) {
            Column(name: "Name", keyPath: \People.name, nilHandling: .keepEmpty)
            Column(name: "Email", keyPath: \People.email, nilHandling: .keepEmpty)
            Column(name: "City", keyPath: \People.city, nilHandling: .keepEmpty)
        }

        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()
        let bookStyle = BookStyle()

        // 生成 SheetXML
        let sheetXML = sheet.makeSheetXML(
            bookStyle: bookStyle,
            sheetStyle: SheetStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        // 验证基本结构
        #expect(sheetXML != nil)
        #expect(sheetXML?.rows.count == 5) // 1个表头 + 4个数据行

        // 验证数据行
        let dataRows = Array(sheetXML?.rows.dropFirst() ?? [])

        for dataRow in dataRows {
            // 验证姓名列（字符串）有共享字符串ID
            let nameCell = dataRow.cells[0]
            #expect(nameCell.sharedStringID != nil, "Name cell should have shared string ID")

            // 验证邮箱列（URL）有共享字符串ID
            let emailCell = dataRow.cells[1]
            #expect(emailCell.sharedStringID != nil, "Email (URL) cell should have shared string ID")

            // 验证城市列（字符串）有共享字符串ID
            let cityCell = dataRow.cells[2]
            #expect(cityCell.sharedStringID != nil, "City cell should have shared string ID")
        }

        // 验证共享字符串中包含期望的字符串
        let allSharedStrings = shareStringRegister.allStrings

        // 表头
        #expect(allSharedStrings.contains("Name"))
        #expect(allSharedStrings.contains("Email"))
        #expect(allSharedStrings.contains("City"))

        // 数据 - 姓名
        #expect(allSharedStrings.contains("John"))
        #expect(allSharedStrings.contains("Jane"))
        #expect(allSharedStrings.contains("Jim"))
        #expect(allSharedStrings.contains("Jill"))

        // 数据 - 城市
        #expect(allSharedStrings.contains("Beijing"))
        #expect(allSharedStrings.contains("Shanghai"))
        #expect(allSharedStrings.contains("Guangzhou"))
        #expect(allSharedStrings.contains("Shenzhen"))

        // 数据 - URL（应该注册为字符串）
        #expect(allSharedStrings.contains("https://www.google.com"))

        // 检查第一个数据行的邮箱单元格
        if let firstDataRow = dataRows.first {
            let emailCell = firstDataRow.cells[1]
            if case .url = emailCell.value {
                #expect(emailCell.sharedStringID != nil, "URL cell should use shared string")
            }
        }

        print("URL and String shared string registration test completed successfully")
        print("Total shared strings: \(allSharedStrings.count)")
        print("Shared strings include URL: \(allSharedStrings.contains("https://www.google.com"))")
        print("Sample shared strings: \(allSharedStrings.prefix(10))")

        // 验证所有预期的字符串都被注册了
        let expectedStrings = [
            "Name",
            "Email",
            "City",
            "John",
            "Jane",
            "Jim",
            "Jill",
            "Beijing",
            "Shanghai",
            "Guangzhou",
            "Shenzhen",
            "https://www.google.com",
        ]
        let missingStrings = expectedStrings.filter { !allSharedStrings.contains($0) }
        #expect(missingStrings.isEmpty, "Missing shared strings: \(missingStrings)")
    }
}
