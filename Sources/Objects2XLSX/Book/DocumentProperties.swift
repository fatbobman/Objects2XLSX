//
// DocumentProperties.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

public struct DocumentProperties {
    // 核心属性 (core.xml)
    public var title: String?
    public var subject: String?
    public var author: String?
    public var keywords: [String]?
    public var description: String?
    public var category: String?
    public var company: String?
    public var manager: String?

    // 创建和修改时间
    public var created: Date? = Date()
    public var modified: Date? = Date()

    // 应用程序属性 (app.xml)
    public var application: String = "Objects2XLSX"
    public var appVersion: String = "1.0"
    public var totalSheets: Int = 0
    public var totalCells: Int = 0

    public init() {}
}
