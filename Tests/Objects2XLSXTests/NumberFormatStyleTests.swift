//
// NumberFormatStyleTests.swift
//
// General as Excel's built-in format.

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
}
