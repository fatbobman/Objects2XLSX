//
// SheetMeta.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Sheet 元数据，包含生成其他 XML 文件所需的关键信息
/// 相比完整的 SheetXML，SheetMeta 只包含轻量级的元数据，避免大数据量时的内存问题
public struct SheetMeta: Sendable {
    /// Sheet 名称（已清理过的安全名称）
    public let name: String
    /// Sheet 在 workbook 中的 ID（从 1 开始）
    public let sheetId: Int
    /// 在 workbook.xml.rels 中的关系 ID（如 "rId1", "rId2"）
    public let relationshipId: String
    /// 是否包含表头行
    public let hasHeader: Bool
    /// 预估的数据行数（不包含表头）
    public let estimatedDataRowCount: Int
    /// 活跃列数（实际会生成的列数）
    public let activeColumnCount: Int
    /// 总行数（包含表头，如果有的话）
    public let totalRowCount: Int
    /// 数据范围信息（用于生成 dimension 等）
    public let dataRange: DataRangeInfo?
    /// Sheet 在 XLSX 包中的文件路径
    public let filePath: String

    /// 数据范围信息
    public struct DataRangeInfo: Sendable {
        public let startRow: Int
        public let startColumn: Int
        public let endRow: Int
        public let endColumn: Int

        /// Excel 格式的范围字符串（如 "A1:C10"）
        public var excelRange: String {
            let startCol = columnIndexToExcelColumn(startColumn)
            let endCol = columnIndexToExcelColumn(endColumn)
            return "\(startCol)\(startRow):\(endCol)\(endRow)"
        }
    }

    public init(
        name: String,
        sheetId: Int,
        relationshipId: String,
        hasHeader: Bool,
        estimatedDataRowCount: Int,
        activeColumnCount: Int,
        dataRange: DataRangeInfo?
    ) {
        self.name = name
        self.sheetId = sheetId
        self.relationshipId = relationshipId
        self.hasHeader = hasHeader
        self.estimatedDataRowCount = estimatedDataRowCount
        self.activeColumnCount = activeColumnCount
        self.totalRowCount = estimatedDataRowCount + (hasHeader ? 1 : 0)
        self.dataRange = dataRange
        self.filePath = "xl/worksheets/sheet\(sheetId).xml"
    }
}

// MARK: - Sheet Extensions

extension Sheet {
    /// 构建 SheetMeta，用于 Book 级别的 XML 生成
    /// 注意：此方法假设数据已通过 loadData() 预先加载
    public func makeSheetMeta(sheetId: Int) -> SheetMeta {
        let dataRowCount = data?.count ?? 0
        let activeColumns = activeColumns(objects: data ?? [])
        let activeColumnCount = activeColumns.count

        // 构建数据范围信息
        let dataRange: SheetMeta.DataRangeInfo?
        if totalRowCount > 0 && activeColumnCount > 0 {
            dataRange = SheetMeta.DataRangeInfo(
                startRow: 1,
                startColumn: 1,
                endRow: totalRowCount,
                endColumn: activeColumnCount
            )
        } else {
            dataRange = nil
        }

        return SheetMeta(
            name: name,
            sheetId: sheetId,
            relationshipId: "rId\(sheetId)",
            hasHeader: hasHeader,
            estimatedDataRowCount: dataRowCount,
            activeColumnCount: activeColumnCount,
            dataRange: dataRange
        )
    }

    /// 获取总行数（包含表头，如果有的话）
    public var totalRowCount: Int {
        (data?.count ?? 0) + (hasHeader ? 1 : 0)
    }

    /// 预估数据行数（不触发实际数据加载，仅用于早期估算）
    public func estimatedDataRowCount() -> Int {
        // 如果数据已加载，返回实际数量
        if let data = data {
            return data.count
        }

        // 如果有 dataProvider，可以尝试调用获取数量
        // 这里简化处理，返回 0 表示未知
        // 实际使用时可以考虑添加专门的 countProvider
        return 0
    }
}

