# Getting Started

Learn how to quickly set up and use Objects2XLSX in your Swift projects.

## Overview

Objects2XLSX is designed to be easy to use while providing powerful features for creating professional Excel files. This guide will walk you through the basic setup and your first Excel file generation.

## Installation

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

## Basic Usage

### 1. Define Your Data Model

First, create a data model that conforms to `Sendable`:

```swift
import Objects2XLSX

struct Employee: Sendable {
    let name: String
    let age: Int
    let department: String
    let salary: Double?
    let isManager: Bool
    let hireDate: Date
}
```

### 2. Prepare Your Data

Create an array of your data objects:

```swift
let employees = [
    Employee(
        name: "Alice Johnson",
        age: 32,
        department: "Engineering",
        salary: 85000.0,
        isManager: true,
        hireDate: Date()
    ),
    Employee(
        name: "Bob Smith",
        age: 28,
        department: "Marketing",
        salary: 65000.0,
        isManager: false,
        hireDate: Date()
    )
]
```

### 3. Create a Sheet

Define how your data should appear in Excel using the declarative column API:

```swift
let employeeSheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    Column(name: "Name", keyPath: \.name)
        .width(20)
    
    Column(name: "Age", keyPath: \.age)
        .width(8)
    
    Column(name: "Department", keyPath: \.department)
        .width(15)
    
    Column(name: "Salary", keyPath: \.salary)
        .defaultValue(0.0)
        .width(12)
    
    Column(name: "Manager", keyPath: \.isManager, booleanExpressions: .yesAndNo)
        .width(10)
    
    Column(name: "Hire Date", keyPath: \.hireDate)
        .width(12)
}
```

### 4. Create a Workbook

Combine your sheets into a workbook:

```swift
let workbook = Book(style: BookStyle()) {
    employeeSheet
}
```

### 5. Generate the Excel File

Write the workbook to a file:

```swift
let outputURL = URL(fileURLWithPath: "/path/to/employees.xlsx")
do {
    try workbook.write(to: outputURL)
    print("✅ Excel file created successfully at: \(outputURL.path)")
} catch {
    print("❌ Error creating Excel file: \(error)")
}
```

## Enhanced Features

### Optional Value Handling

Objects2XLSX provides elegant ways to handle optional values:

```swift
Column(name: "Salary", keyPath: \.salary)
    .defaultValue(0.0)  // Replace nil with 0.0

// Or keep empty cells for nil values
Column(name: "Bonus", keyPath: \.bonus)
    // nil values will appear as empty cells
```

### Type Conversions

Transform data during export using the `toString` method:

```swift
Column(name: "Salary Level", keyPath: \.salary)
    .defaultValue(0.0)
    .toString { salary in
        salary > 70000 ? "Senior" : "Junior"
    }
    .width(12)
```

### Method Chaining

Combine multiple configurations elegantly:

```swift
Column(name: "Department", keyPath: \.department)
    .width(20)
    .headerStyle(CellStyle(
        font: Font(bold: true, color: .white),
        fill: Fill.solid(.blue)
    ))
    .bodyStyle(CellStyle(
        alignment: Alignment(horizontal: .center)
    ))
```

## Next Steps

- Learn about <doc:CreatingSheets> for more advanced sheet configuration
- Explore <doc:StylingWorkbooks> to create professional-looking documents
- Check out <doc:TypeConversions> for advanced data transformation techniques

## See Also

- ``Book``
- ``Sheet``
- ``Column``
- ``BookStyle``