//
// SheetNameSanitizer.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 A utility for sanitizing worksheet names to comply with Excel's XLSX format requirements.

 Excel enforces strict naming rules for worksheets that must be followed to ensure
 compatibility and prevent file corruption. `SheetNameSanitizer` provides a configurable
 approach to cleaning and validating worksheet names according to these requirements.

 ## Excel Naming Requirements

 Excel worksheet names must comply with the following rules:
 - **Cannot contain special characters**: `/`, `\`, `[`, `]`, `*`, `?`, `:`
 - **Cannot start or end with single quotes**: `'` characters are stripped from edges
 - **Maximum length**: 31 characters (Excel specification limit)
 - **Cannot be empty**: Empty names are replaced with a default fallback
 - **Must be unique**: Within a workbook (handled by calling code)

 ## Character Handling Strategies

 The sanitizer supports two approaches for handling invalid characters:

 ### Remove Strategy
 Simply removes all invalid characters from the name:
 ```swift
 let sanitizer = SheetNameSanitizer(characterStrategy: .remove)
 let clean = sanitizer("Sales/Report[2024]*") // Result: "SalesReport2024"
 ```

 ### Replace Strategy
 Maps specific characters to replacement strings, then removes any unmapped invalid characters:
 ```swift
 let replacements = ["/": "-", "[": "(", "]": ")", "*": "_"]
 let sanitizer = SheetNameSanitizer(characterStrategy: .replace(map: replacements))
 let clean = sanitizer("Sales/Report[2024]*") // Result: "Sales-Report(2024)_"
 ```

 ## Usage Examples

 ### Basic Usage
 ```swift
 let sanitizer = SheetNameSanitizer.default
 let cleanName = sanitizer("My Data / Sheet [v2.0]")
 // Result: "My Data  Sheet v20"
 ```

 ### Custom Configuration
 ```swift
 let customSanitizer = SheetNameSanitizer(
     characterStrategy: .replace(map: ["/": "_", "[": "(", "]": ")"]),
     defaultName: "Worksheet"
 )
 let cleanName = customSanitizer("Reports/[Q1]")
 // Result: "Reports_(Q1)"
 ```

 ### Integration with Sheet Creation
 ```swift
 let sheet = Sheet(
     name: "Raw Data / Analysis [2024]*",
     nameSanitizer: .default
 ) {
     // Sheet configuration
 }
 // Worksheet will be named "Raw Data  Analysis 2024"
 ```

 ## Performance Considerations

 The sanitizer performs string operations that scale with input length. For typical
 worksheet names (under 50 characters), performance impact is negligible. The sanitizer
 is `Sendable` and can be safely used across concurrent contexts.

 - Note: The sanitizer only ensures Excel compatibility. Uniqueness within a workbook
   must be handled by the calling code if required.
 */
public struct SheetNameSanitizer: Sendable {

    // MARK: - Character Strategy

    /**
     Defines how to handle special characters that are invalid in Excel worksheet names.

     The strategy determines whether invalid characters are removed entirely or
     replaced with valid alternatives before final processing.
     */
    public enum CharacterStrategy: Sendable {

        /**
         Remove all special characters from the worksheet name.

         This is the simplest approach that simply strips out any characters
         that are not allowed in Excel worksheet names.

         ## Example
         ```swift
         let sanitizer = SheetNameSanitizer(characterStrategy: .remove)
         sanitizer("Sales/Data[2024]*") // Result: "SalesData2024"
         ```
         */
        case remove

        /**
         Replace special characters using a mapping dictionary.

         This strategy first applies character replacements from the provided
         mapping, then removes any remaining unmapped special characters.
         This allows for more control over the final appearance of names.

         - Parameter map: Dictionary mapping special characters to replacement strings

         ## Example
         ```swift
         let replacements = ["/": "-", "[": "(", "]": ")"]
         let sanitizer = SheetNameSanitizer(characterStrategy: .replace(map: replacements))
         sanitizer("Sales/Data[2024]*") // Result: "Sales-Data(2024)"
         ```

         - Note: Unmapped special characters (like `*` in the example) are still removed
         */
        case replace(map: [String: String])

        /**
         Characters that are not allowed in Excel worksheet names.

         These characters will cause Excel to reject the worksheet name or
         may lead to file corruption if included in the final XLSX output.

         The forbidden characters are: `/`, `\`, `[`, `]`, `*`, `?`, `:`
         */
        public static let specialCharacters = ["/", "\\", "[", "]", "*", "?", ":"]
    }

    // MARK: - Properties

    /**
     The strategy for handling special characters in worksheet names.

     Determines whether invalid characters are removed or replaced according
     to the configured approach.
     */
    let characterStrategy: CharacterStrategy

    /**
     The maximum allowed length for worksheet names.

     Excel enforces a strict 31-character limit for worksheet names. Names
     longer than this will be truncated to fit the requirement.

     - Note: This is a fixed Excel specification and cannot be changed
     */
    let maxLength: Int = 31

    /**
     The default name to use when the sanitized result would be empty.

     If the sanitization process removes all characters from a name,
     this fallback value is used to ensure the worksheet has a valid name.
     */
    let defaultName: String

    // MARK: - Initialization

