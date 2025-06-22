# Objects2XLSX AI Reference

**Library**: Objects2XLSX v2.0+  
**Platform**: Swift 6.0+, iOS 14.0+, macOS 11.0+, Linux  
**Purpose**: Type-safe Excel (.xlsx) generation from Swift objects

## Quick Decision Tree

```
Need to export Excel data?
├─ Single data type → Sheet<ObjectType> with Column definitions
├─ Multiple data types → Multiple Sheet<T> in same Book
├─ Complex styling needed → CellStyle + method chaining
├─ Large datasets → Mind thread safety + lazy dataProvider
├─ Core Data objects → Use within context.perform { }
└─ SwiftData objects → Use within @ModelActor
```

## Common Mistakes Quick Reference

```swift
// ❌ WRONG - String literals
Column(name: "Name", keyPath: "name")

// ✅ CORRECT - KeyPath syntax
Column(name: "Name", keyPath: \.name)

// ❌ WRONG - Wrong conversion order
Column(name: "Price", keyPath: \.price)  // Double?
    .toString { price in "¥\(price ?? 0)" }  // Handling optionals manually

// ✅ CORRECT - Use defaultValue first
Column(name: "Price", keyPath: \.price)  // Double?
    .defaultValue(0.0)                   // Now non-optional
    .toString { price in "¥\(price)" }   // Clean conversion

// ❌ WRONG - Thread safety violation
DispatchQueue.global().async {
    let book = Book() { /* Core Data objects */ }  // CRASH RISK
}

// ✅ CORRECT - Proper Core Data context
coreDataContext.perform {
    let book = Book() { /* Core Data objects */ }  // SAFE
}

// ❌ WRONG - Boolean expressions that won't work in Excel
Column(name: "Status", keyPath: \.isActive, booleanExpressions: .custom("Active", "Inactive"))

// ✅ CORRECT - Excel-compatible or use SharedString automatically
Column(name: "Status", keyPath: \.isActive, booleanExpressions: .yesAndNo)  // Auto-optimized
```

## Project Structure

```
Sources/Objects2XLSX/
├── Book/                    # Main workbook container and XLSX generation
│   ├── Book.swift          # Primary API entry point, progress monitoring
│   ├── BookToWorkbookXML.swift  # Workbook XML generation
│   └── Book+GlobalFiles.swift  # Content types, relationships, properties
├── Sheet/                   # Worksheet management and data processing
│   ├── Sheet.swift         # Type-safe sheet container for object collections
│   ├── SheetToSheetXML.swift   # Sheet XML generation and cell processing
│   └── SheetMeta.swift     # Sheet metadata and relationship info
├── Column/                  # Property-to-column mapping system
│   ├── Column.swift        # Enhanced column API with type conversions
│   ├── ColumnBuilder.swift # Builder pattern for column collections
│   └── AnyColumn.swift     # Type-erased column for heterogeneous storage
├── Cell/                    # Cell data model and value handling
│   ├── Cell.swift          # Cell values, types, and boolean optimization
│   └── CellReference.swift # Excel-style cell addressing (A1, B2, etc.)
├── Row/                     # Row container and cell collection
│   └── Row.swift           # Row data structure
├── Style/                   # Comprehensive styling system
│   ├── BookStyle.swift     # Workbook-level styling and properties
│   ├── SheetStyle.swift    # Worksheet-level styling (dimensions, freeze panes)
│   ├── CellStyle.swift     # Cell-level styling (fonts, fills, borders)
│   ├── StyleRegister.swift # Style deduplication and ID management
│   └── Styles+XML.swift    # Style XML serialization
├── Utility/                 # Helper utilities and optimizations
│   ├── ShareStringRegister.swift  # Shared string optimization
│   ├── SimpleZip.swift     # ZIP compression for XLSX packaging
│   └── Extensions.swift    # Swift standard library extensions
└── Progress/                # Real-time progress reporting
    └── BookGenerationProgress.swift  # Progress states and descriptions
```

### Key Responsibilities
- **Book**: Main API, orchestrates entire XLSX generation process
- **Sheet**: Manages typed data collections, triggers data loading
- **Column**: Defines property mappings with type-safe conversions  
- **Cell**: Handles value storage and Excel type compatibility
- **Style**: Hierarchical styling with inheritance and optimization
- **Utility**: Performance optimizations (shared strings, compression)

## Core API

### Main Components
```swift
// Primary types
class Book                              // Excel Workbook container
class Sheet<ObjectType>                 // Typed worksheet for specific object collections
struct Column<ObjectType, InputType, OutputType>  // Property-to-column mapping with type conversion
struct Cell                            // Individual cell with value and styling
struct Row                             // Collection of cells in a row

// Style system
struct BookStyle, SheetStyle, CellStyle  // Hierarchical styling
struct StyleRegister                     // Style deduplication and management
struct ShareStringRegister              // Shared string optimization

// Type erasure for heterogeneous collections
protocol AnySheet, AnyColumn            // Type-erased variants for storage
```

### Factory Methods

