# Objects2XLSX

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/fatbobman/Objects2XLSX)

A powerful, type-safe Swift library for converting Swift objects to Excel (.xlsx) files. Objects2XLSX provides a modern, declarative API for creating professional Excel spreadsheets with full styling support, multiple worksheets, and real-time progress tracking.

## ✨ Features

### 🎯 **Type-Safe Design**

- **Generic Sheets**: `Sheet<ObjectType>` with compile-time type safety
- **KeyPath Integration**: Direct property mapping with `\.propertyName`
- **Swift 6 Compliant**: Full support for Swift's strict concurrency model

### 📊 **Comprehensive Excel Support**

- **Excel-Compliant Output**: Generated XLSX files strictly conform to Excel specifications with no warnings or compatibility issues
- **Enhanced Column API**: Simplified, type-safe column declarations with automatic type inference
- **Smart Nil Handling**: `.defaultValue()` method for elegant optional value management
- **Type Conversions**: Powerful `.toString()` method for custom data transformations
- **Multiple Data Types**: String, Int, Double, Bool, Date, URL, and Percentage with full optional support
- **Full Styling System**: Fonts, colors, borders, fills, alignment, and number formatting
- **Multiple Worksheets**: Create workbooks with unlimited sheets
- **Method Chaining**: Fluent API for combining width, styling, and data transformations

### 🎨 **Advanced Styling**

- **Professional Appearance**: Rich formatting options matching Excel's capabilities
- **Style Hierarchy**: Book → Sheet → Column → Cell styling with proper precedence
- **Custom Themes**: Create consistent styling across your documents
- **Border Management**: Precise border control with automatic region detection

### 🚀 **Performance & Usability**

- **Standards Compliant**: Generated files open seamlessly in Excel, Numbers, Google Sheets, and LibreOffice without warnings
- **Memory Efficient**: Stream-based processing for large datasets
- **Progress Tracking**: Real-time progress updates with AsyncStream
- **Cross-Platform**: Pure Swift implementation supporting macOS, iOS, tvOS, watchOS, and Linux
- **Zero Dependencies**: No external dependencies except optional SimpleLogger

### 🛠 **Developer Experience**

- **Simplified API**: Intuitive, chainable column declarations with automatic type inference
- **Live Demo Project**: Comprehensive example showcasing all library features
- **Builder Pattern**: Declarative DSL for creating sheets and columns
- **Comprehensive Documentation**: Detailed API documentation with real-world examples
- **Extensive Testing**: 340+ tests ensuring reliability across all features
- **SwiftFormat Integration**: Consistent code formatting with Git hooks

## 📦 Installation

### Swift Package Manager

Add Objects2XLSX to your project using Xcode's Package Manager or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/Objects2XLSX.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["Objects2XLSX"]
)
```

## 🚀 Quick Start

### Basic Usage

```swift
import Objects2XLSX

// 1. Define your data model
struct Person: Sendable {
    let name: String
    let age: Int
    let email: String
}

// 2. Prepare your data
let people = [
    Person(name: "Alice Smith", age: 28, email: "alice@example.com"),
    Person(name: "Bob Johnson", age: 35, email: "bob@example.com"),
    Person(name: "Carol Davis", age: 42, email: "carol@example.com")
]

// 3. Create a sheet with type-safe columns
let sheet = Sheet<Person>(name: "Employees", dataProvider: { people }) {
    Column(name: "Full Name", keyPath: \.name)
    Column(name: "Age", keyPath: \.age)
    Column(name: "Email Address", keyPath: \.email)
}

// 4. Create workbook and generate Excel file
let book = Book(style: BookStyle()) {
    sheet
}

let outputURL = URL(fileURLWithPath: "/path/to/employees.xlsx")
try book.write(to: outputURL)
```

### Try the Live Demo

Experience all features with our comprehensive demo project:

```bash
# Clone the repository
git clone https://github.com/fatbobman/Objects2XLSX.git
cd Objects2XLSX

# Run the demo with different options
swift run Objects2XLSXDemo --help
swift run Objects2XLSXDemo -s medium -v demo.xlsx
swift run Objects2XLSXDemo -s large -t mixed -v -b output.xlsx
```

The demo generates a professional Excel workbook with three worksheets showcasing:

- **Employee data** with corporate styling and data transformations
- **Product catalog** with modern styling and conditional formatting  
- **Order history** with default styling and calculated fields

**Demo Features:**

- 🎨 Three professional styling themes (Corporate, Modern, Default)
- 📊 Multiple data sizes (small: 30, medium: 150, large: 600 records)
- 🔧 All column types and advanced features demonstrated
- ⚡ Real-time progress tracking and performance benchmarks
- 📁 Ready-to-open Excel files showcasing library capabilities

### Multiple Data Types & Enhanced Column API

Objects2XLSX features a simplified, type-safe column API that automatically handles various Swift data types:

```swift
struct Employee: Sendable {
    let name: String
    let age: Int
    let salary: Double?        // Optional salary
    let bonus: Double?         // Optional bonus
    let isManager: Bool
    let hireDate: Date
    let profileURL: URL?       // Optional profile URL
}

