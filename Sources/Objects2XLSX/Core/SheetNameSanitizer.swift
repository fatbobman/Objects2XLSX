//
// SheetNameSanitizer.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A utility for sanitizing sheet names to comply with Excel's XLSX format requirements.
///
/// Excel has specific rules for sheet names:
/// - Cannot contain certain special characters: / \ [ ] * ? :
/// - Cannot start or end with single quotes
/// - Maximum length is 31 characters
/// - Cannot be empty
public struct SheetNameSanitizer: Sendable {
    /// Defines how to handle special characters in sheet names.
    public enum CharacterStrategy: Sendable {
        /// Remove all special characters from the name.
        case remove
        /// Replace special characters using a mapping dictionary, then remove any unmapped special
        /// characters.
        /// - Parameter map: Dictionary mapping special characters to replacement strings.
        case replace(map: [String: String])

        /// Characters that are not allowed in Excel sheet names.
        public static let specialCharacters = ["/", "\\", "[", "]", "*", "?", ":"]
    }

    /// Strategy for handling special characters in sheet names.
    let characterStrategy: CharacterStrategy
    /// Maximum allowed length for sheet names (Excel XLSX specification limit: 31 characters).
    let maxLength: Int = 31
    /// Default name to use when the sanitized result would be empty.
    let defaultName: String

    /// Creates a new sheet name sanitizer.
    /// - Parameters:
    ///   - characterStrategy: How to handle special characters. Defaults to `.remove`.
    ///   - defaultName: Fallback name for empty results. Defaults to "Sheet".
    public init(characterStrategy: CharacterStrategy = .remove, defaultName: String = "Sheet") {
        self.characterStrategy = characterStrategy
        self.defaultName = defaultName
    }

    /// Sanitizes a sheet name to comply with Excel requirements.
    /// - Parameter name: The original sheet name to sanitize.
    /// - Returns: A sanitized sheet name that meets Excel's requirements.
    public func callAsFunction(_ name: String) -> String {
        // Remove leading and trailing single quotes as they're not allowed
        var name = name
        if name.hasPrefix("'") {
            name = String(name.dropFirst())
        }
        if name.hasSuffix("'") {
            name = String(name.dropLast())
        }

        // Apply character strategy to handle special characters
        switch characterStrategy {
            case .remove:
                name = name
                    .filter { !Self.CharacterStrategy.specialCharacters.contains(String($0)) }
            case let .replace(map):
                // First apply replacement mapping, then remove any remaining unmapped special
                // characters
                name = name
                    .map { map[String($0)] ?? String($0) }
                    .joined()
                    .filter { !Self.CharacterStrategy.specialCharacters.contains(String($0)) }
        }

        // Use default name if the result is empty after processing
        if name.isEmpty {
            name = defaultName
        }

        // Truncate to maximum length if necessary
        if name.count > maxLength {
            name = String(name.prefix(maxLength))
        }

        return name
    }

    /// Default sanitizer that removes special characters and truncates names longer than 31
    /// characters.
    /// Leading and trailing single quotes are also removed.
    public static let `default` = SheetNameSanitizer(
        characterStrategy: .remove,
        defaultName: "Sheet")
}
