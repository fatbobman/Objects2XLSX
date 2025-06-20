//
// ShareStringRegistor.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A centralized registry that manages shared strings for Excel document generation.
///
/// `ShareStringRegister` optimizes XLSX file size by storing unique string values once
/// in a shared string table (sharedStrings.xml) and referencing them by index throughout
/// the document. This is a standard Excel optimization technique that can significantly
/// reduce file size when the same strings appear multiple times across cells.
///
/// ## Key Features
/// - **Automatic Deduplication**: Identical strings are stored only once
/// - **Index Management**: Assigns sequential indices for efficient reference
/// - **Batch Registration**: Supports both individual and bulk string registration
/// - **XML Generation**: Produces standards-compliant sharedStrings.xml content
///
/// ## Usage Pattern
/// ```swift
/// let register = ShareStringRegister()
///
/// // Register strings and get their indices
/// let index1 = register.register("Hello")
/// let index2 = register.register("World")
/// let index3 = register.register("Hello") // Returns same index as index1
///
/// // Generate the shared strings XML
/// let xml = register.generateXML()
/// ```
///
/// ## Excel Integration
/// The generated indices are used in cell XML as references to the shared string table,
/// replacing inline string values with compact numeric references.
final class ShareStringRegister {
    /// Internal storage mapping strings to their assigned indices
    private var stringPool: [String: Int] = [:]

    /// Returns all registered strings sorted by their assigned indices
    var allStrings: [String] {
        stringPool.sorted { $0.value < $1.value }.map(\.key)
    }

    /// Registers multiple strings in batch, assigning indices to new strings only.
    /// - Parameter strings: A sequence of strings to register
    /// - Note: Existing strings are skipped to maintain their original indices
    func registerStrings(_ strings: some Sequence<String>) {
        for string in strings {
            if stringPool[string] != nil { continue }
            stringPool[string] = stringPool.count
        }
    }

    /// Registers a single string and returns its assigned index.
    /// - Parameter string: The string to register
    /// - Returns: The index assigned to the string (existing or newly created)
    func register(_ string: String) -> Int {
        if let id = stringPool[string] { return id }
        let id = stringPool.count
        stringPool[string] = id
        return id
    }

    /// Retrieves the index for a previously registered string.
    /// - Parameter string: The string to look up
    /// - Returns: The index if the string was registered, nil otherwise
    func stringIndex(for string: String) -> Int? {
        stringPool[string]
    }
    
    /// Generates the complete sharedStrings.xml content for the XLSX file.
    ///
    /// Creates a standards-compliant shared string table XML that contains all registered
    /// strings in their assigned order. Each string is wrapped in appropriate XML elements
    /// with proper escaping for special characters.
    ///
    /// - Returns: Complete XML string ready for inclusion in the XLSX package
    /// - Note: The count and uniqueCount attributes are set to the same value since
    ///         all strings in the pool are unique by design
    func generateXML() -> String {
        let sortedStrings = allStrings
        let count = sortedStrings.count
        
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="\(count)" uniqueCount="\(count)">
        """
        
        for string in sortedStrings {
            xml += "<si><t>"
            xml += string.xmlEscaped
            xml += "</t></si>"
        }
        
        xml += "</sst>"
        return xml
    }
}
