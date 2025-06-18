//
// Color.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct Color: Equatable, Sendable, Hashable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let alpha: ColorAlpha // 新增透明度支持

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: ColorAlpha = .opaque) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public init(hex: String, alpha: ColorAlpha = .opaque) {
        // 处理十六进制字符串，支持 #RRGGBB 或 RRGGBB 格式
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard hexString.count == 6,
              let red = UInt8(hexString.prefix(2), radix: 16),
              let green = UInt8(hexString.dropFirst(2).prefix(2), radix: 16),
              let blue = UInt8(hexString.suffix(2), radix: 16)
        else {
            fatalError("Invalid hex color string")
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// ARGB 十六进制字符串 (Excel 格式)
    public var argbHexString: String {
        String(format: "%02X%02X%02X%02X", alpha.rawValue, red, green, blue)
    }

    /// RGB 十六进制字符串 (向后兼容)
    public var hexString: String {
        String(format: "%02X%02X%02X", red, green, blue)
    }
}

// 便利构造方法
extension Color {
    public static func rgba(_ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: ColorAlpha) -> Color {
        Color(red: red, green: green, blue: blue, alpha: alpha)
    }

    public static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Color {
        Color(red: red, green: green, blue: blue, alpha: .opaque)
    }
}

/// 透明度
public enum ColorAlpha: UInt8, CaseIterable, Sendable, Hashable, Equatable {
    case transparent = 0 // 完全透明
    case light = 64 // 很淡 (25%)
    case medium = 128 // 半透明 (50%)
    case strong = 192 // 略透明 (75%)
    case opaque = 255 // 不透明 (100%)
}

// 预设颜色

extension Color {
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 255, green: 255, blue: 255)
    public static let red = Color(red: 255, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 255, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 255)
    public static let yellow = Color(red: 255, green: 255, blue: 0)
    public static let cyan = Color(red: 0, green: 255, blue: 255)
    public static let magenta = Color(red: 255, green: 0, blue: 255)
    public static let gray = Color(red: 128, green: 128, blue: 128)
    public static let lightGray = Color(red: 211, green: 211, blue: 211)
}