#### Book Creation
```swift
// Basic book with sheets
let book = Book(style: BookStyle()) {
    Sheet<Person>(name: "Employees", dataProvider: { people }) {
        Column(name: "Name", keyPath: \.name)
        Column(name: "Age", keyPath: \.age)
    }
}

// Custom logger configuration
let book = Book(style: BookStyle(), logger: .console(verbosity: .detailed)) {
    // sheets...
}
```

#### Column Declaration (Enhanced API)
```swift
// Basic column
Column(name: "Name", keyPath: \.name)

// With default value (enables non-optional type conversion)
Column(name: "Salary", keyPath: \.salary)  // Double?
    .defaultValue(0.0)                     // Now treated as Double
    .toString { salary in "¥\(salary)" }   // Non-optional parameter

// Type conversion chains
Column(name: "Level", keyPath: \.salary)
    .defaultValue(0.0)
    .toString { salary in salary < 50000 ? "Junior" : "Senior" }

// Boolean with custom expressions
Column(name: "Status", keyPath: \.isActive, booleanExpressions: .yesAndNo)

// Date with timezone
Column(name: "Created", keyPath: \.createdAt, timeZone: .current)

// Styling and sizing
Column(name: "ID", keyPath: \.id)
    .width(8)
    .style(CellStyle(numberFormat: "0000"))
```

## Type System

### Generic Design
```swift
Sheet<ObjectType>                       // Strongly typed sheet
Column<ObjectType, InputType, OutputType> // Type-safe property mapping
```

### Type Conversion Patterns
```swift
// String conversions
.toString { value in "Custom: \(value)" }

// Numeric conversions  
.toInt { double in Int(double.rounded()) }

// Boolean expressions
.yesAndNo, .trueAndFalse, .oneAndZero, .tAndF, .custom("On", "Off")

// Optional handling
.defaultValue(fallback)                 // Unwraps optionals
.keepEmpty                             // Preserves optionals
```

### Sendable Compliance
- **Sheet<ObjectType>**: Only Sendable when ObjectType is Sendable
- **Book, Column, Cell, Row**: Implement Sendable for concurrency safety
- **Style types**: All styling types are Sendable
- **Critical**: Must run on same thread as your data objects for safety

## Usage Patterns

### Basic Usage
```swift
struct Employee: Sendable {
    let name: String
    let department: String?
    let salary: Double?
    let isManager: Bool
    let hireDate: Date
}

let employees = [
    Employee(name: "Alice", department: "Engineering", salary: 75000, isManager: false, hireDate: Date()),
    Employee(name: "Bob", department: nil, salary: nil, isManager: true, hireDate: Date())
]

let book = Book(style: BookStyle()) {
    Sheet<Employee>(name: "Staff", dataProvider: { employees }) {
        Column(name: "Name", keyPath: \.name)
        
        Column(name: "Department", keyPath: \.department)
            .defaultValue("Unassigned")
        
        Column(name: "Salary", keyPath: \.salary)
            .defaultValue(0.0)
            .toString { "¥\(Int($0))" }
        
        Column(name: "Role", keyPath: \.isManager, booleanExpressions: .custom("Manager", "Staff"))
        
        Column(name: "Hire Date", keyPath: \.hireDate, timeZone: .current)
    }
}

try book.write(to: URL(fileURLWithPath: "/path/to/output.xlsx"))
```

### Multi-Sheet Workbooks
```swift
let book = Book(style: BookStyle()) {
    Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
        // employee columns...
    }
    
    Sheet<Department>(name: "Departments", dataProvider: { departments }) {
        // department columns...
    }
}
```

### Progress Monitoring
```swift
let book = Book(style: BookStyle()) { /* sheets */ }

Task {
    for await progress in book.progressStream {
        print("Progress: \(Int(progress.progressPercentage * 100))% - \(progress.description)")
        if progress.isFinal { break }
    }
}

Task {
    try book.write(to: outputURL)
}
```

### Advanced Styling
```swift
let headerStyle = CellStyle(
    font: FontStyle(bold: true, color: "FFFFFF"),
    fill: FillStyle(color: "366092"),
    alignment: AlignmentStyle(horizontal: .center)
)

let sheet = Sheet<Person>(name: "People", dataProvider: { people }) {
    Column(name: "Name", keyPath: \.name)
        .style(headerStyle)
        .width(15)
}
```

## Thread Safety & Concurrency

### Critical Rules
- **Book is NOT thread-safe**: Use on same thread as data objects
- **Progress monitoring IS thread-safe**: Can observe from any thread
- **Sheet<ObjectType> Sendable**: Only when ObjectType is Sendable
- **Must run in data object's thread context**: Core Data perform blocks, SwiftData model actors

### Core Data Integration
```swift
privateContext.perform {
    let employees = // fetch Core Data objects
    let book = Book(style: BookStyle()) {
        Sheet<Employee>(name: "Staff", dataProvider: { employees }) {
            Column(name: "Name", keyPath: \.name)
            Column(name: "Department", keyPath: \.department?.name)
        }
    }
    try book.write(to: outputURL)
}
```

