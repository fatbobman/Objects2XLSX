# Optional Handling

Master the art of handling optional values in your Excel exports with elegant and type-safe approaches.

## Overview

Swift's optional system is powerful for preventing null pointer exceptions, but when exporting to Excel, you need clear strategies for handling `nil` values. Objects2XLSX provides several elegant approaches to manage optional data, from simple default values to sophisticated custom transformations.

## Default Value Strategy

### Simple Default Values

The most straightforward approach is to provide default values for optional properties:

```swift
struct Employee: Sendable {
    let name: String
    let salary: Double?
    let bonus: Double?
    let department: String?
    let isManager: Bool?
}

let sheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    Column(name: "Name", keyPath: \.name)
    
    // Provide default values for optional properties
    Column(name: "Salary", keyPath: \.salary)
        .defaultValue(0.0)
    
    Column(name: "Bonus", keyPath: \.bonus)
        .defaultValue(0.0)
    
    Column(name: "Department", keyPath: \.department)
        .defaultValue("Unassigned")
    
    Column(name: "Manager", keyPath: \.isManager)
        .defaultValue(false)
}
```

### Meaningful Defaults

Choose defaults that make sense in your business context:

```swift
struct Product: Sendable {
    let name: String
    let price: Double?
    let weight: Double?
    let availability: Bool?
    let category: String?
}

let sheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Product Name", keyPath: \.name)
    
    // Use meaningful business defaults
    Column(name: "Price", keyPath: \.price)
        .defaultValue(0.00)  // Free item
    
    Column(name: "Weight (kg)", keyPath: \.weight)
        .defaultValue(0.1)   // Minimal weight
    
    Column(name: "Available", keyPath: \.availability)
        .defaultValue(true)  // Assume available by default
    
    Column(name: "Category", keyPath: \.category)
        .defaultValue("General")  // Default category
}
```

## Empty Cell Strategy

### Keeping Cells Empty

Sometimes it's better to leave cells empty rather than provide defaults:

```swift
struct Contact: Sendable {
    let name: String
    let email: String?
    let phone: String?
    let notes: String?
}

let sheet = Sheet<Contact>(name: "Contacts", dataProvider: { contacts }) {
    Column(name: "Name", keyPath: \.name)
    
    // These will show as empty cells when nil
    Column(name: "Email", keyPath: \.email)
    Column(name: "Phone", keyPath: \.phone)
    Column(name: "Notes", keyPath: \.notes)
}
```

### When to Use Empty Cells

Empty cells are appropriate when:
- The absence of data is meaningful
- Users need to visually identify missing information
- You want to maintain data integrity without assumptions

## Custom Transformation Strategy

### Advanced Nil Handling

Use the `toString` method for sophisticated optional handling:

```swift
struct Customer: Sendable {
    let name: String
    let email: String?
    let lastLogin: Date?
    let totalSpent: Double?
    let preferredContact: ContactMethod?
}

enum ContactMethod: String, Sendable {
    case email, phone, mail
}

let sheet = Sheet<Customer>(name: "Customers", dataProvider: { customers }) {
    Column(name: "Name", keyPath: \.name)
    
    // Custom email validation and formatting
    Column(name: "Email Status", keyPath: \.email)
        .toString { email in
            guard let email = email else { return "❌ No Email" }
            let isValid = email.contains("@") && email.contains(".")
            return isValid ? "✅ \(email)" : "⚠️ Invalid: \(email)"
        }
    
    // Last login with relative time
    Column(name: "Last Seen", keyPath: \.lastLogin)
        .toString { lastLogin in
            guard let lastLogin = lastLogin else { return "Never" }
            
            let interval = Date().timeIntervalSince(lastLogin)
            let days = Int(interval / 86400)
            
            switch days {
            case 0: return "Today"
            case 1: return "Yesterday"
            case 2...7: return "\(days) days ago"
            case 8...30: return "\(days / 7) weeks ago"
            default: return "Over a month ago"
            }
        }
    
    // Spending tier with nil handling
    Column(name: "Customer Tier", keyPath: \.totalSpent)
        .toString { spent in
            guard let spent = spent else { return "New Customer" }
            
            switch spent {
            case 0..<100: return "Bronze ($\(String(format: "%.0f", spent)))"
            case 100..<500: return "Silver ($\(String(format: "%.0f", spent)))"
            case 500..<1000: return "Gold ($\(String(format: "%.0f", spent)))"
            default: return "Platinum ($\(String(format: "%.0f", spent)))"
            }
        }
    
    // Contact preference with fallback
    Column(name: "Contact Method", keyPath: \.preferredContact)
        .toString { method in
            method?.rawValue.capitalized ?? "Not Specified"
        }
}
```

### Type-Safe Optional Handling

The type system helps ensure you handle optionals correctly:

