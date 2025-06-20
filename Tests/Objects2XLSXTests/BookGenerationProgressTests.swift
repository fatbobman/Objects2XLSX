//
// BookGenerationProgressTests.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

struct BookGenerationProgressTests {
    @Test func progressPercentages() {
        // 测试关键进度节点的百分比
        #expect(BookGenerationProgress.started.progressPercentage == 0.0)
        #expect(BookGenerationProgress.creatingDirectory.progressPercentage == 0.05)
        #expect(BookGenerationProgress.processingSheets(totalCount: 3).progressPercentage == 0.1)
        #expect(BookGenerationProgress.sheetsCompleted(totalCount: 3).progressPercentage == 0.3)
        #expect(BookGenerationProgress.generatingGlobalFiles.progressPercentage == 0.35)
        #expect(BookGenerationProgress.completed.progressPercentage == 1.0)

        // 测试错误状态
        let error = BookError.fileWriteError(NSError(domain: "test", code: 1))
        #expect(BookGenerationProgress.failed(error: error).progressPercentage == 0.0)
    }

    @Test func sheetProcessingProgress() {
        // 测试 sheet 处理的精细进度
        let sheet1Progress = BookGenerationProgress.processingSheet(current: 1, total: 3, sheetName: "Sheet1")
        let sheet2Progress = BookGenerationProgress.processingSheet(current: 2, total: 3, sheetName: "Sheet2")
        let sheet3Progress = BookGenerationProgress.processingSheet(current: 3, total: 3, sheetName: "Sheet3")

        // 验证进度递增
        #expect(sheet1Progress.progressPercentage < sheet2Progress.progressPercentage)
        #expect(sheet2Progress.progressPercentage < sheet3Progress.progressPercentage)

        // 验证 sheet 进度在合理范围内 (10% - 30%)
        #expect(sheet1Progress.progressPercentage >= 0.1)
        #expect(sheet3Progress.progressPercentage <= 0.3)

        print("Sheet 1 progress: \(sheet1Progress.progressPercentage)")
        print("Sheet 2 progress: \(sheet2Progress.progressPercentage)")
        print("Sheet 3 progress: \(sheet3Progress.progressPercentage)")
    }

    @Test func progressDescriptions() {
        // 测试英文描述
        let processingSheet = BookGenerationProgress.processingSheet(current: 2, total: 5, sheetName: "Sales Data")
        #expect(processingSheet.description.contains("Processing worksheet"))
        #expect(processingSheet.description.contains("(2/5)"))
        #expect(processingSheet.description.contains("Sales Data"))

        // 测试其他状态描述
        #expect(BookGenerationProgress.started.description == "Starting XLSX generation")
        #expect(BookGenerationProgress.completed.description == "XLSX generation completed")
        #expect(BookGenerationProgress.generatingStyles.description == "Generating styles")

        print("Description: \(processingSheet.description)")
    }

    @Test func statusChecking() {
        // 测试状态检查方法
        #expect(!BookGenerationProgress.started.isCompleted)
        #expect(!BookGenerationProgress.started.isFailed)
        #expect(!BookGenerationProgress.started.isFinal)

        #expect(BookGenerationProgress.completed.isCompleted)
        #expect(!BookGenerationProgress.completed.isFailed)
        #expect(BookGenerationProgress.completed.isFinal)

        let error = BookError.fileWriteError(NSError(domain: "test", code: 1))
        let failedProgress = BookGenerationProgress.failed(error: error)
        #expect(!failedProgress.isCompleted)
        #expect(failedProgress.isFailed)
        #expect(failedProgress.isFinal)
    }

    @Test func progressEquality() {
        // 测试枚举相等性
        let progress1 = BookGenerationProgress.processingSheet(current: 1, total: 3, sheetName: "Test")
        let progress2 = BookGenerationProgress.processingSheet(current: 1, total: 3, sheetName: "Test")
        let progress3 = BookGenerationProgress.processingSheet(current: 2, total: 3, sheetName: "Test")

        #expect(progress1 == progress2)
        #expect(progress1 != progress3)

        #expect(BookGenerationProgress.started == BookGenerationProgress.started)
        #expect(BookGenerationProgress.completed == BookGenerationProgress.completed)
    }

