//
// ExcelGenerator.swift
// Objects2XLSXDemo
//
// Main Excel generation logic for the demo
//

import Foundation
import Objects2XLSX

// MARK: - Excel Generator

/// Main class responsible for generating the demo Excel workbook
struct ExcelGenerator {
    // MARK: - Configuration

    let dataSize: DataSize
    let outputPath: URL
    let styleTheme: StyleTheme
    let verbose: Bool
    let benchmark: Bool

    // MARK: - Initialization

    init(
        dataSize: DataSize = .medium,
        outputPath: URL,
        styleTheme: StyleTheme = .mixed,
        verbose: Bool = false,
        benchmark: Bool = false)
    {
        self.dataSize = dataSize
        self.outputPath = outputPath
        self.styleTheme = styleTheme
        self.verbose = verbose
        self.benchmark = benchmark
    }

    // MARK: - Generation Methods

    /// Generate the complete demo Excel workbook
    func generateWorkbook() async throws {
        let startTime = Date()

        if verbose {
            print("🚀 Starting Excel generation...")
            print("📊 Data size: \(dataSize.rawValue) (\(dataSize.recordCount) records per sheet)")
            print("🎨 Style theme: \(styleTheme.rawValue)")
            print("📁 Output path: \(outputPath.path)")
        }

        // Step 1: Generate sample data
        if verbose { print("\n📊 Generating sample data...") }
        let employees = SampleEmployees.generate(size: dataSize)
        let products = SampleProducts.generate(size: dataSize)
        let orders = SampleOrders.generate(size: dataSize)

        if verbose {
            print("  ✅ Generated \(employees.count) employees")
            print("  ✅ Generated \(products.count) products")
            print("  ✅ Generated \(orders.count) orders")
        }

        // Step 2: Create Book with appropriate style
        let bookStyle = createBookStyle(for: styleTheme)
        let book = Book(style: bookStyle)

        // Step 3: Create and append sheets
        if verbose { print("\n🎨 Creating styled worksheets...") }

        // Create sheets
        let employeeSheet = createEmployeeSheet(employees: employees, theme: styleTheme)
        let productSheet = createProductSheet(products: products, theme: styleTheme)
        let orderSheet = createOrderSheet(orders: orders, theme: styleTheme)

        // Append sheets to the book
        book.append(sheets: [employeeSheet, productSheet, orderSheet])

        if verbose {
            print("  ✅ Created Employee worksheet (Corporate style)")
            print("  ✅ Created Product worksheet (Modern style)")
            print("  ✅ Created Order worksheet (Default style)")
        }

        // Step 4: Track progress if verbose
        if verbose {
            print("\n💾 Writing Excel file...")

            let progressStream = book.progressStream
            Task { @Sendable in
                for await progress in progressStream {
                    print("  📈 \(progress.description) - \(Int(progress.progressPercentage * 100))%")
                    if progress.isFinal { break }
                }
            }
        }

        // Step 5: Write the Excel file
        let outputURL = try book.write(to: outputPath)

        // Step 6: Display completion information
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        print("\n✅ Demo workbook generated successfully!")
        print("📄 File saved to: \(outputURL.path)")

        if let fileSize = try? FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int {
            let sizeInKB = Double(fileSize) / 1024.0
            print("📊 File size: \(String(format: "%.1f", sizeInKB)) KB")
        }

        if benchmark {
            print("\n⏱️  Performance Summary:")
            print("  - Total generation time: \(String(format: "%.2f", duration))s")
            print("  - Total records: \(employees.count + products.count + orders.count)")
            print("  - Records per second: \(String(format: "%.0f", Double(employees.count + products.count + orders.count) / duration))")
        }
    }

    // MARK: - Sheet Creation Methods

