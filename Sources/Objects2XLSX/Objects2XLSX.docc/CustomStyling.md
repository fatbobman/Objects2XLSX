# Custom Styling

Create sophisticated and professional-looking Excel documents with advanced styling techniques.

## Overview

Objects2XLSX provides a comprehensive styling system that allows you to create Excel documents that match your brand identity and professional standards. This guide covers advanced styling techniques, custom themes, and professional design patterns.

## Theme Development

### Creating a Corporate Theme

Develop a consistent corporate theme for all your Excel exports:

```swift
struct CorporateTheme {
    // Brand Colors
    static let primaryBlue = Color(hex: "#1f4e79")
    static let secondaryBlue = Color(hex: "#2e75b6")
    static let accentGreen = Color(hex: "#70ad47")
    static let lightGray = Color(hex: "#f2f2f2")
    static let darkGray = Color(hex: "#595959")
    
    // Typography
    static let headerFont = Font(size: 12, name: "Calibri", bold: true, color: .white)
    static let bodyFont = Font(size: 11, name: "Calibri", color: darkGray)
    static let emphasizedFont = Font(size: 11, name: "Calibri", bold: true, color: primaryBlue)
    
    // Header Styles
    static let primaryHeader = CellStyle(
        font: headerFont,
        fill: Fill.solid(primaryBlue),
        alignment: Alignment(horizontal: .center, vertical: .center),
        border: Border.all(style: .thin, color: .white)
    )
    
    static let secondaryHeader = CellStyle(
        font: Font(size: 11, name: "Calibri", bold: true, color: darkGray),
        fill: Fill.solid(lightGray),
        alignment: Alignment(horizontal: .left, vertical: .center),
        border: Border.bottom(style: .medium, color: primaryBlue)
    )
    
    // Data Styles
    static let standardData = CellStyle(
        font: bodyFont,
        alignment: Alignment(horizontal: .left, vertical: .center),
        border: Border.outline(style: .thin, color: Color(hex: "#d9d9d9"))
    )
    
    static let numericData = CellStyle(
        font: bodyFont,
        alignment: Alignment(horizontal: .right, vertical: .center),
        border: Border.outline(style: .thin, color: Color(hex: "#d9d9d9"))
    )
    
    static let currencyData = CellStyle(
        font: bodyFont,
        alignment: Alignment(horizontal: .right, vertical: .center),
        border: Border.outline(style: .thin, color: Color(hex: "#d9d9d9")),
        numberFormat: .currency
    )
    
    // Accent Styles
    static let positiveValue = CellStyle(
        font: Font(size: 11, name: "Calibri", bold: true, color: accentGreen),
        alignment: Alignment(horizontal: .right, vertical: .center)
    )
    
    static let negativeValue = CellStyle(
        font: Font(size: 11, name: "Calibri", bold: true, color: .red),
        alignment: Alignment(horizontal: .right, vertical: .center)
    )
    
    // Sheet Configuration
    static func configureSheet() -> SheetStyle {
        var style = SheetStyle()
        style.defaultRowHeight = 22
        style.defaultColumnWidth = 15
        style.showGridlines = false
        style.freezePanes = .freezeTopRow()
        style.zoom = .custom(110)
        return style
    }
}
```

### Modern Minimalist Theme

Create a clean, modern appearance:

```swift
struct ModernTheme {
    // Modern Color Palette
    static let charcoal = Color(hex: "#2c3e50")
    static let softBlue = Color(hex: "#3498db")
    static let lightBlue = Color(hex: "#ebf3fd")
    static let warmGray = Color(hex: "#95a5a6")
    static let offWhite = Color(hex: "#fafafa")
    
    // Typography
    static let modernFont = "Segoe UI"
    
    static let titleStyle = CellStyle(
        font: Font(size: 16, name: modernFont, bold: true, color: charcoal),
        alignment: Alignment(horizontal: .left, vertical: .center)
    )
    
    static let headerStyle = CellStyle(
        font: Font(size: 12, name: modernFont, bold: true, color: charcoal),
        fill: Fill.solid(lightBlue),
        alignment: Alignment(horizontal: .left, vertical: .center),
        border: Border.bottom(style: .medium, color: softBlue)
    )
    
    static let dataStyle = CellStyle(
        font: Font(size: 11, name: modernFont, color: charcoal),
        alignment: Alignment(horizontal: .left, vertical: .center)
    )
    
    static let accentStyle = CellStyle(
        font: Font(size: 11, name: modernFont, bold: true, color: softBlue),
        fill: Fill.solid(offWhite),
        alignment: Alignment(horizontal: .center, vertical: .center)
    )
}
```

