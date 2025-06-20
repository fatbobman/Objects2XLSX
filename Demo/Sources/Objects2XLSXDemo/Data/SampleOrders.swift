//
// SampleOrders.swift
// Objects2XLSXDemo
//
// Sample order data generator for demonstration
//

import Foundation

// MARK: - Sample Order Data Generator

/// Generator for sample order data
struct SampleOrders {
    
    /// Generate sample order data
    /// - Parameter size: Data size (small, medium, large)
    /// - Returns: Array of sample orders
    static func generate(size: DataSize = .medium) -> [Order] {
        // TODO: Implement order data generation
        // - Create orders with various statuses
        // - Generate realistic order IDs (sequential or formatted)
        // - Mix of customer names (some empty for filtering demo)
        // - Range of order dates (recent months)
        // - Variable number of items per order (1-5)
        // - Different tax rates (0.05, 0.08, 0.10)
        // - Calculated fields will be computed automatically
        
        return [Order.sample] // Placeholder
    }
}