//
// Column.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A strongly-typed column definition that maps object properties to Excel cell values.
///
/// `Column` provides the core abstraction for extracting data from Swift objects and
/// converting it to Excel-compatible cell content. It combines type safety, data transformation,
/// styling, and conditional logic into a comprehensive column specification.
///
/// ## Generic Type Parameters
/// - **ObjectType**: The Swift type containing source data (e.g., `Person`, `Product`)
/// - **InputType**: The property type extracted via KeyPath (e.g., `String`, `Double?`, `Date`)
/// - **OutputType**: The Excel-compatible output type (e.g., `TextColumnType`, `DoubleColumnType`)
///
/// ## Core Functionality
/// - **Type-Safe Extraction**: Uses KeyPath for compile-time verified property access
/// - **Data Transformation**: Maps input types to Excel-compatible output formats
/// - **Conditional Logic**: Supports conditional display and conditional mapping
/// - **Styling Integration**: Applies fonts, colors, alignment, and borders
/// - **Nil Handling**: Configurable behavior for nil/missing values
///
/// ## Usage Examples
/// ```swift
/// // Simple text column
/// Column<Person, String, TextColumnType>(name: "Full Name", keyPath: \.fullName)
///
/// // Numeric column with styling
/// Column<Product, Double, DoubleColumnType>(name: "Price", keyPath: \.price)
///     .width(12)
///     .bodyStyle(CellStyle(font: Font(size: 12, bold: true)))
///
/// // Conditional column with custom mapping
/// Column<Order, OrderStatus, TextColumnType>.conditional(
///     name: "Status",
///     keyPath: \.status,
///     filter: { $0.isPriority },
///     then: { "PRIORITY: \($0.description)" },
///     else: { $0.description }
/// )
/// ```
///
/// ## Integration with Sheets
/// Columns are collected into arrays and processed by `Sheet` instances to generate
/// Excel worksheets. The type system ensures that all columns in a sheet work with
/// the same `ObjectType` while allowing different data types and formatting.
public struct Column<ObjectType, InputType, OutputType>: ColumnProtocol
where OutputType: ColumnOutputTypeProtocol {
    /// The display name for this column in the Excel header row
    public var name: String

    /// Optional column width in Excel character units (nil = auto-width based on content)
    public var width: Int?

    /// Strategy for handling nil values in the extracted data
    /// - `.keepEmpty`: Renders as empty Excel cells
    /// - `.defaultValue(T)`: Substitutes a specified default value
    public let nilHandling: TypedNilHandling<OutputType>

    /// Optional styling for data cells in this column (body rows)
    public var bodyStyle: CellStyle?

    /// Optional styling for the header cell of this column
    public var headerStyle: CellStyle?

    /// Compile-time verified path to extract data from the source object
    public let keyPath: KeyPath<ObjectType, InputType>

    /// Primary transformation function from input type to Excel-compatible output
    public let mapping: (InputType) -> OutputType

    /// Optional conditional mapping that chooses between two transformations based on a condition
    public var conditionalMapping: ((Bool, InputType) -> OutputType)?

    /// Optional predicate function used by conditional mapping to determine transformation choice
    public var filter: ((ObjectType) -> Bool)?

    /// Visibility predicate that determines if this column should appear for a given object
    public var when: (ObjectType) -> Bool

    /// Creates a new column with comprehensive configuration options.
    ///
    /// This initializer provides full control over column behavior including data extraction,
    /// transformation, styling, and visibility. It's the foundation for all column types.
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: Compile-time verified path to extract data from objects
    ///   - width: Optional column width in character units (nil = auto-width)
    ///   - bodyStyle: Optional styling for data cells (nil = inherit from sheet/book)
    ///   - headerStyle: Optional styling for header cell (nil = inherit from sheet/book)
    ///   - mapping: Transformation function from input to Excel-compatible output
    ///   - nilHandling: Strategy for nil values (default: keep empty)
    ///   - when: Visibility predicate (default: always visible)
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        mapping: @escaping (InputType) -> OutputType,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        when: @escaping (ObjectType) -> Bool = { _ in true })
    {
        self.name = name
        self.keyPath = keyPath
        self.width = width
        self.mapping = mapping
        self.bodyStyle = bodyStyle
        self.nilHandling = nilHandling
        self.headerStyle = headerStyle
        conditionalMapping = nil
        filter = nil
        self.when = when
    }

    /// Creates a conditional column that applies different data transformations based on object state.
    ///
    /// Conditional columns enable dynamic data presentation where the same source property
    /// can be displayed differently based on object conditions. For example, showing priority
    /// indicators for urgent items or formatting values differently based on status.
    ///
    /// ## Use Cases
    /// - Status-dependent formatting ("URGENT: Task" vs "Task")
    /// - Conditional value transformation (percentages vs raw numbers)
    /// - Context-aware display logic (user role-based content)
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: Compile-time verified path to extract source data
    ///   - width: Optional column width in character units
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - filter: Predicate function that determines which mapping to apply
    ///   - thenMapping: Transformation used when filter returns true
    ///   - elseMapping: Transformation used when filter returns false
    ///   - nilHandling: Strategy for handling nil values
    ///   - when: Overall visibility predicate for the column
    /// - Returns: A configured conditional column instance
    public static func conditional(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        filter: @escaping (ObjectType) -> Bool,
        then thenMapping: @escaping (InputType) -> OutputType,
        else elseMapping: @escaping (InputType) -> OutputType,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        when: @escaping (ObjectType) -> Bool = { _ in true }) -> Self
    {
        var col = self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: thenMapping,
            nilHandling: nilHandling,
            when: when)
        col.conditionalMapping = { condition, input in
            condition ? thenMapping(input) : elseMapping(input)
        }
        col.filter = filter
        return col
    }

    /// Extracts data from an object and converts it to an Excel-compatible cell value.
    ///
    /// This method orchestrates the complete data transformation pipeline:
    /// 1. Extracts raw data using the key path
    /// 2. Applies conditional or standard mapping
    /// 3. Processes the result through nil handling logic
    /// 4. Returns a typed cell value ready for Excel serialization
    ///
    /// - Parameter object: The source object to extract data from
    /// - Returns: Excel-compatible cell value with appropriate type and formatting
    func generateCellValue(
        for object: ObjectType) -> Cell.CellType
    {
        let rawValue = object[keyPath: keyPath]
        let outputValue: OutputType = if let conditionalMapping, let filter {
            conditionalMapping(filter(object), rawValue)
        } else {
            mapping(rawValue)
        }

        return processValueForCell(outputValue)
    }

    /// Applies nil handling logic and converts the output value to a cell type.
    ///
    /// This method implements the column's nil handling strategy, either preserving
    /// empty values or substituting configured defaults. The result is converted to
    /// the appropriate `Cell.CellType` for Excel serialization.
    ///
    /// - Parameter outputValue: The transformed output value from the mapping function
    /// - Returns: Final cell type ready for Excel inclusion
    func processValueForCell(_ outputValue: OutputType) -> Cell.CellType {
        switch nilHandling {
            case .keepEmpty:
                outputValue.cellType
            case let .defaultValue(defaultValue):
                OutputType.withDefaultValue(defaultValue, config: outputValue.config).cellType
        }
    }

    /// Converts this strongly-typed column to a type-erased AnyColumn.
    ///
    /// Type erasure enables storing columns with different generic parameters in
    /// homogeneous collections, essential for building dynamic column configurations
    /// and supporting result builder patterns.
    ///
    /// - Returns: Type-erased column wrapper preserving all functionality
    public func eraseToAnyColumn() -> AnyColumn<ObjectType> {
        AnyColumn(self)
    }
}

