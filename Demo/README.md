# Objects2XLSX Demo Project

A comprehensive demonstration of the Objects2XLSX library showcasing all major features through a real-world multi-sheet Excel workbook example.

## 🎯 Overview

This demo project generates a complete Excel workbook with three professionally styled worksheets, each demonstrating different aspects of the Objects2XLSX library:

| Worksheet | Model | Style Theme | Key Features |
|-----------|--------|-------------|--------------|
| **Employees** | `Employee` | Corporate | Custom row heights, enterprise styling, complex data types |
| **Products** | `Product` | Modern | Conditional formatting, modern design, text wrapping |
| **Orders** | `Order` | Default | Calculated fields, default styling, date/currency formatting |

## 🚀 Quick Start

### Prerequisites

- Swift 6.0 or later
- macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, or Linux

### Running the Demo

```bash
# Navigate to the demo directory
cd Demo

# Run with default settings
swift run Objects2XLSXDemo

# Run with custom options
swift run Objects2XLSXDemo --data-size large --verbose --output-path ~/Desktop/
```

### Command Line Options

```bash
swift run Objects2XLSXDemo [OPTIONS]

Options:
  --data-size <size>     Data volume: small (10), medium (50), large (200) [default: medium]
  --output-path <path>   Output directory [default: ./Output/]
  --style <theme>        Styling theme: corporate, modern, default, mixed [default: mixed]
  --verbose              Show detailed progress information
  --benchmark            Include performance timing information
  --help                 Show this help message
```

## 📊 What You'll Get

### Generated Excel File

The demo creates `demo-workbook.xlsx` containing:

1. **Employee Worksheet** (Corporate Style)
   - Professional blue header with white text
   - Times New Roman font family
   - Custom row height (25pt)
   - Complete borders and enterprise formatting

2. **Product Worksheet** (Modern Style)
   - Contemporary color scheme
   - Helvetica/Arial fonts
   - Conditional stock level formatting
   - Text wrapping for product descriptions

3. **Order Worksheet** (Default Style)
   - Excel's standard styling
   - Calculated fields (subtotal, tax, total)
   - Date and currency formatting
   - Status-based conditional colors

### Console Output

```bash
🚀 Objects2XLSX Demo Starting...
📊 Generating Employee data (Corporate Style)...
📦 Generating Product data (Modern Style)...
📋 Generating Order data (Default Style)...
🎨 Applying custom styling...
💾 Writing Excel file...
✅ Demo completed! File saved to: ./Output/demo-workbook.xlsx

📈 Performance Summary:
  - Total generation time: 0.15s
  - Memory usage: 12.3 MB
  - File size: 28.7 KB
  - Total records: 150 (50 employees, 50 products, 50 orders)
```

## 🔧 Technical Features Demonstrated

### Column Configuration Features

- **Filtering**: Age >= 18, active products only, non-empty customer names
- **Data Mapping**: Enums to strings, booleans to Yes/No, arrays to comma-separated lists
- **Nil Handling**: Custom empty value displays, default value substitution
- **Column Widths**: Optimized widths for different content types
- **Text Wrapping**: Automatic wrapping for long descriptions

### Styling Features

- **Three Distinct Themes**: Corporate, Modern, and Default styling approaches
- **Custom Row Heights**: 25pt rows for Employee worksheet
- **Conditional Formatting**: Stock levels, status indicators, priority highlighting
- **Professional Typography**: Font families optimized for business use
- **Border Management**: Complete, selective, and gradient border styles

### Advanced Library Features

- **Type Safety**: Generic `Sheet<T>` with KeyPath-based column definitions
- **Progress Tracking**: Real-time generation progress with AsyncStream
- **Memory Efficiency**: Lazy data loading and stream-based processing
- **Error Handling**: Comprehensive error management with detailed messages
- **Multi-Platform**: Pure Swift implementation for all Apple platforms and Linux

## 📁 Project Structure

```
Demo/
├── Package.swift                          # Executable SPM configuration
├── Sources/Objects2XLSXDemo/
│   ├── main.swift                        # CLI entry point
│   ├── Models/                           # Data models
│   │   ├── Employee.swift               # Corporate employee model
│   │   ├── Product.swift                # E-commerce product model
│   │   └── Order.swift                  # Order with calculated fields
│   ├── Data/                            # Sample data generators
│   │   ├── SampleEmployees.swift        # Employee data generation
│   │   ├── SampleProducts.swift         # Product data generation
│   │   └── SampleOrders.swift           # Order data generation
│   ├── Styles/                          # Styling configurations
│   │   ├── CorporateStyle.swift         # Professional business theme
│   │   ├── ModernStyle.swift            # Contemporary design theme
│   │   └── DefaultStyle.swift           # Excel default theme
│   └── ExcelGenerator.swift             # Main generation logic
├── Output/                               # Generated files directory
└── README.md                            # This file
```

## 💡 Learning Opportunities

### For Beginners

- Start with the generated Excel file to see the end result
- Examine the data models in `Models/` to understand structure
- Review the basic column configurations

### For Intermediate Users

- Study the styling implementations in `Styles/`
- Explore the data generation logic in `Data/`
- Understand the column feature usage patterns

### for Advanced Users

- Analyze the complete generation pipeline in `ExcelGenerator.swift`
- Review performance optimization techniques
- Study the CLI argument parsing and error handling

## 🛠 Customization

### Adding Your Own Data

1. Create a new model in `Models/`
2. Add a data generator in `Data/`
3. Create a style configuration in `Styles/`
4. Update `ExcelGenerator.swift` to include your sheet

### Modifying Styles

Each style file contains clearly marked TODO sections where you can:
- Adjust colors and fonts
- Modify border styles
- Change alignment and formatting
- Add conditional formatting rules

### Extending Functionality

The demo provides a solid foundation for:
- Adding new column types
- Implementing custom data transformations
- Creating additional styling themes
- Building interactive CLI features

## 🧪 Development

### Building

```bash
swift build
```

### Testing

```bash
# Build and run tests for the main library
cd ..
swift test

# Run the demo
cd Demo
swift run Objects2XLSXDemo --data-size small --verbose
```

### Code Formatting

The project inherits SwiftFormat configuration from the parent library:

```bash
# Format demo code
cd ..
swiftformat Demo/Sources/

# Check formatting
swiftformat --lint Demo/Sources/
```

## 📄 Next Steps

1. **Run the Demo**: Generate your first Excel file with `swift run Objects2XLSXDemo`
2. **Explore the Output**: Open the generated file in Excel, Numbers, or Google Sheets
3. **Study the Code**: Review the source files to understand implementation patterns
4. **Customize**: Modify the styles and data to match your needs
5. **Integrate**: Use Objects2XLSX in your own projects

## 🤝 Contributing

Found an issue or have suggestions for the demo? Please contribute:

1. Fork the main Objects2XLSX repository
2. Make changes to the `Demo/` directory
3. Test your changes with `swift run Objects2XLSXDemo`
4. Submit a pull request with a clear description

---

**Happy Excel generation! 📊✨**