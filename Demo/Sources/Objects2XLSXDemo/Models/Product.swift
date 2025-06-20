//
// Product.swift
// Objects2XLSXDemo
//
// Product data model demonstrating modern styling and conditional formatting
//

import Foundation

// MARK: - Product Model

/// Product data model for modern-style worksheet demonstration
///
/// This model showcases:
/// - Filtering by category and status
/// - Rating mapping to visual representations
/// - Stock level conditional formatting
/// - Text wrapping for descriptions
/// - Modern styling with gradients and colors
struct Product: Sendable {
    // MARK: - Properties
    
    /// Unique product identifier
    let id: Int
    
    /// Product name
    let name: String
    
    /// Product category for filtering
    let category: Category
    
    /// Product price (optional for nil handling)
    let price: Double?
    
    /// Current stock quantity
    let stock: Int
    
    /// Customer rating (1-5 scale)
    let rating: Double
    
    /// Product availability status
    let isActive: Bool
    
    /// Product description for text wrapping demo
    let description: String
    
    // MARK: - Category Enum
    
    /// Product category enumeration
    enum Category: String, CaseIterable, Sendable {
        case electronics = "Electronics"
        case clothing = "Clothing"
        case books = "Books"
        case home = "Home & Garden"
        case sports = "Sports & Outdoors"
        case beauty = "Beauty & Personal Care"
        
        /// Display name for Excel output
        var displayName: String {
            return rawValue
        }
    }
}

// MARK: - Product Extensions

extension Product {
    /// Stock level status for conditional formatting
    var stockLevel: StockLevel {
        switch stock {
        case 0:
            return .outOfStock
        case 1...10:
            return .low
        case 11...50:
            return .medium
        default:
            return .high
        }
    }
    
    /// Rating as star representation for mapping
    var starRating: String {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        var stars = String(repeating: "★", count: fullStars)
        if hasHalfStar {
            stars += "☆"
        }
        
        let remaining = 5 - stars.count
        if remaining > 0 {
            stars += String(repeating: "☆", count: remaining)
        }
        
        return "\(stars) (\(String(format: "%.1f", rating)))"
    }
    
    /// Sample product for testing
    static let sample = Product(
        id: 1001,
        name: "Wireless Bluetooth Headphones",
        category: .electronics,
        price: 199.99,
        stock: 45,
        rating: 4.5,
        isActive: true,
        description: "High-quality wireless Bluetooth headphones with noise cancellation, 30-hour battery life, and premium sound quality. Perfect for music lovers and professionals."
    )
}

// MARK: - Stock Level Enum

/// Stock level enumeration for conditional formatting
enum StockLevel: Sendable {
    case outOfStock
    case low
    case medium
    case high
    
    /// Display color for conditional formatting
    var displayColor: String {
        switch self {
        case .outOfStock:
            return "Red"
        case .low:
            return "Orange"
        case .medium:
            return "Yellow"
        case .high:
            return "Green"
        }
    }
}