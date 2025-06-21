# Objects2XLSX Project Context

## 项目概述

Objects2XLSX 是一个 Swift 库，用于将对象数据导出为 Excel (.xlsx) 文件。通过类型安全的设计和灵活的配置选项，支持将 Swift 对象（如 Core Data、SwiftData 等）转换为格式化的 Excel 文件。

## 核心架构

### 主要组件

- **Book**: 对应 Excel 的 Workbook，包含多个工作表
- **Sheet<ObjectType>**: 泛型工作表，将特定类型的对象集合转换为表格数据
- **Column<ObjectType, InputType, OutputType>**: 定义对象属性到 Excel 列的映射
- **Cell**: 单元格，包含位置、值和样式信息
- **Row**: 行，包含多个单元格

### 样式系统

- **CellStyle**: 单元格样式（字体、填充、对齐、边框、数字格式）
- **SheetStyle**: 工作表样式（行高、列宽、冻结窗格、网格线等）
- **BookStyle**: 工作簿样式（主题、默认样式等）

### 注册器

- **StyleRegister**: 管理和去重样式，生成样式ID
- **ShareStringRegister**: 管理共享字符串，优化文件大小

## 当前开发状态

### ✅ 已完成功能

#### 核心架构
- ✅ 完整的样式系统实现
- ✅ XML 生成器（Cell、Row、Sheet、Font、Fill、Border、Alignment）
- ✅ 类型安全的列定义系统
- ✅ Builder 模式（SheetBuilder、ColumnBuilder）
- ✅ 数据类型支持（string、int、double、date、boolean、url、percentage）

#### 工作表生成
- ✅ 完整的 SheetXML 生成功能（表头 + 数据行）
- ✅ 数据行生成逻辑（generateDataRows、generateDataRow、generateDataCell）
- ✅ 样式合并和优先级处理（列样式 > 工作表样式 > 工作簿样式）
- ✅ 共享字符串支持（String 和 URL 类型）
- ✅ 自动边框区域计算和应用
- ✅ 简化的边框系统（DataBorderSettings）

#### 完整的 XLSX 生成流程
- ✅ **Book.write() 方法** - 完整的 XLSX 文件生成
- ✅ **XLSX 全局文件生成**（8个文件）：
  - ✅ `[Content_Types].xml` - 内容类型定义
  - ✅ `_rels/.rels` - 根关系文件
  - ✅ `docProps/app.xml` - 应用程序属性
  - ✅ `docProps/core.xml` - 核心属性
  - ✅ `xl/workbook.xml` - 工作簿定义文件
  - ✅ `xl/_rels/workbook.xml.rels` - 工作簿关系文件
  - ✅ `xl/styles.xml` - 样式定义文件
  - ✅ `xl/sharedStrings.xml` - 共享字符串文件
- ✅ **XLSX 文件打包逻辑** - SimpleZip 纯 Swift 实现
- ✅ **跨平台兼容性** - Linux/macOS 支持
- ✅ **线程安全的进度报告** - AsyncStream<BookGenerationProgress>

#### 高级功能
- ✅ **SimpleLogger 集成** - 灵活的日志系统
- ✅ **多工作表支持** - 任意数量的工作表
- ✅ **内存优化** - 流式处理大数据集
- ✅ **自动清理** - 临时文件管理
- ✅ **完整的错误处理** - 类型化错误系统

### 🎯 项目状态：**基础目标已完成**

Objects2XLSX 现在是一个功能完整的 Swift 库，可以：
1. 将任意 Swift 对象转换为 XLSX 文件
2. 支持自定义样式和格式
3. 生成符合 Office Open XML 标准的文件
4. 提供实时进度反馈
5. 跨平台运行（Linux/macOS）
6. 无外部依赖

## 项目约定

### 代码修改规则

- **只有在获得明确认可后，才能自动修改这个项目的代码**
- 所有代码修改建议应以示例代码形式提供
- 修改前需要说明修改的目的和影响

