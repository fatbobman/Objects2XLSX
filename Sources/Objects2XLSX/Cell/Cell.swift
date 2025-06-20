//
// Cell.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Represents a single cell in an Excel worksheet with position, value, and formatting information.
///
/// `Cell` is the fundamental unit of data in an Excel sheet, containing a value at a specific
/// row and column position. Each cell can have optional styling and may reference shared strings
/// for memory optimization.
///
/// ## Coordinate System
/// Excel uses a 1-based coordinate system where:
/// - Row 1 is the first row (not row 0)
/// - Column 1 is the first column ("A", not column 0)
/// - Cell "A1" has coordinates row=1, column=1
///
/// ## Value Types
/// Cells support various data types through the `CellType` enum:
/// - Strings and URLs (with optional shared string optimization)
/// - Numbers (integers and doubles)
/// - Dates (converted to Excel's date number format)
/// - Booleans (with customizable text representations)
/// - Percentages (with configurable precision)
///
/// ## Styling Integration
/// Cells reference styles by ID rather than embedding style information directly.
/// This approach enables efficient style reuse and smaller file sizes.
///
/// ## Usage Example
/// ```swift
/// let cell = Cell(
///     row: 1,
///     column: 1,
///     value: .string("Hello World"),
///     styleID: 5,
///     sharedStringID: 10
/// )
/// print(cell.excelAddress) // Outputs: "A1"
/// ```
public struct Cell: Equatable, Sendable {
    /// The 1-based row position of the cell (1 = first row)
    public let row: Int
    /// The 1-based column position of the cell (1 = column A)
    public let column: Int
    /// The typed value contained in this cell
    public let value: CellType
    /// Reference to a style definition in the style registry (nil = default style)
    public let styleID: Int?
    /// Reference to a shared string entry for memory optimization (nil = inline string)
    public let sharedStringID: Int?

    /// The Excel-format address of this cell (e.g., "A1", "B5", "AA100").
    ///
    /// Converts the 1-based numeric coordinates to Excel's alphanumeric format where:
    /// - Column 1 becomes "A", Column 26 becomes "Z", Column 27 becomes "AA"
    /// - Combined with the row number to form addresses like "A1", "Z99", "AA1"
    ///
    /// This format is used throughout the Excel XML for cell references.
    public var excelAddress: String {
        "\(columnIndexToExcelColumn(column))\(row)"
    }

    /// Creates a new cell with the specified position, value, and optional formatting.
    ///
    /// - Parameters:
    ///   - row: 1-based row position (1 = first row)
    ///   - column: 1-based column position (1 = column A)
    ///   - value: The typed value to store in this cell
    ///   - styleID: Optional reference to a style definition (nil uses default style)
    ///   - sharedStringID: Optional reference to shared string table for memory optimization
    ///
    /// - Note: When `sharedStringID` is provided for string/URL values, the actual string
    ///         content is stored in the shared string table and referenced by index.
    public init(
        row: Int,
        column: Int,
        value: CellType,
        styleID: Int? = nil,
        sharedStringID: Int? = nil)
    {
        self.row = row
        self.column = column
        self.value = value
        self.styleID = styleID
        self.sharedStringID = sharedStringID
    }
}

extension Cell {
    /// Generates the XML representation of this cell for inclusion in worksheet XML.
    ///
    /// Creates a `<c>` element with the cell's address, optional style reference, and
    /// value formatted according to Excel specifications. The output format depends on
    /// the cell's value type and whether shared strings are used.
    ///
    /// ## XML Structure
    /// ```xml
    /// <c r="A1" s="5">
    ///   <v>123.45</v>  <!-- numeric value -->
    /// </c>
    /// ```
    ///
    /// ## Value Encoding
    /// - **Shared strings**: `<v>index</v>` references shared string table
    /// - **Inline strings**: `<is><t>text</t></is>` for direct string content
    /// - **Numeric values**: `<v>number</v>` for integers, doubles, dates, percentages
    /// - **Booleans**: Always inline as `<is><t>TRUE/FALSE</t></is>`
    ///
    /// - Returns: Complete XML element ready for worksheet inclusion
    func generateXML() -> String {
        var xml = "<c r=\"\(excelAddress)\""

        if let styleID {
            xml += " s=\"\(styleID)\""
        }

        xml += ">"

        // Generate appropriate value format based on CellType
        switch value {
            case let .string(stringValue):
                if let sharedStringID {
                    // Use shared string reference for memory efficiency
                    xml += "<v>\(sharedStringID)</v>"
                } else {
                    // Use inline string value directly
                    xml += "<is><t>\(stringValue ?? "")</t></is>"
                }
            case let .url(url):
                if let sharedStringID {
                    // Use shared string reference for URL
                    xml += "<v>\(sharedStringID)</v>"
                } else {
                    // Use inline URL string value
                    xml += "<is><t>\(url?.absoluteString ?? "")</t></is>"
                }
            case .boolean:
                // Boolean values always use inline text (not numeric 0/1)
                xml += "<is><t>\(value.valueString)</t></is>"
            default:
                // All other types use numeric value format
                xml += "<v>\(value.valueString)</v>"
        }

        xml += "</c>"
        return xml
    }
}

extension Cell {
    /// Represents the various data types that can be stored in an Excel cell.
    ///
    /// `CellType` provides strongly-typed value storage with automatic conversion to Excel's
    /// internal representation. Each case handles the specific formatting requirements and
    /// data conversion needed for proper Excel compatibility.
    ///
    /// ## Supported Types
    /// - **Text**: Strings and URLs (with shared string optimization support)
    /// - **Numeric**: Integers, doubles, and percentages (with precision control)
    /// - **Temporal**: Dates (with timezone handling and Excel date conversion)
    /// - **Logical**: Booleans (with customizable text representations)
    ///
    /// ## Value Conversion
    /// All cell types implement `valueString` which converts the Swift value to the
    /// string representation expected by Excel's XML format.
    public enum CellType: Equatable, Sendable {
        /// Text string value with optional shared string optimization.
        /// - Parameter string: The string content (nil represents empty cell)
        case string(String?)
        
