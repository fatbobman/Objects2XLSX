//
// Samples.swift
// Created by Xu Yang on 2025-06-19.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import Objects2XLSX

struct People: Sendable {
    let name: String
    let age: Int
    let gender: Bool // true: male, false: female
    let city: String
    let country: String
    let weight: Double
    let email: URL
    let birthday: Date

    static let people = [
        People(
            name: "John",
            age: 20,
            gender: true,
            city: "Beijing",
            country: "China",
            weight: 70.5,
            email: URL(string: "https://www.google.com")!,
            birthday: Date(timeIntervalSince1970: 1_718_851_200)),
        People(
            name: "Jane",
            age: 21,
            gender: false,
            city: "Shanghai",
            country: "China",
            weight: 55.2,
            email: URL(string: "https://www.google.com")!,
            birthday: Date(timeIntervalSince1970: 1_718_851_200)),
        People(
            name: "Jim",
            age: 22,
            gender: true,
            city: "Guangzhou",
            country: "China",
            weight: 80.3,
            email: URL(string: "https://www.google.com")!,
            birthday: Date(timeIntervalSince1970: 1_718_851_200)),
        People(
            name: "Jill",
            age: 23,
            gender: false,
            city: "Shenzhen",
            country: "China",
            weight: 60.1,
            email: URL(string: "https://www.google.com")!,
            birthday: Date(timeIntervalSince1970: 1_718_851_200))
    ]
}
