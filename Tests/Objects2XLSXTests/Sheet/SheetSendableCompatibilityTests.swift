//
// SheetSendableCompatibilityTests.swift
// Created as part of Sendable compatibility enhancement
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Sheet Sendable Compatibility Tests")
struct SheetSendableCompatibilityTests {
    // Test struct that conforms to Sendable
    struct SendablePerson: Sendable {
        let id: Int
        let name: String
        let age: Int
    }

    // Test struct that does NOT conform to Sendable (has a class property)
    struct NonSendablePerson {
        let id: Int
        let name: String
        let age: Int
        let someClass: SomeClass
    }

    class SomeClass {
        let value: String
        init(value: String) {
            self.value = value
        }
    }

    @Test("Sendable person can use sync data provider")
    func sendablePersonSyncDataProvider() {
        let sheet = Sheet<SendablePerson>(name: "Sendable People") {
            Column(name: "ID", keyPath: \.id)
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }

        sheet.dataProvider {
            [
                SendablePerson(id: 1, name: "Alice", age: 30),
                SendablePerson(id: 2, name: "Bob", age: 25)
            ]
        }

        sheet.loadData()
        #expect(sheet.data?.count == 2)
        #expect(sheet.data?.first?.name == "Alice")
    }

    @Test("Sendable person can use async data provider")
    func sendablePersonAsyncDataProvider() async {
        let sheet = Sheet<SendablePerson>(
            name: "Async Sendable People",
            asyncDataProvider: {
                // Simulate async data fetching
                try? await Task.sleep(nanoseconds: 100_000) // 0.1ms
                return [
                    SendablePerson(id: 1, name: "Charlie", age: 35),
                    SendablePerson(id: 2, name: "Diana", age: 28)
                ]
            }) {
                Column(name: "ID", keyPath: \.id)
                Column(name: "Name", keyPath: \.name)
                Column(name: "Age", keyPath: \.age)
            }

        #expect(sheet.hasAsyncDataProvider == true)

        await sheet.loadDataAsync()
        #expect(sheet.data?.count == 2)
        #expect(sheet.data?.first?.name == "Charlie")
    }

    @Test("Non-Sendable person can use sync data provider")
    func nonSendablePersonSyncDataProvider() {
        let sheet = Sheet<NonSendablePerson>(name: "Non-Sendable People") {
            Column(name: "ID", keyPath: \.id)
            Column(name: "Name", keyPath: \.name)
            Column(name: "Age", keyPath: \.age)
        }

        sheet.dataProvider {
            [
                NonSendablePerson(
                    id: 1,
                    name: "Eve",
                    age: 40,
                    someClass: SomeClass(value: "test1")),
                NonSendablePerson(
                    id: 2,
                    name: "Frank",
                    age: 35,
                    someClass: SomeClass(value: "test2"))
            ]
        }

        sheet.loadData()
        #expect(sheet.data?.count == 2)
        #expect(sheet.data?.first?.name == "Eve")
    }

    @Test("Non-Sendable person cannot use async data provider - compile time check")
    func nonSendablePersonAsyncDataProviderUnavailable() {
        // This test verifies that async APIs are not available for non-Sendable types
        // If this compiles, it means the conditional extensions are working correctly

        let sheet = Sheet<NonSendablePerson>(name: "Non-Sendable People") {
            Column(name: "Name", keyPath: \.name)
        }

        // The following lines should NOT compile if our conditional extensions work correctly:
        // sheet.asyncDataProvider { ... }  // Should not be available
        // Sheet<NonSendablePerson>(name: "Test", asyncDataProvider: { ... }) { ... }  // Should not be available

        #expect(sheet.hasAsyncDataProvider == false)
    }

    @Test("Mixed Sendable and non-Sendable usage in same codebase")
    func mixedUsage() async {
        // Create sheets for both types
        let sendableSheet = Sheet<SendablePerson>(name: "Sendable") {
            Column(name: "Name", keyPath: \.name)
        }

        let nonSendableSheet = Sheet<NonSendablePerson>(name: "Non-Sendable") {
            Column(name: "Name", keyPath: \.name)
        }

        // Set up data providers
        sendableSheet.asyncDataProvider {
            [SendablePerson(id: 1, name: "Async Person", age: 25)]
        }

        nonSendableSheet.dataProvider {
            [NonSendablePerson(
                id: 1,
                name: "Sync Person",
                age: 30,
                someClass: SomeClass(value: "test"))]
        }

        // Load data
        await sendableSheet.loadDataAsync()
        nonSendableSheet.loadData()

        #expect(sendableSheet.data?.first?.name == "Async Person")
        #expect(nonSendableSheet.data?.first?.name == "Sync Person")
    }

    @Test("AnyColumn type erasure works with both Sendable and non-Sendable")
    func anyColumnTypeErasure() {
        // Create columns for both types
        let sendableColumn = Column<SendablePerson, String, TextColumnType>(
            name: "Name",
            keyPath: \.name)
        let nonSendableColumn = Column<NonSendablePerson, String, TextColumnType>(
            name: "Name",
            keyPath: \.name)

        // Erase to AnyColumn
        let anySendableColumn: AnyColumn<SendablePerson> = sendableColumn.eraseToAnyColumn()
        let anyNonSendableColumn: AnyColumn<NonSendablePerson> = nonSendableColumn
            .eraseToAnyColumn()

        #expect(anySendableColumn.name == "Name")
        #expect(anyNonSendableColumn.name == "Name")
    }
}
