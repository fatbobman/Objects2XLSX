//
// StyleRegistor.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import IdentifiedCollections

final class StyleRegister {
    private(set) var fontPool = IdentifiedArrayOf<Font>()
    private(set) var fillPool = IdentifiedArrayOf<Fill>()
    private(set) var alignmentPool = IdentifiedArrayOf<Alignment>()
    private(set) var borderPool = IdentifiedArrayOf<Border>()
    private(set) var numberFormatPool = IdentifiedArrayOf<NumberFormat>()
    private(set) var resolvedStylePool = IdentifiedArrayOf<ResolvedStyle>()

    private func registerFont(_ font: Font?) -> Int? {
        guard let font else { return 0 }
        return fontPool.append(font).index
    }

    private func registerFill(_ fill: Fill?) -> Int? {
        guard let fill else {
            return 0
        }
        return fillPool.append(fill).index
    }

    private func registerAlignment(_ alignment: Alignment?) -> Int? {
        guard let alignment else { return nil }
        return alignmentPool.append(alignment).index
    }

    private func registerBorder(_ border: Border?) -> Int? {
        guard let border else { return 0 }
        return borderPool.append(border).index
    }

    func registerStyle(_ style: CellStyle?, cellType: Cell.CellType?) -> Int? {
        guard let style else { return nil }

        // 注册各个组件
        let numberFormat = generateNumberFormat(for: cellType)
        let numFmtId = registerNumberFormat(numberFormat)
        let fontID = registerFont(style.font)
        let fillID = registerFill(style.fill)
        let alignmentID = registerAlignment(style.alignment)
        let borderID = registerBorder(style.border)

        // 创建 ResolvedStyle
        let resolved = ResolvedStyle(
            fontID: fontID,
            fillID: fillID,
            alignmentID: alignmentID,
            numFmtId: numFmtId,
            borderID: borderID)

        // 插入新样式
        return resolvedStylePool.append(resolved).index
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

        // Excel 内置的数字格式 ID
        // 0   -> General（默认）
        // 1   -> 0
        // 2   -> 0.00
        // 9   -> 0%
        // 10  -> 0.00%
        // 14  -> m/d/yy
        // 15  -> d-mmm-yy
        // 22  -> m/d/yy h:mm
        // ... 更多内置格式到 163
        // Excel 要求自定义格式从164开始

        if let index = numberFormatPool.ids.firstIndex(of: numberFormat.id) {
            return 164 + index
        }

        let customIndex = numberFormatPool.append(numberFormat).index
        return 164 + customIndex
    }

    init() {
        // 预注册默认填充
        fillPool.append(.none)

        // 预注册默认字体
        fontPool.append(Font.default)

        // 预注册默认边框
        borderPool.append(.none)

        // 预注册默认样式（索引0，Excel要求）
        let defaultStyle = ResolvedStyle(
            fontID: 0,
            fillID: 0,
            alignmentID: nil,
            numFmtId: nil,
            borderID: 0)
        resolvedStylePool.append(defaultStyle)
    }
}

struct ResolvedStyle: Hashable, Sendable, Identifiable {
    let fontID: Int?
    let fillID: Int?
    let alignmentID: Int?
    let numFmtId: Int?
    let borderID: Int?

    var id: String {
        let numFmtStr = numFmtId.map(String.init) ?? "default"
        let fontStr = fontID.map(String.init) ?? "default"
        let fillStr = fillID.map(String.init) ?? "default"
        let alignStr = alignmentID.map(String.init) ?? "default"
        let borderStr = borderID.map(String.init) ?? "default"

        return "\(numFmtStr)_\(fontStr)_\(fillStr)_\(alignStr)_\(borderStr)"
    }
}

public enum NumberFormat: Equatable, Sendable, Hashable, Identifiable {
    case general // 默认格式
    case percentage(precision: Int) // 百分比格式
    case date // 日期格式
    case time // 时间格式
    case dateTime // 日期时间格式
    case currency // 货币格式（未来扩展）
    case scientific // 科学计数法（未来扩展）

    public var id: String {
        switch self {
            case .general:
                "General"
            case let .percentage(precision):
                "Percentage(\(precision))"
            case .date:
                "Date"
            case .time:
                "Time"
            case .dateTime:
                "DateTime"
            case .currency:
                "Currency"
            case .scientific:
                "Scientific"
        }
    }

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
            case .date:
                14 // Excel 内置日期格式
            case .dateTime:
                22 // Excel 内置日期时间格式
            default:
                nil
        }
    }
}
