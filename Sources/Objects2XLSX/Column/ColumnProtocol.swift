//
// ColumnProtocol.swift
// Created by Xu Yang on 2025-06-06.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Internal protocol that defines the core interface for column implementations.
///
/// `ColumnProtocol` establishes the fundamental contract that all column types must fulfill
/// to participate in Excel sheet generation. This protocol is primarily used internally
/// by the framework to ensure consistent behavior across different column implementations.
///
/// ## Core Responsibilities
/// - **Metadata Provision**: Supplies display name, width, and styling information
/// - **Conditional Display**: Determines when columns should appear based on data
/// - **Value Generation**: Converts object data to Excel-compatible cell values
/// - **Type Safety**: Maintains compile-time type safety for object types
///
/// ## Implementation Note
/// This is an internal protocol. External users typically work with the concrete
/// `Column<ObjectType, InputType, OutputType>` struct which implements this protocol
/// and provides additional type safety and functionality.
protocol ColumnProtocol<ObjectType> {
    /// The type of object this column can process for data extraction
    associatedtype ObjectType

    /// Display name for the column header in Excel
    var name: String { get }
    
    /// Optional column width in Excel character units (nil = auto-width)
    var width: Int? { get }
    
    /// Optional styling for data cells in this column (excluding header)
    var bodyStyle: CellStyle? { get }
    
    /// Optional styling for the header cell of this column
    var headerStyle: CellStyle? { get }
    
    /// Visibility predicate that determines if this column should appear for a given object.
    ///
    /// This closure enables conditional column display based on object state or properties.
    /// When the closure returns `false`, the column is excluded from the Excel output.
    var when: (ObjectType) -> Bool { get }

    /// Generates an Excel-compatible cell value from the given object.
    ///
    /// This method encapsulates all type-specific operations needed to extract data
    /// from the object and convert it to a format suitable for Excel serialization.
    /// The implementation should handle key path extraction, data transformation,
    /// and nil value processing.
    ///
    /// - Parameter object: The source object to extract column data from
    /// - Returns: Excel-compatible cell value ready for serialization
    func generateCellValue(
        for object: ObjectType) -> Cell.CellType
}
