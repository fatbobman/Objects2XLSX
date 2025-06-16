//
// Column.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents a column in an Excel sheet.
///
/// `Column` is a generic structure that defines how data from an object should be displayed in an
/// Excel column.
/// It provides type-safe mapping from your object's properties to Excel cell values, along with
/// styling and formatting options.
///
/// - Parameters:
///   - ObjectType: The type of object that contains the data to be displayed
///   - InputType: The type of data that will be extracted from the object
///   - OutputType: The type that will be used to represent the data in Excel（ColumnTypeProtocol）
public struct Column<ObjectType, InputType, OutputType>: ColumnProtocol
where OutputType: ColumnOutputTypeProtocol {
    /// The name of the column as it will appear in the Excel sheet
    public var name: String

    /// The width of the column in characters
    public var width: Int?

    /// Defines how nil values should be handled in the column
    /// - keepEmpty: Keep empty value as empty
    /// - defaultValue: Use default value as empty
    public let nilHandling: TypedNilHandling<OutputType>

    /// The style to be applied to the column's cells (excluding header)
    public var bodyStyle: CellStyle?

    /// The style to be applied to the column's header cell
    public var headerStyle: CellStyle?

    /// The key path used to extract data from the object
    public let keyPath: KeyPath<ObjectType, InputType>

    /// A function that maps the input data to the output type
    public let mapping: (InputType) -> OutputType

    /// Optional conditional mapping function for different output based on a condition
    public var conditionalMapping: ((Bool, InputType) -> OutputType)?

    /// Optional filter function to determine if the column should be included
    public var filter: ((ObjectType) -> Bool)?

    /// A function that determines whether the column should be displayed for a given object
    public var when: (ObjectType) -> Bool

    /// Creates a new column with the specified parameters.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract data from the object
    ///   - width: Optional width of the column in characters
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - mapping: Function to map input data to output type
    ///   - nilHandling: How to handle nil values
    ///   - when: Function to determine if the column should be displayed
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

    /// Creates a conditional column that can display different values based on a condition.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to extract data from the object
    ///   - width: Optional width of the column in characters
    ///   - bodyStyle: Optional style for the column's cells
    ///   - headerStyle: Optional style for the column's header
    ///   - filter: Function to determine which mapping to use
    ///   - thenMapping: Mapping function to use when filter returns true
    ///   - elseMapping: Mapping function to use when filter returns false
    ///   - nilHandling: How to handle nil values
    ///   - when: Function to determine if the column should be displayed
    /// - Returns: A new conditional column
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

    /// Generates a cell for the given object at the specified position.
    ///
    /// - Parameters:
    ///   - object: The object to generate the cell for
    ///   - row: The row index
    ///   - column: The column index
    ///   - bodyStyleID: Optional style ID for the cell body
    ///   - headerStyleID: Optional style ID for the header
    ///   - isHeader: Whether this is a header cell
    /// - Returns: A Cell instance
    func generateCell(
        for object: ObjectType,
        row: Int,
        column: Int,
        bodyStyleID: Int? = nil,
        headerStyleID: Int? = nil,
        isHeader: Bool = false) -> Cell
    {
        let rawValue = object[keyPath: keyPath]
        let outputValue: OutputType = if let conditionalMapping, let filter {
            conditionalMapping(filter(object), rawValue)
        } else {
            mapping(rawValue)
        }

        // 应用 nilHandling 处理并转换为 CellType
        let cellValue = processValueForCell(outputValue)

        // 根据是否为header选择合适的styleID
        let finalStyleID = isHeader ? headerStyleID : bodyStyleID

        return Cell(row: row, column: column, value: cellValue, styleID: finalStyleID)
    }

    /// Processes the output value according to nilHandling settings and converts it to a
    /// Cell.CellType.
    ///
    /// - Parameter outputValue: The value to process
    /// - Returns: A Cell.CellType instance
    func processValueForCell(_ outputValue: OutputType) -> Cell.CellType {
        switch nilHandling {
            case .keepEmpty:
                outputValue.cellType
            case let .defaultValue(defaultValue):
                OutputType.withDefaultValue(defaultValue, config: outputValue.config).cellType
        }
    }

    /// Converts the column to a type-erased AnyColumn.
    ///
    /// - Returns: An AnyColumn instance
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