## 关键设计决策

### 类型安全

- 使用泛型确保编译时类型检查
- KeyPath 用于安全的属性访问
- 类型擦除（AnySheet、AnyColumn）支持异构集合

### 并发安全

- 使用 Swift 6 严格并发模式
- 所有公共类型实现 Sendable 协议
- 注意：Sheet 操作应在数据源的同一线程执行

### 样式优先级

1. 单元格级别样式（最高优先级）
2. 列级别样式
3. 工作表级别样式
4. 工作簿默认样式（最低优先级）

## 测试策略

- ✅ **单元测试** - 覆盖所有 XML 生成逻辑（223 个测试）
- ✅ **集成测试** - 验证完整的 XLSX 文件生成流程
- ✅ **ZIP 测试** - 验证纯 Swift ZIP 实现（17 个测试）
- ✅ **进度报告测试** - 验证 AsyncStream 功能
- ✅ **跨平台测试** - Linux/macOS 兼容性验证
- ✅ **大数据集测试** - 100+ 行数据性能验证

## 常用命令

```bash
# 运行测试
swift test

# 构建项目
swift build

# 生成 Xcode 项目
swift package generate-xcodeproj
```

## 注意事项

1. 行列索引从 1 开始（Excel 标准）
2. Sheet 名称会自动清理非法字符并限制长度
3. 大数据集需要考虑内存使用
4. 共享字符串用于优化文件大小（String 和 URL 类型自动注册）
5. 边框系统使用简化的 DataBorderSettings，支持自动区域计算

## 核心功能实现详情

### SheetXML 生成流程

1. **makeSheetXML()** - 主入口方法
   - 合并样式（Book + Sheet 样式）
   - 筛选有效列（activeColumns）
   - 自动计算数据区域和边框设置
   - 生成表头行和数据行

2. **表头生成** - generateHeaderRow()
   - 使用列名创建表头单元格
   - 应用表头样式（columnHeaderStyle）
   - 自动注册共享字符串

3. **数据行生成** - generateDataRows()
   - 遍历对象数据创建数据行
   - 应用列样式和工作表样式
   - 处理不同数据类型的单元格值

4. **单元格生成** - generateDataCell()
   - 样式合并（列 > 工作表 > 工作簿）
   - 自动应用数据边框
   - 共享字符串注册（String、URL）
   - 样式ID注册和分配

### 边框系统

- **DataBorderSettings**: 简化的边框配置
  - `enabled`: 是否启用边框
  - `includeHeader`: 是否包含表头
  - `borderStyle`: 边框样式（thin、medium、thick等）
- **自动区域计算**: 根据数据范围自动确定边框应用区域
- **位置智能**: 根据单元格在数据区域中的位置自动应用对应边框

### 共享字符串优化

- **支持类型**: String、URL
- **自动注册**: 生成单元格时自动检测并注册
- **去重优化**: 相同字符串只注册一次
- **XML引用**: 使用共享字符串ID替代直接字符串值

## 🎉 项目里程碑

### v1.0 基础功能（已完成）

✅ **完整的 XLSX 生成管道**
- 对象数据 → XML 生成 → ZIP 打包 → .xlsx 文件
- 支持任意 Swift 对象类型（Core Data、SwiftData、普通结构体等）

✅ **企业级功能**
- 多工作表支持
- 自定义样式系统
- 内存优化处理
- 错误处理和日志记录
- 实时进度报告

✅ **跨平台支持**
- 纯 Swift 实现
- 无外部依赖
- Linux/macOS 兼容性

## 🚀 Column API 优化历程

### v1.1 简化列声明语法（已完成）

#### 📋 背景问题
在 v1.0 版本中，用户需要手动编写复杂的列定义：

```swift
// v1.0 冗长语法
Column<Person, Double?, DoubleColumnType>(
    name: "Salary", 
    keyPath: \.salary,
    mapping: { salary in
        DoubleColumnType(DoubleColumnConfig(value: salary))
    }
)
```

