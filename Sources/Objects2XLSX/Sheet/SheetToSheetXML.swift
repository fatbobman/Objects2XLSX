//
// SheetToSheetXML.swift
// Created by Xu Yang on 2025-06-19.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

extension Sheet {
    func makeSheetXML(
        with objects: [ObjectType],
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML? // TODO: 返回 SheetData,临时
    {
        /*
            // 1. 筛选有效列（基于 when 条件和第一个对象）
            let activeColumns = filterActiveColumns(for: objects.first)

            // 2. 计算最终的样式和尺寸设置
            let resolvedStyles = resolveSheetAndColumnStyles()
            let resolvedDimensions = resolveSheetAndColumnDimensions()

            // 3. 构建样式映射表（避免重复计算）
            let styleRegistry = buildStyleRegistry(resolvedStyles)

            // 4. 生成表头行（如果需要）
           let headerCells = generateHeaderCells(activeColumns, styleRegistry)

           // 5. 逐行处理对象数据
          for (rowIndex, object) in objects.enumerated() {
              // 6. 对当前行，逐列生成 Cell
              let rowCells = generateRowCells(
                  object: object,
                  rowIndex: rowIndex,
                  activeColumns: activeColumns,
                  styleRegistry: styleRegistry
              )
          }

          // 7. 汇总所有数据，构建最终的 XlsxSheetData
         let sheetData = XlsxSheetData(
             cells: allCells,
             dimensions: resolvedDimensions,
             styleRegistry: styleRegistry,
             metadata: sheetMetadata
         )
          */
        nil
    }
}