    /// Create the Employee worksheet with corporate styling
    private func createEmployeeSheet(employees: [Employee], theme: StyleTheme) -> AnySheet {
        let sheetStyle = theme == .mixed || theme == .corporate
            ? CorporateStyle.createSheetStyle()
            : theme == .modern
            ? ModernStyle.createSheetStyle()
            : DefaultStyle.createSheetStyle()

        let sheet = Sheet<Employee>(
            name: "Employees",
            style: sheetStyle,
            dataProvider: { employees.filter { $0.age >= 18 } } // Filter out minors
        ) {
            // Name column - basic string
            Column(name: "Name", keyPath: \.name)
                .width(20)
                .bodyStyle(CorporateStyle.createDataStyle())

            // Age column - basic integer
            Column(name: "Age", keyPath: \.age)
                .width(8)
                .bodyStyle(CorporateStyle.createDataStyle())

            // Department column - enum mapping
            Column(name: "Department", keyPath: \.department.displayName)
                .width(18)
                .bodyStyle(CorporateStyle.createDataStyle())

            // Salary column - optional with currency formatting
            Column(
                name: "Salary",
                keyPath: \Employee.salary,
                width: 12,
                bodyStyle: CorporateStyle.createCurrencyStyle(),
                mapping: { salary in
                    DoubleColumnType(DoubleColumnConfig(value: salary ?? 0.0))
                })

            // Email column - URL type
            Column(name: "Email", keyPath: \.email.absoluteString)
                .width(25)
                .bodyStyle(CorporateStyle.createDataStyle())

            // Hire Date column - date formatting
            Column(name: "Hire Date", keyPath: \.hireDate)
                .width(12)
                .bodyStyle(CorporateStyle.createDateStyle())

            // Manager Status column - boolean mapping
            Column(
                name: "Is Manager",
                keyPath: \.isManager,
                width: 10,
                bodyStyle: CorporateStyle.createStatusStyle(),
                booleanExpressions: .yesAndNo)

            // Address column - optional string
            Column(
                name: "Address",
                keyPath: \.address,
                width: 30,
                bodyStyle: CorporateStyle.createDataStyle(),
                mapping: { address in
                    TextColumnType(TextColumnConfig(value: address ?? "Not Provided"))
                })
        }

        return sheet.eraseToAnySheet()
    }

    /// Create the Product worksheet with modern styling
    private func createProductSheet(products: [Product], theme: StyleTheme) -> AnySheet {
        let sheetStyle = theme == .mixed || theme == .modern
            ? ModernStyle.createSheetStyle()
            : theme == .corporate
            ? CorporateStyle.createSheetStyle()
            : DefaultStyle.createSheetStyle()

        let sheet = Sheet<Product>(
            name: "Products",
            style: sheetStyle,
            dataProvider: { products.filter(\.isActive) } // Only show active products
        ) {
            // ID column - simple integer
            Column(name: "ID", keyPath: \.id)
                .width(8)
                .bodyStyle(ModernStyle.createDataStyle())

            // Name column - product name
            Column(name: "Product Name", keyPath: \.name)
                .width(25)
                .bodyStyle(ModernStyle.createDataStyle())

            // Category column - enum display
            Column(name: "Category", keyPath: \.category.displayName)
                .width(18)
                .bodyStyle(ModernStyle.createDataStyle())

            // Price column - optional with currency
            Column(
                name: "Price",
                keyPath: \Product.price,
                width: 10,
                bodyStyle: ModernStyle.createPriceStyle(),
                mapping: { price in
                    DoubleColumnType(DoubleColumnConfig(value: price ?? 0.0))
                })

            // Stock column - with conditional formatting
            Column(
                name: "Stock",
                keyPath: \.stock,
                width: 8,
                bodyStyle: ModernStyle.createDataStyle(),
                mapping: { stock in
                    switch stock {
                        case 0: TextColumnType(TextColumnConfig(value: "Out"))
                        case 1 ... 10: TextColumnType(TextColumnConfig(value: "\(stock) ⚠️"))
                        default: TextColumnType(TextColumnConfig(value: "\(stock)"))
                    }
                })

            // Stock Level column - visual indicator
            Column(name: "Level", keyPath: \.stockLevel.displayColor)
                .width(10)
                .bodyStyle(ModernStyle.createDataStyle())

            // Rating column - star representation
            Column(name: "Rating", keyPath: \.starRating)
                .width(15)
                .bodyStyle(ModernStyle.createRatingStyle())

            // Active Status column - boolean filter demo
            Column(
                name: "Status",
                keyPath: \.isActive,
                width: 8,
                bodyStyle: ModernStyle.createDataStyle(),
                mapping: { active in
                    TextColumnType(TextColumnConfig(value: active ? "Active" : "Inactive"))
                })

            // Description column - text wrapping demo
            Column(name: "Description", keyPath: \.description)
                .width(40)
                .bodyStyle(ModernStyle.createDescriptionStyle())
        }

        return sheet.eraseToAnySheet()
    }

