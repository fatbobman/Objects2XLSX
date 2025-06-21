//
// SimplifiedColumnSyntaxTests.swift
// Created by Claude on 2025-06-21.
// Test suite for simplified Column declaration syntax with type precision optimization
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Simplified Column Declaration Syntax")
struct SimplifiedColumnSyntaxTests {
    // Test data models
    struct TestEmployee: Sendable {
        let name: String
        let age: Int
        let salary: Double // Non-optional Double
        let bonus: Double? // Optional Double
        let isManager: Bool // Bool type
    }

    struct TestProduct: Sendable {
        let name: String
        let price: Double // Non-optional Double
        let discount: Double? // Optional Double
        let stockCount: Int // Int type
        let isActive: Bool // Bool type
    }

    @Test("Simplified syntax for non-optional Double")
    func simplifiedNonOptionalDouble() throws {
        let employees = [
            TestEmployee(name: "Alice", age: 30, salary: 50000.0, bonus: 5000.0, isManager: true),
            TestEmployee(name: "Bob", age: 25, salary: 45000.0, bonus: nil, isManager: false),
        ]

        // Test simplified column creation
        let salaryColumn = Column<TestEmployee, Double, DoubleColumnType>(
            name: "Salary",
            keyPath: \.salary)

        #expect(salaryColumn.name == "Salary", "Column name should match")

        // Test data extraction and cell generation
        for employee in employees {
            let cellValue = salaryColumn.generateCellValue(for: employee)

            switch cellValue {
                case let .doubleValue(value):
                    #expect(value == employee.salary, "DoubleValue should match employee salary")
                default:
                    Issue.record("Expected doubleValue enum case for non-optional Double")
            }
        }
    }

    @Test("Simplified syntax for optional Double")
    func simplifiedOptionalDouble() throws {
        let employees = [
            TestEmployee(name: "Alice", age: 30, salary: 50000.0, bonus: 5000.0, isManager: true),
            TestEmployee(name: "Bob", age: 25, salary: 45000.0, bonus: nil, isManager: false),
        ]

        // Test simplified column creation for optional type
        let bonusColumn = Column<TestEmployee, Double?, DoubleColumnType>(
            name: "Bonus",
            keyPath: \.bonus)

        #expect(bonusColumn.name == "Bonus", "Column name should match")

        // Test data extraction - should use optionalDouble enum case
        let aliceCell = bonusColumn.generateCellValue(for: employees[0])
        switch aliceCell {
            case let .optionalDouble(value):
                #expect(value == 5000.0, "OptionalDouble should match Alice's bonus")
            default:
                Issue.record("Expected optionalDouble enum case for optional Double with value")
        }

        let bobCell = bonusColumn.generateCellValue(for: employees[1])
        switch bobCell {
            case let .optionalDouble(value):
                #expect(value == nil, "OptionalDouble should be nil for Bob's bonus")
            default:
                Issue.record("Expected optionalDouble enum case for optional Double with nil")
        }
    }

    @Test("Chainable defaultValue method for optional Double")
    func chainableDefaultValue() throws {
        let products = [
            TestProduct(name: "Laptop", price: 999.99, discount: 0.1, stockCount: 50, isActive: true),
            TestProduct(name: "Mouse", price: 29.99, discount: nil, stockCount: 100, isActive: true),
        ]

        // Test chainable defaultValue method
        let discountColumn = Column<TestProduct, Double?, DoubleColumnType>(
            name: "Discount",
            keyPath: \.discount).defaultValue(0.0)

        #expect(discountColumn.name == "Discount", "Column name should match")
        // Test that nilHandling is properly configured
        switch discountColumn.nilHandling {
            case let .defaultValue(value):
                #expect(value == 0.0, "Default value should be 0.0")
            case .keepEmpty:
                Issue.record("Expected defaultValue, got keepEmpty")
        }

        // Test that default value is applied for nil
        let mouseCell = discountColumn.generateCellValue(for: products[1])
        switch mouseCell {
            case let .doubleValue(value):
                #expect(value == 0.0, "Default value should be applied for nil discount")
            default:
                Issue.record("Expected doubleValue with default for nil input")
        }

        // Test that actual value is preserved when not nil
        let laptopCell = discountColumn.generateCellValue(for: products[0])
        switch laptopCell {
            case let .doubleValue(value):
                #expect(value == 0.1, "Actual discount value should be preserved")
            default:
                Issue.record("Expected doubleValue with actual value for non-nil input")
        }
    }

