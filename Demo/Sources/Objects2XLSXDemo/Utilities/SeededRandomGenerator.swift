//
// SeededRandomGenerator.swift
// Objects2XLSXDemo
//
// Shared utilities for demo data generation
//

import Foundation

// MARK: - Seeded Random Generator

/// A seeded random number generator for consistent demo data across runs
struct SeededRandomGenerator {
    private var state: UInt64
    
    /// Initialize with a seed value
    /// - Parameter seed: Seed for random generation
    init(seed: UInt64) {
        self.state = seed
    }
    
    /// Generate next random number in range 0..<max
    /// - Parameter max: Maximum value (exclusive)
    /// - Returns: Random integer from 0 to max-1
    mutating func next(max: Int) -> Int {
        state = state &* 1103515245 &+ 12345
        return Int(state % UInt64(max))
    }
    
    /// Generate next random number in specified range
    /// - Parameter range: Closed range for random generation
    /// - Returns: Random integer within the specified range
    mutating func next(range: ClosedRange<Int>) -> Int {
        let count = range.upperBound - range.lowerBound + 1
        return range.lowerBound + next(max: count)
    }
    
    /// Generate a random double in a specified range
    /// - Parameter range: Closed range for random generation
    /// - Returns: Random double within the specified range
    mutating func nextDouble(range: ClosedRange<Double>) -> Double {
        let randomInt = next(max: 10000)
        let normalizedValue = Double(randomInt) / 10000.0
        return range.lowerBound + normalizedValue * (range.upperBound - range.lowerBound)
    }
}

// MARK: - Data Size Enum

/// Data generation size options for demo data
enum DataSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    
    /// Number of records for each size
    var recordCount: Int {
        switch self {
        case .small:
            return 10
        case .medium:
            return 50
        case .large:
            return 200
        }
    }
}