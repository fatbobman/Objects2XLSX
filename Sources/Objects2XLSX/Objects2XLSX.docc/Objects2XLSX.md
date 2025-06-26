# ``Objects2XLSX``

A powerful, type-safe Swift library for converting Swift objects to Excel (.xlsx) files.

## Overview

Objects2XLSX provides a modern, declarative API for creating professional Excel spreadsheets with full styling support, multiple worksheets, and real-time progress tracking. The library is designed with type safety in mind, utilizing Swift's generic system and KeyPath integration for compile-time safety.

### Key Features

- **Type-Safe Design**: Generic `Sheet<ObjectType>` with compile-time safety
- **Excel Standards Compliance**: Generated XLSX files strictly conform to Excel specifications with no warnings
- **Enhanced Column API**: Simplified, intuitive column declarations with automatic type inference
- **Professional Styling**: Complete styling system with fonts, colors, borders, and fills
- **Cross-Platform**: Pure Swift implementation supporting macOS, iOS, tvOS, watchOS, and Linux
- **Production Ready**: Memory-efficient processing with 340+ comprehensive tests

### Quick Start

Create your first Excel file in just a few lines:

```swift
import Objects2XLSX

struct Person: Sendable {
    let name: String
    let age: Int
    let email: String
}

let people = [
    Person(name: "Alice Smith", age: 28, email: "alice@example.com"),
    Person(name: "Bob Johnson", age: 35, email: "bob@example.com")
]

let sheet = Sheet<Person>(name: "Employees", dataProvider: { people }) {
    Column(name: "Full Name", keyPath: \.name)
    Column(name: "Age", keyPath: \.age)
    Column(name: "Email Address", keyPath: \.email)
}

let book = Book(style: BookStyle()) {
    sheet
}

let outputURL = URL(fileURLWithPath: "/path/to/employees.xlsx")
try book.write(to: outputURL)
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:CreatingSheets>
- <doc:StylingWorkbooks>

### Core Components

- ``Book``
- ``Sheet``
- ``Column``
- ``BookStyle``
- ``SheetStyle``
- ``CellStyle``

### Data Types and Formatting

- ``Cell``
- ``Row``
- ``Color``
- ``Font``
- ``Fill``
- ``Border``
- ``Alignment``
- ``NumberFormat``

### Progress and Monitoring

- ``BookGenerationProgress``

### Error Handling

- ``BookError``

### Advanced Topics

- <doc:TypeConversions>
- <doc:OptionalHandling>
- <doc:PerformanceOptimization>
- <doc:CustomStyling>

## See Also

- [Objects2XLSX GitHub Repository](https://github.com/fatbobman/Objects2XLSX)
- [Fatbobman's Blog](https://fatbobman.com)
- [Swift Weekly Newsletter](https://weekly.fatbobman.com)