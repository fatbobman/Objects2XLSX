//
// Types.swift
// Created by Xu Yang on 2025-06-05.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

struct Student: Sendable {
    let name: String
    let age: Int
    let score: Double
}

let students = [
    Student(name: "John", age: 18, score: 90),
    Student(name: "Jane", age: 20, score: 95),
]
