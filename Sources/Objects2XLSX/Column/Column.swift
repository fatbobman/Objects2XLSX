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
    init(
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

    /// Creates a conditional column that applies different data transformations based on object
    /// state.
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
    static func conditional(
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
    init(
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
    init(
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
    init(
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
    init(
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
    init(
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
    init(
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
    init(
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
    /// Column(name: "Price", keyPath: \.price, mapping: {
    /// DoubleColumnType(DoubleColumnConfig(value: $0)) })
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
        keyPath: KeyPath<ObjectType, Double>) where InputType == Double,
        OutputType == DoubleColumnType
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
        keyPath: KeyPath<ObjectType, Double?>) where InputType == Double?,
        OutputType == DoubleColumnType
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
}

// MARK: - Simplified Column Declaration for Int Types

extension Column {
    /// Creates a simplified column for non-optional Int values with automatic type mapping.
    ///
    /// This convenience initializer eliminates the need for explicit mapping when working with
    /// non-optional Int properties, providing a cleaner syntax for common use cases.
    ///
    /// Example usage:
    /// ```swift
    /// // Instead of verbose mapping:
    /// Column(name: "Count", keyPath: \.count, mapping: { IntColumnType(IntColumnConfig(value: $0))
    /// })
    ///
    /// // Use simplified syntax:
    /// Column(name: "Count", keyPath: \.count)
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional Int property
    /// - Returns: A configured column that automatically maps Int values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Int>) where InputType == Int, OutputType == IntColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                IntColumnType(IntColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a simplified column for optional Int values with automatic type mapping.
    ///
    /// This convenience initializer provides simplified syntax for optional Int properties.
    /// By default, nil values are kept as empty cells, but this can be modified using
    /// the `.defaultValue()` method.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic optional column:
    /// Column(name: "Quantity", keyPath: \.quantity)  // nil -> empty cell
    ///
    /// // With default value:
    /// Column(name: "Quantity", keyPath: \.quantity).defaultValue(0)  // nil -> 0
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional Int property
    /// - Returns: A configured column that automatically maps optional Int values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Int?>) where InputType == Int?, OutputType == IntColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                IntColumnType(IntColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

// MARK: - Simplified Column Declaration for String Types

extension Column {
    /// Creates a simplified column for non-optional String values with automatic type mapping.
    ///
    /// This convenience initializer eliminates the need for explicit mapping when working with
    /// non-optional String properties, providing a cleaner syntax for common use cases.
    ///
    /// Example usage:
    /// ```swift
    /// // Instead of verbose mapping:
    /// Column(name: "Name", keyPath: \.name, mapping: { TextColumnType(TextColumnConfig(value: $0))
    /// })
    ///
    /// // Use simplified syntax:
    /// Column(name: "Name", keyPath: \.name)
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional String property
    /// - Returns: A configured column that automatically maps String values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, String>) where InputType == String,
        OutputType == TextColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                TextColumnType(TextColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a simplified column for optional String values with automatic type mapping.
    ///
    /// This convenience initializer provides simplified syntax for optional String properties.
    /// By default, nil values are kept as empty cells, but this can be modified using
    /// the `.defaultValue()` method.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic optional column:
    /// Column(name: "Description", keyPath: \.description)  // nil -> empty cell
    ///
    /// // With default value:
    /// Column(name: "Description", keyPath: \.description).defaultValue("N/A")  // nil -> "N/A"
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional String property
    /// - Returns: A configured column that automatically maps optional String values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, String?>) where InputType == String?,
        OutputType == TextColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                TextColumnType(TextColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

// MARK: - Simplified Column Declaration for Date Types

extension Column {
    /// Creates a simplified column for non-optional Date values with automatic type mapping.
    ///
    /// This convenience initializer eliminates the need for explicit mapping when working with
    /// non-optional Date properties. Uses the current system timezone by default.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Created At", keyPath: \.createdAt)
    ///
    /// // With custom timezone:
    /// Column(name: "Created At", keyPath: \.createdAt, timezone: TimeZone(identifier: "UTC")!)
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional Date property
    ///   - timeZone: Timezone for date interpretation (default: current system timezone)
    /// - Returns: A configured column that automatically maps Date values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Date>,
        timeZone: TimeZone = .current) where InputType == Date, OutputType == DateColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                DateColumnType(DateColumnConfig(value: value, timeZone: timeZone))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a column for optional Date values that will be displayed as dates.
    ///
    /// This is a convenience initializer that automatically maps optional Date values
    /// to DateColumnType without requiring explicit column configuration. Uses the
    /// current system timezone by default.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Modified Date", keyPath: \.modifiedDate)  // nil -> empty cell
    ///
    /// // With default value:
    /// Column(name: "Due Date", keyPath: \.dueDate).defaultValue(Date())  // nil -> current date
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional Date property
    ///   - timeZone: Timezone for date interpretation (default: current system timezone)
    /// - Returns: A configured column that automatically maps optional Date values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Date?>,
        timeZone: TimeZone = .current) where InputType == Date?, OutputType == DateColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                DateColumnType(DateColumnConfig(value: value, timeZone: timeZone))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column {
    /// Creates a column for non-optional URL values that will be displayed as URLs.
    ///
    /// This is a convenience initializer that automatically maps non-optional URL values
    /// to URLColumnType without requiring explicit column configuration.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Website", keyPath: \.website)
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional URL property
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, URL>) where InputType == URL, OutputType == URLColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                URLColumnType(URLColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a column for optional URL values that will be displayed as URLs.
    ///
    /// This is a convenience initializer that automatically maps optional URL values
    /// to URLColumnType without requiring explicit column configuration.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Website", keyPath: \.website)  // nil -> empty cell
    ///
    /// // With default value:
    /// Column(name: "Homepage", keyPath: \.homepage).defaultValue(URL(string:
    /// "https://example.com")!)  // nil -> default URL
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional URL property
    /// - Returns: A configured column that automatically maps optional URL values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, URL?>) where InputType == URL?, OutputType == URLColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                URLColumnType(URLColumnConfig(value: value))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column {
    /// Creates a column for non-optional Bool values that will be displayed as boolean text.
    ///
    /// This is a convenience initializer that automatically maps non-optional Bool values
    /// to BoolColumnType without requiring explicit column configuration.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Is Active", keyPath: \.isActive)  // true -> "1", false -> "0"
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional Bool property
    ///   - booleanExpressions: The boolean expressions to use for the column (default: oneAndZero)
    ///   - caseStrategy: The case strategy to use for the column (default: upper)
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Bool>,
        booleanExpressions: Cell.BooleanExpressions = .oneAndZero,
        caseStrategy: Cell.CaseStrategy = .upper) where InputType == Bool,
        OutputType == BoolColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                BoolColumnType(BoolColumnConfig(
                    value: value,
                    booleanExpressions: booleanExpressions,
                    caseStrategy: caseStrategy))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a column for optional Bool values that will be displayed as boolean text.
    ///
    /// This is a convenience initializer that automatically maps optional Bool values
    /// to BoolColumnType without requiring explicit column configuration.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Is Active", keyPath: \.isActive)  // nil -> empty cell, true -> "1", false ->
    /// "0"
    ///
    /// // With default value:
    /// Column(name: "Is Premium", keyPath: \.isPremium).defaultValue(false)  // nil -> false
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional Bool property
    ///   - booleanExpressions: The boolean expressions to use for the column (default: oneAndZero)
    ///   - caseStrategy: The case strategy to use for the column (default: upper)
    /// - Returns: A configured column that automatically maps optional Bool values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Bool?>,
        booleanExpressions: Cell.BooleanExpressions = .oneAndZero,
        caseStrategy: Cell.CaseStrategy = .upper) where InputType == Bool?,
        OutputType == BoolColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                BoolColumnType(BoolColumnConfig(
                    value: value,
                    booleanExpressions: booleanExpressions,
                    caseStrategy: caseStrategy))
            },
            nilHandling: .keepEmpty)
    }
}

extension Column {
    /// Creates a column for non-optional Percentage values that will be displayed as percentages.
    ///
    /// This is a convenience initializer that automatically maps non-optional Double values
    /// to PercentageColumnType without requiring explicit column configuration.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Growth Rate", keyPath: \.growthRate)  // 0.5 -> 50%
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to a non-optional Double property (as decimal: 0.5 = 50%)
    ///   - precision: Number of decimal places to display in percentage format (default: 2)
    /// - Returns: A configured column that automatically maps non-optional percentage values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Double>,
        precision: Int = 2) where InputType == Double, OutputType == PercentageColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                PercentageColumnType(PercentageColumnConfig(value: value, precision: precision))
            },
            nilHandling: .keepEmpty)
    }

    /// Creates a column for optional Percentage values that will be displayed as percentages.
    ///
    /// This is a convenience initializer that automatically maps optional Double values
    /// to PercentageColumnType without requiring explicit column configuration.
    ///
    /// Example usage:
    /// ```swift
    /// // Basic usage:
    /// Column(name: "Growth Rate", keyPath: \.growthRate)  // nil -> empty cell, 0.5 -> 50%
    ///
    /// // With default value:
    /// Column(name: "Accuracy", keyPath: \.accuracy).defaultValue(0.0)  // nil -> 0%
    ///
    /// // With custom precision:
    /// Column(name: "Success Rate", keyPath: \.successRate, precision: 1)  // 0.567 -> 56.7%
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name in the Excel header row
    ///   - keyPath: KeyPath to an optional Double property (as decimal: 0.5 = 50%)
    ///   - precision: Number of decimal places to display in percentage format (default: 2)
    /// - Returns: A configured column that automatically maps optional percentage values
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, Double?>,
        precision: Int = 2) where InputType == Double?, OutputType == PercentageColumnType
    {
        self.init(
            name: name,
            keyPath: keyPath,
            width: nil,
            bodyStyle: nil,
            headerStyle: nil,
            mapping: { value in
                PercentageColumnType(PercentageColumnConfig(value: value, precision: precision))
            },
            nilHandling: .keepEmpty)
    }
}

// MARK: - Sendable Conformance

extension Column: @unchecked Sendable where ObjectType: Sendable, InputType: Sendable,
OutputType: Sendable {}
