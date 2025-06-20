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
    
    // MARK: - Data Arrays
    
    /// Product names by category
    private static let productNames: [Product.Category: [String]] = [
        .electronics: [
            "Wireless Bluetooth Headphones", "Smart Watch Pro", "4K USB Webcam", 
            "Gaming Mechanical Keyboard", "Wireless Mouse", "Portable SSD Drive",
            "USB-C Hub", "Bluetooth Speaker", "Smartphone Stand", "Laptop Cooling Pad"
        ],
        .clothing: [
            "Cotton T-Shirt", "Denim Jeans", "Winter Jacket", "Running Shoes",
            "Baseball Cap", "Casual Sneakers", "Dress Shirt", "Yoga Pants",
            "Sweater Hoodie", "Athletic Shorts"
        ],
        .books: [
            "Swift Programming Guide", "Digital Marketing Handbook", "Data Science Essentials",
            "Business Strategy Manual", "Photography Masterclass", "Cooking for Beginners",
            "Travel Photography", "Financial Planning Guide", "Mindfulness Meditation",
            "Web Development Fundamentals"
        ],
        .home: [
            "Indoor Plant Pot", "Kitchen Knife Set", "Bed Sheet Set", "Table Lamp",
            "Storage Organizer", "Bathroom Mirror", "Garden Tool Set", "Throw Pillow",
            "Wall Clock", "Decorative Vase"
        ],
        .sports: [
            "Yoga Mat", "Resistance Bands", "Water Bottle", "Tennis Racket",
            "Basketball", "Hiking Backpack", "Exercise Dumbbells", "Running Belt",
            "Compression Socks", "Fitness Tracker"
        ],
        .beauty: [
            "Face Moisturizer", "Hair Styling Gel", "Makeup Brush Set", "Nail Polish",
            "Body Lotion", "Lip Balm", "Sunscreen SPF 50", "Eye Cream",
            "Hand Sanitizer", "Perfume"
        ]
    ]
    
    /// Product description templates
    private static let descriptionTemplates = [
        "High-quality {product} with premium materials and excellent durability. Perfect for daily use and professional applications.",
        "Professional-grade {product} designed for optimal performance and user satisfaction. Includes warranty and customer support.",
        "Innovative {product} featuring cutting-edge technology and modern design. Ideal for tech-savvy consumers.",
        "Versatile {product} suitable for multiple uses and environments. Lightweight, portable, and user-friendly.",
        "Premium {product} crafted with attention to detail and superior quality. Recommended by industry experts.",
        "Eco-friendly {product} made from sustainable materials. Environmentally conscious choice for modern consumers.",
        "Affordable {product} offering great value for money without compromising on quality. Perfect starter option.",
        "Luxury {product} designed for discerning customers who appreciate fine craftsmanship and elegant aesthetics."
    ]
    
    // MARK: - Generation Logic
    
    /// Generate sample product data
    /// - Parameter size: Data size (small, medium, large)
    /// - Returns: Array of sample products
    static func generate(size: DataSize = .medium) -> [Product] {
        let count = size.recordCount
        var products: [Product] = []
        
        // Use a seeded random number generator for consistent results
        var randomGenerator = SeededRandomGenerator(seed: 123)
        
        for i in 0..<count {
            let product = generateProduct(index: i, using: &randomGenerator)
            products.append(product)
        }
        
        return products
    }
    
    /// Generate a single product with realistic data
    /// - Parameters:
    ///   - index: Product index for unique identification
    ///   - randomGenerator: Seeded random generator for consistent results
    /// - Returns: Generated product
    private static func generateProduct(index: Int, using randomGenerator: inout SeededRandomGenerator) -> Product {
        // Generate unique ID (starting from 1001)
        let id = 1001 + index
        
        // Select category (weighted distribution)
        let category: Product.Category
        let categoryRoll = randomGenerator.next(max: 100)
        switch categoryRoll {
        case 0..<25: category = .electronics
        case 25..<40: category = .clothing
        case 40..<55: category = .books
        case 55..<70: category = .home
        case 70..<85: category = .sports
        default: category = .beauty
        }
        
        // Select product name from category
        let categoryNames = productNames[category]!
        let name = categoryNames[randomGenerator.next(max: categoryNames.count)]
        
        // Generate price (15% nil for nil handling demo)
        let price: Double?
        if randomGenerator.next(max: 100) < 15 { // 15% chance of nil price
            price = nil
        } else {
            let basePrice: Double
            switch category {
            case .electronics:
                basePrice = Double(randomGenerator.next(range: 2999...29999)) / 100.0 // $29.99 - $299.99
            case .clothing:
                basePrice = Double(randomGenerator.next(range: 1999...9999)) / 100.0  // $19.99 - $99.99
            case .books:
                basePrice = Double(randomGenerator.next(range: 999...4999)) / 100.0   // $9.99 - $49.99
            case .home:
                basePrice = Double(randomGenerator.next(range: 1499...12999)) / 100.0 // $14.99 - $129.99
            case .sports:
                basePrice = Double(randomGenerator.next(range: 1999...19999)) / 100.0 // $19.99 - $199.99
            case .beauty:
                basePrice = Double(randomGenerator.next(range: 899...7999)) / 100.0   // $8.99 - $79.99
            }
            price = basePrice
        }
        
        // Generate stock (20% out of stock, varied distribution)
        let stock: Int
        let stockRoll = randomGenerator.next(max: 100)
        switch stockRoll {
        case 0..<20: stock = 0 // 20% out of stock
        case 20..<35: stock = randomGenerator.next(range: 1...10) // 15% low stock
        case 35..<60: stock = randomGenerator.next(range: 11...50) // 25% medium stock
        default: stock = randomGenerator.next(range: 51...200) // 40% high stock
        }
        
        // Generate rating (weighted toward higher ratings)
        let rating: Double
        let ratingRoll = randomGenerator.next(max: 100)
        switch ratingRoll {
        case 0..<5: rating = Double(randomGenerator.next(range: 10...20)) / 10.0 // 5% poor (1.0-2.0)
        case 5..<15: rating = Double(randomGenerator.next(range: 20...30)) / 10.0 // 10% fair (2.0-3.0)
        case 15..<30: rating = Double(randomGenerator.next(range: 30...40)) / 10.0 // 15% good (3.0-4.0)
        case 30..<60: rating = Double(randomGenerator.next(range: 40...45)) / 10.0 // 30% very good (4.0-4.5)
        default: rating = Double(randomGenerator.next(range: 45...50)) / 10.0 // 40% excellent (4.5-5.0)
        }
        
        // Generate active status (10% inactive for filtering demo)
        let isActive = randomGenerator.next(max: 10) != 0 // 90% active, 10% inactive
        
        // Generate description
        let template = descriptionTemplates[randomGenerator.next(max: descriptionTemplates.count)]
        let description = template.replacingOccurrences(of: "{product}", with: name.lowercased())
        
        return Product(
            id: id,
            name: name,
            category: category,
            price: price,
            stock: stock,
            rating: rating,
            isActive: isActive,
            description: description
        )
    }
}