//
// StyleRegistorTests.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Style Register Tests")
struct StyleRegistorTests {
    @Test("Style Registor")
    func styleRegister() async throws {
        let styleRegister = StyleRegister()
        let cellStyle = CellStyle(font: .header, fill: .solid(.blue), alignment: .center, border: nil)
        let cellStyleID = styleRegister.registerCellStyle(cellStyle, cellType: .intValue(10))
        print(cellStyleID ?? "No style ID")
        print(styleRegister.fontPool)
    }
}