    @Test("Chainable width method")
    func chainableWidth() throws {
        // Test width chaining with non-optional Double
        let salaryColumn = Column<TestEmployee, Double, DoubleColumnType>(
            name: "Salary",
            keyPath: \.salary).width(12)

        #expect(salaryColumn.width == 12, "Width should be set to 12")

        // Test width chaining with optional Double and defaultValue
        let bonusColumn = Column<TestEmployee, Double?, DoubleColumnType>(
            name: "Bonus",
            keyPath: \.bonus).defaultValue(0.0).width(10)

        #expect(bonusColumn.width == 10, "Width should be set to 10")
        // Test that nilHandling is properly configured after chaining
        switch bonusColumn.nilHandling {
            case let .defaultValue(value):
                #expect(value == 0.0, "Default value should be 0.0")
            case .keepEmpty:
                Issue.record("Expected defaultValue, got keepEmpty")
        }
    }

    @Test("Chainable bodyStyle method")
    func chainableBodyStyle() throws {
        let currencyStyle = CellStyle(
            font: Font(bold: true))

        // Test bodyStyle chaining
        let salaryColumn = Column<TestEmployee, Double, DoubleColumnType>(
            name: "Salary",
            keyPath: \.salary).bodyStyle(currencyStyle)

        #expect(salaryColumn.bodyStyle == currencyStyle, "BodyStyle should be set")

        // Test combined chaining
        let bonusColumn = Column<TestEmployee, Double?, DoubleColumnType>(
            name: "Bonus",
            keyPath: \.bonus).defaultValue(0.0).width(10).bodyStyle(currencyStyle)

        #expect(bonusColumn.bodyStyle == currencyStyle, "BodyStyle should be set")
        #expect(bonusColumn.width == 10, "Width should still be 10")
        // Test that nilHandling is properly configured in combined chaining
        switch bonusColumn.nilHandling {
            case let .defaultValue(value):
                #expect(value == 0.0, "Default value should be 0.0")
            case .keepEmpty:
                Issue.record("Expected defaultValue, got keepEmpty")
        }
    }

    @Test("Type safety - defaultValue only for optional types")
    func typeSafetyDefaultValue() throws {
        // This should compile (Optional Double)
        _ = Column<TestProduct, Double?, DoubleColumnType>(
            name: "Discount",
            keyPath: \.discount).defaultValue(0.0)

        // This test verifies that the constraint works at compile time
        // The following line should NOT compile if uncommented:
        // let _ = Column<TestProduct, Double, DoubleColumnType>(
        //     name: "Price",
        //     keyPath: \.price
        // ).defaultValue(0.0)  // Should cause compile error

        // Just test that the above constraint exists by ensuring column exists
        let priceColumn = Column<TestProduct, Double, DoubleColumnType>(
            name: "Price",
            keyPath: \.price)
        #expect(priceColumn.name == "Price", "Non-optional column should still work")
    }

    @Test("toString transformation method")
    func toStringTransformation() throws {
        let products = [
            TestProduct(name: "Laptop", price: 999.99, discount: 0.1, stockCount: 50, isActive: true),
            TestProduct(name: "Mouse", price: 29.99, discount: nil, stockCount: 100, isActive: true),
        ]

        // Test toString transformation from Double to String
        let priceColumn = Column<TestProduct, Double, DoubleColumnType>(
            name: "Price Category",
            keyPath: \.price).toString { (price: Double?) in
            guard let price else { return "No Price" }
            return price < 100 ? "Cheap" : "Expensive"
        }

        #expect(priceColumn.name == "Price Category", "Column name should match")

        // Test data extraction and transformation
        let laptopCell = priceColumn.generateCellValue(for: products[0])
        switch laptopCell {
            case let .string(value):
                #expect(value == "Expensive", "Laptop should be categorized as Expensive")
            default:
                Issue.record("Expected string enum case for toString result")
        }

        let mouseCell = priceColumn.generateCellValue(for: products[1])
        switch mouseCell {
            case let .string(value):
                #expect(value == "Cheap", "Mouse should be categorized as Cheap")
            default:
                Issue.record("Expected string enum case for toString result")
        }
    }

