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

## 项目状态

### 🎯 当前状态：**功能完整，持续优化**

Objects2XLSX 是一个功能完整的 Swift 库，具备：
1. 完整的 XLSX 生成流程（对象 → XML → ZIP → .xlsx）
2. 简化的列声明 API 和类型安全的数据转换
3. 多工作表支持和自定义样式系统
4. 跨平台兼容性（Linux/macOS）和 Swift 6 并发安全
5. 完整的演示项目和 340+ 测试用例

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

- ✅ **单元测试** - 340+ 测试覆盖所有核心组件
- ✅ **集成测试** - 验证完整的 XLSX 文件生成流程
- ✅ **演示项目** - 可执行的功能展示和性能验证
- ✅ **跨平台测试** - Linux/macOS 兼容性验证

## 常用命令

```bash
# 运行测试
swift test

# 构建项目
swift build

# 运行演示项目
swift run Objects2XLSXDemo --help
swift run Objects2XLSXDemo -s medium -v demo.xlsx
```

## 增强列 API

### 简化语法

新的 API 支持直观的列声明和链式配置：

```swift
let sheet = Sheet<Employee>(name: "Employees", dataProvider: { employees }) {
    // 基础列声明
    Column(name: "Name", keyPath: \.name)
    
    // 可选值 + 默认值
    Column(name: "Salary", keyPath: \.salary)
        .defaultValue(0.0)
        .width(12)
    
    // 类型转换
    Column(name: "Level", keyPath: \.salary)
        .defaultValue(0.0)
        .toString { salary in salary < 50000 ? "Standard" : "Premium" }
    
    // 布尔值自定义格式
    Column(name: "Manager", keyPath: \.isManager, booleanExpressions: .yesAndNo)
    
    // 日期时区支持
    Column(name: "Hire Date", keyPath: \.hireDate, timeZone: .utc)
}
```

### 支持的数据类型

**✅ 完整支持**：
- **String/String?**: 简化构造器 + defaultValue + toString
- **Double/Double?**: 简化构造器 + defaultValue + toString/toInt
- **Int/Int?**: 简化构造器 + defaultValue + toString/toInt
- **Bool/Bool?**: 简化构造器 + defaultValue + 自定义表达式
- **Date/Date?**: 简化构造器 + defaultValue + 时区支持
- **URL/URL?**: 简化构造器 + defaultValue
- **Percentage**: 精度控制和自定义格式

### 类型安全特性

```swift
// defaultValue 后，转换方法接收非可选类型
Column(name: "Category", keyPath: \.price)  // Double?
    .defaultValue(0.0)
    .toString { (price: Double) in          // 非可选！
        price < 50 ? "Budget" : "Premium"
    }

// keepEmpty 时，显式处理可选值
Column(name: "Status", keyPath: \.price)    // Double?
    .toString { (price: Double?) in         // 可选
        price.map { "¥\($0)" } ?? "未定价"
    }
```

## 注意事项

1. 行列索引从 1 开始（Excel 标准）
2. Sheet 名称会自动清理非法字符并限制长度
3. 大数据集需要考虑内存使用
4. 共享字符串用于优化文件大小（String 和 URL 类型自动注册）
5. 方法链式调用支持灵活的列配置

## 使用示例

### 基础用法

```swift
import Objects2XLSX

struct Person: Sendable {
    let name: String
    let age: Int
    let salary: Double?
}

let people = [
    Person(name: "Alice", age: 25, salary: 75000.0),
    Person(name: "Bob", age: 30, salary: nil)
]

let sheet = Sheet<Person>(name: "People", dataProvider: { people }) {
    Column(name: "姓名", keyPath: \.name)
    
    Column(name: "年龄分组", keyPath: \.age)
        .toString { age in age < 18 ? "未成年" : "成年" }
    
    Column(name: "薪资等级", keyPath: \.salary)
        .defaultValue(0.0)
        .toString { salary in salary < 50000 ? "标准" : "高级" }
}

let book = Book(style: BookStyle()) { sheet }
try book.write(to: URL(fileURLWithPath: "/path/to/output.xlsx"))
```

### 进度监控

```swift
let book = Book(style: BookStyle()) { /* sheets */ }

Task {
    for await progress in book.progressStream {
        print("进度: \(Int(progress.progressPercentage * 100))% - \(progress.description)")
        if progress.isFinal { break }
    }
}

Task {
    try book.write(to: outputURL)
}
```