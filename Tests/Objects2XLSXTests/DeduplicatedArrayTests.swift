//
// DeduplicatedArrayTests.swift
// Created by Claude on 2025-06-20.
//

import Foundation
@testable import Objects2XLSX
import Testing

struct DeduplicatedArrayTests {
    @Test func basicFunctionality() {
        var array = DeduplicatedArray<Int>()

        // Test initial state
        #expect(array.isEmpty)
        #expect(array.isEmpty)

        // Test adding elements
        let result1 = array.append(10)
        #expect(result1.index == 0)
        #expect(result1.inserted == true)
        #expect(array.count == 1)
        #expect(!array.isEmpty)

        let result2 = array.append(20)
        #expect(result2.index == 1)
        #expect(result2.inserted == true)
        #expect(array.count == 2)

        // Test duplicate detection
        let result3 = array.append(10) // duplicate
        #expect(result3.index == 0)
        #expect(result3.inserted == false)
        #expect(array.count == 2) // no change

        // Test indexing
        #expect(array[0] == 10)
        #expect(array[1] == 20)
    }

    @Test func sequenceConformance() {
        var array = DeduplicatedArray<String>()
        array.append("first")
        array.append("second")
        array.append("third")
        array.append("second") // duplicate

        let collected = Array(array)
        #expect(collected == ["first", "second", "third"])
        #expect(collected.count == 3)
    }

    @Test func collectionConformance() {
        var array = DeduplicatedArray<Int>()
        array.append(1)
        array.append(2)
        array.append(3)

        #expect(array.startIndex == 0)
        #expect(array.endIndex == 3)
        #expect(array.index(after: 0) == 1)

        // Test enumeration
        let enumerated = Array(array.enumerated())
        #expect(enumerated.count == 3)
        #expect(enumerated[0].element == 1)
        #expect(enumerated[1].element == 2)
        #expect(enumerated[2].element == 3)
    }

    @Test func arrayLiteralInit() {
        let array: DeduplicatedArray<Int> = [1, 2, 3, 2, 1] // duplicates should be removed
        #expect(array.count == 3)
        #expect(Array(array) == [1, 2, 3])
    }

    @Test func sequenceInit() {
        let original = [1, 2, 3, 2, 1]
        let array = DeduplicatedArray(original)
        #expect(array.count == 3)
        #expect(Array(array) == [1, 2, 3])
    }

    @Test func testContains() {
        var array = DeduplicatedArray<String>()
        array.append("apple")
        array.append("banana")

        #expect(array.contains("apple"))
        #expect(array.contains("banana"))
        #expect(!array.contains("cherry"))
    }

    @Test func testFirstIndex() {
        var array = DeduplicatedArray<String>()
        array.append("apple")
        array.append("banana")
        array.append("cherry")

        #expect(array.firstIndex(of: "apple") == 0)
        #expect(array.firstIndex(of: "banana") == 1)
        #expect(array.firstIndex(of: "cherry") == 2)
        #expect(array.firstIndex(of: "grape") == nil)
    }

    @Test func testAllElements() {
        var array = DeduplicatedArray<Int>()
        array.append(10)
        array.append(20)
        array.append(30)

        let elements = array.allElements
        #expect(elements == [10, 20, 30])
    }

    @Test func equatable() {
        var array1 = DeduplicatedArray<Int>()
        var array2 = DeduplicatedArray<Int>()

        array1.append(1)
        array1.append(2)

        array2.append(1)
        array2.append(2)

        #expect(array1 == array2)

        array2.append(3)
        #expect(array1 != array2)
    }

    @Test func customStringConvertible() {
        var array = DeduplicatedArray<Int>()
        array.append(1)
        array.append(2)
        array.append(3)

        let description = array.description
        #expect(description == "[1, 2, 3]")
    }
}

// MARK: - Tests for Identifiable Elements

struct IdentifiableInt: Hashable, Identifiable {
    let id = UUID()
    let value: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    static func == (lhs: IdentifiableInt, rhs: IdentifiableInt) -> Bool {
        lhs.value == rhs.value
    }
}

struct DeduplicatedArrayIdentifiableTests {
    @Test func identifiableSupport() {
        var array = DeduplicatedArray<IdentifiableInt>()

        let item1 = IdentifiableInt(value: 10)
        let item2 = IdentifiableInt(value: 20)
        let item3 = IdentifiableInt(value: 10) // same value, different ID

        array.append(item1)
        array.append(item2)
        let result = array.append(item3) // should be treated as duplicate due to hash/equality

        #expect(array.count == 2)
        #expect(result.inserted == false)
        #expect(result.index == 0) // should return index of first item with value 10
    }

