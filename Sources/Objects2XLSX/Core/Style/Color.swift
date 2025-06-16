//
// Color.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A structure that represents a color in an Excel Cell.
///
/// `Color` is a structure that represents a color in an Excel Cell.
/// It provides a way to create a color with a hex code.
public enum Color: Equatable, Sendable, Hashable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange
    case brown
    case gray
    case black
    case white
    case custom(String)

    /// The hex code of the color.
    ///
    /// - Returns: The hex code of the color.
    var hex: String { // TODO: 考虑添加透明度的支持
        switch self {
            case .red: "#FF0000"
            case .blue: "#0000FF"
            case .green: "#00FF00"
            case .yellow: "#FFFF00"
            case .purple: "#800080"
            case .orange: "#FFA500"
            case .brown: "#A52A2A"
            case .gray: "#808080"
            case .black: "#000000"
            case .white: "#FFFFFF"
            case let .custom(hex): hex
        }
    }
}