```swift
struct Order: Sendable {
    let id: String
    let customerNote: String?
    let discountPercent: Double?
    let estimatedDelivery: Date?
}

let sheet = Sheet<Order>(name: "Orders", dataProvider: { orders }) {
    Column(name: "Order ID", keyPath: \.id)
    
    // Type-safe optional handling with defaultValue
    Column(name: "Discount", keyPath: \.discountPercent)
        .defaultValue(0.0)  // Now the closure receives Double (non-optional)
        .toString { (discount: Double) in  // Type is now Double, not Double?
            discount == 0.0 ? "No Discount" : "\(String(format: "%.1f", discount))% off"
        }
    
    // Keep as optional for explicit nil handling
    Column(name: "Customer Note", keyPath: \.customerNote)
        .toString { (note: String?) in  // Explicitly handling String?
            note?.isEmpty == false ? note! : "No special instructions"
        }
    
    // Delivery estimation
    Column(name: "Delivery", keyPath: \.estimatedDelivery)
        .toString { (date: Date?) in
            guard let date = date else { return "TBD" }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            
            if date > Date() {
                return "Est: \(formatter.string(from: date))"
            } else {
                return "Overdue: \(formatter.string(from: date))"
            }
        }
}
```

## Chaining with Optional Handling

### Combining Strategies

You can combine different optional handling strategies in a single column configuration:

```swift
struct Employee: Sendable {
    let name: String
    let salary: Double?
    let performanceRating: Int?
}

let sheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    Column(name: "Name", keyPath: \.name)
    
    // Chain defaultValue with toString for complex logic
    Column(name: "Salary Band", keyPath: \.salary)
        .defaultValue(0.0)  // Handle nil first
        .toString { salary in  // Then transform the non-optional value
            switch salary {
            case 0: return "Not Disclosed"
            case 0..<40000: return "Entry Level"
            case 40000..<70000: return "Mid Level"
            case 70000..<100000: return "Senior Level"
            default: return "Executive Level"
            }
        }
        .width(15)
    
    // Performance rating with multiple fallbacks
    Column(name: "Performance", keyPath: \.performanceRating)
        .toString { rating in
            guard let rating = rating else { return "Not Rated" }
            
            switch rating {
            case 1...2: return "Needs Improvement"
            case 3: return "Meets Expectations"
            case 4: return "Exceeds Expectations"
            case 5: return "Outstanding"
            default: return "Invalid Rating"
            }
        }
}
```

## Boolean Optional Handling

### Special Handling for Optional Booleans

Optional booleans require special consideration:

```swift
struct Task: Sendable {
    let title: String
    let isCompleted: Bool?
    let isUrgent: Bool?
    let isPublic: Bool?
}

let sheet = Sheet<Task>(name: "Tasks", dataProvider: { tasks }) {
    Column(name: "Title", keyPath: \.title)
    
    // Strategy 1: Use defaultValue
    Column(name: "Completed", keyPath: \.isCompleted)
        .defaultValue(false)  // Assume not completed if unknown
    
    // Strategy 2: Three-state display
    Column(name: "Urgent", keyPath: \.isUrgent)
        .toString { urgent in
            switch urgent {
            case .some(true): return "🔴 Urgent"
            case .some(false): return "⚪ Normal"
            case .none: return "❓ Unknown"
            }
        }
    
    // Strategy 3: Custom boolean expressions with nil handling
    Column(name: "Visibility", keyPath: \.isPublic)
        .toString { isPublic in
            guard let isPublic = isPublic else { return "Private (default)" }
            return isPublic ? "Public" : "Private"
        }
}
```

## Nested Optional Handling

### Working with Complex Data

Handle optionals in nested structures:

```swift
struct Address: Sendable {
    let street: String
    let city: String
    let zipCode: String?
}

struct Person: Sendable {
    let name: String
    let address: Address?
    let emergencyContact: Person?
}

let sheet = Sheet<Person>(name: "People", dataProvider: { people }) {
    Column(name: "Name", keyPath: \.name)
    
    // Access nested optional properties
    Column(name: "City", keyPath: \.address)
        .toString { address in
            address?.city ?? "No Address"
        }
    
    Column(name: "ZIP Code", keyPath: \.address)
        .toString { address in
            guard let address = address else { return "N/A" }
            return address.zipCode ?? "No ZIP"
        }
    
    // Handle deeply nested optionals
    Column(name: "Emergency Contact", keyPath: \.emergencyContact)
        .toString { contact in
            contact?.name ?? "None Listed"
        }
}
```

## Best Practices

### Choose the Right Strategy

1. **Use defaultValue when**:
   - You have a sensible business default
   - Empty cells would be confusing
   - You need numeric calculations

2. **Use empty cells when**:
   - The absence of data is meaningful
   - Users need to identify missing information
   - You want to preserve data integrity

3. **Use custom toString when**:
   - You need complex conditional logic
   - You want to provide context about missing data
   - You need to validate or format optional data

### Performance Considerations

- Simple defaultValue operations are faster than toString transformations
- Cache complex formatting objects (like DateFormatter) outside the toString closure
- Avoid heavy computations in optional handling logic

### User Experience

- Provide clear indicators for missing data
- Use consistent nil handling patterns across your application
- Consider internationalization for text like "Not Available"

### Type Safety

- Let the type system help you handle optionals correctly
- Use defaultValue to convert optionals to non-optionals when appropriate
- Be explicit about your nil handling strategy in each column

## See Also

- ``Column``
- <doc:TypeConversions>
- <doc:CreatingSheets>
- ``CellStyle``