let employees = [
    Employee(
        name: "John Doe",
        age: 30,
        salary: 75000.50,
        bonus: nil,           // No bonus this period
        isManager: true,
        hireDate: Date(),
        profileURL: URL(string: "https://company.com/profiles/john")
    )
]

let sheet = Sheet<Employee>(name: "Staff", dataProvider: { employees }) {
    // Simple non-optional columns
    Column(name: "Name", keyPath: \.name)
    Column(name: "Age", keyPath: \.age)
    
    // Optional columns with default values
    Column(name: "Salary", keyPath: \.salary)
        .defaultValue(0.0)
        .width(12)
    
    Column(name: "Bonus", keyPath: \.bonus)
        .defaultValue(0.0)
        .width(10)
    
    // Boolean and date columns
    Column(name: "Manager", keyPath: \.isManager, booleanExpressions: .yesAndNo)
    Column(name: "Hire Date", keyPath: \.hireDate, timeZone: .current)
    
    // Optional URL with default
    Column(name: "Profile", keyPath: \.profileURL)
        .defaultValue(URL(string: "https://company.com/default")!)
}
```

## 🔧 Enhanced Column Features

### Simplified Column Declarations

The new API provides intuitive, type-safe column creation with automatic type inference:

```swift
struct Product: Sendable {
    let id: Int
    let name: String
    let price: Double?
    let discount: Double?
    let stock: Int?
    let isActive: Bool?
}

let sheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    // Non-optional columns (simple syntax)
    Column(name: "ID", keyPath: \.id)
    Column(name: "Product Name", keyPath: \.name)
    
    // Optional columns with default values
    Column(name: "Price", keyPath: \.price)
        .defaultValue(0.0)
    
    Column(name: "Stock", keyPath: \.stock)
        .defaultValue(0)
    
    Column(name: "Active", keyPath: \.isActive)
        .defaultValue(true)
}
```

### Advanced Type Conversions

Transform column data using the powerful `toString` method:

```swift
let sheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    // Convert price ranges to categories
    Column(name: "Price Category", keyPath: \.price)
        .defaultValue(0.0)
        .toString { (price: Double) in
            switch price {
            case 0..<50: "Budget"
            case 50..<200: "Mid-Range"
            default: "Premium"
            }
        }
    
    // Convert stock levels to status
    Column(name: "Stock Status", keyPath: \.stock)
        .defaultValue(0)
        .toString { (stock: Int) in
            stock == 0 ? "Out of Stock" : 
            stock < 10 ? "Low Stock" : "In Stock"
        }
    
    // Convert optional discount to display format
    Column(name: "Discount Info", keyPath: \.discount)
        .toString { (discount: Double?) in
            guard let discount = discount else { return "No Discount" }
            return String(format: "%.0f%% Off", discount * 100)
        }
}
```

### Flexible Nil Handling

Control how optional values are handled:

```swift
let sheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    // Option 1: Use default values
    Column(name: "Salary", keyPath: \.salary)
        .defaultValue(0.0)  // nil becomes 0.0
    
    // Option 2: Keep empty cells (default behavior)
    Column(name: "Bonus", keyPath: \.bonus)
        // nil values remain as empty cells
    
    // Option 3: Transform with custom nil handling
    Column(name: "Salary Range", keyPath: \.salary)
        .toString { (salary: Double?) in
            guard let salary = salary else { return "Not Specified" }
            return salary > 50000 ? "High" : "Standard"
        }
}
```

### Method Chaining

Combine multiple configurations elegantly:

```swift
let sheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    Column(name: "Salary Level", keyPath: \.salary)
        .defaultValue(0.0)                    // Handle nil values
        .toString { $0 > 50000 ? "Senior" : "Junior" }  // Transform to categories
        .width(15)                            // Set column width
        .bodyStyle(CellStyle(                 // Apply styling
            font: Font(bold: true),
            fill: Fill.solid(.lightBlue)
        ))
}
```

## 🎨 Styling & Formatting

### Professional Styling

```swift
// Create custom header style
let headerStyle = CellStyle(
    font: Font(size: 14, name: "Arial", bold: true, color: .white),
    fill: Fill.solid(.blue),
    alignment: Alignment(horizontal: .center, vertical: .center),
    border: Border.all(style: .thin, color: .black)
)