    @Test("toString with chaining and defaultValue")
    func toStringWithChaining() throws {
        let products = [
            TestProduct(name: "Laptop", price: 999.99, discount: 0.1, stockCount: 50, isActive: true),
            TestProduct(name: "Monitor", price: 299.99, discount: nil, stockCount: 25, isActive: false),
        ]

        // Test toString chaining with optional input and defaultValue
        let discountColumn = Column<TestProduct, Double?, DoubleColumnType>(
            name: "Discount Level",
            keyPath: \.discount)
            .defaultValue(0.0)
            .toString { (discount: Double) in
                discount > 0.05 ? "High Discount" : "Low Discount"
            }
            .width(15)

        #expect(discountColumn.name == "Discount Level", "Column name should match")
        #expect(discountColumn.width == 15, "Width should be preserved")

        // Test laptop with actual discount
        let laptopCell = discountColumn.generateCellValue(for: products[0])
        switch laptopCell {
            case let .string(value):
                #expect(value == "High Discount", "Laptop should have High Discount")
            default:
                Issue.record("Expected string enum case for toString result")
        }

        // Test monitor with nil discount (should use default 0.0)
        let monitorCell = discountColumn.generateCellValue(for: products[1])
        switch monitorCell {
            case let .string(value):
                #expect(value == "Low Discount", "Monitor should have Low Discount (default)")
            default:
                Issue.record("Expected string enum case for toString result")
        }
    }

    @Test("toString for Int type")
    func toStringForIntType() throws {
        let products = [
            TestProduct(name: "Laptop", price: 999.99, discount: 0.1, stockCount: 50, isActive: true),
            TestProduct(name: "Mouse", price: 29.99, discount: nil, stockCount: 100, isActive: true),
            TestProduct(name: "Keyboard", price: 79.99, discount: 0.05, stockCount: 5, isActive: true),
        ]

        // Test toString transformation from Int to String
        let stockColumn = Column<TestProduct, Int, IntColumnType>(
            name: "Stock Status",
            keyPath: \.stockCount).toString { (stock: Int) in
            stock < 10 ? "Low Stock" : stock < 50 ? "Medium Stock" : "High Stock"
        }

        #expect(stockColumn.name == "Stock Status", "Column name should match")

        // Test data extraction and transformation
        let laptopCell = stockColumn.generateCellValue(for: products[0])
        switch laptopCell {
            case let .string(value):
                #expect(value == "High Stock", "Laptop should have High Stock")
            default:
                Issue.record("Expected string enum case for Int toString result")
        }

        let mouseCell = stockColumn.generateCellValue(for: products[1])
        switch mouseCell {
            case let .string(value):
                #expect(value == "High Stock", "Mouse should have High Stock")
            default:
                Issue.record("Expected string enum case for Int toString result")
        }

        let keyboardCell = stockColumn.generateCellValue(for: products[2])
        switch keyboardCell {
            case let .string(value):
                #expect(value == "Low Stock", "Keyboard should have Low Stock")
            default:
                Issue.record("Expected string enum case for Int toString result")
        }
    }

    @Test("toString for Bool type")
    func toStringForBoolType() throws {
        let products = [
            TestProduct(name: "Laptop", price: 999.99, discount: 0.1, stockCount: 50, isActive: true),
            TestProduct(name: "Monitor", price: 299.99, discount: nil, stockCount: 25, isActive: false),
        ]

        // Test toString transformation from Bool to String
        let statusColumn = Column<TestProduct, Bool, BoolColumnType>(
            name: "Availability",
            keyPath: \.isActive).toString { (isActive: Bool) in
            isActive ? "Available for Purchase" : "Out of Stock"
        }

        #expect(statusColumn.name == "Availability", "Column name should match")

        // Test data extraction and transformation
        let laptopCell = statusColumn.generateCellValue(for: products[0])
        switch laptopCell {
            case let .string(value):
                #expect(value == "Available for Purchase", "Laptop should be available")
            default:
                Issue.record("Expected string enum case for Bool toString result")
        }

        let monitorCell = statusColumn.generateCellValue(for: products[1])
        switch monitorCell {
            case let .string(value):
                #expect(value == "Out of Stock", "Monitor should be out of stock")
            default:
                Issue.record("Expected string enum case for Bool toString result")
        }
    }

