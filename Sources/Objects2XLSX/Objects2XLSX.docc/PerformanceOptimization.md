# Performance Optimization

Optimize your Excel generation for large datasets and complex workbooks.

## Overview

Objects2XLSX is designed for high performance out of the box, but when working with large datasets or complex workbooks, there are several strategies you can employ to maximize performance and minimize memory usage.

## Memory Management

### Stream-Based Processing

Objects2XLSX uses stream-based processing to handle large datasets efficiently:

```swift
// Large dataset handling
struct LargeDataModel: Sendable {
    let id: Int
    let data: String
    let value: Double
}

// The library automatically streams data processing
let largeSheet = Sheet<LargeDataModel>(name: "Large Dataset") {
    dataProvider: {
        // Data is loaded only when needed
        return DatabaseManager.fetchLargeDataset() // 100,000+ records
    }
} columns: {
    Column(name: "ID", keyPath: \.id)
    Column(name: "Data", keyPath: \.data)
    Column(name: "Value", keyPath: \.value)
}
```

### Lazy Data Loading

Implement lazy loading for memory-intensive operations:

```swift
class DataManager {
    private var cache: [LargeDataModel] = []
    private let batchSize = 1000
    
    func loadDataBatch(offset: Int) -> [LargeDataModel] {
        // Load data in batches to manage memory
        return DatabaseManager.fetchBatch(offset: offset, limit: batchSize)
    }
}

let optimizedSheet = Sheet<LargeDataModel>(name: "Optimized Data") {
    dataProvider: {
        // Load all data at once, but this could be optimized further
        // for extremely large datasets
        return DataManager().loadAllData()
    }
} columns: {
    Column(name: "ID", keyPath: \.id)
    Column(name: "Value", keyPath: \.value)
}
```

## Styling Optimization

### Reuse Style Objects

Create and reuse style objects instead of creating new ones for each cell:

```swift
// ❌ Inefficient - creates new styles for each column
let inefficientSheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Name", keyPath: \.name)
        .headerStyle(CellStyle(font: Font(bold: true), fill: Fill.solid(.blue)))
        .bodyStyle(CellStyle(font: Font(size: 11), alignment: Alignment(horizontal: .left)))
    
    Column(name: "Price", keyPath: \.price)
        .headerStyle(CellStyle(font: Font(bold: true), fill: Fill.solid(.blue)))
        .bodyStyle(CellStyle(font: Font(size: 11), alignment: Alignment(horizontal: .right)))
}

// ✅ Efficient - reuse style objects
let headerStyle = CellStyle(
    font: Font(bold: true, color: .white),
    fill: Fill.solid(.blue),
    alignment: Alignment(horizontal: .center)
)

let textBodyStyle = CellStyle(
    font: Font(size: 11),
    alignment: Alignment(horizontal: .left)
)

let numberBodyStyle = CellStyle(
    font: Font(size: 11),
    alignment: Alignment(horizontal: .right)
)

let efficientSheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Name", keyPath: \.name)
        .headerStyle(headerStyle)
        .bodyStyle(textBodyStyle)
    
    Column(name: "Price", keyPath: \.price)
        .headerStyle(headerStyle)
        .bodyStyle(numberBodyStyle)
}
```

### Style Hierarchy Optimization

Use the style hierarchy effectively to minimize style definitions:

```swift
// Define styles at the sheet level when possible
var sheetStyle = SheetStyle()
sheetStyle.defaultRowHeight = 20
sheetStyle.defaultColumnWidth = 15

let optimizedSheet = Sheet<Employee>(
    name: "Employees",
    dataProvider: { employees },
    style: sheetStyle
) {
    // Only override styles when necessary
    Column(name: "Name", keyPath: \.name)
        .width(25)  // Only specify width, inherit other styles
    
    Column(name: "Department", keyPath: \.department)
        .width(20)
    
    // Only apply special styling where needed
    Column(name: "Salary", keyPath: \.salary)
        .width(15)
        .bodyStyle(CellStyle(numberFormat: .currency))
}
```

## Data Processing Optimization

### Minimize Type Conversions

Keep type conversions simple and fast:

```swift
// ❌ Complex conversion that might be slow
Column(name: "Complex Calculation", keyPath: \.data)
    .toString { data in
        // Avoid complex calculations in toString
        let result = performComplexCalculation(data)
        return formatComplexResult(result)
    }

// ✅ Pre-compute complex values in your data model
struct OptimizedDataModel: Sendable {
    let data: String
    let precomputedValue: String  // Calculate this once in your data layer
}

Column(name: "Calculated Value", keyPath: \.precomputedValue)
```

### Efficient String Operations

Optimize string operations for better performance:

```swift
// ❌ Inefficient string operations
Column(name: "Formatted ID", keyPath: \.id)
    .toString { id in
        return "PREFIX-" + String(id) + "-SUFFIX"  // Multiple string concatenations
    }

// ✅ Efficient string formatting
Column(name: "Formatted ID", keyPath: \.id)
    .toString { id in
        return "PREFIX-\(id)-SUFFIX"  // String interpolation is faster
    }

// ✅ Even better - use format strings for complex formatting
Column(name: "Formatted Amount", keyPath: \.amount)
    .toString { amount in
        return String(format: "$%.2f", amount)  // Efficient formatting
    }
```

## Progress Monitoring for Performance

### Use Progress Tracking

Monitor performance and provide user feedback:

