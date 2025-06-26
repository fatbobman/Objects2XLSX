# Type Conversions

Transform your data during Excel export with powerful type conversion methods.

## Overview

Objects2XLSX provides flexible type conversion capabilities that allow you to transform your Swift data types into the exact format you want in your Excel files. Whether you need to format numbers, convert enums to readable strings, or create custom data representations, the type conversion system has you covered.

## Basic Type Conversions

### String Transformations

Convert various data types to custom string representations:

```swift
struct Product: Sendable {
    let id: Int
    let name: String
    let price: Double
    let category: ProductCategory
}

enum ProductCategory: String, Sendable {
    case electronics, clothing, books, home
}

let sheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    // Convert ID to formatted string
    Column(name: "Product Code", keyPath: \.id)
        .toString { "PRD-\(String(format: "%05d", $0))" }
    
    // Uppercase product names
    Column(name: "Product Name", keyPath: \.name)
        .toString { $0.uppercased() }
    
    // Format price as currency string
    Column(name: "Price Display", keyPath: \.price)
        .toString { String(format: "$%.2f", $0) }
    
    // Convert enum to display name
    Column(name: "Category", keyPath: \.category)
        .toString { $0.rawValue.capitalized }
}
```

### Numeric Conversions

Transform numeric data for better presentation:

```swift
struct SalesData: Sendable {
    let revenue: Double
    let units: Int
    let profit: Double?
}

let sheet = Sheet<SalesData>(name: "Sales", dataProvider: { salesData }) {
    // Convert to thousands
    Column(name: "Revenue (K)", keyPath: \.revenue)
        .toString { String(format: "%.1fK", $0 / 1000) }
    
    // Convert to percentage
    Column(name: "Units Sold", keyPath: \.units)
        .toInt { $0 }  // Keep as number
    
    // Profit margin calculation and formatting
    Column(name: "Profit Margin", keyPath: \.profit)
        .defaultValue(0.0)
        .toString { profit in
            let percentage = (profit / 100000) * 100  // Assuming revenue base
            return String(format: "%.1f%%", percentage)
        }
}
```

## Advanced Conversions

### Conditional Formatting

Apply different formatting based on data values:

```swift
struct Employee: Sendable {
    let name: String
    let salary: Double
    let performanceScore: Int
    let department: String
    let yearsOfService: Int
}

let sheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    Column(name: "Name", keyPath: \.name)
    
    // Salary grade based on amount
    Column(name: "Salary Grade", keyPath: \.salary)
        .toString { salary in
            switch salary {
            case 0..<40000: "Entry Level"
            case 40000..<70000: "Mid Level"
            case 70000..<100000: "Senior Level"
            default: "Executive Level"
            }
        }
    
    // Performance rating with emojis
    Column(name: "Performance", keyPath: \.performanceScore)
        .toString { score in
            switch score {
            case 90...100: "🌟 Excellent"
            case 80..<90: "✅ Good"
            case 70..<80: "⚠️ Average"
            default: "❌ Needs Improvement"
            }
        }
    
    // Seniority level
    Column(name: "Seniority", keyPath: \.yearsOfService)
        .toString { years in
            switch years {
            case 0..<2: "Junior (\(years) years)"
            case 2..<5: "Regular (\(years) years)"
            case 5..<10: "Senior (\(years) years)"
            default: "Veteran (\(years) years)"
            }
        }
}
```

### Date and Time Formatting

Customize date and time representations:

```swift
struct Event: Sendable {
    let title: String
    let startDate: Date
    let endDate: Date
    let createdAt: Date
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "MMM dd, yyyy"

let timeFormatter = DateFormatter()
timeFormatter.dateFormat = "h:mm a"

let sheet = Sheet<Event>(name: "Events", dataProvider: { events }) {
    Column(name: "Event Title", keyPath: \.title)
    
    // Custom date format
    Column(name: "Start Date", keyPath: \.startDate)
        .toString { dateFormatter.string(from: $0) }
    
    // Time only
    Column(name: "Start Time", keyPath: \.startDate)
        .toString { timeFormatter.string(from: $0) }
    
    // Relative time
    Column(name: "Created", keyPath: \.createdAt)
        .toString { date in
            let interval = Date().timeIntervalSince(date)
            let days = Int(interval / 86400)
            return days == 0 ? "Today" : "\(days) days ago"
        }
    
    // Duration calculation
    Column(name: "Duration", keyPath: \.startDate)
        .toString { startDate in
            // Assuming we have access to endDate somehow
            let duration = events.first(where: { $0.startDate == startDate })?.endDate.timeIntervalSince(startDate) ?? 0
            let hours = Int(duration / 3600)
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)h \(minutes)m"
        }
}
```

## Handling Optional Values

### Smart Nil Handling

Combine optional handling with type conversions:

