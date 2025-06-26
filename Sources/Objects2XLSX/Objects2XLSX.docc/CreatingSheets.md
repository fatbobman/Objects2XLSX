# Creating Sheets

Learn how to create and configure worksheets for different data types and use cases.

## Overview

Sheets are the core component of any Excel workbook. Objects2XLSX provides a powerful, type-safe API for creating sheets that automatically map your Swift objects to Excel rows and columns.

## Basic Sheet Creation

### Simple Sheet

Create a basic sheet with minimal configuration:

```swift
struct Product: Sendable {
    let name: String
    let price: Double
    let category: String
}

let products = [
    Product(name: "iPhone 15", price: 999.0, category: "Electronics"),
    Product(name: "MacBook Pro", price: 1999.0, category: "Computers")
]

let sheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Product Name", keyPath: \.name)
    Column(name: "Price", keyPath: \.price)
    Column(name: "Category", keyPath: \.category)
}
```

### Sheet with Custom Styling

Apply custom styling to your entire sheet:

```swift
var sheetStyle = SheetStyle()
sheetStyle.defaultRowHeight = 25
sheetStyle.defaultColumnWidth = 15
sheetStyle.showGridlines = false
sheetStyle.freezePanes = .freezeTopRow()

let styledSheet = Sheet<Product>(
    name: "Styled Products",
    dataProvider: { products },
    style: sheetStyle
) {
    Column(name: "Product Name", keyPath: \.name)
        .width(25)
    Column(name: "Price", keyPath: \.price)
        .width(12)
    Column(name: "Category", keyPath: \.category)
        .width(20)
}
```

## Advanced Column Configuration

### Handling Optional Values

Objects2XLSX provides several strategies for handling optional data:

```swift
struct Employee: Sendable {
    let name: String
    let salary: Double?
    let bonus: Double?
    let department: String?
}

let sheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    Column(name: "Name", keyPath: \.name)
    
    // Strategy 1: Provide default values
    Column(name: "Salary", keyPath: \.salary)
        .defaultValue(0.0)
    
    // Strategy 2: Keep empty cells (default behavior)
    Column(name: "Bonus", keyPath: \.bonus)
    
    // Strategy 3: Custom nil handling with transformation
    Column(name: "Department", keyPath: \.department)
        .toString { department in
            department ?? "Unassigned"
        }
}
```

### Type Conversions

Transform your data during export:

```swift
struct Order: Sendable {
    let id: Int
    let amount: Double
    let status: OrderStatus
    let createdAt: Date
}

enum OrderStatus: String, Sendable {
    case pending, processing, completed, cancelled
}

let sheet = Sheet<Order>(name: "Orders", dataProvider: { orders }) {
    Column(name: "Order ID", keyPath: \.id)
        .toString { "ORD-\($0)" }
    
    Column(name: "Amount Category", keyPath: \.amount)
        .toString { amount in
            switch amount {
            case 0..<100: "Small"
            case 100..<500: "Medium"
            default: "Large"
            }
        }
    
    Column(name: "Status", keyPath: \.status)
        .toString { $0.rawValue.capitalized }
    
    Column(name: "Order Date", keyPath: \.createdAt)
        .width(15)
}
```

### Boolean Formatting

Customize how boolean values appear in your Excel file:

```swift
struct Task: Sendable {
    let title: String
    let isCompleted: Bool
    let isUrgent: Bool?
    let isPublic: Bool
}

let sheet = Sheet<Task>(name: "Tasks", dataProvider: { tasks }) {
    Column(name: "Title", keyPath: \.title)
    
    // Use predefined boolean expressions
    Column(name: "Completed", keyPath: \.isCompleted, booleanExpressions: .yesAndNo)
    
    Column(name: "Urgent", keyPath: \.isUrgent)
        .defaultValue(false)
        .toString { $0 ? "🔴 Urgent" : "⚪ Normal" }
    
    Column(name: "Public", keyPath: \.isPublic, booleanExpressions: .trueAndFalse)
}
```

## Multiple Sheets in a Workbook

Create workbooks with multiple sheets for different data types:

```swift
struct Customer: Sendable {
    let name: String
    let email: String
    let registrationDate: Date
}

struct Product: Sendable {
    let name: String
    let price: Double
    let category: String
}

// Create individual sheets
let customerSheet = Sheet<Customer>(name: "Customers", dataProvider: { customers }) {
    Column(name: "Customer Name", keyPath: \.name)
        .width(25)
    Column(name: "Email", keyPath: \.email)
        .width(30)
    Column(name: "Registration", keyPath: \.registrationDate)
        .width(15)
}

let productSheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Product Name", keyPath: \.name)
        .width(25)
    Column(name: "Price", keyPath: \.price)
        .width(12)
    Column(name: "Category", keyPath: \.category)
        .width(20)
}

// Combine in workbook
let workbook = Book(style: BookStyle()) {
    customerSheet
    productSheet
}
```

## Sheet-Level Styling

### Freeze Panes

Keep headers visible while scrolling:

```swift
var style = SheetStyle()
style.freezePanes = .freezeTopRow()              // Freeze first row
style.freezePanes = .freezeFirstColumn()         // Freeze first column
style.freezePanes = .custom(row: 2, column: 1)   // Custom freeze point
```

### Gridlines and Zoom

Control sheet appearance:

```swift
var style = SheetStyle()
style.showGridlines = false
style.zoom = .custom(125)  // 125% zoom level
```

### Row and Column Defaults

Set default dimensions:

```swift
var style = SheetStyle()
style.defaultRowHeight = 20
style.defaultColumnWidth = 15
```

## Data Loading Strategies

### Lazy Loading for Large Datasets

For memory efficiency with large datasets:

```swift
let largeDataSheet = Sheet<LargeDataModel>(name: "Big Data") {
    dataProvider: {
        // Load data only when needed
        return DatabaseManager.fetchLargeDataset()
    }
} columns: {
    Column(name: "ID", keyPath: \.id)
    Column(name: "Value", keyPath: \.value)
    // ... more columns
}
```

### Dynamic Data Sources

Use closures for dynamic data loading:

```swift
let dynamicSheet = Sheet<Employee>(name: "Current Employees") {
    dataProvider: {
        // This closure is called when the sheet is processed
        return EmployeeService.getCurrentEmployees()
    }
} columns: {
    Column(name: "Name", keyPath: \.name)
    Column(name: "Department", keyPath: \.department)
}
```

## Best Practices

### Sheet Naming

- Use descriptive, concise names
- Avoid special characters that Excel doesn't support
- Objects2XLSX automatically sanitizes sheet names

### Performance Considerations

- Use lazy data loading for large datasets
- Consider memory usage when processing many sheets
- Take advantage of the progress tracking for user feedback

### Type Safety

- Always use strongly-typed models that conform to `Sendable`
- Leverage KeyPath for compile-time safety
- Use the type-safe column API to prevent runtime errors

## See Also

- ``Sheet``
- ``Column``
- ``SheetStyle``
- <doc:StylingWorkbooks>
- <doc:TypeConversions>