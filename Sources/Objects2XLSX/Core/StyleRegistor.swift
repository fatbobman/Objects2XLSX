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

    func registerStyle(_ style: CellStyle?) -> Int? {
        guard let style else { return nil }

        let fontID = registerFont(style.font)
        let fillID = registerFill(style.fillColor)
        let alignmentID = registerAlignment(style.alignment)

        let resolved = ResolvedStyle(fontID: fontID, fillID: fillID, alignmentID: alignmentID)

        if let index = resolvedStylePool[resolved] {
            return index
        }
        resolvedStylePool[resolved] = resolvedStylePool.count
        return resolvedStylePool.count - 1
    }
}

struct ResolvedStyle: Hashable {
    let fontID: Int?
    let fillID: Int?
    let alignmentID: Int?
}
