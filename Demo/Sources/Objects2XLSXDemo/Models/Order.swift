//
// Order.swift
// Objects2XLSXDemo
//
// Order data model demonstrating default styling and calculated fields
//

import Foundation

// MARK: - Order Model

/// Order data model for default-style worksheet demonstration
///
/// This model showcases:
/// - Default Excel styling
/// - Calculated fields (subtotal, tax, total)
/// - Array to string mapping for items
/// - Date formatting
/// - Status-based conditional colors
struct Order: Sendable {
    // MARK: - Properties
    
    /// Unique order identifier
    let orderID: String
    
    /// Customer name
    let customerName: String
    
    /// Order placement date
    let orderDate: Date
    
    /// List of ordered items
    let items: [OrderItem]
    
    /// Tax rate (as decimal, e.g., 0.08 for 8%)
    let taxRate: Double
    
    /// Order status
    let status: OrderStatus
    
    // MARK: - Calculated Properties
    
    /// Subtotal before tax
    var subtotal: Double {
        items.reduce(0) { total, item in
            total + (item.price * Double(item.quantity))
        }
    }
    
    /// Tax amount
    var tax: Double {
        subtotal * taxRate
    }
    
    /// Total amount including tax
    var total: Double {
        subtotal + tax
    }
    
    /// Items as formatted string for Excel display
    var itemsDescription: String {
        items.map { "\($0.name) (×\($0.quantity))" }
             .joined(separator: ", ")
    }
}

// MARK: - Order Item Model

/// Individual item within an order
struct OrderItem: Sendable {
    let name: String
    let price: Double
    let quantity: Int
}

// MARK: - Order Status Enum

/// Order status enumeration
enum OrderStatus: String, CaseIterable, Sendable {
    case pending = "Pending"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    case returned = "Returned"
    
    /// Display name for Excel output
    var displayName: String {
        return rawValue
    }
    
    /// Status color for conditional formatting
    var statusColor: String {
        switch self {
        case .pending:
            return "Gray"
        case .processing:
            return "Blue"
        case .shipped:
            return "Orange"
        case .delivered:
            return "Green"
        case .cancelled:
            return "Red"
        case .returned:
            return "Purple"
        }
    }
}

// MARK: - Order Extensions

extension Order {
    /// Sample order for testing
    static let sample = Order(
        orderID: "ORD-2024-001",
        customerName: "Alice Johnson",
        orderDate: Date(),
        items: [
            OrderItem(name: "Laptop Stand", price: 49.99, quantity: 1),
            OrderItem(name: "Wireless Mouse", price: 29.99, quantity: 2),
            OrderItem(name: "USB-C Cable", price: 19.99, quantity: 3)
        ],
        taxRate: 0.08,
        status: .shipped
    )
}