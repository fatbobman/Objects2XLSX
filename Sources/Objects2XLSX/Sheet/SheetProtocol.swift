//
// SheetProtocol.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Protocol defining the core functionality for worksheet implementations.
 
 `SheetProtocol` establishes the contract that all sheet types must fulfill
 to participate in the Excel generation process. It defines the essential
 operations needed to convert typed object data into Excel-compatible XML.
 
 ## Overview
 
 This protocol serves as the foundation for the sheet system, enabling:
 - Type-safe object-to-worksheet conversion
 - Uniform interface for XML generation
 - Integration with the broader Excel generation pipeline
 - Extensibility for custom sheet implementations
 
 ## Associated Type
 
 The `ObjectType` associated type represents the Swift objects that will
 be converted into worksheet rows. This provides compile-time type safety
 while allowing different sheet implementations for different data types.
 
 ## Implementation Requirements
 
 Conforming types must:
 1. Provide a worksheet name for Excel tabs
 2. Convert object arrays to SheetXML format
 3. Integrate with the styling and string sharing systems
 
 ## Usage
 
 This protocol is primarily implemented by the `Sheet<ObjectType>` class
 and is not typically implemented directly by client code.
 
 ```swift
 // The main implementation
 public final class Sheet<ObjectType>: SheetProtocol {
     // ... implementation
 }
 ```
 */
protocol SheetProtocol<ObjectType> {
    
    /**
     The type of objects that this sheet can process.
     
     This associated type provides compile-time type safety, ensuring that
     the sheet can only work with objects of the specified type.
     */
    associatedtype ObjectType

    /**
     The name of the worksheet.
     
     This name appears on the worksheet tab in Excel and must comply
     with Excel naming requirements (handled by name sanitization).
     */
    var name: String { get }

    /**
     Generates the XML representation of the worksheet from object data.
     
     This is the core method that converts an array of typed objects into
     the XML format required by Excel files. It integrates with the styling
     and string sharing systems to produce optimized output.
     
     - Parameters:
        - objects: The array of objects to convert into worksheet rows
        - bookStyle: The workbook-level styling configuration
        - styleRegister: Registry for managing and deduplicating cell styles
        - shareStringRegistor: Registry for managing shared strings
     
     - Returns: A `SheetXML` object containing the complete worksheet XML,
       or `nil` if generation fails
     
     ## Implementation Notes
     
     Implementations should:
     1. Filter columns based on the first object's properties
     2. Generate header rows if enabled
     3. Convert each object to appropriately styled data rows
     4. Apply worksheet-level styling and formatting
     5. Handle edge cases like empty data sets gracefully
     
     ## Example Implementation Pattern
     
     ```swift
     func makeSheetXML(
         with objects: [ObjectType],
         bookStyle: BookStyle,
         styleRegister: StyleRegister,
         shareStringRegistor: ShareStringRegister
     ) -> SheetXML? {
         let columns = activeColumns(objects: objects)
         var rows: [Row] = []
         
         // Generate header if needed
         if hasHeader {
             rows.append(generateHeaderRow(...))
         }
         
         // Generate data rows
         for object in objects {
             rows.append(generateDataRow(object: object, ...))
         }
         
         return SheetXML(name: name, rows: rows, style: mergedStyle)
     }
     ```
     */
    func makeSheetXML(
        with objects: [ObjectType],
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML?
}
