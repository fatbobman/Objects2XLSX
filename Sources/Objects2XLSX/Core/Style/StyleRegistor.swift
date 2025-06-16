//
// StyleRegistor.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import Synchronization

final class StyleRegistor {
    private(set) var fontPool: [Font: Int] = [:]
    private(set) var fillPool: [Color: Int] = [:]
    private(set) var alignmentPool: [Alignment: Int] = [:]
    private(set) var numberFormatPool: [NumberFormat] = []
    private(set) var resolvedStylePool: [ResolvedStyle: Int] = [:]

    var allResolvedStyles: [ResolvedStyle] {
        resolvedStylePool
            .sorted { $0.value < $1.value }
            .map(\.key)
    }

    var fonts: [Font] {
        fontPool.sorted { $0.value < $1.value }.map(\.key)
    }

    var fills: [Color] {
        fillPool.sorted { $0.value < $1.value }.map(\.key)
    }

    var alignments: [Alignment] {
        alignmentPool.sorted { $0.value < $1.value }.map(\.key)
    }

    var numberFormats: [NumberFormat] {
        numberFormatPool
    }

    private func registerFont(_ font: Font?) -> Int? {
        guard let font else { return nil }
        if let index = fontPool[font] { return index }
        fontPool[font] = fontPool.count
        return fontPool.count - 1
    }

    private func registerFill(_ fill: Color?) -> Int? {
        guard let fill else { return nil }
        if let index = fillPool[fill] { return index }
        fillPool[fill] = fillPool.count
        return fillPool.count - 1
    }

    private func registerAlignment(_ alignment: Alignment?) -> Int? {
        guard let alignment else { return nil }
        if let index = alignmentPool[alignment] { return index }
        alignmentPool[alignment] = alignmentPool.count
        return alignmentPool.count - 1
    }

    func registerStyle(_ style: CellStyle?, cellType: Cell.CellType?) -> Int? {
        guard let style else { return nil }

        // 1. 根据 CellType 自动生成 numberFormat
        let numberFormat = generateNumberFormat(for: cellType)
        let numFmtId = registerNumberFormat(numberFormat)

        // 2. 注册其他样式组件
        let fontID = registerFont(style.font)
        let fillID = registerFill(style.fillColor)
        let alignmentID = registerAlignment(style.alignment)

        // 3. 创建 ResolvedStyle
        let resolved = ResolvedStyle(
            fontID: fontID,
            fillID: fillID,
            alignmentID: alignmentID,
            numFmtId: numFmtId)

        // 4. 注册并返回样式ID
        if let index = resolvedStylePool[resolved] {
            return index
        }
        resolvedStylePool[resolved] = resolvedStylePool.count
        return resolvedStylePool.count - 1
    }

    // 根据 CellType 生成对应的数字格式代码
    private func generateNumberFormat(for cellType: Cell.CellType?) -> NumberFormat? {
        guard let cellType else { return nil }

        switch cellType {
            case let .percentage(_, precision):
                return .percentage(precision: precision)
            case .date:
                return .dateTime
            case .int, .string, .boolean, .url, .double:
                return .general
        }
    }

    private func registerNumberFormat(_ numberFormat: NumberFormat?) -> Int? {
        guard let numberFormat else { return nil }

        // 优先使用内置格式
        if let builtinId = numberFormat.builtinId {
            return builtinId
        }

        // 检查是否已注册
        if let index = numberFormatPool.firstIndex(of: numberFormat) {
            return 164 + index // 自定义格式从164开始
        }

        // 注册新格式
        numberFormatPool.append(numberFormat)
        return 164 + numberFormatPool.count - 1
    }
}

struct ResolvedStyle: Hashable {
    let fontID: Int?
    let fillID: Int?
    let alignmentID: Int?
    let numFmtId: Int?
}

public enum NumberFormat: Equatable, Sendable, Hashable {
    case general // 默认格式
    case percentage(precision: Int) // 百分比格式
    case date // 日期格式
    case time // 时间格式
    case dateTime // 日期时间格式
    case currency // 货币格式（未来扩展）
    case scientific // 科学计数法（未来扩展）

    // 获取对应的格式代码
    var formatCode: String? {
        switch self {
            case .general:
                nil // 使用 Excel 默认
            case let .percentage(precision):
                "0.\(String(repeating: "0", count: precision))%"
            case .date:
                "yyyy-mm-dd"
            case .time:
                "hh:mm:ss"
            case .dateTime:
                "yyyy-mm-dd hh:mm:ss"
            case .currency:
                "\"$\"#,##0.00"
            case .scientific:
                "0.00E+00"
        }
    }

    // 获取内置格式ID（如果有的话）
    var builtinId: Int? {
        switch self {
            case .percentage:
                10 // Excel 内置百分比格式
            default:
                nil
        }
    }
}
