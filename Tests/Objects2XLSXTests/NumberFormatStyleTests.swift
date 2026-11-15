//
// NumberFormatStyleTests.swift
//
// Number formats chosen by a cell style, and General as Excel's built-in format.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Number Format Style Tests")
struct NumberFormatStyleTests {
    /// The cellXfs element for a registered style
    private func xf(_ styleID: Int?, in xml: String) throws -> String {
        let styleID = try #require(styleID)
        let cellXfs = try #require(xml.firstMatch(of: #/<cellXfs count="\d+">(.*?)</cellXfs>/#)).output.1
        let xfs = cellXfs.matches(of: #/<xf [^>]*>/#).map { String($0.output) }
        return try #require(xfs.indices.contains(styleID) ? xfs[styleID] : nil)
    }

    @Test("General is Excel's built-in format 0, with nothing to define")
    func generalIsBuiltin() throws {
        let register = StyleRegister()
        let text = register.registerCellStyle(CellStyle(font: .default), cellType: .stringValue("a"))
        let number = register.registerCellStyle(CellStyle(font: .default), cellType: .doubleValue(1.5))
        let xml = register.generateXML()

        #expect(try xf(text, in: xml).contains(#"numFmtId="0""#))
        #expect(try xf(number, in: xml).contains(#"numFmtId="0""#))
        #expect(!xml.contains("<numFmts"))
        #expect(!xml.contains(#"numFmtId="164""#))
    }

    @Test("A style's number format wins over the one the value implies")
    func styleFormatWins() throws {
        let register = StyleRegister()
        let date = register.registerCellStyle(CellStyle(numberFormat: .date), cellType: .dateValue(Date(), timeZone: .gmt))
        let amount = register.registerCellStyle(CellStyle(numberFormat: .custom("#,##0.00")), cellType: .optionalDouble(nil))
        let plainDate = register.registerCellStyle(CellStyle(), cellType: .dateValue(Date(), timeZone: .gmt))
        let xml = register.generateXML()

        #expect(try xf(date, in: xml).contains(#"numFmtId="14" applyNumberFormat="1""#))
        #expect(try xf(amount, in: xml).contains(#"numFmtId="4" applyNumberFormat="1""#))
        #expect(try xf(plainDate, in: xml).contains(#"numFmtId="22" applyNumberFormat="1""#))
    }

    @Test("Built-in codes use Excel's own numbers; other codes are defined as custom formats")
    func customCodes() throws {
        #expect(NumberFormat.custom("0.00").builtinId == 2)
        #expect(NumberFormat.custom("#,##0").builtinId == 3)
        #expect(NumberFormat.custom("#,##0.00").builtinId == 4)

        let register = StyleRegister()
        let style = register.registerCellStyle(CellStyle(numberFormat: .custom("#,##0.000")), cellType: .doubleValue(1))
        let xml = register.generateXML()
        #expect(try xf(style, in: xml).contains(#"numFmtId="164""#))
        #expect(xml.contains(##"<numFmts count="1"><numFmt numFmtId="164" formatCode="#,##0.000"/></numFmts>"##))
    }

    @Test("Merging keeps a number format unless the higher style sets its own")
    func merging() {
        let sheet = CellStyle(font: .default, numberFormat: .custom("0.00"))
        let column = CellStyle(numberFormat: .custom("#,##0.00"))
        #expect(CellStyle.merge(sheet, CellStyle(fill: .none))?.numberFormat == .custom("0.00"))
        #expect(CellStyle.merge(sheet, column)?.numberFormat == .custom("#,##0.00"))
        #expect(CellStyle.merge(sheet, column)?.font == .default)
    }
}