    @Test func idsProperty() {
        var array = DeduplicatedArray<IdentifiableInt>()

        let item1 = IdentifiableInt(value: 10)
        let item2 = IdentifiableInt(value: 20)

        array.append(item1)
        array.append(item2)

        let ids = array.ids
        #expect(ids.count == 2)
        #expect(ids[0] == item1.id)
        #expect(ids[1] == item2.id)
    }

    @Test func firstIndexOfId() {
        var array = DeduplicatedArray<IdentifiableInt>()

        let item1 = IdentifiableInt(value: 10)
        let item2 = IdentifiableInt(value: 20)

        array.append(item1)
        array.append(item2)

        #expect(array.firstIndex(of: item1.id) == 0)
        #expect(array.firstIndex(of: item2.id) == 1)

        let nonExistentId = UUID()
        #expect(array.firstIndex(of: nonExistentId) == nil)
    }
}

// MARK: - Integration Tests with Style Types

struct DeduplicatedArrayStyleIntegrationTests {
    @Test func withFont() {
        var fontPool = DeduplicatedArray<Font>()

        let arial12 = Font(size: 12, name: "Arial")
        let arial14 = Font(size: 14, name: "Arial")
        let arial12_duplicate = Font(size: 12, name: "Arial")

        let result1 = fontPool.append(arial12)
        let result2 = fontPool.append(arial14)
        let result3 = fontPool.append(arial12_duplicate)

        #expect(result1.index == 0)
        #expect(result1.inserted == true)

        #expect(result2.index == 1)
        #expect(result2.inserted == true)

        #expect(result3.index == 0) // duplicate
        #expect(result3.inserted == false)

        #expect(fontPool.count == 2)
    }

    @Test func withFill() {
        var fillPool = DeduplicatedArray<Fill>()

        let redFill = Fill.solid(.red)
        let blueFill = Fill.solid(.blue)
        let redFillDuplicate = Fill.solid(.red)

        let result1 = fillPool.append(redFill)
        let result2 = fillPool.append(blueFill)
        let result3 = fillPool.append(redFillDuplicate)

        #expect(result1.index == 0)
        #expect(result2.index == 1)
        #expect(result3.index == 0) // duplicate
        #expect(result3.inserted == false)

        #expect(fillPool.count == 2)
    }

    @Test func withBorder() {
        var borderPool = DeduplicatedArray<Border>()

        let thinBorder = Border(top: Border.Side(style: .thin, color: .black))
        let thickBorder = Border(bottom: Border.Side(style: .thick, color: .blue))
        let thinBorderDuplicate = Border(top: Border.Side(style: .thin, color: .black))

        let result1 = borderPool.append(thinBorder)
        let result2 = borderPool.append(thickBorder)
        let result3 = borderPool.append(thinBorderDuplicate)

        #expect(result1.index == 0)
        #expect(result2.index == 1)
        #expect(result3.index == 0) // duplicate
        #expect(result3.inserted == false)

        #expect(borderPool.count == 2)
    }

    @Test func styleRegisterCompatibility() {
        let styleRegister = StyleRegister()

        // Test that StyleRegister works with DeduplicatedArray
        let font1 = Font(size: 12, name: "Arial", bold: true)
        let font2 = Font(size: 14, name: "Helvetica")
        let font1Duplicate = Font(size: 12, name: "Arial", bold: true)

        let cellStyle1 = CellStyle(font: font1)
        let cellStyle2 = CellStyle(font: font2)
        let cellStyle3 = CellStyle(font: font1Duplicate)

        let styleId1 = styleRegister.registerCellStyle(cellStyle1, cellType: .string("test"))
        let styleId2 = styleRegister.registerCellStyle(cellStyle2, cellType: .string("test"))
        let styleId3 = styleRegister.registerCellStyle(cellStyle3, cellType: .string("test"))

        // Should have registered 2 unique fonts
        #expect(styleRegister.fontPool.count == 3) // default + 2 unique fonts

        // Style IDs should be different for different styles
        #expect(styleId1 != styleId2)

        // But same for duplicate styles
        #expect(styleId1 == styleId3)
    }
}