### SwiftData Integration
```swift
@ModelActor
actor DataExporter {
    func exportEmployees() async throws -> URL {
        let employees = // fetch SwiftData objects
        let book = Book(style: BookStyle()) {
            Sheet<Employee>(name: "Staff", dataProvider: { employees }) {
                Column(name: "Name", keyPath: \.name)
            }
        }
        return try book.write(to: outputURL)
    }
}
```

## Performance & Optimization

### Memory Management
- Streaming data processing for large datasets
- Shared string optimization for repeated text
- Style deduplication via StyleRegister
- Lazy data loading in sheets

### Boolean Storage Optimization (Critical for Excel Compatibility)
```swift
// Automatically optimized based on Excel boolean type recognition:
.oneAndZero        // Inline storage (t="b") - Excel recognizes "1"/"0"
.trueAndFalse      // SharedString (t="s") - Excel recognizes "true"/"false"  
.yesAndNo          // SharedString (t="s") - Excel recognizes "yes"/"no"
.tAndF             // SharedString (t="s") - Excel doesn't recognize "T"/"F" as boolean
.custom("A", "B")  // SharedString (t="s") - Excel doesn't recognize custom values as boolean

// ⚠️ Key Point: Only oneAndZero, trueAndFalse, yesAndNo work as actual booleans in Excel
// Others display as text but use SharedString optimization for file size
```

### Large Dataset Handling
```swift
// Efficient for thousands of rows
let sheet = Sheet<LargeObject>(name: "Data", dataProvider: { 
    // Lazy data provider - loaded when needed
    return fetchLargeDataset()
}) {
    // Column definitions...
}
```

## Error Handling

### Error Types
```swift
enum BookError: Error {
    case fileWriteError(Error)      // File system operations
    case dataProviderError(String)  // Data loading failures
    case xmlGenerationError(String) // XML creation issues
    case encodingError(String)      // Text encoding problems
    case xmlValidationError(String) // Invalid XML structure
}
```

### Error Patterns
```swift
do {
    try book.write(to: outputURL)
} catch BookError.dataProviderError(let message) {
    // Handle data loading issues
} catch BookError.fileWriteError(let error) {
    // Handle file system errors
} catch {
    // Handle other errors
}
```

## Key Design Principles

### Type Safety First
- Compile-time validation of property access
- KeyPath-based property mapping
- Generic type constraints prevent runtime errors

### Styling Priority (Highest to Lowest)
1. Cell-level styles (highest precedence)
2. Column-level styles  
3. Sheet-level styles
4. Book default styles (lowest precedence)

### Excel Compatibility
- OOXML standard compliance
- Boolean type Excel recognition rules
- Proper shared string handling
- Valid cell reference formats

## Common Patterns for Code Generation

### Service Class Integration
```swift
class ReportGenerator {
    private let logger = LoggerManager.default(subsystem: "com.app", category: "reports")
    
    func generateEmployeeReport() async throws -> URL {
        let book = Book(style: BookStyle(), logger: logger) {
            Sheet<Employee>(name: "Staff", dataProvider: { employees }) {
                Column(name: "Name", keyPath: \.name)
                Column(name: "Salary", keyPath: \.salary)
                    .defaultValue(0.0)
                    .toString { "¥\(Int($0))" }
            }
        }
        
        return try book.write(to: outputURL)
    }
}
```

### Dynamic Column Generation
```swift
let columns = properties.map { property in
    Column(name: property.displayName, keyPath: property.keyPath)
        .width(property.preferredWidth)
}

let sheet = Sheet<DynamicObject>(name: "Data", dataProvider: { objects }) {
    columns.forEach { $0 }
}
```

## Import Statement
```swift
import Objects2XLSX
```

## Package.swift Integration
```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/Objects2XLSX.git", branch: "main")
]
```

## Common Build Commands
```bash
swift build                    # Build package
swift test                     # Run test suite
swift run Objects2XLSXDemo    # Run demo project (Demo Folder)
```

## Critical Notes for AI Code Generation

### ⚠️ MUST FOLLOW (Crash/Correctness Issues)
1. **Always use KeyPath syntax**: `\.propertyName` not string literals
2. **Thread safety is CRITICAL**: Book must run on same thread as data objects
3. **Core Data**: Always use within `context.perform { }` blocks
4. **SwiftData**: Always use within `@ModelActor` or proper model context

### 🎯 Best Practices (Quality/Performance)
5. **Type conversion order matters**: Apply `defaultValue` before conversion methods
6. **Boolean expressions**: Use `.oneAndZero`, `.trueAndFalse`, `.yesAndNo` for Excel compatibility
7. **Styling is hierarchical**: More specific styles override general ones
8. **File URLs must be absolute**: Relative paths may cause issues

### 🚀 Performance Tips
9. **Progress monitoring is async**: Use separate tasks for monitoring
10. **XLSX extension is automatic**: Will be added if missing
11. **Memory efficiency**: Use lazy data providers for large datasets
12. **SharedString optimization**: Automatically handled for repeated text