#### 🎯 解决方案：简化构造方法
为常用数据类型添加了简化构造方法，支持类型推断：

```swift
// v1.1 简化语法
Column(name: "Salary", keyPath: \.salary)
    .defaultValue(0.0)
    .width(12)
    .bodyStyle(currencyStyle)
```

#### ✅ toString 方法类型安全优化

**核心问题**：`toString` 方法在设置 `defaultValue` 后仍然传递可选类型给闭包

```swift
// 问题代码
Column(name: "Salary Level", keyPath: \.salary)
    .defaultValue(0.0)
    .toString { salary in salary < 50000 ? "Standard" : "Premium" }
    //         ^^^^^^ 编译错误：Value of optional type 'Double?' must be unwrapped
```

**解决方案**：实现双重载 toString 方法
- `toString<T>(_ transform: @escaping (T) -> String)` - 用于 defaultValue 后的非可选值
- `toString<T>(_ transform: @escaping (T?) -> String)` - 用于 keepEmpty 的可选值

**关键实现**：
1. 在 `toString` 方法内部先应用 `nilHandling` 逻辑
2. 根据 `nilHandling` 类型选择正确的闭包签名
3. Swift 编译器根据闭包参数类型自动选择正确的重载

#### ✅ Int 类型完整支持

**第一阶段：基础 Int 支持**
- 添加简化构造方法：`Column(name: String, keyPath: KeyPath<ObjectType, Int>)`
- 添加可选 Int 支持：`Column(name: String, keyPath: KeyPath<ObjectType, Int?>)`
- 实现 `defaultValue(_ defaultValue: Int)` 方法

**第二阶段：toInt 转换方法**
- 实现双重载 `toInt` 方法，遵循 `toString` 的设计模式
- 支持从任意类型转换为 Int：`String -> Int`, `Double -> Int` 等

**第三阶段：CellType 类型安全**
发现关键问题：Int 类型缺少类型安全的 CellType 支持

**现有 Double 类型**：
- `case doubleValue(Double)` - 非可选
- `case optionalDouble(Double?)` - 可选  
- `case double(Double?)` - 已弃用

**需要补充 Int 类型**：
- `case intValue(Int)` - 非可选
- `case optionalInt(Int?)` - 可选
- `case int(Int?)` - 保持向后兼容

**完整实现**：
1. **CellType 枚举扩展**：添加 `intValue` 和 `optionalInt` cases
2. **XML 生成支持**：为新 cases 添加专门的 XML 生成逻辑
3. **IntColumnType 优化**：使用类型安全的 cellType，像 DoubleColumnType 一样
4. **StyleRegister 更新**：添加对新 Int cases 的支持
5. **withDefaultValue 修正**：确保正确保留非 nil 值

#### 🏗️ API 设计优化

**移除冗余构造方法**：
- 移除了带 `width` 参数的构造方法
- 将完整参数构造方法改为 `internal`
- 强制用户使用统一的链式调用风格

**优势**：
- **简化公共 API**：用户只需要记住基础构造方法
- **统一代码风格**：所有配置都通过链式调用
- **保持内部灵活性**：internal 构造方法仍可用于内部实现

#### 📊 当前支持状态

**✅ Double 类型（完整支持）**：
```swift
Column(name: "Price", keyPath: \.price)           // Double
Column(name: "Discount", keyPath: \.discount)     // Double?
    .defaultValue(0.0)
    .toString { price in "¥\(price)" }
    .toInt { price in Int(price.rounded()) }
```

**✅ Int 类型（完整支持）**：
```swift
Column(name: "Count", keyPath: \.count)           // Int  
Column(name: "Stock", keyPath: \.stock)           // Int?
    .defaultValue(0)
    .toString { count in "\(count) items" }
    .toInt { count in count * 2 }
```

