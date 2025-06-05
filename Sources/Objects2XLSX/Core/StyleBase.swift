//
// StyleBase.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Font: Equatable, Sendable, Hashable {
    var size: Int?
    var name: String?
    var bold: Bool?
    var color: Color?

    public init(
        size: Int? = nil,
        name: String? = nil,
        bold: Bool? = nil,
        color: Color? = nil)
    {
        self.size = size
        self.name = name
        self.bold = bold
        self.color = color
    }

    public func bolded() -> Self {
        var newSelf = self
        newSelf.bold = true
        return newSelf
    }

    public func color(_ color: Color) -> Self {
        var newSelf = self
        newSelf.color = color
        return newSelf
    }

    public func size(_ size: Int) -> Self {
        var newSelf = self
        newSelf.size = size
        return newSelf
    }

    public static let `default` = Font(size: 11, name: "Calibri")
    public static let header = Font(size: 11, name: "Calibri", bold: true)
}

public enum Alignment: Equatable, Sendable, Hashable {
    case leading
    case center
    case trailing
}

public enum Color: Equatable, Sendable, Hashable {
    case red, blue, green, yellow, purple, orange, brown, gray, black, white, custom(String)
}
