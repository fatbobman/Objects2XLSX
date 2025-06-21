//
// CellValueStringEnhancementsTests.swift
// Tests for enhanced CellValueString methods
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("CellValueString Enhancements Tests")
struct CellValueStringEnhancementsTests {
    // MARK: - String type tests

    @Test("String cellValueString with XML escaping")
    func stringCellValueString() throws {
        // Test non-optional string
        let normalString = "Hello World"
        #expect(normalString.cellValueString == "Hello World", "Normal string should be unchanged")

        let xmlString = "Test & <Demo>"
        #expect(xmlString.cellValueString == "Test &amp; &lt;Demo&gt;", "XML characters should be escaped")

        let quotesString = "She said \"Hello\" and 'Goodbye'"
        #expect(quotesString.cellValueString.contains("&quot;"), "Double quotes should be escaped")
        #expect(quotesString.cellValueString.contains("&apos;"), "Single quotes should be escaped")
    }

    @Test("Optional String cellValueString")
    func optionalStringCellValueString() throws {
        let nilString: String? = nil
        #expect(nilString.cellValueString == "", "nil string should return empty")

        let someString: String? = "Test & Demo"
        #expect(someString.cellValueString == "Test &amp; Demo", "Optional string should be escaped")
    }

    // MARK: - Double type tests

    @Test("Double cellValueString with edge cases")
    func doubleCellValueString() throws {
        let normal = 123.456
        #expect(normal.cellValueString == "123.456", "Normal double should convert to string")

        let infinity = Double.infinity
        #expect(infinity.cellValueString == "", "Infinity should return empty string")

        let negInfinity = -Double.infinity
        #expect(negInfinity.cellValueString == "", "Negative infinity should return empty string")

        let nan = Double.nan
        #expect(nan.cellValueString == "", "NaN should return empty string")

        let zero = 0.0
        #expect(zero.cellValueString == "0.0", "Zero should convert normally")

        let negative = -123.456
        #expect(negative.cellValueString == "-123.456", "Negative should convert normally")
    }

    @Test("Double cellValueString with precision")
    func doubleCellValueStringWithPrecision() throws {
        let value = 0.123456789

        // Test different precisions
        #expect(value.cellValueString(precision: 0) == "0.12", "Precision 0 should give 2 decimal places")
        #expect(value.cellValueString(precision: 1) == "0.123", "Precision 1 should give 3 decimal places")
        #expect(value.cellValueString(precision: 2) == "0.1235", "Precision 2 should give 4 decimal places with rounding")
        #expect(value.cellValueString(precision: 3) == "0.12346", "Precision 3 should give 5 decimal places with rounding")

        // Test edge cases with precision
        let infinity = Double.infinity
        #expect(infinity.cellValueString(precision: 2) == "", "Infinity with precision should return empty")

        let nan = Double.nan
        #expect(nan.cellValueString(precision: 2) == "", "NaN with precision should return empty")
    }

    @Test("Optional Double cellValueString")
    func optionalDoubleCellValueString() throws {
        let nilDouble: Double? = nil
        #expect(nilDouble.cellValueString == "", "nil double should return empty")

        let someDouble: Double? = 123.456
        #expect(someDouble.cellValueString == "123.456", "Optional double should convert")

        let someInfinity: Double? = Double.infinity
        #expect(someInfinity.cellValueString == "", "Optional infinity should return empty")

        // With precision
        let someValue: Double? = 0.123456
        #expect(someValue.cellValueString(precision: 2) == "0.1235", "Optional double with precision should work")

        let nilWithPrecision: Double? = nil
        #expect(nilWithPrecision.cellValueString(precision: 2) == "", "nil with precision should return empty")
    }

    // MARK: - Int type tests

    @Test("Int cellValueString")
    func intCellValueString() throws {
        let positive = 123
        #expect(positive.cellValueString == "123", "Positive int should convert")

        let negative = -456
        #expect(negative.cellValueString == "-456", "Negative int should convert")

        let zero = 0
        #expect(zero.cellValueString == "0", "Zero should convert")

        let maxInt = Int.max
        #expect(maxInt.cellValueString == String(Int.max), "Max int should convert")
    }

    @Test("Optional Int cellValueString")
    func optionalIntCellValueString() throws {
        let nilInt: Int? = nil
        #expect(nilInt.cellValueString == "", "nil int should return empty")

        let someInt: Int? = 789
        #expect(someInt.cellValueString == "789", "Optional int should convert")
    }

    // MARK: - Bool type tests