**✅ String 类型（基础支持）**：
```swift
Column(name: "Name", keyPath: \.name)             // String
Column(name: "Note", keyPath: \.note)             // String?
```

#### 🎨 技术架构亮点

**类型安全保证**：
- 编译时类型检查：`defaultValue` 后的转换方法接收非可选类型
- 性能优化：非可选值使用专门的 CellType cases
- 一致性：Int 和 Double 有相同的 API 模式

**内存和性能优化**：
- `intValue(Int)` 和 `doubleValue(Double)` 避免可选值包装
- 专门的 XML 生成路径：`<v>\(String(int))</v>`
- 编译器内联优化机会

**代码组织**：
- **Column.swift**：核心定义和简化构造方法
- **Column+OptionalSupport.swift**：可选类型支持（defaultValue 等）
- **Column+TypeConversions.swift**：类型转换方法（toString, toInt 等）

#### 📈 使用效果对比

**v1.0 复杂语法**：
```swift
Column<Employee, Double?, DoubleColumnType>(
    name: "Salary Level",
    keyPath: \.salary,
    mapping: { salary in
        let processedSalary = salary ?? 0.0
        let level = processedSalary < 50000 ? "Standard" : "Premium" 
        return TextColumnType(TextColumnConfig(value: level))
    }
)
```

**v1.1 简洁语法**：
```swift
Column(name: "Salary Level", keyPath: \.salary)
    .defaultValue(0.0)
    .toString { salary in salary < 50000 ? "Standard" : "Premium" }
    .width(12)
    .bodyStyle(headerStyle)
```

**改进效果**：
- **代码行数**：从 8 行减少到 5 行
- **可读性**：从技术实现细节转为业务逻辑表达
- **类型安全**：编译时保证，无需手动 nil 检查
- **链式调用**：配置更加灵活和直观

#### 🎯 Demo 项目成果

Objects2XLSX 现在包含一个完整的可执行演示项目 (`Demo/`)，展示了所有核心功能：

**核心特性**
- ✅ 三表演示 (Employee/Product/Order) + 三种专业样式主题
- ✅ 完整的命令行接口 (`swift run Objects2XLSXDemo --help`)
- ✅ 实时进度跟踪和性能基准测试
- ✅ 26.5KB/30记录/0.02s 生成性能验证

**技术价值**
- ✅ 最佳实践参考和功能完整性验证
- ✅ 端到端集成测试补充
- ✅ 用户学习和评估的最佳入口

#### ✅ Int 类型完整支持（v1.1.1 更新）

继 Double 类型优化成功后，Int 类型现已获得完整的类型安全支持，遵循相同的设计模式：

**第一阶段：基础结构**
- ✅ 添加简化构造方法：`Column(name: String, keyPath: KeyPath<ObjectType, Int>)`
- ✅ 添加可选 Int 支持：`Column(name: String, keyPath: KeyPath<ObjectType, Int?>)`
- ✅ 实现 `defaultValue(_ defaultValue: Int)` 方法

**第二阶段：toInt 转换方法**
- ✅ 实现双重载 `toInt` 方法，遵循 `toString` 的设计模式
- ✅ 支持从任意类型转换为 Int：`String -> Int`, `Double -> Int` 等
- ✅ 类型安全：`defaultValue` 后的 `toInt` 接收非可选类型

**第三阶段：CellType 类型安全**
- ✅ 添加 `intValue(Int)` - 非可选整数，性能优化
- ✅ 添加 `optionalInt(Int?)` - 可选整数，完整兼容
- ✅ 保留 `int(Int?)` - 向后兼容，标记为传统用法

**第四阶段：系统集成**
- ✅ 更新 IntColumnType 使用类型安全的 cellType
- ✅ 修正 withDefaultValue 正确保留非 nil 值
- ✅ 更新 StyleRegister 支持新的 Int cases
- ✅ 完善 XML 生成专门路径：`<v>\(String(int))</v>`

