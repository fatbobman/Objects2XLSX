//
// BookGenerationProgress.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Book 生成过程的进度状态
public enum BookGenerationProgress: Sendable {
    // MARK: - 初始化阶段

    /// 开始创建 Book
    case started

    /// 创建临时目录结构
    case creatingDirectory

    // MARK: - Sheet 处理阶段

    /// 开始处理所有 Sheets
    case processingSheets(totalCount: Int)

    /// 正在处理特定 Sheet（包含精细进度）
    case processingSheet(current: Int, total: Int, sheetName: String)

    /// 完成 Sheet 处理
    case sheetsCompleted(totalCount: Int)

    // MARK: - 全局文件生成阶段

    /// 开始生成全局文件
    case generatingGlobalFiles

    /// 生成内容类型文件
    case generatingContentTypes

    /// 生成根关系文件
    case generatingRootRelationships

    /// 生成工作簿文件
    case generatingWorkbook

    /// 生成工作簿关系文件
    case generatingWorkbookRelationships

    /// 生成样式文件
    case generatingStyles

    /// 生成共享字符串文件
    case generatingSharedStrings

    /// 生成主题文件
    case generatingTheme

    /// 生成核心属性文件
    case generatingCoreProperties

    /// 生成应用程序属性文件
    case generatingAppProperties

    // MARK: - 完成阶段

    /// 准备打包（未来实现）
    case preparingPackage

    /// 清理临时文件（未来实现）
    case cleaningUp

    /// 完成所有操作
    case completed

    // MARK: - 错误状态

    /// 发生错误
    case failed(error: BookError)
}

// MARK: - Progress Calculation

extension BookGenerationProgress {
    /// 获取当前进度百分比 (0.0 - 1.0)
    public var progressPercentage: Double {
        switch self {
            case .started:
                return 0.0

            case .creatingDirectory:
                return 0.05

            case let .processingSheets(totalCount):
                return totalCount == 0 ? 0.3 : 0.1

            case let .processingSheet(current, total, _):
                // Sheet 处理占总进度的 20%，从 10% 到 30%
                let sheetProgress = total > 0 ? Double(current - 1) / Double(total) : 0.0
                return 0.1 + (sheetProgress * 0.2)

            case .sheetsCompleted:
                return 0.3

            case .generatingGlobalFiles:
                return 0.35

            case .generatingContentTypes:
                return 0.4

            case .generatingRootRelationships:
                return 0.45

            case .generatingWorkbook:
                return 0.5

            case .generatingWorkbookRelationships:
                return 0.55

            case .generatingStyles:
                return 0.65

            case .generatingSharedStrings:
                return 0.75

            case .generatingTheme:
                return 0.8

            case .generatingCoreProperties:
                return 0.85

            case .generatingAppProperties:
                return 0.9

            case .preparingPackage:
                return 0.95

            case .cleaningUp:
                return 0.98

            case .completed:
                return 1.0

            case .failed:
                return 0.0 // 错误状态不计算进度
        }
    }

    /// 获取当前阶段的描述
    public var description: String {
        switch self {
            case .started:
                "Starting XLSX generation"

            case .creatingDirectory:
                "Creating temporary directory structure"

            case let .processingSheets(totalCount):
                "Preparing to process \(totalCount) worksheet(s)"

            case let .processingSheet(current, total, sheetName):
                "Processing worksheet (\(current)/\(total)): \(sheetName)"

            case let .sheetsCompleted(totalCount):
                "Completed processing \(totalCount) worksheet(s)"

            case .generatingGlobalFiles:
                "Generating global files"

            case .generatingContentTypes:
                "Generating content types"

            case .generatingRootRelationships:
                "Generating root relationships"

            case .generatingWorkbook:
                "Generating workbook"

            case .generatingWorkbookRelationships:
                "Generating workbook relationships"

            case .generatingStyles:
                "Generating styles"

            case .generatingSharedStrings:
                "Generating shared strings"

            case .generatingTheme:
                "Generating theme"

            case .generatingCoreProperties:
                "Generating core properties"

            case .generatingAppProperties:
                "Generating application properties"

            case .preparingPackage:
                "Preparing XLSX package"

            case .cleaningUp:
                "Cleaning up temporary files"

            case .completed:
                "XLSX generation completed"

            case let .failed(error):
                "Generation failed: \(error.localizedDescription)"
        }
    }

    /// 判断是否为完成状态
    public var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }

    /// 判断是否为错误状态
    public var isFailed: Bool {
        if case .failed = self {
            return true
        }
        return false
    }

    /// 判断是否为最终状态（完成或失败）
    public var isFinal: Bool {
        isCompleted || isFailed
    }
}

// MARK: - Equatable Conformance

extension BookGenerationProgress: Equatable {
    public static func == (lhs: BookGenerationProgress, rhs: BookGenerationProgress) -> Bool {
        switch (lhs, rhs) {
            case (.started, .started),
                 (.creatingDirectory, .creatingDirectory),
                 (.generatingGlobalFiles, .generatingGlobalFiles),
                 (.generatingContentTypes, .generatingContentTypes),
                 (.generatingRootRelationships, .generatingRootRelationships),
                 (.generatingWorkbook, .generatingWorkbook),
                 (.generatingWorkbookRelationships, .generatingWorkbookRelationships),
                 (.generatingStyles, .generatingStyles),
                 (.generatingSharedStrings, .generatingSharedStrings),
                 (.generatingTheme, .generatingTheme),
                 (.generatingCoreProperties, .generatingCoreProperties),
                 (.generatingAppProperties, .generatingAppProperties),
                 (.preparingPackage, .preparingPackage),
                 (.cleaningUp, .cleaningUp),
                 (.completed, .completed):
                true

            case let (.processingSheets(lhsTotal), .processingSheets(rhsTotal)):
                lhsTotal == rhsTotal

            case let (
            .processingSheet(lhsCurrent, lhsTotal, lhsName),
            .processingSheet(rhsCurrent, rhsTotal, rhsName)):
                lhsCurrent == rhsCurrent && lhsTotal == rhsTotal && lhsName == rhsName

            case let (.sheetsCompleted(lhsTotal), .sheetsCompleted(rhsTotal)):
                lhsTotal == rhsTotal

            case let (.failed(lhsError), .failed(rhsError)):
                // 比较错误类型和消息，因为 BookError 不是 Equatable
                type(of: lhsError) == type(of: rhsError) &&
                    lhsError.localizedDescription == rhsError.localizedDescription

            default:
                false
        }
    }
}