    /**
     Creates a new worksheet name sanitizer with the specified configuration.

     - Parameters:
        - characterStrategy: How to handle special characters (defaults to `.remove`)
        - defaultName: Fallback name for empty results (defaults to "Sheet")

     ## Usage Examples

     ### Default Configuration
     ```swift
     let sanitizer = SheetNameSanitizer()
     // Uses .remove strategy with "Sheet" as default name
     ```

     ### Custom Strategy
     ```swift
     let sanitizer = SheetNameSanitizer(
         characterStrategy: .replace(map: ["/": "_", "*": ""]),
         defaultName: "Data"
     )
     ```
     */
    public init(characterStrategy: CharacterStrategy = .remove, defaultName: String = "Sheet") {
        self.characterStrategy = characterStrategy
        self.defaultName = defaultName
    }

    /**
     Sanitizes a worksheet name to comply with Excel's XLSX format requirements.

     This method performs the complete sanitization process, applying all configured
     rules to transform the input name into a valid Excel worksheet name. The process
     includes character filtering, length validation, and fallback handling.

     - Parameter name: The original worksheet name to sanitize
     - Returns: A sanitized worksheet name that meets all Excel requirements

     ## Processing Steps

     1. **Quote Removal**: Strips leading and trailing single quotes (`'`)
     2. **Character Handling**: Applies the configured character strategy
     3. **Empty Check**: Uses default name if result is empty
     4. **Length Validation**: Truncates to 31 characters maximum

     ## Character Strategy Processing

     ### Remove Strategy
     Simply removes all forbidden characters:
     ```swift
     let sanitizer = SheetNameSanitizer(characterStrategy: .remove)
     sanitizer("Data/Report[2024]*") // Result: "DataReport2024"
     ```

     ### Replace Strategy
     First applies mappings, then removes unmapped characters:
     ```swift
     let replacements = ["/": "_", "[": "(", "]": ")"]
     let sanitizer = SheetNameSanitizer(characterStrategy: .replace(map: replacements))
     sanitizer("Data/Report[2024]*") // Result: "Data_Report(2024)"
     ```

     ## Edge Cases Handled

     - **Empty Input**: Returns default name
     - **Only Special Characters**: Removes all, returns default name
     - **Quotes Only**: Strips quotes, may result in default name
     - **Overly Long Names**: Truncates to 31 characters
     - **Mixed Content**: Processes all transformations in sequence

     ## Performance

     The method performs string operations with O(n) complexity where n is the
     input length. For typical worksheet names, performance is excellent.

     - Complexity: O(n) where n is the input string length
     - Memory: O(n) for string processing and result storage
     - Thread Safety: Fully thread-safe, no shared mutable state

     ## Examples

     ```swift
     let sanitizer = SheetNameSanitizer.default

     // Basic sanitization
     sanitizer("Sales Report") // Result: "Sales Report"

     // Special character removal
     sanitizer("Data/Analysis[2024]*") // Result: "DataAnalysis2024"

     // Quote handling
     sanitizer("'Quoted Name'") // Result: "Quoted Name"

     // Length truncation
     sanitizer("Very Long Worksheet Name That Exceeds Thirty One Characters")
     // Result: "Very Long Worksheet Name That Ex"
     ```
     */
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

    /**
     A preconfigured sanitizer instance with standard Excel-compatible settings.

     This default instance provides the most commonly used configuration for worksheet
     name sanitization, suitable for the majority of Excel export scenarios. It uses
     a simple removal strategy and standard fallback naming.

     ## Default Configuration

     - **Character Strategy**: `.remove` - Simply removes all forbidden characters
     - **Default Name**: `"Sheet"` - Standard Excel worksheet name fallback
     - **Behavior**: Conservative approach ensuring maximum compatibility

     ## Processing Rules

     1. **Special Characters**: Completely removed (`/`, `\`, `[`, `]`, `*`, `?`, `:`)
     2. **Leading/Trailing Quotes**: Stripped from worksheet names
     3. **Length Limit**: Truncated to 31 characters maximum
     4. **Empty Names**: Replaced with "Sheet"

     ## Usage Examples

     ```swift
     // Simple usage - most common case
     let cleanName = SheetNameSanitizer.default("User Data / Reports [2024]")
     // Result: "User Data  Reports 2024"

     // Integration with Sheet creation
     let sheet = Sheet(
         name: "Sales/Revenue*Analysis",
         nameSanitizer: .default
     ) {
         // Sheet configuration
     }
     // Sheet will be named "SalesRevenueAnalysis"

     // Batch processing
     let originalNames = ["Data/Export", "Report[Q1]", "Analysis*2024"]
     let cleanNames = originalNames.map(SheetNameSanitizer.default)
     // Results: ["DataExport", "ReportQ1", "Analysis2024"]
     ```

     ## When to Use Default vs Custom

     ### Use Default When:
     - You need simple, reliable name cleaning
     - Maximum Excel compatibility is required
     - You don't need to preserve special character meanings
     - You're processing user-generated names

     ### Use Custom When:
     - You want to replace rather than remove characters
     - You need different fallback names
     - You have specific character replacement requirements
     - You're working with structured naming conventions

     ## Performance Characteristics

     The default sanitizer is highly optimized for common use cases:
     - **Memory Efficient**: No replacement mappings to store
     - **Fast Processing**: Simple character filtering
     - **Thread Safe**: Immutable configuration, safe for concurrent use
     - **Reusable**: Single instance can handle unlimited sanitization requests

     - Note: This is the recommended sanitizer for most applications
     */
    public static let `default` = SheetNameSanitizer(
        characterStrategy: .remove,
        defaultName: "Sheet")
}
