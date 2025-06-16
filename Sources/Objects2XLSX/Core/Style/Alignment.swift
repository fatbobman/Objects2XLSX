//
// Alignment.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents the alignment of a cell in an Excel Cell.
///
/// `Alignment` is a structure that represents the alignment of a cell in an Excel Cell.
/// It provides a way to create an alignment with a leading, center, or trailing property.
public enum Alignment: Equatable, Sendable, Hashable, Identifiable {
    /// Aligns the text to the left.
    case leading
    /// Aligns the text to the center.
    case center
    /// Aligns the text to the right.
    case trailing

    public var id: String {
        switch self {
            case .leading:
                "leading"
            case .center:
                "center"
            case .trailing:
                "trailing"
        }
    }
}