#### 🎯 Int 类型 API 使用指南

**基础用法**：
```swift
// 非可选 Int
Column(name: "Count", keyPath: \.count)           // Int
    .width(8)
    .toString { count in "\(count) items" }

// 可选 Int + 默认值
Column(name: "Stock", keyPath: \.stock)           // Int?
    .defaultValue(0)
    .toInt { stock in stock * 2 }                 // 非可选！

// 可选 Int + 显式 nil 处理
Column(name: "Quantity", keyPath: \.quantity)     // Int?
    .toString { (quantity: Int?) in               // 可选
        quantity.map { "\($0) units" } ?? "N/A"
    }
```

**类型安全保证**：
- `defaultValue(0)` 后，所有转换方法接收 `Int` 而非 `Int?`
- 专门的 `intValue(Int)` CellType 避免不必要的可选值包装
- 编译时类型检查确保运行时安全

**性能优化**：
- 非可选路径：`intValue(Int)` → `<v>\(String(int))</v>`
- 减少 nil 检查和条件分支
- 编译器内联优化机会

### 后续发展方向

#### v1.1 增强功能（可选）
- 🔄 数据验证和约束
- 🔄 图表和图像支持
- 🔄 公式支持
- 🔄 条件格式化

#### v1.2 性能优化（可选）
- 🔄 并行处理支持
- 🔄 流式写入大文件
- 🔄 内存使用优化
- 🔄 压缩算法集成

#### v1.3 高级特性（可选）
- 🔄 模板系统
- 🔄 数据透视表
- 🔄 宏支持
- 🔄 密码保护

## 技术架构总览

### 完整的 XLSX 生成流程

```
Swift 对象 → Column 配置 → Sheet 数据处理
    ↓
XML 生成（工作表 + 全局文件）
    ↓
样式注册 + 共享字符串优化
    ↓
SimpleZip 打包（纯 Swift）
    ↓
.xlsx 文件输出
```

### 核心技术特性

#### 1. 类型安全设计
- 泛型工作表：`Sheet<ObjectType>`
- KeyPath 属性映射：安全的编译时检查
- 类型擦除：`AnySheet`、`AnyColumn` 支持异构集合

#### 2. 内存优化策略
- 流式处理：逐个工作表生成，避免全量内存占用
- 懒加载：`dataProvider` 闭包延迟数据获取
- 自动清理：临时文件系统管理

#### 3. 并发安全保证
- Swift 6 严格并发模式
- 所有公共类型实现 `Sendable`
- AsyncStream 线程安全进度报告

#### 4. 跨平台兼容性
- 纯 Swift ZIP 实现（SimpleZip）
- 无外部依赖（不依赖系统 zip 命令）
- 标准化路径处理

### 性能基准

| 数据规模 | 文件大小 | 生成时间 | 内存使用 |
|---------|---------|---------|---------|
| 10 行 × 3 列 | ~6KB | <10ms | 最小 |
| 100 行 × 3 列 | ~23KB | <50ms | 低 |
| 多工作表 | ~7KB | <20ms | 低 |

### 最佳实践

#### 1. 数据源设计
```swift
// ✅ 推荐：使用 dataProvider 闭包
let sheet = Sheet<Person>(name: "People", dataProvider: { 
    fetchPeopleData() // 延迟加载
}) {
    Column(name: "Name", keyPath: \.name)
}

// ❌ 避免：直接传递大数组
let largeArray = fetchAllData() // 立即占用内存
```

#### 2. 样式优化
```swift
// ✅ 推荐：复用样式对象
let headerStyle = CellStyle(font: Font(bold: true))
Column(name: "Name", keyPath: \.name).headerStyle(headerStyle)

// ✅ 推荐：使用工作表级样式
sheet.columnHeaderStyle(commonHeaderStyle)
```

#### 3. 错误处理
```swift
do {
    try book.write(to: outputURL)
} catch let error as BookError {
    // 处理具体的 XLSX 生成错误
} catch {
    // 处理其他系统错误
}
```

