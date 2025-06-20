//
// ShareStringRegistor.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

final class ShareStringRegister {
    private var stringPool: [String: Int] = [:]

    var allStrings: [String] {
        stringPool.sorted { $0.value < $1.value }.map(\.key)
    }

    /// 批量注册字符串
    func registerStrings(_ strings: some Sequence<String>) {
        for string in strings {
            if stringPool[string] != nil { continue }
            stringPool[string] = stringPool.count
        }
    }

    /// 注册单个字符串，并返回其索引
    func register(_ string: String) -> Int {
        if let id = stringPool[string] { return id }
        let id = stringPool.count
        stringPool[string] = id
        return id
    }

    /// 获取字符串的索引
    func stringIndex(for string: String) -> Int? {
        stringPool[string]
    }
    
    /// Generates the complete sharedStrings.xml content for the XLSX file
    /// - Returns: XML string conforming to Office Open XML standards
    func generateXML() -> String {
        let sortedStrings = allStrings
        let count = sortedStrings.count
        
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="\(count)" uniqueCount="\(count)">
        """
        
        for string in sortedStrings {
            xml += "<si><t>"
            xml += string.xmlEscaped
            xml += "</t></si>"
        }
        
        xml += "</sst>"
        return xml
    }
}