        /// Floating-point numeric value.
        /// - Parameter double: The numeric value (nil represents empty cell)
        case double(Double?)
        
        /// Integer numeric value.
        /// - Parameter int: The integer value (nil represents empty cell)
        case int(Int?)
        
        /// Date and time value with timezone support.
        /// - Parameter date: The date/time value (nil represents empty cell)
        /// - Parameter timeZone: Timezone for date interpretation (defaults to current)
        case date(Date?, timeZone: TimeZone = TimeZone.current)
        
        /// Boolean value with customizable text representation.
        /// - Parameter boolean: The boolean value (nil represents empty cell)
        /// - Parameter booleanExpressions: Text format for true/false values
        /// - Parameter caseStrategy: Case transformation for the boolean text
        case boolean(
            Bool?,
            booleanExpressions: BooleanExpressions = .oneAndZero,
            caseStrategy: CaseStrategy = .upper)
        
        /// URL value stored as text with optional shared string optimization.
        /// - Parameter url: The URL value (nil represents empty cell)
        case url(URL?)
        
        /// Percentage value with configurable decimal precision.
        /// - Parameter percentage: The percentage as decimal (0.5 = 50%)
        /// - Parameter precision: Number of decimal places to preserve
        case percentage(Double?, precision: Int = 2)

        /// Converts the cell value to its string representation for Excel XML.
        ///
        /// Each value type is converted according to Excel's expected format:
        /// - Strings and URLs: Direct text content
        /// - Numbers: String representation of numeric values
        /// - Dates: Excel's numeric date format (days since 1900-01-01)
        /// - Booleans: Configurable text representation (TRUE/FALSE, 1/0, etc.)
        /// - Percentages: Decimal representation for percentage formatting
        ///
        /// - Returns: String representation suitable for Excel XML storage
        public var valueString: String {
            switch self {
                case let .string(string):
                    string.cellValueString
                case let .double(double):
                    double.cellValueString
                case let .int(int):
                    int.cellValueString
                case let .date(date, timeZone):
                    date.cellValueString(timeZone: timeZone)
                case let .boolean(boolean, booleanExpressions, caseStrategy):
                    boolean.cellValueString(
                        booleanExpressions: booleanExpressions,
                        caseStrategy: caseStrategy)
                case let .url(url):
                    url.cellValueString
                case let .percentage(percentage, precision):
                    percentage.cellValueString(precision: precision)
            }
        }
    }

    /// Defines different text representations for boolean values in Excel cells.
    ///
    /// Excel doesn't have a native boolean type, so boolean values are stored as text.
    /// This enum provides common boolean text formats that users might expect.
    ///
    /// ## Common Formats
    /// - **trueAndFalse**: "TRUE" / "FALSE" (Excel's default boolean format)
    /// - **oneAndZero**: "1" / "0" (numeric-style boolean)
    /// - **tAndF**: "T" / "F" (abbreviated format)
    /// - **yesAndNo**: "YES" / "NO" (natural language format)
    /// - **custom**: User-defined true/false strings
    public enum BooleanExpressions: Equatable, Sendable {
        /// Standard Excel boolean format: "TRUE" / "FALSE"
        case trueAndFalse
        
        /// Abbreviated format: "T" / "F"
        case tAndF
        
        /// Numeric-style format: "1" / "0"
        case oneAndZero
        
        /// Natural language format: "YES" / "NO"
        case yesAndNo
        
        /// Custom boolean text representation
        /// - Parameter true: Text to display for true values
        /// - Parameter false: Text to display for false values
        case custom(true: String, false: String)

        /// Returns the text representation for true values in this boolean format.
        public var trueString: String {
            switch self {
                case .trueAndFalse:
                    "TRUE"
                case .tAndF:
                    "T"
                case .oneAndZero:
                    "1"
                case .yesAndNo:
                    "YES"
                case let .custom(trueString, _):
                    trueString
            }
        }

        /// Returns the text representation for false values in this boolean format.
        public var falseString: String {
            switch self {
                case .trueAndFalse:
                    "FALSE"
                case .tAndF:
                    "F"
                case .oneAndZero:
                    "0"
                case .yesAndNo:
                    "NO"
                case let .custom(_, falseString):
                    falseString
            }
        }
    }

    /// Defines text case transformation strategies for boolean and other text values.
    ///
    /// Case strategies control how text values are transformed before being written
    /// to Excel cells, allowing for consistent text formatting across the document.
    public enum CaseStrategy: Equatable, Sendable {
        /// Transform text to all uppercase (e.g., "true" → "TRUE")
        case upper
        
        /// Transform text to all lowercase (e.g., "TRUE" → "true")
        case lower
        
        /// Transform text to title case (e.g., "true" → "True")
        case firstLetterUpper

        /// Applies the case transformation strategy to the given string.
        ///
        /// - Parameter string: The input string to transform
        /// - Returns: The string with the case strategy applied
        func apply(to string: String) -> String {
            switch self {
                case .upper:
                    return string.uppercased()
                case .lower:
                    return string.lowercased()
                case .firstLetterUpper:
                    guard !string.isEmpty else {
                        return ""
                    }
                    return string.prefix(1).uppercased() + string.dropFirst().lowercased()
            }
        }
    }
}