    @Test func globalFileProgressSequence() {
        // 测试全局文件生成阶段的进度序列
        let globalFileStages: [BookGenerationProgress] = [
            .generatingGlobalFiles,
            .generatingContentTypes,
            .generatingRootRelationships,
            .generatingWorkbook,
            .generatingWorkbookRelationships,
            .generatingStyles,
            .generatingSharedStrings,
            .generatingCoreProperties,
            .generatingAppProperties,
        ]

        // 验证进度递增
        for i in 0 ..< globalFileStages.count - 1 {
            let current = globalFileStages[i].progressPercentage
            let next = globalFileStages[i + 1].progressPercentage
            #expect(current < next, "进度应该递增: \(globalFileStages[i]) -> \(globalFileStages[i + 1])")
        }

        // 验证最后一个阶段的进度小于完成状态
        #expect(globalFileStages.last!.progressPercentage < BookGenerationProgress.completed.progressPercentage)
    }

    @Test func sheetProgressCalculation() {
        // 测试不同数量 sheet 的进度计算
        let singleSheetProgress = BookGenerationProgress.processingSheet(current: 1, total: 1, sheetName: "Only")
        let multiSheetFirstProgress = BookGenerationProgress.processingSheet(current: 1, total: 10, sheetName: "First")
        let multiSheetLastProgress = BookGenerationProgress.processingSheet(current: 10, total: 10, sheetName: "Last")

        // 验证单个 sheet 的进度
        #expect(singleSheetProgress.progressPercentage >= 0.1)
        #expect(singleSheetProgress.progressPercentage <= 0.3)

        // 验证多个 sheet 的进度范围
        #expect(multiSheetFirstProgress.progressPercentage >= 0.1)
        #expect(multiSheetLastProgress.progressPercentage <= 0.3)
        #expect(multiSheetFirstProgress.progressPercentage < multiSheetLastProgress.progressPercentage)

        print("单个 sheet 进度: \(singleSheetProgress.progressPercentage)")
        print("10个 sheet 第1个: \(multiSheetFirstProgress.progressPercentage)")
        print("10个 sheet 第10个: \(multiSheetLastProgress.progressPercentage)")
    }

    @Test func completeProgressFlow() {
        // 测试完整的进度流程
        let completeFlow: [BookGenerationProgress] = [
            .started,
            .creatingDirectory,
            .processingSheets(totalCount: 2),
            .processingSheet(current: 1, total: 2, sheetName: "Sheet1"),
            .processingSheet(current: 2, total: 2, sheetName: "Sheet2"),
            .sheetsCompleted(totalCount: 2),
            .generatingGlobalFiles,
            .generatingContentTypes,
            .generatingRootRelationships,
            .generatingWorkbook,
            .generatingWorkbookRelationships,
            .generatingStyles,
            .generatingSharedStrings,
            .generatingCoreProperties,
            .generatingAppProperties,
            .preparingPackage,
            .cleaningUp,
            .completed,
        ]

        // 验证整个流程的进度是递增的
        for i in 0 ..< completeFlow.count - 1 {
            let current = completeFlow[i].progressPercentage
            let next = completeFlow[i + 1].progressPercentage
            #expect(current <= next, "进度应该单调递增: \(completeFlow[i].description) (\(current)) -> \(completeFlow[i + 1].description) (\(next))")
        }

        // 验证从开始到结束的完整范围
        #expect(completeFlow.first!.progressPercentage == 0.0)
        #expect(completeFlow.last!.progressPercentage == 1.0)

        print("完整进度流程验证通过，包含 \(completeFlow.count) 个阶段")
    }
}