    /// Create the Order worksheet with default styling
    private func createOrderSheet(orders: [Order], theme: StyleTheme) -> AnySheet {
        let sheetStyle = theme == .mixed || theme == .defaultTheme
            ? DefaultStyle.createSheetStyle()
            : theme == .corporate
            ? CorporateStyle.createSheetStyle()
            : ModernStyle.createSheetStyle()

        let sheet = Sheet<Order>(
            name: "Orders",
            style: sheetStyle,
            dataProvider: { orders.filter { !$0.customerName.isEmpty } } // Filter out empty customer names
        ) {
            // Order ID column
            Column(name: "Order ID", keyPath: \.orderID)
                .width(15)
                .bodyStyle(DefaultStyle.createDataStyle())

            // Customer Name column
            Column(name: "Customer", keyPath: \.customerName)
                .width(20)
                .bodyStyle(DefaultStyle.createDataStyle())

            // Order Date column
            Column(name: "Order Date", keyPath: \.orderDate)
                .width(12)
                .bodyStyle(DefaultStyle.createDateStyle())

            // Items column - array to string mapping
            Column(name: "Items", keyPath: \.itemsDescription)
                .width(35)
                .bodyStyle(DefaultStyle.createTextWrapStyle())

            // Subtotal column - calculated field
            Column(name: "Subtotal", keyPath: \.subtotal)
                .width(12)
                .bodyStyle(DefaultStyle.createCurrencyStyle())

            // Tax Rate column - percentage
            Column(
                name: "Tax Rate",
                keyPath: \.taxRate,
                width: 10,
                bodyStyle: DefaultStyle.createNumericStyle(),
                mapping: { rate in
                    PercentageColumnType(PercentageColumnConfig(value: rate, precision: 1))
                })

            // Tax Amount column
            Column(name: "Tax", keyPath: \.tax)
                .width(10)
                .bodyStyle(DefaultStyle.createCurrencyStyle())

            // Total column - calculated with emphasis
            Column(name: "Total", keyPath: \.total)
                .width(12)
                .bodyStyle(DefaultStyle.createCurrencyStyle())

            // Status column - with color coding
            Column(name: "Status", keyPath: \.status.displayName)
                .width(12)
                .bodyStyle(DefaultStyle.createStatusStyle())
        }

        return sheet.eraseToAnySheet()
    }

    // MARK: - Style Creation Methods

    /// Create book style based on theme selection
    private func createBookStyle(for theme: StyleTheme) -> BookStyle {
        switch theme {
            case .corporate:
                CorporateStyle.createBookStyle()
            case .modern:
                ModernStyle.createBookStyle()
            case .defaultTheme:
                DefaultStyle.createBookStyle()
            case .mixed:
                // For mixed theme, use a neutral book style
                BookStyle(
                    sheetStyle: nil,
                    bodyCellStyle: nil,
                    headerCellStyle: nil)
        }
    }
}

// MARK: - Style Theme Enum

/// Available styling themes for the demo
enum StyleTheme: String, CaseIterable {
    case corporate
    case modern
    case defaultTheme = "default"
    case mixed

    /// Description of the theme
    var description: String {
        switch self {
            case .corporate:
                "Professional corporate styling for all sheets"
            case .modern:
                "Contemporary modern styling for all sheets"
            case .defaultTheme:
                "Excel default styling for all sheets"
            case .mixed:
                "Different styling theme for each sheet (recommended)"
        }
    }
}
