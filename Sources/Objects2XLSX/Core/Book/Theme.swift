//
// Theme.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

struct Theme {
    var name: String

    // 颜色方案
    struct ColorScheme {
        // 从实际使用的样式中提取的颜色
        var accentColors: [Color] // 从 Fill 中提取
        var textColors: [Color] // 从 Font 中提取
        var borderColors: [Color] // 从 Border 中提取
    }

    // 字体方案
    struct FontScheme {
        // 从实际使用的样式中提取的字体
        var majorFont: Font? // 标题字体
        var minorFont: Font? // 正文字体
    }

    // 效果方案
    struct EffectScheme {
        // 从实际使用的样式中提取的效果
        var fills: [Fill]
        var borders: [Border]
    }

    // 从 StyleRegister 中提取主题信息
    static func extractFromStyleRegister(_ register: StyleRegister) -> Theme? {
        // 从 register 中提取实际使用的样式
        // 生成对应的主题配置
        nil
    }
}