    @Test("Bool cellValueString with different expressions")
    func boolCellValueString() throws {
        let trueValue = true
        let falseValue = false

        // Test default (oneAndZero + upper)
        #expect(trueValue.cellValueString() == "1", "True should be '1' by default")
        #expect(falseValue.cellValueString() == "0", "False should be '0' by default")

        // Test yesAndNo with different cases
        #expect(trueValue.cellValueString(booleanExpressions: .yesAndNo, caseStrategy: .upper) == "YES", "True should be 'YES'")
        #expect(falseValue.cellValueString(booleanExpressions: .yesAndNo, caseStrategy: .lower) == "no", "False should be 'no'")
        #expect(trueValue.cellValueString(booleanExpressions: .yesAndNo, caseStrategy: .firstLetterUpper) == "Yes", "True should be 'Yes'")

        // Test trueAndFalse
        #expect(trueValue.cellValueString(booleanExpressions: .trueAndFalse, caseStrategy: .upper) == "TRUE", "True should be 'TRUE'")
        #expect(falseValue.cellValueString(booleanExpressions: .trueAndFalse, caseStrategy: .lower) == "false", "False should be 'false'")

        // Test custom with XML characters
        let customTrue = trueValue.cellValueString(
            booleanExpressions: .custom(true: "Yes & Active", false: "No & Inactive"),
            caseStrategy: .upper)
        #expect(customTrue == "YES &amp; ACTIVE", "Custom boolean strings should be XML escaped and uppercased")
    }

    @Test("Optional Bool cellValueString")
    func optionalBoolCellValueString() throws {
        let nilBool: Bool? = nil
        #expect(nilBool.cellValueString() == "", "nil bool should return empty")

        let someTrue: Bool? = true
        #expect(someTrue.cellValueString() == "1", "Optional true should be '1'")

        let someFalse: Bool? = false
        #expect(someFalse.cellValueString(booleanExpressions: .yesAndNo, caseStrategy: .upper) == "NO", "Optional false should be 'NO'")
    }

    // MARK: - URL type tests

    @Test("URL cellValueString with XML escaping")
    func urlCellValueString() throws {
        let simpleURL = URL(string: "https://example.com")!
        #expect(simpleURL.cellValueString == "https://example.com", "Simple URL should be unchanged")

        let complexURL = URL(string: "https://example.com/path?param1=value&param2=<test>")!
        // URL special characters get URL-encoded by URL.absoluteString, then XML-escaped
        #expect(complexURL.cellValueString == "https://example.com/path?param1=value&amp;param2=%3Ctest%3E", "URL with special characters should be URL encoded then XML escaped")

        let urlWithQuotes = URL(string: "https://example.com/search?q=\"hello\"")!
        // Quotes get URL-encoded to %22 by URL.absoluteString
        #expect(urlWithQuotes.cellValueString == "https://example.com/search?q=%22hello%22", "URL with quotes should be URL encoded")
    }

    @Test("Optional URL cellValueString")
    func optionalURLCellValueString() throws {
        let nilURL: URL? = nil
        #expect(nilURL.cellValueString == "", "nil URL should return empty")

        let someURL: URL? = URL(string: "https://example.com?test=1&other=2")
        #expect(someURL?.cellValueString == "https://example.com?test=1&amp;other=2", "Optional URL should be escaped")
    }

    // MARK: - Integration with Cell.CellType

    @Test("Cell.CellType valueString uses cellValueString methods")
    func cellTypeValueStringIntegration() throws {
        // Test that Cell.CellType.valueString properly delegates to cellValueString

        // String
        let stringCell = Cell.CellType.stringValue("Test & Demo")
        #expect(stringCell.valueString == "Test &amp; Demo", "CellType should use string.cellValueString")

        // Double
        let doubleCell = Cell.CellType.doubleValue(Double.infinity)
        #expect(doubleCell.valueString == "", "CellType should use double.cellValueString")

        // Int
        let intCell = Cell.CellType.intValue(42)
        #expect(intCell.valueString == "42", "CellType should use int.cellValueString")

        // Bool
        let boolCell = Cell.CellType.booleanValue(true, booleanExpressions: .yesAndNo, caseStrategy: .upper)
        #expect(boolCell.valueString == "YES", "CellType should use bool.cellValueString")

        // URL
        let urlCell = Cell.CellType.urlValue(URL(string: "https://example.com?a=1&b=2")!)
        #expect(urlCell.valueString == "https://example.com?a=1&amp;b=2", "CellType should use url.cellValueString")

        // Percentage
        let percentCell = Cell.CellType.percentageValue(0.12345, precision: 2)
        #expect(percentCell.valueString == "0.1235", "CellType should use percentage cellValueString")
    }
}