// Create data cell style
let dataStyle = CellStyle(
    font: Font(size: 11, name: "Calibri"),
    alignment: Alignment(horizontal: .left, wrapText: true),
    border: Border.outline(style: .thin, color: .gray)
)

// Apply styles to sheet using enhanced API
let styledSheet = Sheet<Person>(name: "Styled Employees", dataProvider: { people }) {
    Column(name: "Name", keyPath: \.name)
        .width(20)
        .headerStyle(headerStyle)
        .bodyStyle(dataStyle)
    
    Column(name: "Age", keyPath: \.age)
        .width(8)
        .headerStyle(headerStyle)
        .bodyStyle(CellStyle(alignment: Alignment(horizontal: .center)))
}
```

### Color Customization

```swift
// Predefined colors
let redFill = Fill.solid(.red)
let blueFill = Fill.solid(.blue)

// Custom colors
let customColor = Color(red: 255, green: 128, blue: 0) // Orange
let hexColor = Color(hex: "#FF5733") // From hex string
let transparentColor = Color(red: 255, green: 0, blue: 0, alpha: .medium) // 50% transparent red

// Gradient fills (advanced)
let gradientFill = Fill.gradient(
    .linear(angle: 90),
    colors: [.blue, .white, .red]
)
```

### Border Styles

```swift
// Simple borders
let thinBorder = Border.all(style: .thin, color: .black)
let thickOutline = Border.outline(style: .thick, color: .blue)

// Selective borders
let horizontalOnly = Border.horizontal(style: .medium, color: .gray)
let verticalOnly = Border.vertical(style: .thin, color: .lightGray)

// Custom border configuration
let customBorder = Border(
    left: Border.Side(style: .thick, color: .red),
    right: Border.Side(style: .thin, color: .black),
    top: Border.Side(style: .dashed, color: .blue),
    bottom: nil // No bottom border
)
```

## 📈 Multiple Worksheets

Create workbooks with multiple sheets for different data types:

```swift
struct Product: Sendable {
    let name: String
    let price: Double?
    let category: String
    let inStock: Bool?
}

struct Customer: Sendable {
    let name: String
    let email: String?
    let registrationDate: Date
    let isPremium: Bool?
}

// Create multiple sheets with enhanced API
let productsSheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Product Name", keyPath: \.name)
        .width(25)
    
    Column(name: "Price", keyPath: \.price)
        .defaultValue(0.0)
        .width(12)
    
    Column(name: "Category", keyPath: \.category)
        .width(15)
    
    Column(name: "In Stock", keyPath: \.inStock)
        .defaultValue(false)
        .width(10)
}

let customersSheet = Sheet<Customer>(name: "Customers", dataProvider: { customers }) {
    Column(name: "Customer Name", keyPath: \.name)
        .width(20)
    
    Column(name: "Email", keyPath: \.email)
        .defaultValue("no-email@company.com")
        .width(25)
    
    Column(name: "Registration", keyPath: \.registrationDate)
        .width(15)
    
    Column(name: "Premium", keyPath: \.isPremium)
        .defaultValue(false)
        .toString { $0 ? "Premium Member" : "Standard Member" }
        .width(15)
}

// Combine sheets in workbook
let book = Book(style: BookStyle()) {
    productsSheet
    customersSheet
}

try book.write(to: outputURL)
```

## 📊 Progress Tracking

Monitor Excel generation progress for large datasets:

```swift
let book = Book(style: BookStyle()) {
    // ... add your sheets
}

// Monitor progress
Task {
    for await progress in book.progressStream {
        print("Progress: \(Int(progress.progressPercentage * 100))%")
        print("Current step: \(progress.description)")
        
        if progress.isFinal {
            print("✅ Excel file generation completed!")
            break
        }
    }
}

// Generate file asynchronously
Task {
    do {
        try book.write(to: outputURL)
        print("📁 File saved to: \(outputURL.path)")
    } catch {
        print("❌ Error: \(error)")
    }
}
```

## 🔧 Advanced Configuration

### Custom Sheet Styling

```swift
var sheetStyle = SheetStyle()
sheetStyle.defaultRowHeight = 20
sheetStyle.defaultColumnWidth = 15
sheetStyle.showGridlines = false
sheetStyle.freezePanes = .freezeTopRow()
sheetStyle.zoom = .custom(125)

