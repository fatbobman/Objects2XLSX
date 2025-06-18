//
// SheetBuilder.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A result builder for building [AnySheet]
@resultBuilder
public struct SheetBuilder {
    /// Builds a block of AnySheet components
    public static func buildBlock(_ components: AnySheet...) -> [AnySheet] {
        components
    }

    /// Builds an empty array when no components are provided
    public static func buildBlock() -> [AnySheet] {
        []
    }

    /// Builds an array from a single AnySheet
    public static func buildExpression(_ expression: AnySheet) -> [AnySheet] {
        [expression]
    }

    /// Builds an array from an array of AnySheet
    public static func buildExpression(_ expression: [AnySheet]) -> [AnySheet] {
        expression
    }

    /// Builds an array from optional AnySheet
    public static func buildOptional(_ component: [AnySheet]?) -> [AnySheet] {
        component ?? []
    }

    /// Builds an array from either component
    public static func buildEither(first component: [AnySheet]) -> [AnySheet] {
        component
    }

    /// Builds an array from either component
    public static func buildEither(second component: [AnySheet]) -> [AnySheet] {
        component
    }

    /// Builds an array from an array of arrays
    public static func buildArray(_ components: [[AnySheet]]) -> [AnySheet] {
        components.flatMap(\.self)
    }
}

// MARK: - Sheet Type Erasure Support

extension SheetBuilder {
    /// Builds an array from a generic Sheet<ObjectType>
    public static func buildExpression<ObjectType>(_ expression: Sheet<ObjectType>) -> [AnySheet] {
        [expression.eraseToAnySheet()]
    }

    /// Builds an array from an array of generic Sheet<ObjectType>
    public static func buildExpression<ObjectType>(_ expression: [Sheet<ObjectType>]) -> [AnySheet] {
        expression.map { $0.eraseToAnySheet() }
    }
}
