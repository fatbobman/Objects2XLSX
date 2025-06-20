//
// SheetBuilder.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 A result builder for creating collections of worksheets using a declarative syntax.
 
 `SheetBuilder` enables the creation of multiple worksheets in a clean, SwiftUI-like syntax
 within the `Book` initializer. It handles type erasure automatically, allowing sheets with
 different object types to be combined into a single collection.
 
 ## Overview
 
 The builder pattern allows for intuitive worksheet construction without the need for
 manual array creation or type erasure calls. It supports various Swift constructs
 including conditionals, loops, and optional values.
 
 ## Features
 
 - **Type Safety**: Automatically converts typed `Sheet<ObjectType>` to `AnySheet`
 - **Flexible Syntax**: Supports conditional statements, loops, and optional values
 - **Clean Code**: Eliminates boilerplate code for sheet collection creation
 - **SwiftUI-like**: Familiar syntax for developers using SwiftUI
 
 ## Usage
 
 ```swift
 let book = Book(style: BookStyle()) {
     // Single sheet
     Sheet<Person>(name: "Employees") { employees } {
         Column("Name", keyPath: \.name)
         Column("Age", keyPath: \.age)
     }
     
     // Conditional sheet
     if includeProducts {
         Sheet<Product>(name: "Products") { products } {
             Column("Name", keyPath: \.name)
             Column("Price", keyPath: \.price)
         }
     }
     
     // Loop-generated sheets
     for department in departments {
         Sheet<Employee>(name: department.name) { department.employees } {
             Column("Name", keyPath: \.name)
             Column("Role", keyPath: \.role)
         }
     }
 }
 ```
 
 ## Implementation Details
 
 The builder uses Swift's `@resultBuilder` feature to transform the declarative syntax
 into array construction calls. It handles both individual sheets and collections,
 performing automatic type erasure to enable heterogeneous storage.
 
 - Note: This builder is used internally by the `Book` class and rarely needs direct usage
 */
@resultBuilder
public struct SheetBuilder {
    
    // MARK: - Core Builder Methods
    
    /**
     Combines multiple worksheet components into a single array.
     
     This is the primary building method that handles multiple sheet declarations
     within the builder context. It takes variadic parameters and combines them
     into a single array.
     
     - Parameter components: Variable number of worksheet components
     - Returns: An array containing all provided worksheets
     
     ## Usage
     ```swift
     Book(style: style) {
         sheet1    // AnySheet
         sheet2    // AnySheet
         sheet3    // AnySheet
     }
     ```
     */
    public static func buildBlock(_ components: AnySheet...) -> [AnySheet] {
        components
    }

    /**
     Creates an empty array when no worksheet components are provided.
     
     This method handles the case where the builder block is empty,
     returning an empty array instead of causing a compilation error.
     
     - Returns: An empty array of worksheets
     
     ## Usage
     ```swift
     Book(style: style) {
         // Empty block - returns []
     }
     ```
     */
    public static func buildBlock() -> [AnySheet] {
        []
    }

    /**
     Converts a single worksheet into an array.
     
     This method handles the case where a single `AnySheet` is provided
     in the builder context, wrapping it in an array for consistency.
     
     - Parameter expression: A single worksheet instance
     - Returns: An array containing the single worksheet
     */
    public static func buildExpression(_ expression: AnySheet) -> [AnySheet] {
        [expression]
    }

    /**
     Passes through an array of worksheets unchanged.
     
     This method handles cases where an array of worksheets is provided
     directly in the builder context, such as from helper methods or
     pre-constructed collections.
     
     - Parameter expression: An array of worksheets
     - Returns: The same array unchanged
     
     ## Usage
     ```swift
     Book(style: style) {
         createStandardSheets()  // Returns [AnySheet]
     }
     ```
     */
    public static func buildExpression(_ expression: [AnySheet]) -> [AnySheet] {
        expression
    }

    /**
     Handles optional worksheet components.
     
     This method supports optional values in the builder context, converting
     `nil` values to empty arrays to maintain type consistency.
     
     - Parameter component: An optional array of worksheets
     - Returns: The provided array or an empty array if `nil`
     
     ## Usage
     ```swift
     Book(style: style) {
         optionalSheets  // [AnySheet]? - might be nil
     }
     ```
     */
    public static func buildOptional(_ component: [AnySheet]?) -> [AnySheet] {
        component ?? []
    }

    /**
     Handles the first branch of conditional statements.
     
     This method supports `if-else` constructs within the builder context,
     handling the "true" branch of conditional expressions.
     
     - Parameter component: Worksheets from the first conditional branch
     - Returns: The provided array unchanged
     
     ## Usage
     ```swift
     Book(style: style) {
         if condition {
             sheet1  // First branch
         } else {
             sheet2  // Second branch (handled by buildEither(second:))
         }
     }
     ```
     */
    public static func buildEither(first component: [AnySheet]) -> [AnySheet] {
        component
    }

    /**
     Handles the second branch of conditional statements.
     
     This method supports `if-else` constructs within the builder context,
     handling the "false" branch of conditional expressions.
     
     - Parameter component: Worksheets from the second conditional branch
     - Returns: The provided array unchanged
     */
    public static func buildEither(second component: [AnySheet]) -> [AnySheet] {
        component
    }

    /**
     Flattens nested arrays from loop constructs.
     
     This method handles `for-in` loops within the builder context, flattening
     the resulting array of arrays into a single flat array.
     
     - Parameter components: An array of worksheet arrays from loop iterations
     - Returns: A flattened array containing all worksheets
     
     ## Usage
     ```swift
     Book(style: style) {
         for category in categories {
             Sheet<Product>(name: category.name) { category.products } {
                 Column("Name", keyPath: \.name)
             }
         }  // Each iteration returns [AnySheet], this method flattens them
     }
     ```
     */
    public static func buildArray(_ components: [[AnySheet]]) -> [AnySheet] {
        components.flatMap(\.self)
    }
}

// MARK: - Sheet Type Erasure Support

extension SheetBuilder {
    
    /**
     Automatically converts a typed worksheet to type-erased form.
     
     This method enables direct use of `Sheet<ObjectType>` instances within
     the builder context without manual type erasure. It automatically calls
     `eraseToAnySheet()` to convert the typed sheet to `AnySheet`.
     
     - Parameter expression: A typed worksheet instance
     - Returns: An array containing the type-erased worksheet
     
     ## Usage
     ```swift
     Book(style: style) {
         Sheet<Person>(name: "People") { people } {  // Automatically converted
             Column("Name", keyPath: \.name)
         }
     }
     ```
     
     - Note: This is the primary convenience method that makes the builder syntax clean
     */
    public static func buildExpression<ObjectType>(_ expression: Sheet<ObjectType>) -> [AnySheet] {
        [expression.eraseToAnySheet()]
    }

    /**
     Automatically converts an array of typed worksheets to type-erased form.
     
     This method handles arrays of typed sheets, automatically converting each
     element to `AnySheet` for storage in the heterogeneous collection.
     
     - Parameter expression: An array of typed worksheet instances
     - Returns: An array of type-erased worksheets
     
     ## Usage
     ```swift
     Book(style: style) {
         createTypedSheets()  // Returns [Sheet<SomeType>]
     }
     ```
     */
    public static func buildExpression<ObjectType>(_ expression: [Sheet<ObjectType>]) -> [AnySheet] {
        expression.map { $0.eraseToAnySheet() }
    }
}
