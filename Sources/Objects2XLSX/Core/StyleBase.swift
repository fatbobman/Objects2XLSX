//
// StyleBase.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Font: Equatable, Sendable, Hashable {
    public let size: Int
    public let name: String
    public let bold: Bool
    public let color: Color
}

public enum Alignment: Equatable, Sendable, Hashable {
    case leading
    case center
    case trailing
}

public enum Color: Equatable, Sendable, Hashable {
    case red, blue
}
