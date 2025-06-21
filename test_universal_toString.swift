#!/usr/bin/env swift

import Foundation

// 测试通用 toString 方法

struct Employee {
    let name: String
    let age: Int
    let salary: Double?  // Optional
    let isActive: Bool
}

// 模拟相关结构
struct DoubleColumnConfig {
    let value: Double?
    init(value: Double?) { self.value = value }
}

struct DoubleColumnType {
    let config: DoubleColumnConfig
    init(_ config: DoubleColumnConfig) { self.config = config }
}

struct IntColumnConfig {
    let value: Int?
    init(value: Int?) { self.value = value }
}

struct IntColumnType {
    let config: IntColumnConfig
    init(_ config: IntColumnConfig) { self.config = config }
}

struct BoolColumnConfig {
    let value: Bool?
    init(value: Bool?) { self.value = value }
}

struct BoolColumnType {
    let config: BoolColumnConfig
    init(_ config: BoolColumnConfig) { self.config = config }
}

struct TextColumnConfig {
    let value: String?
    init(value: String?) { self.value = value }
}

struct TextColumnType {
    let config: TextColumnConfig
    init(_ config: TextColumnConfig) { self.config = config }
}

// 简化的通用 toString 实现
struct Column<ObjectType, InputType, OutputType> {
    let name: String
    let keyPath: KeyPath<ObjectType, InputType>
    let mapping: (InputType) -> OutputType
    
    init(name: String, keyPath: KeyPath<ObjectType, InputType>, mapping: @escaping (InputType) -> OutputType) {
        self.name = name
        self.keyPath = keyPath
        self.mapping = mapping
    }
    
    // 通用 toString 方法
    func toString<T>(
        _ transform: @escaping (T?) -> String
    ) -> Column<ObjectType, InputType, TextColumnType> {
        Column<ObjectType, InputType, TextColumnType>(
            name: name,
            keyPath: keyPath,
            mapping: { input in
                let originalOutput = self.mapping(input)
                // 这里需要根据具体类型提取值，简化版本
                let rawValue: T? = {
                    if let doubleOutput = originalOutput as? DoubleColumnType {
                        return doubleOutput.config.value as? T
                    } else if let intOutput = originalOutput as? IntColumnType {
                        return intOutput.config.value as? T
                    } else if let boolOutput = originalOutput as? BoolColumnType {
                        return boolOutput.config.value as? T
                    }
                    return nil
                }()
                
                let stringValue = transform(rawValue)
                return TextColumnType(TextColumnConfig(value: stringValue))
            }
        )
    }
}

// 测试数据
let employees = [
    Employee(name: "Alice", age: 30, salary: 75000.0, isActive: true),
    Employee(name: "Bob", age: 25, salary: nil, isActive: false),
    Employee(name: "Carol", age: 17, salary: 45000.0, isActive: true)
]

print("🧪 测试通用 toString 方法")
print()

// 测试 1: Double? 类型 - 显式处理 nil
print("1️⃣ Double? 类型测试（显式处理 nil）:")
let salaryColumn = Column<Employee, Double?, DoubleColumnType>(
    name: "Salary Level",
    keyPath: \.salary,
    mapping: { DoubleColumnType(DoubleColumnConfig(value: $0)) }
).toString { (salary: Double?) -> String in
    guard let salary = salary else { return "No Salary" }
    return salary < 50000 ? "Standard" : "Premium"
}

for employee in employees {
    let result = salaryColumn.mapping(employee.salary)
    print("  \(employee.name): \(employee.salary?.description ?? "nil") -> \(result.config.value ?? "nil")")
}
print()

// 测试 2: Int 类型 - 非 Optional
print("2️⃣ Int 类型测试:")
let ageColumn = Column<Employee, Int, IntColumnType>(
    name: "Age Category",
    keyPath: \.age,
    mapping: { IntColumnType(IntColumnConfig(value: $0)) }
).toString { (age: Int?) -> String in
    guard let age = age else { return "Unknown Age" }
    return age < 18 ? "Minor" : "Adult"
}

for employee in employees {
    let result = ageColumn.mapping(employee.age)
    print("  \(employee.name): \(employee.age) -> \(result.config.value ?? "nil")")
}
print()

// 测试 3: Bool 类型
print("3️⃣ Bool 类型测试:")
let statusColumn = Column<Employee, Bool, BoolColumnType>(
    name: "Status",
    keyPath: \.isActive,
    mapping: { BoolColumnType(BoolColumnConfig(value: $0)) }
).toString { (isActive: Bool?) -> String in
    guard let isActive = isActive else { return "Unknown Status" }
    return isActive ? "Active Employee" : "Inactive Employee"
}

for employee in employees {
    let result = statusColumn.mapping(employee.isActive)
    print("  \(employee.name): \(employee.isActive) -> \(result.config.value ?? "nil")")
}

print()
print("🎉 通用 toString 测试完成！")
print()
print("✅ 主要改进:")
print("  - 不再强制将 nil 转换为默认值")
print("  - 支持任意类型的转换")
print("  - 用户可以自行决定如何处理 nil 值")
print("  - 类型约束移除，更加灵活")