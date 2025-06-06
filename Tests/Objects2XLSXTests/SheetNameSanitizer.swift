//
// SheetNameSanitizer.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import Objects2XLSX
import Testing

@Suite("Sheet Name Sanitizer Tests")
struct SheetNameSanitizerTests {
    /// Test that leading and trailing single quotes are removed
    @Test("removeQuotes", arguments: ["'Hello'World", "Hello'World'", "'Hello'World'"])
    func removeQuotes(name: String) {
        let sanitize = SheetNameSanitizer.default
        #expect(sanitize(name) == "Hello'World")
    }

    /// Test that names longer than 31 characters are truncated
    @Test func truncate() {
        let sanitize = SheetNameSanitizer.default
        let name = Array(repeating: "A", count: 32).joined()
        #expect(sanitize(name).count == 31)
    }

    /// Test default name handling for empty strings
    @Test func defaultName() {
        let sanitize = SheetNameSanitizer.default
        let name = ""
        #expect(sanitize(name) == "Sheet")

        let sanitize2 = SheetNameSanitizer(defaultName: "Default")
        #expect(sanitize2(name) == "Default")
    }

    /// Test remove strategy for special characters
    @Test func removeStrategy() {
        let sanitize = SheetNameSanitizer(characterStrategy: .remove)
        let specialCharacters = SheetNameSanitizer.CharacterStrategy.specialCharacters
        let name = "Hello /\(specialCharacters.joined())/\(specialCharacters.joined()) World"
        #expect(sanitize(name) == "Hello  World")
    }

    /// Test replace strategy for special characters
    @Test func mapStrategy() {
        let sanitize = SheetNameSanitizer(characterStrategy: .replace(map: ["/": "_", "[": "_"]))
        let specialCharacters = SheetNameSanitizer.CharacterStrategy.specialCharacters
        let name = "Hello\(specialCharacters.joined())World"
        #expect(sanitize(name) == "Hello__World") // Only / and [ are replaced, others are removed
    }

    /// Test truncation after character removal
    @Test func truncateAfterRemove() {
        let sanitize = SheetNameSanitizer(characterStrategy: .remove)
        let specialCharacters = SheetNameSanitizer.CharacterStrategy.specialCharacters
        let name = "'" + Array(repeating: "A", count: 32).joined() + specialCharacters
            .joined() + "'"
        let sanitized = sanitize(name)
        #expect(sanitized.count == 31)
        #expect(sanitized.allSatisfy { $0 == "A" })
    }
}
