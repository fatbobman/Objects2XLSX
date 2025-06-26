# Styling Workbooks

Create professional-looking Excel files with comprehensive styling options.

## Overview

Objects2XLSX provides a rich styling system that allows you to create professional Excel documents with custom fonts, colors, borders, and formatting. The styling system follows a hierarchical approach: Book → Sheet → Column → Cell, where more specific styles override general ones.

## Style Hierarchy

The styling system uses a clear precedence order:

1. **Cell Style** (highest priority) - Individual cell styling
2. **Column Style** - Column-wide styling  
3. **Sheet Style** - Sheet-wide styling
4. **Book Style** (lowest priority) - Workbook defaults

## Basic Styling

### Cell Styles

Create custom cell styles for different purposes:

```swift
// Header style
let headerStyle = CellStyle(
    font: Font(size: 14, name: "Arial", bold: true, color: .white),
    fill: Fill.solid(.blue),
    alignment: Alignment(horizontal: .center, vertical: .center),
    border: Border.all(style: .thin, color: .black)
)

// Data style
let dataStyle = CellStyle(
    font: Font(size: 11, name: "Calibri"),
    alignment: Alignment(horizontal: .left, wrapText: true),
    border: Border.outline(style: .thin, color: .gray)
)

// Apply to columns
let sheet = Sheet<Person>(name: "Styled Employees", dataProvider: { people }) {
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

### Fonts

Customize text appearance:

```swift
// Basic font
let basicFont = Font(size: 12, name: "Calibri")

// Bold header font
let headerFont = Font(size: 14, name: "Arial", bold: true, color: .white)

// Custom colored font
let accentFont = Font(size: 11, name: "Helvetica", color: .blue)

// Font with multiple properties
let specialFont = Font(
    size: 13,
    name: "Times New Roman",
    bold: true,
    italic: true,
    underline: true,
    color: .red
)
```

### Colors

Use predefined or custom colors:

```swift
// Predefined colors
let redColor = Color.red
let blueColor = Color.blue
let lightGrayColor = Color.lightGray

// Custom RGB colors
let customColor = Color(red: 255, green: 128, blue: 0) // Orange

// Hex colors
let hexColor = Color(hex: "#FF5733")

// Colors with transparency
let transparentRed = Color(red: 255, green: 0, blue: 0, alpha: .medium) // 50% transparent
```

## Advanced Styling

### Fills and Backgrounds

Create solid fills and gradients:

```swift
// Solid fills
let solidBlue = Fill.solid(.blue)
let solidGray = Fill.solid(.lightGray)

// Gradient fills
let gradientFill = Fill.gradient(
    .linear(angle: 90),  // Vertical gradient
    colors: [.blue, .white, .red]
)

// Pattern fills
let patternFill = Fill.pattern(
    .diagonal,
    foregroundColor: .blue,
    backgroundColor: .white
)

// Apply to cells
let styledCell = CellStyle(fill: gradientFill)
```

### Borders

Create various border styles:

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
    bottom: nil  // No bottom border
)

// Diagonal borders
let diagonalBorder = Border(diagonal: .up(style: .medium, color: .green))
```

### Alignment and Text Control

Control text positioning and behavior:

```swift
// Basic alignment
let centerAlign = Alignment(horizontal: .center, vertical: .center)
let leftAlign = Alignment(horizontal: .left, vertical: .top)

// Text wrapping
let wrapText = Alignment(horizontal: .left, wrapText: true)

// Text rotation
let rotatedText = Alignment(textRotation: 45) // 45-degree rotation

// Indentation
let indentedText = Alignment(horizontal: .left, indent: 2)

// Complete alignment configuration
let complexAlignment = Alignment(
    horizontal: .center,
    vertical: .center,
    wrapText: true,
    textRotation: 0,
    indent: 0
)
```

## Number Formatting

### Currency and Percentage

Format numbers appropriately:

```swift
let sheet = Sheet<Product>(name: "Products", dataProvider: { products }) {
    Column(name: "Product Name", keyPath: \.name)
    
    // Currency formatting
    Column(name: "Price", keyPath: \.price)
        .bodyStyle(CellStyle(numberFormat: .currency))
    
    // Percentage formatting
    Column(name: "Discount", keyPath: \.discountRate)
        .bodyStyle(CellStyle(numberFormat: .percentage(precision: 1)))
    
    // Date formatting
    Column(name: "Launch Date", keyPath: \.launchDate)
        .bodyStyle(CellStyle(numberFormat: .date))
    
    // Custom number format
    Column(name: "Quantity", keyPath: \.quantity)
        .bodyStyle(CellStyle(numberFormat: .custom("#,##0")))
}
```

## Theme-Based Styling

### Corporate Theme

Create a professional corporate look:

```swift
struct CorporateTheme {
    static let primaryColor = Color(hex: "#1f4e79")
    static let secondaryColor = Color(hex: "#2e75b6")
    static let accentColor = Color(hex: "#70ad47")
    
    static let headerStyle = CellStyle(
        font: Font(size: 12, name: "Calibri", bold: true, color: .white),
        fill: Fill.solid(primaryColor),
        alignment: Alignment(horizontal: .center, vertical: .center),
        border: Border.all(style: .thin, color: .white)
    )
    
    static let dataStyle = CellStyle(
        font: Font(size: 11, name: "Calibri"),
        alignment: Alignment(horizontal: .left, vertical: .center),
        border: Border.outline(style: .thin, color: Color(hex: "#d9d9d9"))
    )
    
    static let accentStyle = CellStyle(
        font: Font(size: 11, name: "Calibri", bold: true),
        fill: Fill.solid(Color(hex: "#e2f0d9")),
        alignment: Alignment(horizontal: .center, vertical: .center)
    )
}

// Apply theme
let corporateSheet = Sheet<Employee>(name: "Corporate Report", dataProvider: { employees }) {
    Column(name: "Employee Name", keyPath: \.name)
        .width(25)
        .headerStyle(CorporateTheme.headerStyle)
        .bodyStyle(CorporateTheme.dataStyle)
    
    Column(name: "Department", keyPath: \.department)
        .width(20)
        .headerStyle(CorporateTheme.headerStyle)
        .bodyStyle(CorporateTheme.dataStyle)
    
    Column(name: "Performance", keyPath: \.performanceRating)
        .width(15)
        .headerStyle(CorporateTheme.headerStyle)
        .bodyStyle(CorporateTheme.accentStyle)
}
```

### Modern Theme

Create a clean, modern appearance:

```swift
struct ModernTheme {
    static let backgroundColor = Color(hex: "#f8f9fa")
    static let primaryText = Color(hex: "#212529")
    static let secondaryText = Color(hex: "#6c757d")
    static let accentColor = Color(hex: "#007bff")
    
    static let headerStyle = CellStyle(
        font: Font(size: 13, name: "Segoe UI", bold: true, color: primaryText),
        fill: Fill.solid(backgroundColor),
        alignment: Alignment(horizontal: .left, vertical: .center),
        border: Border.bottom(style: .medium, color: accentColor)
    )
    
    static let dataStyle = CellStyle(
        font: Font(size: 11, name: "Segoe UI", color: primaryText),
        alignment: Alignment(horizontal: .left, vertical: .center)
    )
}
```

## Sheet-Level Styling

### Sheet Appearance

Control overall sheet appearance:

```swift
var modernSheetStyle = SheetStyle()
modernSheetStyle.defaultRowHeight = 22
modernSheetStyle.defaultColumnWidth = 15
modernSheetStyle.showGridlines = false
modernSheetStyle.freezePanes = .freezeTopRow()
modernSheetStyle.zoom = .custom(110)

let modernSheet = Sheet<Product>(
    name: "Modern Products",
    dataProvider: { products },
    style: modernSheetStyle
) {
    // Column definitions...
}
```

## Book-Level Styling

### Document Properties

Set document-wide properties:

```swift
var bookStyle = BookStyle()
bookStyle.properties.title = "Sales Report 2024"
bookStyle.properties.author = "Your Company"
bookStyle.properties.subject = "Quarterly Sales Analysis"
bookStyle.properties.keywords = "sales, report, analysis"

let workbook = Book(style: bookStyle) {
    // Sheets...
}
```

## Conditional Styling

### Data-Driven Styling

Apply different styles based on data values:

```swift
let sheet = Sheet<Order>(name: "Orders", dataProvider: { orders }) {
    Column(name: "Order ID", keyPath: \.id)
    
    Column(name: "Status", keyPath: \.status)
        .toString { status in
            status.rawValue.capitalized
        }
        .bodyStyle { order in
            switch order.status {
            case .completed:
                return CellStyle(
                    font: Font(bold: true, color: .white),
                    fill: Fill.solid(.green)
                )
            case .cancelled:
                return CellStyle(
                    font: Font(bold: true, color: .white),
                    fill: Fill.solid(.red)
                )
            case .pending:
                return CellStyle(
                    font: Font(bold: true, color: .black),
                    fill: Fill.solid(.yellow)
                )
            default:
                return CellStyle()
            }
        }
}
```

## Best Practices

### Performance

- Reuse style objects when possible
- Use the style hierarchy effectively
- Avoid excessive unique styles

### Readability

- Use consistent color schemes
- Ensure sufficient contrast
- Choose readable fonts

### Professional Appearance

- Use subtle borders and fills
- Maintain consistent spacing
- Apply appropriate number formatting

## See Also

- ``CellStyle``
- ``Font``
- ``Color``
- ``Fill``
- ``Border``
- ``Alignment``
- ``NumberFormat``
- <doc:CreatingSheets>