```swift
let book = Book(style: BookStyle()) {
    largeSheet1
    largeSheet2
    largeSheet3
}

// Monitor progress for performance insights
Task {
    var startTime = Date()
    
    for await progress in book.progressStream {
        let elapsed = Date().timeIntervalSince(startTime)
        print("Progress: \(Int(progress.progressPercentage * 100))% - Elapsed: \(String(format: "%.2f", elapsed))s")
        
        if progress.isFinal {
            print("Total generation time: \(String(format: "%.2f", elapsed))s")
            break
        }
    }
}

Task {
    let generationStart = Date()
    try book.write(to: outputURL)
    let generationTime = Date().timeIntervalSince(generationStart)
    print("File generation completed in \(String(format: "%.2f", generationTime))s")
}
```

## Large Dataset Strategies

### Batch Processing for Extremely Large Data

For datasets with hundreds of thousands of records:

```swift
class BatchedDataProvider {
    private let totalRecords: Int
    private let batchSize: Int
    
    init(totalRecords: Int, batchSize: Int = 10000) {
        self.totalRecords = totalRecords
        self.batchSize = batchSize
    }
    
    func provideBatchedData() -> [LargeRecord] {
        var allRecords: [LargeRecord] = []
        
        for offset in stride(from: 0, to: totalRecords, by: batchSize) {
            autoreleasepool {
                let batch = DatabaseManager.fetchBatch(offset: offset, limit: batchSize)
                allRecords.append(contentsOf: batch)
            }
        }
        
        return allRecords
    }
}

let batchedSheet = Sheet<LargeRecord>(name: "Large Data") {
    dataProvider: {
        return BatchedDataProvider(totalRecords: 500000).provideBatchedData()
    }
} columns: {
    Column(name: "ID", keyPath: \.id)
    Column(name: "Value", keyPath: \.value)
}
```

### Memory Pool Management

For very large datasets, consider memory management:

```swift
func createLargeWorkbook() throws {
    autoreleasepool {
        let sheet1 = Sheet<LargeDataType1>(name: "Data1", dataProvider: { data1 }) {
            // Column definitions
        }
        
        let book = Book(style: BookStyle()) { sheet1 }
        try book.write(to: outputURL)
    }
    // Memory is released here
}
```

## SharedString Optimization

### Understanding SharedString Behavior

Objects2XLSX automatically optimizes shared strings:

```swift
// The library automatically handles shared strings for:
// - String values that appear multiple times
// - URL values (automatically registered as shared strings)
// - Boolean expressions (optimized based on frequency)

struct DataWithRepeatedValues: Sendable {
    let category: String  // "Electronics", "Books", etc. - will be shared
    let status: String    // "Active", "Inactive" - will be shared
    let uniqueId: String  // Unique values - won't be shared
}

// No special handling needed - the library optimizes automatically
let sheet = Sheet<DataWithRepeatedValues>(name: "Data", dataProvider: { data }) {
    Column(name: "Category", keyPath: \.category)
    Column(name: "Status", keyPath: \.status)
    Column(name: "ID", keyPath: \.uniqueId)
}
```

## Performance Monitoring

### Benchmarking Your Usage

Create performance benchmarks for your specific use cases:

```swift
func benchmarkGeneration() {
    let datasets = [
        ("Small", 100),
        ("Medium", 1000),
        ("Large", 10000),
        ("XLarge", 100000)
    ]
    
    for (name, count) in datasets {
        let data = generateTestData(count: count)
        
        let startTime = Date()
        
        let sheet = Sheet<TestData>(name: "\(name) Dataset", dataProvider: { data }) {
            Column(name: "ID", keyPath: \.id)
            Column(name: "Name", keyPath: \.name)
            Column(name: "Value", keyPath: \.value)
        }
        
        let book = Book(style: BookStyle()) { sheet }
        
        do {
            try book.write(to: URL(fileURLWithPath: "/tmp/benchmark_\(name).xlsx"))
            let elapsed = Date().timeIntervalSince(startTime)
            let recordsPerSecond = Double(count) / elapsed
            
            print("\(name): \(count) records in \(String(format: "%.2f", elapsed))s (\(String(format: "%.0f", recordsPerSecond)) records/sec)")
        } catch {
            print("Error generating \(name) dataset: \(error)")
        }
    }
}
```

## Best Practices Summary

### Memory Optimization

1. **Use stream processing** - Let the library handle large datasets automatically
2. **Implement lazy loading** - Load data only when needed
3. **Use autoreleasepool** - For very large datasets in tight loops
4. **Avoid holding references** - Don't keep unnecessary data in memory

### Styling Optimization

1. **Reuse style objects** - Create once, use multiple times
2. **Use style hierarchy** - Define styles at the appropriate level
3. **Minimize unique styles** - Reduce the number of different styles

### Processing Optimization

1. **Pre-compute complex values** - Do calculations in your data layer
2. **Keep conversions simple** - Avoid complex logic in toString methods
3. **Use efficient string operations** - Prefer interpolation over concatenation
4. **Cache formatters** - Reuse DateFormatter and NumberFormatter instances

### Monitoring

1. **Use progress tracking** - Monitor performance and provide user feedback
2. **Benchmark your usage** - Test with realistic data sizes
3. **Profile memory usage** - Use Instruments for memory analysis

## See Also

- ``BookGenerationProgress``
- <doc:CreatingSheets>
- ``Book``
- ``Sheet``