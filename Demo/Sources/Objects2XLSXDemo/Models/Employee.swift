//
// Employee.swift
// Objects2XLSXDemo
//
// Employee data model demonstrating complex data types and enterprise styling
//

import Foundation

// MARK: - Employee Model

/// Employee data model for corporate-style worksheet demonstration
/// 
/// This model showcases:
/// - Complex data types (String, Int, Double, Date, URL, Bool, Optional)
/// - Enum properties for mapping demonstrations
/// - Optional properties for nil handling examples
/// - Currency and date formatting scenarios
struct Employee: Sendable {
    // MARK: - Properties
    
    /// Employee full name
    let name: String
    
    /// Employee age (will be filtered >= 18)
    let age: Int
    
    /// Department enumeration for mapping demonstration
    let department: Department
    
    /// Monthly salary in USD (optional for nil handling demo)
    let salary: Double?
    
    /// Employee email URL
    let email: URL
    
    /// Date when employee was hired
    let hireDate: Date
    
    /// Management status for boolean mapping
    let isManager: Bool
    
    /// Home address (optional for nil handling)
    let address: String?
    
    // MARK: - Department Enum
    
    /// Department enumeration for mapping demonstrations
    enum Department: String, CaseIterable, Sendable {
        case engineering = "Engineering"
        case marketing = "Marketing"
        case sales = "Sales"
        case hr = "Human Resources"
        case finance = "Finance"
        case operations = "Operations"
        
        /// Display name for Excel output
        var displayName: String {
            return rawValue
        }
    }
}

// MARK: - Employee Extensions

extension Employee {
    /// Sample employee for testing
    static let sample = Employee(
        name: "John Doe",
        age: 32,
        department: .engineering,
        salary: 85000.0,
        email: URL(string: "john.doe@company.com")!,
        hireDate: Date(timeIntervalSince1970: 1609459200), // 2021-01-01
        isManager: true,
        address: "123 Main St, San Francisco, CA 94105"
    )
}