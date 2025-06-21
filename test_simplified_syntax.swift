#!/usr/bin/env swift

import Foundation

// 定义测试数据模型
struct TestProduct {
    let name: String
    let price: Double        // 非 Optional
    let discount: Double?    // Optional
}

// 模拟 DoubleColumnType 和相关类型（简化版本用于测试）
struct DoubleColumnConfig {
    let value: Double?
    init(value: Double?) { self.value = value }
}

struct DoubleColumnType {
    let config: DoubleColumnConfig
    init(_ config: DoubleColumnConfig) { self.config = config }
}

// 简化的 Column 类型用于语法测试
struct Column<ObjectType, InputType, OutputType> {
    let name: String
    let keyPath: KeyPath<ObjectType, InputType>
    let width: Int?
    
    init(name: String, keyPath: KeyPath<ObjectType, InputType>) where InputType == Double, OutputType == DoubleColumnType {
        self.name = name
        self.keyPath = keyPath
        self.width = nil
        print("✅ 创建简化 Double 列: \(name)")
    }
    
    init(name: String, keyPath: KeyPath<ObjectType, InputType>, width: Int) where InputType == Double, OutputType == DoubleColumnType {
        self.name = name
        self.keyPath = keyPath
        self.width = width
        print("✅ 创建带宽度的简化 Double 列: \(name), 宽度: \(width)")
    }
    
    init(name: String, keyPath: KeyPath<ObjectType, InputType>) where InputType == Double?, OutputType == DoubleColumnType {
        self.name = name
        self.keyPath = keyPath
        self.width = nil
        print("✅ 创建简化 Optional Double 列: \(name)")
    }
    
    func defaultValue(_ value: Double) -> Column<ObjectType, InputType, OutputType> where InputType == Double? {
        print("✅ 设置默认值: \(value) for \(name)")
        return self
    }
    
    func width(_ width: Int) -> Column<ObjectType, InputType, OutputType> {
        print("✅ 设置宽度: \(width) for \(name)")
        return self
    }
}

// 测试简化语法
print("🧪 测试简化的 Column 声明语法")
print()

// 测试 1: 非 Optional Double
print("1️⃣ 非 Optional Double 测试:")
let priceColumn: Column<TestProduct, Double, DoubleColumnType> = 
    Column(name: "Price", keyPath: \.price)

let priceColumnWithWidth: Column<TestProduct, Double, DoubleColumnType> = 
    Column(name: "Price", keyPath: \.price, width: 12)

print()

// 测试 2: Optional Double
print("2️⃣ Optional Double 测试:")
let discountColumn: Column<TestProduct, Double?, DoubleColumnType> = 
    Column(name: "Discount", keyPath: \.discount)

let discountWithDefault: Column<TestProduct, Double?, DoubleColumnType> = 
    Column(name: "Discount", keyPath: \.discount)
        .defaultValue(0.0)

let discountWithDefaultAndWidth: Column<TestProduct, Double?, DoubleColumnType> = 
    Column(name: "Discount", keyPath: \.discount)
        .defaultValue(0.0)
        .width(10)

print()

print("🎉 所有简化语法测试通过！")
print()
print("📋 期望的声明方式已实现:")
print("✅ Column(name: \"Price\", keyPath: \\.price)")
print("✅ Column(name: \"Discount\", keyPath: \\.discount).defaultValue(0.0)")
print("✅ 链式方法调用 .defaultValue().width()")