let sheet = Sheet<Person>(name: "Custom Sheet", dataProvider: { people }, style: sheetStyle) {
    // ... columns
}
```

### Number Formatting

```swift
let sheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Product", keyPath: \.name)
    
    Column(name: "Price", keyPath: \.price)
        .bodyStyle(CellStyle(numberFormat: .currency))
    
    Column(name: "Discount", keyPath: \.discountRate)
        .bodyStyle(CellStyle(numberFormat: .percentage(precision: 1)))
    
    Column(name: "Launch Date", keyPath: \.launchDate)
        .bodyStyle(CellStyle(numberFormat: .date))
}
```

### Memory Optimization for Large Datasets

```swift
// Use lazy data loading for large datasets
let largeDataSheet = Sheet<LargeDataModel>(name: "Big Data") {
    dataProvider: {
        // Load data only when needed
        return fetchLargeDataset()
    }
} columns: {
    Column(name: "ID", keyPath: \.id)
    Column(name: "Value", keyPath: \.value)
    // ... more columns
}
```

## 📚 Architecture Overview

Objects2XLSX follows a hierarchical architecture:

```
Book (Workbook)
├── BookStyle (Global styling)
├── Sheet<ObjectType> (Individual worksheets)
│   ├── SheetStyle (Sheet-specific styling)
│   └── Column<ObjectType, InputType, OutputType>
│       ├── ColumnStyle (Column-specific styling)
│       └── Cell (Individual cells)
│           └── CellStyle (Cell-specific styling)
```

### Style Precedence

Styles are applied with the following precedence (highest to lowest):

1. **Cell Style** - Individual cell styling
2. **Column Style** - Column-wide styling  
3. **Sheet Style** - Sheet-wide styling
4. **Book Style** - Workbook defaults

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose

# Run specific test cases
swift test --filter BookAPITests
```

The library includes:

- **340+ Unit Tests** covering all components including enhanced column API
- **Integration Tests** for complete workflows and demo scenarios
- **Performance Tests** for large dataset handling and memory optimization
- **Cross-Platform Tests** ensuring compatibility across all supported platforms

## 🛠 Development

### Code Formatting

The project uses SwiftFormat with Git hooks for consistent code style:

```bash
# Format code manually
swiftformat Sources Tests

# Check formatting without changes
swiftformat --lint Sources Tests

# The pre-push hook automatically formats code before pushing
git push
```

### Building

```bash
# Build the library
swift build

# Build for release
swift build -c release

# Generate Xcode project
swift package generate-xcodeproj
```

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Standards

- Follow Swift API Design Guidelines
- Add comprehensive documentation for public APIs
- Include unit tests for new functionality
- Ensure SwiftFormat compliance
- Maintain Swift 6 concurrency compliance

## 📋 Requirements

- **Swift 6.0+**
- **Platforms**: macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, Linux
- **Dependencies**: None (except optional SimpleLogger for logging)

## 👨‍💻 Author

**Fatbobman (东坡肘子)**

- Blog: [https://fatbobman.com](https://fatbobman.com)
- GitHub: [@fatbobman](https://github.com/fatbobman)
- X: [@fatbobman](https://x.com/fatbobman)
- LinkedIn: [@fatbobman](https://www.linkedin.com/in/fatbobman/)
- Mastodon: [@fatbobman@mastodon.social](https://mastodon.social/@fatbobman)
- BlueSky: [@fatbobman.com](https://bsky.app/profile/fatbobman.com)

### 📰 Stay Connected

Don't miss out on the latest updates and excellent articles about Swift, SwiftUI, Core Data, and SwiftData. Subscribe to **[Fatbobman's Swift Weekly](https://weekly.fatbobman.com)** and receive weekly insights and valuable content directly to your inbox.

## 💖 Support the Project

If you find Objects2XLSX useful and want to support its continued development:

- [☕️ Buy Me A Coffee](https://buymeacoffee.com/fatbobman) - Support development with a small donation
- [💳 PayPal](https://www.paypal.com/paypalme/fatbobman) - Alternative donation method

Your support helps maintain and improve this open-source project. Thank you! 🙏

## 📄 License

Objects2XLSX is released under the Apache License 2.0. See [LICENSE](LICENSE) for details.

### Third-Party Dependencies

This project includes the following third-party software:

- **[SimpleLogger](https://github.com/fatbobman/SimpleLogger)** - MIT License
  - A lightweight logging library for Swift
  - Copyright (c) 2024 Fatbobman

## 🙏 Acknowledgments

- Built with ❤️ using Swift 6's modern concurrency features
- Inspired by the need for type-safe Excel generation in Swift
- Thanks to the Swift community for feedback and contributions

## 📖 Documentation

For detailed API documentation, examples, and advanced usage patterns, explore the comprehensive DocC documentation included with the library. You can access it directly in Xcode after importing the package, or build it locally using:

```bash
swift package generate-documentation --target Objects2XLSX
```

The library includes extensive inline documentation for all public APIs, complete with usage examples and best practices.

---

**Made with ❤️ by the Swift Community**