#### 🎯 数据类型支持现状

**✅ 完整支持（类型安全 + 转换方法）**：
- **Double/Double?**: 简化构造器 + defaultValue + toString/toInt
- **Int/Int?**: 简化构造器 + defaultValue + toString/toInt  
- **String/String?**: 基础简化构造器

**🔄 计划扩展（按需实现）**：
- Bool/Bool?, Date/Date?, URL/URL? 
- 通用转换系统 (toXXX 方法)

#### 🎯 核心设计模式

**类型安全保证**：
```swift
// 设置 defaultValue 后，转换方法接收非可选类型
Column(name: "Level", keyPath: \.salary)  // Double?
    .defaultValue(0.0)
    .toString { (salary: Double) in         // 非可选！
        salary < 50000 ? "Standard" : "Premium"
    }
```

**一致的 API 模式**：
```swift
// 所有数据类型遵循相同模式
Column(name: "Name", keyPath: \.name)       // String
Column(name: "Count", keyPath: \.count)     // Int  
Column(name: "Price", keyPath: \.price)     // Double?
    .defaultValue(0.0)
    .width(12)
    .bodyStyle(style)
```

## 使用示例

### 基础用法

```swift
import Objects2XLSX

// 1. 定义数据模型
struct Person: Sendable {
    let name: String
    let age: Int
    let salary: Double?  // 可选薪水
}

// 2. 准备数据
let people = [
    Person(name: "Alice", age: 25, salary: 75000.0),
    Person(name: "Bob", age: 30, salary: nil)
]

// 3. 创建工作表 - 使用新的 toString API
let sheet = Sheet<Person>(name: "People", dataProvider: { people }) {
    Column(name: "姓名", keyPath: \.name)
    
    Column(name: "年龄", keyPath: \.age)
        .toString { (age: Int) in age < 18 ? "未成年" : "成年" }
    
    // 可选薪水 + 默认值 = 非可选 toString
    Column(name: "薪资等级", keyPath: \.salary)
        .defaultValue(0.0)
        .toString { (salary: Double) in 
            salary < 50000 ? "标准" : "高级"
        }
    
    // 可选薪水 + 显式 nil 处理
    Column(name: "薪资状态", keyPath: \.salary)
        .toString { (salary: Double?) in
            guard let salary = salary else { return "未设置" }
            return "已设置: $\(Int(salary))"
        }
}

// 4. 创建工作簿并写入文件
let book = Book(style: BookStyle()) {
    sheet
}

try book.write(to: URL(fileURLWithPath: "/path/to/output.xlsx"))
```

### 进度监控

```swift
let book = Book(style: BookStyle()) { /* sheets */ }

// 监听进度
Task {
    for await progress in book.progressStream {
        print("进度: \(Int(progress.progressPercentage * 100))% - \(progress.description)")
        if progress.isFinal { break }
    }
}

// 异步生成文件
Task {
    try book.write(to: outputURL)
}
```

### 自定义样式与高级 toString

```swift
let headerStyle = CellStyle(
    font: Font(bold: true, size: 14),
    fill: Fill.solid(.blue),
    alignment: Alignment(horizontal: .center)
)

let sheet = Sheet<Person>(name: "Styled People", dataProvider: { people }) {
    Column(name: "姓名", keyPath: \.name)
        .headerStyle(headerStyle)
        .bodyStyle(CellStyle(alignment: Alignment(horizontal: .left)))
    
    // 复杂的 toString 逻辑
    Column(name: "综合评级", keyPath: \.salary)
        .defaultValue(0.0)
        .toString { (salary: Double) in
            switch salary {
            case 0..<30000: return "⭐"
            case 30000..<60000: return "⭐⭐"
            case 60000..<90000: return "⭐⭐⭐"
            default: return "⭐⭐⭐⭐"
            }
        }
        .width(15)
}
```