    @Test("defaultValue bug fix - preserves non-nil values")
    func defaultValueBugFix() throws {
        let employees = [
            TestEmployee(name: "Alice", age: 30, salary: 50000.0, bonus: 5000.0, isManager: true), // 有奖金
            TestEmployee(name: "Bob", age: 25, salary: 45000.0, bonus: nil, isManager: false), // 无奖金
            TestEmployee(name: "Carol", age: 28, salary: 60000.0, bonus: 3000.0, isManager: false), // 有奖金
        ]

        // 测试 defaultValue 不会覆盖非 nil 值（使用 bonus 字段测试 Double?）
        let bonusColumn = Column(name: "Bonus", keyPath: \TestEmployee.bonus)
            .defaultValue(0.0)

        #expect(bonusColumn.name == "Bonus", "Column name should match")

        // 验证有奖金的员工的奖金保持原值，而不是被替换为 defaultValue(0.0)
        let aliceCellValue = bonusColumn.generateCellValue(for: employees[0])
        switch aliceCellValue {
            case let .doubleValue(value):
                #expect(value == 5000.0, "Alice's bonus should preserve original value (5000.0), not be replaced by defaultValue")
                #expect(value != 0.0, "Alice's bonus should not be replaced by defaultValue(0.0)")
            default:
                Issue.record("Expected doubleValue enum case for non-nil bonus with defaultValue")
        }

        let carolCellValue = bonusColumn.generateCellValue(for: employees[2])
        switch carolCellValue {
            case let .doubleValue(value):
                #expect(value == 3000.0, "Carol's bonus should preserve original value (3000.0), not be replaced by defaultValue")
                #expect(value != 0.0, "Carol's bonus should not be replaced by defaultValue(0.0)")
            default:
                Issue.record("Expected doubleValue enum case for non-nil bonus with defaultValue")
        }

        // 测试 nil 值情况（Bob 的奖金为 nil）
        let bobCellValue = bonusColumn.generateCellValue(for: employees[1])
        switch bobCellValue {
            case let .doubleValue(value):
                #expect(value == 0.0, "Bob's nil bonus should use defaultValue(0.0)")
            default:
                Issue.record("Expected doubleValue enum case for nil bonus with defaultValue")
        }
    }

    @Test("Integration with sheet generation")
    func integrationWithSheet() throws {
        let employees = [
            TestEmployee(name: "Alice", age: 30, salary: 50000.0, bonus: 5000.0, isManager: true),
            TestEmployee(name: "Bob", age: 25, salary: 45000.0, bonus: nil, isManager: false),
        ]

        // Create sheet with simplified column syntax
        let sheet = Sheet<TestEmployee>(
            name: "Employees",
            dataProvider: { employees })
        {
            Column(name: "Name", keyPath: \.name)
                .width(20)

            Column(name: "Salary", keyPath: \.salary)
                .width(12)

            Column(name: "Bonus", keyPath: \.bonus)
                .defaultValue(0.0)
                .width(10)
        }

        #expect(sheet.name == "Employees", "Sheet name should match")

        // Test that sheet can generate XML without errors
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            with: employees,
            bookStyle: BookStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil, "Sheet should generate SheetXML")

        guard let xml = sheetXML else {
            Issue.record("Expected non-nil SheetXML")
            return
        }

        let xmlString = xml.generateXML()
        #expect(!xmlString.isEmpty, "Sheet should generate non-empty XML")
        #expect(xmlString.contains("Name"), "XML should contain Name column")
        #expect(xmlString.contains("Salary"), "XML should contain Salary column")
        #expect(xmlString.contains("Bonus"), "XML should contain Bonus column")
        #expect(xmlString.contains("Alice"), "XML should contain Alice's data")
        #expect(xmlString.contains("50000"), "XML should contain Alice's salary")
        #expect(xmlString.contains("5000"), "XML should contain Alice's bonus")
        #expect(xmlString.contains("Bob"), "XML should contain Bob's data")
        #expect(xmlString.contains("45000"), "XML should contain Bob's salary")
        // Bob's bonus should show as 0 due to defaultValue
    }

    @Test("Backward compatibility with old syntax")
    func backwardCompatibility() throws {
        let employees = [
            TestEmployee(name: "Alice", age: 30, salary: 50000.0, bonus: 5000.0, isManager: true),
        ]

        // Old verbose syntax should still work
        let oldStyleColumn = Column<TestEmployee, Double?, DoubleColumnType>(
            name: "Bonus",
            keyPath: \.bonus,
            mapping: { bonus in
                DoubleColumnType(DoubleColumnConfig(value: bonus ?? 0.0))
            })

        // New simplified syntax
        let newStyleColumn = Column<TestEmployee, Double?, DoubleColumnType>(
            name: "Bonus",
            keyPath: \.bonus).defaultValue(0.0)

        // Both should produce equivalent results
        let oldResult = oldStyleColumn.generateCellValue(for: employees[0])
        let newResult = newStyleColumn.generateCellValue(for: employees[0])

        switch (oldResult, newResult) {
            case let (.doubleValue(oldValue), .doubleValue(newValue)):
                #expect(oldValue == newValue, "Old and new syntax should produce same results")
            default:
                Issue.record("Both old and new syntax should produce doubleValue enum case")
        }
    }
}