## Advanced Styling Techniques

### Conditional Formatting

Apply different styles based on data values:

```swift
struct SalesReport: Sendable {
    let product: String
    let revenue: Double
    let target: Double
    let growth: Double
}

func createSalesReportWithConditionalFormatting(data: [SalesReport]) -> Sheet<SalesReport> {
    return Sheet<SalesReport>(name: "Sales Performance", dataProvider: { data }) {
        Column(name: "Product", keyPath: \.product)
            .width(25)
            .headerStyle(CorporateTheme.primaryHeader)
            .bodyStyle(CorporateTheme.standardData)
        
        Column(name: "Revenue", keyPath: \.revenue)
            .width(15)
            .headerStyle(CorporateTheme.primaryHeader)
            .bodyStyle(CorporateTheme.currencyData)
        
        // Conditional styling based on target achievement
        Column(name: "vs Target", keyPath: \.revenue)
            .width(15)
            .headerStyle(CorporateTheme.primaryHeader)
            .toString { revenue in
                let target = data.first(where: { $0.revenue == revenue })?.target ?? 0
                let percentage = (revenue / target) * 100
                return String(format: "%.1f%%", percentage)
            }
            .bodyStyle { report in
                let percentage = (report.revenue / report.target) * 100
                switch percentage {
                case 110...: return CorporateTheme.positiveValue
                case 90..<110: return CorporateTheme.standardData
                default: return CorporateTheme.negativeValue
                }
            }
        
        // Growth indicator with color coding
        Column(name: "Growth", keyPath: \.growth)
            .width(12)
            .headerStyle(CorporateTheme.primaryHeader)
            .toString { growth in
                let sign = growth >= 0 ? "+" : ""
                return "\(sign)\(String(format: "%.1f", growth))%"
            }
            .bodyStyle { report in
                switch report.growth {
                case 10...: return CellStyle(
                    font: Font(size: 11, name: "Calibri", bold: true, color: .white),
                    fill: Fill.solid(CorporateTheme.accentGreen),
                    alignment: Alignment(horizontal: .center, vertical: .center)
                )
                case 0..<10: return CorporateTheme.positiveValue
                case -5..<0: return CorporateTheme.standardData
                default: return CellStyle(
                    font: Font(size: 11, name: "Calibri", bold: true, color: .white),
                    fill: Fill.solid(.red),
                    alignment: Alignment(horizontal: .center, vertical: .center)
                )
                }
            }
    }
}
```

### Multi-Level Headers

Create complex header structures:

```swift
struct FinancialData: Sendable {
    let period: String
    let revenue: Double
    let costs: Double
    let profit: Double
}

// This would require custom implementation for true multi-level headers
// For now, we can simulate with careful naming
func createFinancialReport(data: [FinancialData]) -> Sheet<FinancialData> {
    return Sheet<FinancialData>(name: "Financial Report", dataProvider: { data }) {
        Column(name: "Period", keyPath: \.period)
            .width(15)
            .headerStyle(CorporateTheme.primaryHeader)
            .bodyStyle(CorporateTheme.standardData)
        
        Column(name: "Revenue ($K)", keyPath: \.revenue)
            .width(15)
            .headerStyle(CorporateTheme.secondaryHeader)
            .toString { String(format: "%.0f", $0 / 1000) }
            .bodyStyle(CorporateTheme.numericData)
        
        Column(name: "Costs ($K)", keyPath: \.costs)
            .width(15)
            .headerStyle(CorporateTheme.secondaryHeader)
            .toString { String(format: "%.0f", $0 / 1000) }
            .bodyStyle(CorporateTheme.numericData)
        
        Column(name: "Profit ($K)", keyPath: \.profit)
            .width(15)
            .headerStyle(CorporateTheme.secondaryHeader)
            .toString { String(format: "%.0f", $0 / 1000) }
            .bodyStyle { data in
                data.profit >= 0 ? CorporateTheme.positiveValue : CorporateTheme.negativeValue
            }
    }
}
```

## Professional Design Patterns

### Dashboard-Style Layout

Create dashboard-like reports with sections:

```swift
struct DashboardData: Sendable {
    let kpi: String
    let currentValue: Double
    let previousValue: Double
    let target: Double
}

func createDashboardReport(kpis: [DashboardData]) -> Sheet<DashboardData> {
    let dashboardStyle = SheetStyle()
    dashboardStyle.defaultRowHeight = 28
    dashboardStyle.showGridlines = false
    
    let titleStyle = CellStyle(
        font: Font(size: 14, name: "Calibri", bold: true, color: CorporateTheme.primaryBlue),
        alignment: Alignment(horizontal: .center, vertical: .center),
        border: Border.bottom(style: .thick, color: CorporateTheme.primaryBlue)
    )
    
    let kpiStyle = CellStyle(
        font: Font(size: 12, name: "Calibri", bold: true, color: CorporateTheme.darkGray),
        fill: Fill.solid(CorporateTheme.lightGray),
        alignment: Alignment(horizontal: .left, vertical: .center),
        border: Border.all(style: .thin, color: .white)
    )
    
    return Sheet<DashboardData>(name: "KPI Dashboard", dataProvider: { kpis }, style: dashboardStyle) {
        Column(name: "Key Performance Indicator", keyPath: \.kpi)
            .width(30)
            .headerStyle(titleStyle)
            .bodyStyle(kpiStyle)
        
        Column(name: "Current", keyPath: \.currentValue)
            .width(15)
            .headerStyle(titleStyle)
            .toString { String(format: "%.2f", $0) }
            .bodyStyle(CorporateTheme.numericData)
        
        Column(name: "Previous", keyPath: \.previousValue)
            .width(15)
            .headerStyle(titleStyle)
            .toString { String(format: "%.2f", $0) }
            .bodyStyle(CorporateTheme.numericData)
        
        Column(name: "Target", keyPath: \.target)
            .width(15)
            .headerStyle(titleStyle)
            .toString { String(format: "%.2f", $0) }
            .bodyStyle(CorporateTheme.numericData)
        
        Column(name: "Achievement", keyPath: \.currentValue)
            .width(15)
            .headerStyle(titleStyle)
            .toString { current in
                let kpi = kpis.first(where: { $0.currentValue == current })
                guard let target = kpi?.target, target > 0 else { return "N/A" }
                let percentage = (current / target) * 100
                return String(format: "%.1f%%", percentage)
            }
            .bodyStyle { data in
                let percentage = (data.currentValue / data.target) * 100
                switch percentage {
                case 100...: return CellStyle(
                    font: Font(size: 11, name: "Calibri", bold: true, color: .white),
                    fill: Fill.solid(CorporateTheme.accentGreen),
                    alignment: Alignment(horizontal: .center, vertical: .center)
                )
                case 80..<100: return CellStyle(
                    font: Font(size: 11, name: "Calibri", bold: true, color: CorporateTheme.accentGreen),
                    alignment: Alignment(horizontal: .center, vertical: .center)
                )
                case 60..<80: return CellStyle(
                    font: Font(size: 11, name: "Calibri", color: Color(hex: "#f39c12")),
                    alignment: Alignment(horizontal: .center, vertical: .center)
                )
                default: return CellStyle(
                    font: Font(size: 11, name: "Calibri", bold: true, color: .red),
                    alignment: Alignment(horizontal: .center, vertical: .center)
                )
                }
            }
    }
}
```

### Data Table with Alternating Rows

Create tables with alternating row colors:

```swift
func createAlternatingRowsSheet<T: Sendable>(
    name: String,
    data: [T],
    @ColumnBuilder<T> columns: () -> [AnyColumn<T>]
) -> Sheet<T> {
    
    let evenRowStyle = CellStyle(
        fill: Fill.solid(Color(hex: "#f9f9f9")),
        border: Border.outline(style: .thin, color: Color(hex: "#e0e0e0"))
    )
    
    let oddRowStyle = CellStyle(
        fill: Fill.solid(.white),
        border: Border.outline(style: .thin, color: Color(hex: "#e0e0e0"))
    )
    
    // Note: This is a conceptual example
    // Actual alternating rows would require additional implementation
    return Sheet<T>(name: name, dataProvider: { data }) {
        // Apply columns with alternating row styling logic
        // This would need to be implemented in the actual column configuration
    }
}
```

## Advanced Border Techniques

### Creating Visual Sections

Use borders to create visual separation:

