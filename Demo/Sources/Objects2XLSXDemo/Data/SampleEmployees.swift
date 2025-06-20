//
// SampleEmployees.swift
// Objects2XLSXDemo
//
// Sample employee data generator for demonstration
//

import Foundation

// MARK: - Sample Employee Data Generator

/// Generator for sample employee data
struct SampleEmployees {
    
    /// Generate sample employee data
    /// - Parameter size: Data size (small, medium, large)
    /// - Returns: Array of sample employees
    static func generate(size: DataSize = .medium) -> [Employee] {
        // TODO: Implement employee data generation
        // - Create realistic employee data with various departments
        // - Include some employees with nil salaries and addresses
        // - Ensure age filtering will work (some < 18, most >= 18)
        // - Mix of managers and non-managers
        // - Variety of hire dates
        
        return [Employee.sample] // Placeholder
    }
}

// MARK: - Data Size Enum

/// Data generation size options
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