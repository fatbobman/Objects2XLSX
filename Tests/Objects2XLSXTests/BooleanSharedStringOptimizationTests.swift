//
// BooleanSharedStringOptimizationTests.swift
// Created by Claude on 2025-06-22.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

/// Tests to verify Boolean SharedString optimization functionality.
///
/// This test suite validates that Boolean values use the optimal storage strategy:
/// - oneAndZero expressions use inline storage (no SharedString benefit)
/// - Multi-character expressions (trueAndFalse, yesAndNo, etc.) use SharedString optimization
struct BooleanSharedStringOptimizationTests {
    struct TestPerson: Sendable {
        let name: String
        let isActive: Bool
        let hasPermission: Bool?
    }

    @Test("oneAndZero expressions should NOT use SharedString")
    func oneAndZeroNoSharedString() throws {
        let people = [
            TestPerson(name: "Alice", isActive: true, hasPermission: true),
            TestPerson(name: "Bob", isActive: false, hasPermission: false),
            TestPerson(name: "Charlie", isActive: true, hasPermission: nil)
        ]

        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { people }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .oneAndZero)
            Column(name: "Permission", keyPath: \.hasPermission, booleanExpressions: .oneAndZero)
        }

        let shareStringRegister = ShareStringRegister()
        let styleRegister = StyleRegister()

        // Generate sheet XML to trigger SharedString registration
        let sheetXML = sheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        // Verify SharedString registration
        let sharedStrings = shareStringRegister.allStrings

        // Should only contain names, not boolean values
        #expect(sharedStrings.contains("Alice"))
        #expect(sharedStrings.contains("Bob"))
        #expect(sharedStrings.contains("Charlie"))
        #expect(!sharedStrings.contains("1"))
        #expect(!sharedStrings.contains("0"))

        print("SharedStrings for oneAndZero: \(sharedStrings)")

        // Verify XML uses boolean type for oneAndZero
        let xml = sheetXML!.generateXML()
        #expect(xml.contains("t=\"b\"")) // Boolean type should be used for oneAndZero

        // Check that boolean cells use inline values (1/0) not SharedString references
        #expect(xml.contains("<c r=\"B2\" t=\"b\"><v>1</v></c>")) // true -> 1
        #expect(xml.contains("<c r=\"B3\" t=\"b\"><v>0</v></c>")) // false -> 0
    }

    @Test("trueAndFalse expressions should use SharedString")
    func trueAndFalseUsesSharedString() throws {
        let people = [
            TestPerson(name: "Alice", isActive: true, hasPermission: true),
            TestPerson(name: "Bob", isActive: false, hasPermission: false),
            TestPerson(name: "Charlie", isActive: true, hasPermission: nil)
        ]

        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { people }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .trueAndFalse)
            Column(name: "Permission", keyPath: \.hasPermission, booleanExpressions: .trueAndFalse)
        }

        let shareStringRegister = ShareStringRegister()
        let styleRegister = StyleRegister()

        // Generate sheet XML to trigger SharedString registration
        let sheetXML = sheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        // Verify SharedString registration
        let sharedStrings = shareStringRegister.allStrings

        // Should contain names AND boolean expressions
        #expect(sharedStrings.contains("Alice"))
        #expect(sharedStrings.contains("Bob"))
        #expect(sharedStrings.contains("Charlie"))
        #expect(sharedStrings.contains("TRUE"))
        #expect(sharedStrings.contains("FALSE"))

        print("SharedStrings for trueAndFalse: \(sharedStrings)")

        // Verify XML uses both types appropriately
        let xml = sheetXML!.generateXML()
        #expect(xml.contains("t=\"s\"")) // SharedString type should be used for boolean cells
    }

    @Test("yesAndNo expressions should use SharedString")
    func yesAndNoUsesSharedString() throws {
        let people = [
            TestPerson(name: "Alice", isActive: true, hasPermission: true),
            TestPerson(name: "Bob", isActive: false, hasPermission: false)
        ]

        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { people }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .yesAndNo, caseStrategy: .upper)
            Column(name: "Permission", keyPath: \.hasPermission, booleanExpressions: .yesAndNo, caseStrategy: .lower)
        }

        let shareStringRegister = ShareStringRegister()
        let styleRegister = StyleRegister()

        // Generate sheet XML
        let sheetXML = sheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        let sharedStrings = shareStringRegister.allStrings

        // Should contain boolean expressions with different cases
        #expect(sharedStrings.contains("YES")) // Upper case
        #expect(sharedStrings.contains("NO")) // Upper case
        #expect(sharedStrings.contains("yes")) // Lower case
        #expect(sharedStrings.contains("no")) // Lower case

        print("SharedStrings for yesAndNo: \(sharedStrings)")
    }

    @Test("tAndF expressions should use SharedString")
    func tAndFUsesSharedString() throws {
        let people = [
            TestPerson(name: "Alice", isActive: true, hasPermission: false)
        ]

        let sheet = Sheet<TestPerson>(name: "People", dataProvider: { people }) {
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .tAndF)
            Column(name: "Permission", keyPath: \.hasPermission, booleanExpressions: .tAndF)
        }

        let shareStringRegister = ShareStringRegister()
        let styleRegister = StyleRegister()

        let sheetXML = sheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        let sharedStrings = shareStringRegister.allStrings

        // Should contain column names AND T/F values
        #expect(sharedStrings.contains("Active"))
        #expect(sharedStrings.contains("Permission"))
        #expect(sharedStrings.contains("T")) // Should use SharedString to ensure correct display
        #expect(sharedStrings.contains("F")) // Should use SharedString to ensure correct display

        print("SharedStrings for tAndF: \(sharedStrings)")

        // Verify XML uses SharedString type for tAndF
        let xml = sheetXML!.generateXML()
        #expect(xml.contains("t=\"s\"")) // SharedString type should be used for tAndF
    }

    @Test("custom expressions should always use SharedString")
    func customExpressionsAlwaysSharedString() throws {
        let people = [
            TestPerson(name: "Alice", isActive: true, hasPermission: false),
            TestPerson(name: "Bob", isActive: false, hasPermission: true)
        ]

        // Test short custom expressions (now use SharedString for Excel compatibility)
        let shortSheet = Sheet<TestPerson>(name: "Short", dataProvider: { people }) {
            Column(
                name: "Active",
                keyPath: \.isActive,
                booleanExpressions: .custom(true: "Y", false: "N"))
        }

        let shortRegister = ShareStringRegister()
        let shortStyleRegister = StyleRegister()

        let shortXML = shortSheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: shortStyleRegister,
            shareStringRegistor: shortRegister)

        let shortStrings = shortRegister.allStrings
        #expect(shortStrings.contains("Y")) // Should use SharedString for Excel compatibility
        #expect(shortStrings.contains("N")) // Should use SharedString for Excel compatibility

        // Test long custom expressions (should use SharedString)
        let longPeople = [
            TestPerson(name: "Alice", isActive: true, hasPermission: false),
            TestPerson(name: "Bob", isActive: false, hasPermission: true)
        ]
        let longSheet = Sheet<TestPerson>(name: "Long", dataProvider: { longPeople }) {
            Column(
                name: "Active",
                keyPath: \.isActive,
                booleanExpressions: .custom(true: "ENABLED", false: "DISABLED"))
        }

        let longRegister = ShareStringRegister()
        let longStyleRegister = StyleRegister()

        let longXML = longSheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: longStyleRegister,
            shareStringRegistor: longRegister)

        let longStrings = longRegister.allStrings
        #expect(longStrings.contains("ENABLED")) // Should use SharedString
        #expect(longStrings.contains("DISABLED"))

        print("Short custom expressions SharedStrings: \(shortStrings)")
        print("Long custom expressions SharedStrings: \(longStrings)")
        print("All custom expressions now use SharedString for Excel compatibility")
    }

    @Test("shouldUseSharedString logic validation")
    func shouldUseSharedStringLogic() throws {
        // Test all boolean expression types
        #expect(Cell.BooleanExpressions.oneAndZero.shouldUseSharedString == false)
        #expect(Cell.BooleanExpressions.tAndF.shouldUseSharedString == true)
        #expect(Cell.BooleanExpressions.trueAndFalse.shouldUseSharedString == true)
        #expect(Cell.BooleanExpressions.yesAndNo.shouldUseSharedString == true)

        // Test custom expressions - all use SharedString for Excel compatibility
        #expect(Cell.BooleanExpressions.custom(true: "Y", false: "N").shouldUseSharedString == true)
        #expect(Cell.BooleanExpressions.custom(true: "YES", false: "N").shouldUseSharedString == true)
        #expect(Cell.BooleanExpressions.custom(true: "Y", false: "NO").shouldUseSharedString == true)
        #expect(Cell.BooleanExpressions.custom(true: "ACTIVE", false: "INACTIVE").shouldUseSharedString == true)
    }

    @Test("space optimization comparison")
    func spaceOptimizationComparison() throws {
        // Create large dataset to test optimization benefits
        let largeDataset = Array(0 ..< 1000).map { index in
            TestPerson(name: "Person\(index)", isActive: index % 2 == 0, hasPermission: index % 3 == 0)
        }

        // Test oneAndZero (no optimization)
        let oneZeroSheet = Sheet<TestPerson>(name: "OneZero", dataProvider: { largeDataset }) {
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .oneAndZero)
        }

        let oneZeroRegister = ShareStringRegister()
        let oneZeroStyleRegister = StyleRegister()

        let oneZeroXML = oneZeroSheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: oneZeroStyleRegister,
            shareStringRegistor: oneZeroRegister)

        // Test trueAndFalse (optimized)
        let trueFalseSheet = Sheet<TestPerson>(name: "TrueFalse", dataProvider: { largeDataset }) {
            Column(name: "Active", keyPath: \.isActive, booleanExpressions: .trueAndFalse)
        }

        let trueFalseRegister = ShareStringRegister()
        let trueFalseStyleRegister = StyleRegister()

        let trueFalseXML = trueFalseSheet.makeSheetXML(
            bookStyle: BookStyle(),
            sheetStyle: SheetStyle(),
            styleRegister: trueFalseStyleRegister,
            shareStringRegistor: trueFalseRegister)

        // Compare SharedString usage
        let oneZeroStrings = oneZeroRegister.allStrings.filter { $0 == "1" || $0 == "0" }
        let trueFalseStrings = trueFalseRegister.allStrings.filter { $0 == "TRUE" || $0 == "FALSE" }

        #expect(oneZeroStrings.isEmpty) // Should not register boolean values
        #expect(trueFalseStrings.count == 2) // Should register TRUE and FALSE

        print("OneZero boolean SharedStrings: \(oneZeroStrings.count)")
        print("TrueFalse boolean SharedStrings: \(trueFalseStrings.count)")
        print("Optimization achieved: boolean expressions now use SharedString for multi-character formats")
    }
}