```swift
let sectionHeaderStyle = CellStyle(
    font: Font(size: 12, name: "Calibri", bold: true, color: CorporateTheme.primaryBlue),
    fill: Fill.solid(CorporateTheme.lightGray),
    alignment: Alignment(horizontal: .left, vertical: .center),
    border: Border(
        top: Border.Side(style: .thick, color: CorporateTheme.primaryBlue),
        bottom: Border.Side(style: .medium, color: CorporateTheme.primaryBlue),
        left: Border.Side(style: .thin, color: CorporateTheme.primaryBlue),
        right: Border.Side(style: .thin, color: CorporateTheme.primaryBlue)
    )
)

let sectionDataStyle = CellStyle(
    font: CorporateTheme.bodyFont,
    alignment: Alignment(horizontal: .left, vertical: .center),
    border: Border(
        left: Border.Side(style: .thin, color: CorporateTheme.primaryBlue),
        right: Border.Side(style: .thin, color: CorporateTheme.primaryBlue),
        bottom: Border.Side(style: .thin, color: Color(hex: "#e0e0e0"))
    )
)
```

### Summary Row Styling

Create distinctive summary rows:

```swift
let summaryStyle = CellStyle(
    font: Font(size: 11, name: "Calibri", bold: true, color: .white),
    fill: Fill.solid(CorporateTheme.primaryBlue),
    alignment: Alignment(horizontal: .right, vertical: .center),
    border: Border.all(style: .medium, color: .white)
)

let totalLabelStyle = CellStyle(
    font: Font(size: 11, name: "Calibri", bold: true, color: .white),
    fill: Fill.solid(CorporateTheme.primaryBlue),
    alignment: Alignment(horizontal: .left, vertical: .center),
    border: Border.all(style: .medium, color: .white)
)
```

## Color Psychology in Business Reports

### Status Indication Colors

Use colors that convey clear meaning:

```swift
struct StatusColors {
    static let success = Color(hex: "#27ae60")      // Green
    static let warning = Color(hex: "#f39c12")      // Orange  
    static let danger = Color(hex: "#e74c3c")       // Red
    static let info = Color(hex: "#3498db")         // Blue
    static let neutral = Color(hex: "#95a5a6")      // Gray
    
    static let lightSuccess = Color(hex: "#d5f4e6") // Light green
    static let lightWarning = Color(hex: "#fdeaa7")  // Light orange
    static let lightDanger = Color(hex: "#fadbd8")   // Light red
    static let lightInfo = Color(hex: "#d6eaf8")     // Light blue
}

func getStatusStyle(for value: Double, threshold: Double) -> CellStyle {
    switch value {
    case threshold...: return CellStyle(
        font: Font(bold: true, color: .white),
        fill: Fill.solid(StatusColors.success)
    )
    case (threshold * 0.8)..<threshold: return CellStyle(
        font: Font(color: StatusColors.warning),
        fill: Fill.solid(StatusColors.lightWarning)
    )
    default: return CellStyle(
        font: Font(bold: true, color: .white),
        fill: Fill.solid(StatusColors.danger)
    )
    }
}
```

## Accessibility Considerations

### High Contrast Themes

Ensure your styles are accessible:

```swift
struct AccessibleTheme {
    // High contrast colors
    static let darkText = Color(hex: "#000000")
    static let lightBackground = Color(hex: "#ffffff")
    static let highContrastBlue = Color(hex: "#0066cc")
    static let highContrastRed = Color(hex: "#cc0000")
    
    static let accessibleHeader = CellStyle(
        font: Font(size: 12, name: "Arial", bold: true, color: .white),
        fill: Fill.solid(darkText),
        border: Border.all(style: .medium, color: darkText)
    )
    
    static let accessibleData = CellStyle(
        font: Font(size: 11, name: "Arial", color: darkText),
        fill: Fill.solid(lightBackground),
        border: Border.all(style: .thin, color: darkText)
    )
}
```

## Best Practices

### Style Consistency

1. **Create style libraries** - Develop reusable style objects
2. **Use consistent color palettes** - Stick to your brand colors
3. **Maintain hierarchy** - Use font sizes and weights consistently
4. **Test readability** - Ensure sufficient contrast

### Performance

1. **Reuse style objects** - Don't create new styles unnecessarily
2. **Limit unique styles** - Too many styles can impact performance
3. **Use efficient patterns** - Apply styles at the appropriate level

### Maintainability

1. **Document your themes** - Comment complex styling logic
2. **Version your styles** - Track changes to styling systems
3. **Test across platforms** - Verify appearance in different Excel versions

## See Also

- ``CellStyle``
- ``Font``
- ``Color``
- ``Fill``
- ``Border``
- ``Alignment``
- <doc:StylingWorkbooks>
- <doc:CreatingSheets>