```swift
struct Customer: Sendable {
    let name: String
    let email: String?
    let phone: String?
    let lastPurchase: Date?
    let totalSpent: Double?
}

let sheet = Sheet<Customer>(name: "Customers", dataProvider: { customers }) {
    Column(name: "Name", keyPath: \.name)
    
    // Email with custom nil handling
    Column(name: "Email Status", keyPath: \.email)
        .toString { email in
            guard let email = email else { return "❌ No Email" }
            return email.contains("@") ? "✅ \(email)" : "⚠️ Invalid Email"
        }
    
    // Phone formatting
    Column(name: "Phone", keyPath: \.phone)
        .toString { phone in
            guard let phone = phone else { return "Not Provided" }
            // Simple phone formatting
            let digits = phone.filter { $0.isNumber }
            guard digits.count == 10 else { return phone }
            return "(\(digits.prefix(3))) \(digits.dropFirst(3).prefix(3))-\(digits.suffix(4))"
        }
    
    // Last purchase with default
    Column(name: "Last Purchase", keyPath: \.lastPurchase)
        .toString { date in
            guard let date = date else { return "Never" }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    
    // Customer tier based on spending
    Column(name: "Customer Tier", keyPath: \.totalSpent)
        .toString { spent in
            guard let spent = spent else { return "New Customer" }
            switch spent {
            case 0..<100: "Bronze"
            case 100..<500: "Silver"
            case 500..<1000: "Gold"
            default: "Platinum"
            }
        }
}
```

## Complex Data Transformations

### Multi-Property Calculations

Access multiple properties for complex calculations:

```swift
struct Order: Sendable {
    let id: String
    let quantity: Int
    let unitPrice: Double
    let discountPercent: Double
    let taxPercent: Double
    let shippingCost: Double
}

let sheet = Sheet<Order>(name: "Orders", dataProvider: { orders }) {
    Column(name: "Order ID", keyPath: \.id)
    
    // Subtotal calculation
    Column(name: "Subtotal", keyPath: \.quantity)
        .toString { quantity in
            // Note: In real usage, you'd need access to the full object
            // This is a simplified example
            return String(format: "$%.2f", Double(quantity) * 10.0) // Placeholder calculation
        }
    
    // Discount amount
    Column(name: "Discount", keyPath: \.discountPercent)
        .toString { discount in
            String(format: "%.1f%% off", discount)
        }
    
    // Final total (this would need custom column implementation for real multi-property access)
    Column(name: "Total", keyPath: \.unitPrice)
        .toString { unitPrice in
            // Simplified calculation
            String(format: "$%.2f", unitPrice)
        }
}
```

### Enum and Complex Type Handling

Handle enums and complex data structures:

```swift
enum OrderStatus: String, CaseIterable, Sendable {
    case pending, confirmed, shipped, delivered, cancelled
    
    var displayName: String {
        switch self {
        case .pending: return "🟡 Pending"
        case .confirmed: return "🔵 Confirmed"
        case .shipped: return "🟠 Shipped"
        case .delivered: return "🟢 Delivered"
        case .cancelled: return "🔴 Cancelled"
        }
    }
    
    var priority: Int {
        switch self {
        case .pending: return 1
        case .confirmed: return 2
        case .shipped: return 3
        case .delivered: return 4
        case .cancelled: return 0
        }
    }
}

struct OrderItem: Sendable {
    let orderId: String
    let status: OrderStatus
    let priority: Priority
    let tags: [String]
}

enum Priority: Int, CaseIterable, Sendable {
    case low = 1, normal = 2, high = 3, urgent = 4
}

let sheet = Sheet<OrderItem>(name: "Order Items", dataProvider: { items }) {
    Column(name: "Order ID", keyPath: \.orderId)
    
    // Enum with custom display
    Column(name: "Status", keyPath: \.status)
        .toString { $0.displayName }
    
    // Priority with emoji
    Column(name: "Priority", keyPath: \.priority)
        .toString { priority in
            switch priority {
            case .low: return "🟢 Low"
            case .normal: return "🟡 Normal"
            case .high: return "🟠 High"
            case .urgent: return "🔴 Urgent"
            }
        }
    
    // Array of tags as comma-separated string
    Column(name: "Tags", keyPath: \.tags)
        .toString { tags in
            tags.isEmpty ? "No tags" : tags.joined(separator: ", ")
        }
}
```

## Best Practices

### Performance Considerations

- Keep conversion logic simple and fast
- Avoid heavy computations in conversion methods
- Cache formatter objects when possible

### Type Safety

- Use strong typing in your conversion methods
- Handle edge cases explicitly
- Provide meaningful defaults for optional values

### Readability

- Make converted values human-readable
- Use consistent formatting across similar data
- Add visual indicators (emojis, symbols) sparingly but effectively

### Localization

- Consider locale-specific formatting for dates and numbers
- Use appropriate currency symbols and decimal separators
- Handle right-to-left languages if needed

## See Also

- ``Column``
- <doc:OptionalHandling>
- <doc:CreatingSheets>
- ``CellStyle``