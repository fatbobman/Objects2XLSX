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
    
    // MARK: - Data Arrays
    
    /// Customer first names
    private static let customerFirstNames = [
        "Alice", "Bob", "Carol", "David", "Emma", "Frank", "Grace", "Henry",
        "Isabella", "James", "Katherine", "Liam", "Maya", "Nathan", "Olivia", "Peter",
        "Quinn", "Rachel", "Samuel", "Taylor", "Uma", "Victor", "Wendy", "Xavier",
        "Yara", "Zachary", "Aria", "Benjamin", "Charlotte", "Daniel"
    ]
    
    /// Customer last names
    private static let customerLastNames = [
        "Anderson", "Brown", "Chen", "Davis", "Evans", "Fischer", "Garcia", "Harris",
        "Jackson", "Johnson", "Kim", "Lee", "Martinez", "Miller", "Nguyen", "O'Connor",
        "Patel", "Rodriguez", "Smith", "Taylor", "Thompson", "Williams", "Wilson", "Young"
    ]
    
    /// Available product items with prices
    private static let availableItems = [
        OrderItem(name: "Laptop Stand", price: 49.99, quantity: 1),
        OrderItem(name: "Wireless Mouse", price: 29.99, quantity: 1),
        OrderItem(name: "USB-C Cable", price: 19.99, quantity: 1),
        OrderItem(name: "Bluetooth Headphones", price: 89.99, quantity: 1),
        OrderItem(name: "Keyboard Wrist Rest", price: 24.99, quantity: 1),
        OrderItem(name: "Phone Stand", price: 15.99, quantity: 1),
        OrderItem(name: "Desk Lamp", price: 39.99, quantity: 1),
        OrderItem(name: "Notebook", price: 12.99, quantity: 1),
        OrderItem(name: "Pen Set", price: 18.99, quantity: 1),
        OrderItem(name: "Coffee Mug", price: 14.99, quantity: 1),
        OrderItem(name: "Water Bottle", price: 22.99, quantity: 1),
        OrderItem(name: "Desk Organizer", price: 34.99, quantity: 1),
        OrderItem(name: "Monitor Stand", price: 79.99, quantity: 1),
        OrderItem(name: "Webcam", price: 59.99, quantity: 1),
        OrderItem(name: "Charging Station", price: 44.99, quantity: 1)
    ]
    
    /// Tax rates used in different regions
    private static let taxRates = [0.05, 0.08, 0.10, 0.12]
    
    // MARK: - Generation Logic
    
    /// Generate sample order data
    /// - Parameter size: Data size (small, medium, large)
    /// - Returns: Array of sample orders
    static func generate(size: DataSize = .medium) -> [Order] {
        let count = size.recordCount
        var orders: [Order] = []
        
        // Use a seeded random number generator for consistent results
        var randomGenerator = SeededRandomGenerator(seed: 456)
        
        for i in 0..<count {
            let order = generateOrder(index: i, using: &randomGenerator)
            orders.append(order)
        }
        
        return orders
    }
    
    /// Generate a single order with realistic data
    /// - Parameters:
    ///   - index: Order index for unique identification
    ///   - randomGenerator: Seeded random generator for consistent results
    /// - Returns: Generated order
    private static func generateOrder(index: Int, using randomGenerator: inout SeededRandomGenerator) -> Order {
        // Generate order ID (format: ORD-YYYY-#### starting from 1001)
        let currentYear = Calendar.current.component(.year, from: Date())
        let orderNumber = String(format: "%04d", 1001 + index)
        let orderID = "ORD-\(currentYear)-\(orderNumber)"
        
        // Generate customer name (10% empty for filtering demo)
        let customerName: String
        if randomGenerator.next(max: 10) == 0 { // 10% chance of empty customer name
            customerName = ""
        } else {
            let firstName = customerFirstNames[randomGenerator.next(max: customerFirstNames.count)]
            let lastName = customerLastNames[randomGenerator.next(max: customerLastNames.count)]
            customerName = "\(firstName) \(lastName)"
        }
        
        // Generate order date (within past 6 months)
        let currentDate = Date()
        let daysSinceOrder = randomGenerator.next(max: 180) // ~6 months in days
        let orderDate = Calendar.current.date(byAdding: .day, value: -daysSinceOrder, to: currentDate)!
        
        // Generate order items (1-5 items per order)
        let itemCount = randomGenerator.next(range: 1...5)
        var orderItems: [OrderItem] = []
        var usedItemIndices: Set<Int> = []
        
        for _ in 0..<itemCount {
            // Select unique items for this order
            var itemIndex: Int
            repeat {
                itemIndex = randomGenerator.next(max: availableItems.count)
            } while usedItemIndices.contains(itemIndex)
            usedItemIndices.insert(itemIndex)
            
            let baseItem = availableItems[itemIndex]
            let quantity = randomGenerator.next(range: 1...3) // 1-3 quantity per item
            
            let orderItem = OrderItem(
                name: baseItem.name,
                price: baseItem.price,
                quantity: quantity
            )
            orderItems.append(orderItem)
        }
        
        // Select tax rate
        let taxRate = taxRates[randomGenerator.next(max: taxRates.count)]
        
        // Generate order status (weighted distribution based on typical order lifecycle)
        let status: OrderStatus
        let statusRoll = randomGenerator.next(max: 100)
        switch statusRoll {
        case 0..<10: status = .pending    // 10% pending
        case 10..<25: status = .processing // 15% processing
        case 25..<40: status = .shipped    // 15% shipped
        case 40..<70: status = .delivered  // 30% delivered
        case 70..<85: status = .cancelled  // 15% cancelled
        default: status = .returned        // 15% returned
        }
        
        return Order(
            orderID: orderID,
            customerName: customerName,
            orderDate: orderDate,
            items: orderItems,
            taxRate: taxRate,
            status: status
        )
    }
}