//
// SheetAsyncTests.swift
// Created as part of async data provider enhancement
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Sheet Async DataProvider Tests")
struct SheetAsyncTests {
    // Test struct that conforms to Sendable
    struct AsyncPerson: Sendable {
        let id: Int
        let name: String
        let age: Int
    }

    @Test("Create sheet with async data provider")
    func asyncDataProviderInitialization() async {
        // Create sheet with async data provider
        let sheet = Sheet<AsyncPerson>(
            name: "Async People",
            asyncDataProvider: {
                // Simulate async data fetching
                try? await Task.sleep(nanoseconds: 100_000) // 0.1ms
                return [
                    AsyncPerson(id: 1, name: "Alice", age: 30),
                    AsyncPerson(id: 2, name: "Bob", age: 25)
                ]
            }) {
                Column(name: "ID", keyPath: \.id)
                Column(name: "Name", keyPath: \.name)
                Column(name: "Age", keyPath: \.age)
            }

        #expect(sheet.name == "Async People")
        #expect(sheet.hasAsyncDataProvider == true)
        #expect(sheet.columns.count == 3)

        // Load data asynchronously
        await sheet.loadDataAsync()

        #expect(sheet.data?.count == 2)
        #expect(sheet.data?.first?.name == "Alice")
    }

    @Test("Set async data provider via method")
    func asyncDataProviderMethod() async {
        // Create sheet without data provider
        let sheet = Sheet<AsyncPerson>(name: "People") {
            Column(name: "ID", keyPath: \.id)
            Column(name: "Name", keyPath: \.name)
        }

        #expect(sheet.hasAsyncDataProvider == false)

        // Set async data provider
        sheet.asyncDataProvider {
            [
                AsyncPerson(id: 1, name: "Charlie", age: 35),
                AsyncPerson(id: 2, name: "Diana", age: 28)
            ]
        }

        #expect(sheet.hasAsyncDataProvider == true)

        // Load data
        await sheet.loadDataAsync()

        #expect(sheet.data?.count == 2)
        #expect(sheet.data?.first?.name == "Charlie")
    }

    @Test("Async data provider clears sync provider")
    func asyncClearsSyncProvider() async {
        let sheet = Sheet<AsyncPerson>(name: "People") {
            Column(name: "Name", keyPath: \.name)
        }

        // Set sync provider first
        sheet.dataProvider {
            [AsyncPerson(id: 1, name: "Sync", age: 40)]
        }

        // Set async provider (should clear sync)
        sheet.asyncDataProvider {
            [AsyncPerson(id: 2, name: "Async", age: 45)]
        }

        #expect(sheet.hasAsyncDataProvider == true)

        await sheet.loadDataAsync()
        #expect(sheet.data?.first?.name == "Async")
    }

    @Test("Sync data provider clears async provider")
    func syncClearsAsyncProvider() {
        let sheet = Sheet<AsyncPerson>(name: "People") {
            Column(name: "Name", keyPath: \.name)
        }

        // Set async provider first
        sheet.asyncDataProvider {
            [AsyncPerson(id: 1, name: "Async", age: 50)]
        }

        #expect(sheet.hasAsyncDataProvider == true)

        // Set sync provider (should clear async)
        sheet.dataProvider {
            [AsyncPerson(id: 2, name: "Sync", age: 55)]
        }

        #expect(sheet.hasAsyncDataProvider == false)

        sheet.loadData()
        #expect(sheet.data?.first?.name == "Sync")
    }

    @Test("LoadDataAsync falls back to sync provider")
    func loadDataAsyncFallback() async {
        let sheet = Sheet<AsyncPerson>(name: "People") {
            Column(name: "Name", keyPath: \.name)
        }

        // Only set sync provider
        sheet.dataProvider {
            [AsyncPerson(id: 1, name: "Fallback", age: 60)]
        }

        // loadDataAsync should use sync provider as fallback
        await sheet.loadDataAsync()

        #expect(sheet.data?.first?.name == "Fallback")
    }
}