// MARK: - Display Condition Modifiers

extension Column {
    /// Sets the display condition for the column.
    /// The column will only be displayed when the condition returns true.
    ///
    /// - Parameter condition: The condition function
    /// - Returns: A new column with the updated condition
    public func when(_ condition: @escaping (ObjectType) -> Bool) -> Self {
        var newSelf = self
        newSelf.when = condition
        return newSelf
    }

    /// Sets the disable condition for the column.
    /// The column will not be displayed when the condition returns true.
    ///
    /// - Parameter condition: The condition function
    /// - Returns: A new column with the updated condition
    public func disable(_ condition: @escaping (ObjectType) -> Bool) -> Self {
        var newSelf = self
        newSelf.when = { !condition($0) }
        return newSelf
    }
}

// MARK: - Style Modifiers

extension Column {
    /// Sets the style for the column's cells (excluding header).
    ///
    /// - Parameter style: The style to apply
    /// - Returns: A new column with the updated style
    public func bodyStyle(_ style: CellStyle?) -> Self {
        var newSelf = self
        newSelf.bodyStyle = style
        return newSelf
    }

    /// Sets the style for the column's header.
    ///
    /// - Parameter style: The style to apply
    /// - Returns: A new column with the updated style
    public func headerStyle(_ style: CellStyle?) -> Self {
        var newSelf = self
        newSelf.headerStyle = style
        return newSelf
    }

