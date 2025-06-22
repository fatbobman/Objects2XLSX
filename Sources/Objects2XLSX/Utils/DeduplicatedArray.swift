//
// DeduplicatedArray.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A lightweight collection that maintains insertion order while ensuring element uniqueness.
///
/// `DeduplicatedArray` combines the benefits of Array (ordered access, indexing) and Dictionary (fast lookup)
/// to provide an efficient container for storing unique elements in their insertion order.
///
/// ## Key Features
/// - **Automatic Deduplication**: Duplicate elements are rejected, returning existing index
/// - **Insertion Order**: Elements maintain their original insertion sequence
/// - **O(1) Operations**: Fast uniqueness checking and index lookup via internal Dictionary
/// - **Standard Protocols**: Supports Collection, Sequence, and index-based access
///
/// ## Usage
/// ```swift
/// var numbers = DeduplicatedArray<Int>()
/// let result1 = numbers.append(10)  // (index: 0, inserted: true)
/// let result2 = numbers.append(20)  // (index: 1, inserted: true)
/// let result3 = numbers.append(10)  // (index: 0, inserted: false) - duplicate
///
/// print(numbers.count)  // 2
/// print(numbers[0])     // 10
/// ```
///
/// ## Performance
/// - **Append**: O(1) for both new elements and duplicates
/// - **Access**: O(1) for index-based access
/// - **Contains**: O(1) via internal Dictionary
/// - **Index Lookup**: O(1) via internal Dictionary
///
/// ## Memory Usage
/// Uses approximately 1.5-2x memory compared to a plain Array due to the additional
/// Dictionary for fast lookups. This trade-off provides significant performance benefits
/// for scenarios with frequent duplicate checking and index lookups.
///
/// This type is particularly useful for style registries, string deduplication, and other
/// scenarios where both uniqueness and order matter with frequent lookups.
public struct DeduplicatedArray<Element: Hashable> {
    /// Internal array maintaining insertion order
    private var elements: [Element] = []

    /// Internal dictionary mapping elements to their indices for O(1) lookup
    private var elementToIndex: [Element: Int] = [:]

    /// The number of elements in the collection
    public var count: Int { elements.count }

    /// Whether the collection is empty
    public var isEmpty: Bool { elements.isEmpty }

    /// Creates an empty deduplicated array
    public init() {}

    /// Creates a deduplicated array from a sequence, preserving first occurrence order
    /// - Parameter sequence: The sequence to deduplicate
    public init(_ sequence: some Sequence<Element>) {
        for element in sequence {
            append(element)
        }
    }

    /// Appends an element to the collection, ensuring uniqueness
    /// - Parameter element: The element to append
    /// - Returns: A tuple containing the element's index and whether it was newly inserted
    @discardableResult
    public mutating func append(_ element: Element) -> (index: Int, inserted: Bool) {
        // Fast O(1) lookup using Dictionary
        if let existingIndex = elementToIndex[element] {
            return (index: existingIndex, inserted: false)
        }

        // New element - add to both structures
        let newIndex = elements.count
        elements.append(element)
        elementToIndex[element] = newIndex
        return (index: newIndex, inserted: true)
    }

    /// Accesses the element at the specified index
    /// - Parameter index: The index of the element to access
    /// - Returns: The element at the specified index
    public subscript(index: Int) -> Element {
        elements[index]
    }

    /// Returns the first index of the specified element
    /// - Parameter element: The element to find
    /// - Returns: The index of the element, or nil if not found
    public func firstIndex(of element: Element) -> Int? {
        elementToIndex[element]
    }

    /// Checks whether the collection contains the specified element
    /// - Parameter element: The element to check for
    /// - Returns: true if the element is present, false otherwise
    public func contains(_ element: Element) -> Bool {
        elementToIndex.keys.contains(element)
    }

    /// Returns all elements as an array, maintaining insertion order
    public var allElements: [Element] {
        elements
    }
}

// MARK: - Identifiable Element Support

extension DeduplicatedArray where Element: Identifiable {
    /// Returns the first index of an element with the specified ID
    /// - Parameter id: The ID to search for
    /// - Returns: The index of the element with the matching ID, or nil if not found
    public func firstIndex(of id: Element.ID) -> Int? {
        elements.firstIndex { $0.id == id }
    }

    /// Returns all element IDs in insertion order
    public var ids: [Element.ID] {
        elements.map(\.id)
    }
}

// MARK: - Collection Conformance

extension DeduplicatedArray: Collection {
    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }

    public func index(after i: Int) -> Int {
        elements.index(after: i)
    }
}

// MARK: - Sequence Conformance

extension DeduplicatedArray: Sequence {
    public func makeIterator() -> Array<Element>.Iterator {
        elements.makeIterator()
    }
}

// MARK: - ExpressibleByArrayLiteral

extension DeduplicatedArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

// MARK: - CustomStringConvertible

extension DeduplicatedArray: CustomStringConvertible {
    public var description: String {
        elements.description
    }
}

// MARK: - Equatable

extension DeduplicatedArray: Equatable where Element: Equatable {
    public static func == (lhs: DeduplicatedArray<Element>, rhs: DeduplicatedArray<Element>) -> Bool {
        lhs.elements == rhs.elements
    }
}

// MARK: - Hashable

extension DeduplicatedArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}

// MARK: - Sendable

extension DeduplicatedArray: Sendable where Element: Sendable {}
