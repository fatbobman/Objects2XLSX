//
// SheetProtocol.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

protocol SheetProtocol<ObjectType> {
    associatedtype ObjectType

    var name: String { get }

    /// Generate sheet data based on the provided objects.
    func makeSheetData(
        with objects: [ObjectType],
        bookStyle: BookStyle,
        styleRegister: StyleRegister,
        shareStringRegistor: ShareStringRegister) -> SheetXML?
}