    /// Sets the width of the column.
    ///
    /// - Parameter width: The width in characters
    /// - Returns: A new column with the updated width
    public func width(_ width: Int?) -> Self {
        var newSelf = self
        newSelf.width = width
        return newSelf
    }

    /// Sets the name of the column.
    ///
    /// - Parameter name: The new name
    /// - Returns: A new column with the updated name
    public func columnName(_ name: String) -> Self {
        var newSelf = self
        newSelf.name = name
        return newSelf
    }

    /// Sets both header and body styles for the column.
    ///
    /// - Parameters:
    ///   - header: Optional style for the header
    ///   - body: Optional style for the cells
    /// - Returns: A new column with the updated styles
    public func style(header: CellStyle? = nil, body: CellStyle? = nil) -> Self {
        var newSelf = self
        newSelf.headerStyle = header
        newSelf.bodyStyle = body
        return newSelf
    }
}

// MARK: - ColumnOutputType

extension Column where InputType == Double, OutputType == DoubleColumnType {
    /// Creates a column for Double values that will be displayed as numbers.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Double value
    ///   - width: Optional width of the column
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - nilHandling: How to handle nil values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> DoubleColumnType = {
            DoubleColumnType(DoubleColumnConfig(value: $0))
        }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == Int, OutputType == IntColumnType {
    /// Creates a column for Int values that will be displayed as numbers.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Int value
    ///   - width: Optional width of the column
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - nilHandling: How to handle nil values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> IntColumnType = {
            IntColumnType(IntColumnConfig(value: $0))
        }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == String, OutputType == TextColumnType {
    /// Creates a column for String values that will be displayed as text.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the String value
    ///   - width: Optional width of the column
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - nilHandling: How to handle nil values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> TextColumnType = {
            TextColumnType(TextColumnConfig(value: $0))
        }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == Date, OutputType == DateColumnType {
    /// Creates a column for Date values that will be displayed as dates.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Date value
    ///   - width: Optional width of the column
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - nilHandling: How to handle nil values
    ///   - timeZone: The time zone to use for the date
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        timeZone: TimeZone = TimeZone.current)
    {
        let mapping: (InputType) -> DateColumnType = {
            DateColumnType(DateColumnConfig(value: $0, timeZone: timeZone))
        }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == Bool, OutputType == BoolColumnType {
    /// Creates a column for Bool values that will be displayed as booleans.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Bool value
    ///   - width: Optional width of the column
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - nilHandling: How to handle nil values
    ///   - booleanExpressions: The boolean expressions to use for the column
    ///   - caseStrategy: The case strategy to use for the column
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        booleanExpressions: Cell.BooleanExpressions = .oneAndZero,
        caseStrategy: Cell.CaseStrategy = .upper)
    {
        let mapping: (InputType) -> BoolColumnType = {
            BoolColumnType(BoolColumnConfig(
                value: $0,
                booleanExpressions: booleanExpressions,
                caseStrategy: caseStrategy))
        }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == URL, OutputType == URLColumnType {
    /// Creates a column for URL values that will be displayed as URLs.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the URL value
    ///   - width: Optional width of the column
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - nilHandling: How to handle nil values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty)
    {
        let mapping: (InputType) -> URLColumnType = {
            URLColumnType(URLColumnConfig(value: $0))
        }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

extension Column where InputType == Double, OutputType == PercentageColumnType {
    /// Creates a column for Percentage values that will be displayed as percentages.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Percentage value
    ///   - width: Optional width of the column
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - nilHandling: How to handle nil values
    ///   - precision: The precision to use for the column
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, InputType>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<OutputType> = .keepEmpty,
        precision: Int = 2)
    {
        let mapping: (InputType) -> PercentageColumnType = {
            PercentageColumnType(PercentageColumnConfig(value: $0, precision: precision))
        }
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

// MARK: - Simplified Mapping Extensions

// MARK: - Instance Convenience Methods

extension Column where InputType == Double {
    /// Converts this column to use percentage formatting with specified precision.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Rate", keyPath: \.rate).percentage(precision: 1)
    /// ```
    ///
    /// - Parameter precision: The precision for percentage display (default: 2)
    /// - Returns: A configured percentage column
    public func percentage(precision: Int = 2) -> Column<ObjectType, Double, PercentageColumnType> {
        Column<ObjectType, Double, PercentageColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                PercentageColumnType(PercentageColumnConfig(value: value, precision: precision))
            },
            nilHandling: .keepEmpty)
    }

    /// Converts this column to use double formatting.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Price", keyPath: \.price).double()
    /// ```
    ///
    /// - Returns: A configured double column
    public func double() -> Column<ObjectType, Double, DoubleColumnType> {
        Column<ObjectType, Double, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column where InputType == Double? {
    /// Converts this column to use percentage formatting with specified precision for optional Double values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Rate", keyPath: \.rate).percentage(precision: 1)
    /// ```
    ///
    /// - Parameter precision: The precision for percentage display (default: 2)
    /// - Returns: A configured percentage column
    public func percentage(precision: Int = 2) -> Column<ObjectType, Double?, PercentageColumnType> {
        Column<ObjectType, Double?, PercentageColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                PercentageColumnType(PercentageColumnConfig(value: value, precision: precision))
            },
            nilHandling: .keepEmpty)
    }

    /// Converts this column to use double formatting for optional Double values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Price", keyPath: \.price).double()
    /// ```
    ///
    /// - Returns: A configured double column
    public func double() -> Column<ObjectType, Double?, DoubleColumnType> {
        Column<ObjectType, Double?, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column where InputType == String {
    /// Converts this column to use text formatting.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Name", keyPath: \.name).text()
    /// ```
    ///
    /// - Returns: A configured text column
    public func text() -> Column<ObjectType, String, TextColumnType> {
        Column<ObjectType, String, TextColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                TextColumnType(TextColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column where InputType == Int {
    /// Converts this column to use integer formatting.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Age", keyPath: \.age).int()
    /// ```
    ///
    /// - Returns: A configured integer column
    public func int() -> Column<ObjectType, Int, IntColumnType> {
        Column<ObjectType, Int, IntColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                IntColumnType(IntColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column where InputType == Date {
    /// Converts this column to use date formatting.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Birth Date", keyPath: \.birthDate).date(timeZone: .utc)
    /// ```
    ///
    /// - Parameter timeZone: The time zone to use (default: current)
    /// - Returns: A configured date column
    public func date(timeZone: TimeZone = TimeZone.current) -> Column<ObjectType, Date, DateColumnType> {
        Column<ObjectType, Date, DateColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                DateColumnType(DateColumnConfig(value: value, timeZone: timeZone))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column where InputType == Bool {
    /// Converts this column to use boolean formatting.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Active", keyPath: \.isActive).boolean(expressions: .yesAndNo)
    /// ```
    ///
    /// - Parameters:
    ///   - expressions: The boolean expressions to use (default: .trueAndFalse)
    ///   - caseStrategy: The case strategy to use (default: .upper)
    /// - Returns: A configured boolean column
    public func boolean(expressions: Cell.BooleanExpressions = .trueAndFalse, caseStrategy: Cell.CaseStrategy = .upper) -> Column<ObjectType, Bool, BoolColumnType> {
        Column<ObjectType, Bool, BoolColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                BoolColumnType(BoolColumnConfig(
                    value: value,
                    booleanExpressions: expressions,
                    caseStrategy: caseStrategy))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column where InputType == URL {
    /// Converts this column to use URL formatting.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Website", keyPath: \.website).url()
    /// ```
    ///
    /// - Returns: A configured URL column
    public func url() -> Column<ObjectType, URL, URLColumnType> {
        Column<ObjectType, URL, URLColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                URLColumnType(URLColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

// MARK: - Static Convenience Methods

extension Column {
    /// Creates a column with simplified percentage mapping syntax.
    ///
    /// Example usage:
    /// ```swift
    /// Column.percentage("Rate", keyPath: \.rate, precision: 1)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Double value
    ///   - precision: The precision for percentage display (default: 2)
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured percentage column
    public static func percentage(
        _ name: String,
        keyPath: KeyPath<ObjectType, Double>,
        precision: Int = 2,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<PercentageColumnType> = .keepEmpty) -> Column<ObjectType, Double, PercentageColumnType>
    {
        Column<ObjectType, Double, PercentageColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                PercentageColumnType(PercentageColumnConfig(value: value, precision: precision))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified percentage mapping syntax for optional Double values.
    ///
    /// Example usage:
    /// ```swift
    /// Column.percentage("Rate", keyPath: \.rate, precision: 1)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the optional Double value
    ///   - precision: The precision for percentage display (default: 2)
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured percentage column
    public static func percentage(
        _ name: String,
        keyPath: KeyPath<ObjectType, Double?>,
        precision: Int = 2,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<PercentageColumnType> = .keepEmpty) -> Column<ObjectType, Double?, PercentageColumnType>
    {
        Column<ObjectType, Double?, PercentageColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                PercentageColumnType(PercentageColumnConfig(value: value, precision: precision))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified text mapping syntax.
    ///
    /// Example usage:
    /// ```swift
    /// Column.text("Name", keyPath: \.name)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the String value
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured text column
    public static func text(
        _ name: String,
        keyPath: KeyPath<ObjectType, String>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<TextColumnType> = .keepEmpty) -> Column<ObjectType, String, TextColumnType>
    {
        Column<ObjectType, String, TextColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                TextColumnType(TextColumnConfig(value: value))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified double mapping syntax.
    ///
    /// Example usage:
    /// ```swift
    /// Column.double("Price", keyPath: \.price)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Double value
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured double column
    public static func double(
        _ name: String,
        keyPath: KeyPath<ObjectType, Double>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<DoubleColumnType> = .keepEmpty) -> Column<ObjectType, Double, DoubleColumnType>
    {
        Column<ObjectType, Double, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified double mapping syntax for optional Double values.
    ///
    /// Example usage:
    /// ```swift
    /// Column.double("Price", keyPath: \.price)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the optional Double value
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured double column
    public static func double(
        _ name: String,
        keyPath: KeyPath<ObjectType, Double?>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<DoubleColumnType> = .keepEmpty) -> Column<ObjectType, Double?, DoubleColumnType>
    {
        Column<ObjectType, Double?, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified integer mapping syntax.
    ///
    /// Example usage:
    /// ```swift
    /// Column.int("Age", keyPath: \.age)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Int value
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured integer column
    public static func int(
        _ name: String,
        keyPath: KeyPath<ObjectType, Int>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<IntColumnType> = .keepEmpty) -> Column<ObjectType, Int, IntColumnType>
    {
        Column<ObjectType, Int, IntColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                IntColumnType(IntColumnConfig(value: value))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified date mapping syntax.
    ///
    /// Example usage:
    /// ```swift
    /// Column.date("Birth Date", keyPath: \.birthDate, timeZone: .utc)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Date value
    ///   - timeZone: The time zone to use (default: current)
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured date column
    public static func date(
        _ name: String,
        keyPath: KeyPath<ObjectType, Date>,
        timeZone: TimeZone = TimeZone.current,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<DateColumnType> = .keepEmpty) -> Column<ObjectType, Date, DateColumnType>
    {
        Column<ObjectType, Date, DateColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                DateColumnType(DateColumnConfig(value: value, timeZone: timeZone))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified boolean mapping syntax.
    ///
    /// Example usage:
    /// ```swift
    /// Column.boolean("Active", keyPath: \.isActive, expressions: .yesAndNo)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the Bool value
    ///   - expressions: The boolean expressions to use (default: .trueAndFalse)
    ///   - caseStrategy: The case strategy to use (default: .upper)
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured boolean column
    public static func boolean(
        _ name: String,
        keyPath: KeyPath<ObjectType, Bool>,
        expressions: Cell.BooleanExpressions = .trueAndFalse,
        caseStrategy: Cell.CaseStrategy = .upper,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<BoolColumnType> = .keepEmpty) -> Column<ObjectType, Bool, BoolColumnType>
    {
        Column<ObjectType, Bool, BoolColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                BoolColumnType(BoolColumnConfig(
                    value: value,
                    booleanExpressions: expressions,
                    caseStrategy: caseStrategy))
            },
            nilHandling: nilHandling)
    }

    /// Creates a column with simplified URL mapping syntax.
    ///
    /// Example usage:
    /// ```swift
    /// Column.url("Website", keyPath: \.website)
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract the URL value
    ///   - width: Optional column width
    ///   - bodyStyle: Optional styling for data cells
    ///   - headerStyle: Optional styling for header cell
    ///   - nilHandling: How to handle nil values
    /// - Returns: A configured URL column
    public static func url(
        _ name: String,
        keyPath: KeyPath<ObjectType, URL>,
        width: Int? = nil,
        bodyStyle: CellStyle? = nil,
        headerStyle: CellStyle? = nil,
        nilHandling: TypedNilHandling<URLColumnType> = .keepEmpty) -> Column<ObjectType, URL, URLColumnType>
    {
        Column<ObjectType, URL, URLColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { value in
                URLColumnType(URLColumnConfig(value: value))
            },
            nilHandling: nilHandling)
    }
}

// MARK: - Simplified Column Declaration for Double Types

extension Column {
    /// Creates a simplified column for non-optional Double values with automatic type mapping.
    ///
    /// This convenience initializer eliminates the need for explicit mapping when working with
    /// non-optional Double properties, providing a cleaner syntax for common use cases.
    ///
    /// Example usage:
    /// ```swift
    /// // Instead of verbose mapping:
    /// Column(name: "Price", keyPath: \.price, mapping: { DoubleColumnType(DoubleColumnConfig(value: $0)) })
    ///
    /// // Use simplified syntax:
    /// Column(name: "Price", keyPath: \.price)
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional Double property
    /// - Returns: A configured column that automatically maps Double values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Double>) where InputType == Double, OutputType == DoubleColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a simplified column for non-optional Double values with width specification.
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional Double property
    ///   - width: Column width in character units
    /// - Returns: A configured column that automatically maps Double values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Double>,
        width: Int) where InputType == Double, OutputType == DoubleColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a simplified column for optional Double values with automatic type mapping.
    ///
    /// This convenience initializer provides simplified syntax for optional Double properties.
    /// By default, nil values are kept as empty cells, but this can be modified using
    /// the `.defaultValue()` method.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic optional column:
    /// Column(name: "Salary", keyPath: \.salary)  // nil -> empty cell
    ///
    /// // With default value:
    /// Column(name: "Salary", keyPath: \.salary).defaultValue(0.0)  // nil -> 0.0
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional Double property
    /// - Returns: A configured column that automatically maps optional Double values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Double?>) where InputType == Double?, OutputType == DoubleColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a simplified column for optional Double values with width specification.
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional Double property
    ///   - width: Column width in character units
    /// - Returns: A configured column that automatically maps optional Double values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Double?>,
        width: Int) where InputType == Double?, OutputType == DoubleColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                DoubleColumnType(DoubleColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

// MARK: - Chainable Configuration Methods for Optional Double Columns

extension Column where InputType == Double?, OutputType == DoubleColumnType {
    /// Sets a default value to use when the source property is nil.
    ///
    /// This method transforms an optional Double column into one that uses a specified
    /// default value instead of empty cells for nil values.
    ///
    /// Example usage:
    /// ```swift
    /// Column(name: "Salary", keyPath: \.salary)
    ///     .defaultValue(0.0)  // nil salaries become 0.0
    ///     .bodyStyle(currencyStyle)
    /// ```
    ///
    /// - Parameter defaultValue: The Double value to use when the source is nil
    /// - Returns: A new column that replaces nil values with the default value
    public func defaultValue(_ defaultValue: Double) -> Column<ObjectType, Double?, DoubleColumnType> {
        Column<ObjectType, Double?, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: .defaultValue(defaultValue))
    }
}

// MARK: - Chainable Style Configuration for Simplified Double Columns

extension Column where OutputType == DoubleColumnType {
    /// Sets the body style for data cells in this column.
    ///
    /// - Parameter style: The CellStyle to apply to data cells
    /// - Returns: A new column instance with the specified body style
    public func bodyStyle(_ style: CellStyle) -> Column<ObjectType, InputType, DoubleColumnType> {
        Column<ObjectType, InputType, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: style,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }

    /// Sets the header style for the header cell in this column.
    ///
    /// - Parameter style: The CellStyle to apply to the header cell
    /// - Returns: A new column instance with the specified header style
    public func headerStyle(_ style: CellStyle) -> Column<ObjectType, InputType, DoubleColumnType> {
        Column<ObjectType, InputType, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: style,
            mapping: mapping,
            nilHandling: nilHandling)
    }

    /// Sets the column width.
    ///
    /// - Parameter width: The width in character units
    /// - Returns: A new column instance with the specified width
    public func width(_ width: Int) -> Column<ObjectType, InputType, DoubleColumnType> {
        Column<ObjectType, InputType, DoubleColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: mapping,
            nilHandling: nilHandling)
    }
}

// MARK: - Value Transformation Methods

extension Column {
    /// Transforms column values to String using a custom conversion closure.
    ///
    /// This method provides a universal way to convert any column output type to string representations.
    /// The closure receives the processed value based on the column's nilHandling configuration:
    /// - For columns with `.keepEmpty`: receives T? (may be nil)
    /// - For columns with `.defaultValue`: receives T (never nil, default applied)
    ///
    /// Example usage:
    /// ```swift
    /// // For optional values without defaultValue
    /// Column(name: "Bonus", keyPath: \.bonus)
    ///     .toString { (bonus: Double?) in
    ///         guard let bonus = bonus else { return "No Bonus" }
    ///         return bonus > 1000 ? "High" : "Low"
    ///     }
    ///
    /// // For optional values with defaultValue
    /// Column(name: "Salary", keyPath: \.salary)
    ///     .defaultValue(0.0)
    ///     .toString { (salary: Double) in  // Non-optional after defaultValue!
    ///         salary < 50000 ? "Standard" : "Premium"
    ///     }
    ///
    /// // For non-optional values
    /// Column(name: "Age", keyPath: \.age)
    ///     .toString { (age: Int) in
    ///         age < 18 ? "Minor" : "Adult"
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the processed value to String
    /// - Returns: A new column that outputs TextColumnType with transformed values
    public func toString<T>(
        _ transform: @escaping (T) -> String) -> Column<ObjectType, InputType, TextColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, TextColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { input in
                // First apply the original mapping
                let originalOutput = self.mapping(input)

                // Apply nilHandling logic to get the final processed output
                let processedOutput = switch self.nilHandling {
                    case .keepEmpty:
                        originalOutput
                    case let .defaultValue(defaultValue):
                        OutputType.withDefaultValue(defaultValue, config: originalOutput.config)
                }

                // Extract the value from the processed output (now with defaults applied)
                let finalValue = processedOutput.config.value

                // Apply the transformation - when defaultValue is used, finalValue is guaranteed to be non-nil
                let stringValue: String = switch self.nilHandling {
                    case .keepEmpty:
                        // For keepEmpty, we need to handle nil safely
                        if let finalValue {
                            transform(finalValue)
                        } else {
                            // This shouldn't happen with the current API, but handle gracefully
                            transform(finalValue!)
                        }
                    case .defaultValue:
                        // For defaultValue, finalValue is guaranteed to be non-nil
                        transform(finalValue!)
                }

                // Return TextColumnType
                return TextColumnType(TextColumnConfig(value: stringValue))
            },
            nilHandling: .keepEmpty // String output is never nil
        )
    }

    /// Transforms column values to String using a custom conversion closure that handles optional values.
    ///
    /// This overload is for columns that may contain nil values (when nilHandling is .keepEmpty).
    /// Use this when you need to explicitly handle nil cases in your transformation.
    ///
    /// Example usage:
    /// ```swift
    /// // For handling optional values explicitly
    /// Column(name: "Bonus", keyPath: \.bonus)
    ///     .toString { (bonus: Double?) in
    ///         guard let bonus = bonus else { return "No Bonus" }
    ///         return bonus > 1000 ? "High" : "Low"
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the optional value to String
    /// - Returns: A new column that outputs TextColumnType with transformed values
    public func toString<T>(
        _ transform: @escaping (T?) -> String) -> Column<ObjectType, InputType, TextColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, TextColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { input in
                // First apply the original mapping
                let originalOutput = self.mapping(input)

                // Apply nilHandling logic to get the final processed output
                let processedOutput = switch self.nilHandling {
                    case .keepEmpty:
                        originalOutput
                    case let .defaultValue(defaultValue):
                        OutputType.withDefaultValue(defaultValue, config: originalOutput.config)
                }

                // Extract the value from the processed output
                let finalValue = processedOutput.config.value

                // Apply the transformation with optional handling
                let stringValue = transform(finalValue)

                // Return TextColumnType
                return TextColumnType(TextColumnConfig(value: stringValue))
            },
            nilHandling: .keepEmpty // String output is never nil
        )
    }
}
