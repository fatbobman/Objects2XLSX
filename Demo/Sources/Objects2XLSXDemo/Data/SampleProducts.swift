//
// SampleProducts.swift
// Objects2XLSXDemo
//
// Sample product data generator for demonstration
//

import Foundation

// MARK: - Sample Product Data Generator

/// Generator for sample product data
struct SampleProducts {
    
    /// Generate sample product data
    /// - Parameter size: Data size (small, medium, large)
    /// - Returns: Array of sample products
    static func generate(size: DataSize = .medium) -> [Product] {
        // TODO: Implement product data generation
        // - Create products across all categories
        // - Include variety of stock levels (including 0 and low stock)
        // - Mix of active and inactive products
        // - Range of ratings from 1.0 to 5.0
        // - Some products with nil prices
        // - Realistic product descriptions of varying lengths
        
        return [Product.sample] // Placeholder
    }
}