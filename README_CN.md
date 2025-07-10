# Objects2XLSX

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/fatbobman/Objects2XLSX)

**语言**: [English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md)

一个强大且类型安全的 Swift 库，用于将 Swift 对象转换为 Excel (.xlsx) 文件。Objects2XLSX 提供现代化的声明式 API，支持完整的样式设置、多工作表和实时进度跟踪，可创建专业的 Excel 电子表格。

## ✨ 特性

### 🎯 **类型安全设计**

- **泛型工作表**：`Sheet<ObjectType>` 提供编译时类型安全
- **KeyPath 集成**：通过 `\.propertyName` 直接映射属性
- **Swift 6 兼容**：完整支持 Swift 的严格并发模型

### 📊 **全面的 Excel 支持**

- **Excel 标准兼容**：生成的 XLSX 文件严格符合 Excel 规范，无警告或兼容性问题
- **增强的列 API**：简化的、类型安全的列声明，具有自动类型推断
- **智能空值处理**：`.defaultValue()` 方法优雅处理可选值
- **类型转换**：强大的 `.toString()` 方法用于自定义数据转换
- **多种数据类型**：String、Int、Double、Bool、Date、URL 和 Percentage，完全支持可选类型
- **完整样式系统**：字体、颜色、边框、填充、对齐和数字格式化
- **多工作表**：创建包含无限工作表的工作簿
- **方法链式调用**：流畅的 API 结合宽度、样式和数据转换

### 🎨 **高级样式**

- **专业外观**：丰富的格式选项，媲美 Excel 的功能
- **样式层次**：Book → Sheet → Column → Cell 的样式优先级
- **自定义主题**：在文档中创建一致的样式
- **边框管理**：精确的边框控制，自动区域检测

### 🚀 **性能与可用性**

- **标准兼容**：生成的文件可在 Excel、Numbers、Google Sheets 和 LibreOffice 中无缝打开，无警告
- **异步数据支持**：通过 `@Sendable` 异步数据提供器支持安全的跨线程数据获取
- **内存高效**：基于流的处理，适用于大型数据集
- **进度跟踪**：通过 AsyncStream 实时进度更新
- **跨平台**：支持 macOS、iOS、tvOS、watchOS 和 Linux 的纯 Swift 实现
- **零依赖**：除可选的 SimpleLogger 外无外部依赖

### 🛠 **开发者体验**

- **简化 API**：直观的、可链式调用的列声明，具有自动类型推断
- **实时演示项目**：展示库所有功能的综合示例
- **构建器模式**：用于创建工作表和列的声明式 DSL
- **全面文档**：详细的 API 文档和实际示例
- **广泛测试**：340+ 测试确保所有核心组件的可靠性
- **SwiftFormat 集成**：通过 Git hooks 保持一致的代码格式

## 📋 系统要求

- **Swift**: 6.0+
- **iOS**: 15.0+
- **macOS**: 12.0+
- **tvOS**: 15.0+
- **watchOS**: 8.0+
- **Linux**: Ubuntu 20.04+ (需要 Swift 6.0+)

> **注意**：当前测试涵盖 iOS 15+ 和 macOS 12+。如果您有条件在更早的系统版本上进行测试，请告诉我们，以便我们相应调整最低版本要求。

## 📦 安装

### Swift Package Manager

使用 Xcode 的 Package Manager 或在 `Package.swift` 中添加 Objects2XLSX：

```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/Objects2XLSX.git", from: "1.2.1")
]
```

然后添加到目标：

```swift
.target(
    name: "YourTarget",
    dependencies: ["Objects2XLSX"]
)
```

## 🚀 快速开始

### 基本用法

```swift
import Objects2XLSX

// 1. 定义数据模型
struct Person: Sendable {
    let name: String
    let age: Int
    let email: String
}

// 2. 准备数据
let people = [
    Person(name: "张三", age: 28, email: "zhangsan@example.com"),
    Person(name: "李四", age: 35, email: "lisi@example.com"),
    Person(name: "王五", age: 42, email: "wangwu@example.com")
]

// 3. 创建具有类型安全列的工作表
let sheet = Sheet<Person>(name: "员工", dataProvider: { people }) {
    Column(name: "姓名", keyPath: \.name)
    Column(name: "年龄", keyPath: \.age)
    Column(name: "邮箱", keyPath: \.email)
}

// 4. 创建工作簿并生成 Excel 文件
let book = Book(style: BookStyle()) {
    sheet
}

let outputURL = URL(fileURLWithPath: "/path/to/employees.xlsx")
try book.write(to: outputURL)
```

### 异步数据提供器（新功能！）

Objects2XLSX 现在支持异步数据获取，实现与 Core Data、SwiftData 和 API 调用的线程安全操作：

```swift
import Objects2XLSX

// 定义 Sendable 数据传输对象
struct PersonData: Sendable {
    let name: String
    let department: String
    let salary: Double
    let hireDate: Date
}

// 创建具有异步获取功能的数据服务
class DataService {
    private let persistentContainer: NSPersistentContainer
    
    @Sendable
    func fetchEmployees() async -> [PersonData] {
        await withCheckedContinuation { continuation in
            // 在 Core Data 的线程中执行
            persistentContainer.viewContext.perform {
                let employees = // ... 获取 Core Data 对象
                
                // 转换为 Sendable 对象
                let data = employees.map { employee in
                    PersonData(
                        name: employee.name ?? "",
                        department: employee.department?.name ?? "",
                        salary: employee.salary,
                        hireDate: employee.hireDate ?? Date()
                    )
                }
                continuation.resume(returning: data)
            }
        }
    }
}

// 创建具有异步数据提供器的工作表
let dataService = DataService(persistentContainer: container)

let sheet = Sheet<PersonData>(
    name: "异步员工",
    asyncDataProvider: dataService.fetchEmployees  // 🚀 异步且线程安全！
) {
    Column(name: "姓名", keyPath: \.name)
    Column(name: "部门", keyPath: \.department)
    Column(name: "薪资", keyPath: \.salary)
    Column(name: "入职日期", keyPath: \.hireDate)
}

let book = Book(style: BookStyle()) { sheet }

// 异步生成 Excel 文件
let outputURL = try await book.writeAsync(to: URL(fileURLWithPath: "/path/to/report.xlsx"))
```

**主要优势：**
- ✅ **线程安全**：数据获取在正确的线程上下文中进行
- ✅ **类型安全**：`@Sendable` 约束确保安全的数据传输
- ✅ **混合数据源**：在同一工作簿中结合同步和异步工作表
- ✅ **进度跟踪**：完整的异步进度监控支持

### 尝试实时演示

体验我们综合演示项目的所有功能：

```bash
# 克隆仓库
git clone https://github.com/fatbobman/Objects2XLSX.git
cd Objects2XLSX

# 运行不同选项的演示
swift run Objects2XLSXDemo --help
swift run Objects2XLSXDemo -s medium -v demo.xlsx
swift run Objects2XLSXDemo -s large -t mixed -v -b output.xlsx
```

演示生成包含三个工作表的专业 Excel 工作簿，展示：

- **员工数据** - 企业样式和数据转换
- **产品目录** - 现代样式和条件格式
- **订单历史** - 默认样式和计算字段

**演示功能：**

- 🎨 三种专业样式主题（企业、现代、默认）
- 📊 多种数据大小（小：30，中：150，大：600 条记录）
- 🔧 演示所有列类型和高级功能
- ⚡ 实时进度跟踪和性能基准
- 📁 可直接打开的 Excel 文件展示库功能

### 多种数据类型和增强列 API

Objects2XLSX 具有简化的、类型安全的列 API，自动处理各种 Swift 数据类型：

```swift
struct Employee: Sendable {
    let name: String
    let age: Int
    let salary: Double?        // 可选薪资
    let bonus: Double?         // 可选奖金
    let isManager: Bool
    let hireDate: Date
    let profileURL: URL?       // 可选个人资料 URL
}

let employees = [
    Employee(
        name: "张三",
        age: 30,
        salary: 75000.50,
        bonus: nil,           // 本期无奖金
        isManager: true,
        hireDate: Date(),
        profileURL: URL(string: "https://company.com/profiles/zhangsan")
    )
]

let sheet = Sheet<Employee>(name: "员工", dataProvider: { employees }) {
    // 简单的非可选列
    Column(name: "姓名", keyPath: \.name)
    Column(name: "年龄", keyPath: \.age)
    
    // 带默认值的可选列
    Column(name: "薪资", keyPath: \.salary)
        .defaultValue(0.0)
        .width(12)
    
    Column(name: "奖金", keyPath: \.bonus)
        .defaultValue(0.0)
        .width(10)
    
    // 布尔和日期列
    Column(name: "经理", keyPath: \.isManager, booleanExpressions: .yesAndNo)
    Column(name: "入职日期", keyPath: \.hireDate, timeZone: .current)
    
    // 带默认值的可选 URL
    Column(name: "个人资料", keyPath: \.profileURL)
        .defaultValue(URL(string: "https://company.com/default")!)
}
```

## 🔧 增强列功能

### 简化列声明

新 API 提供直观的、类型安全的列创建，具有自动类型推断：

```swift
struct Product: Sendable {
    let id: Int
    let name: String
    let price: Double?
    let discount: Double?
    let stock: Int?
    let isActive: Bool?
}

let sheet = Sheet<Product>(name: "产品", dataProvider: { products }) {
    // 非可选列（简单语法）
    Column(name: "ID", keyPath: \.id)
    Column(name: "产品名称", keyPath: \.name)
    
    // 带默认值的可选列
    Column(name: "价格", keyPath: \.price)
        .defaultValue(0.0)
    
    Column(name: "库存", keyPath: \.stock)
        .defaultValue(0)
    
    Column(name: "激活", keyPath: \.isActive)
        .defaultValue(true)
}
```

### 高级类型转换

使用强大的 `toString` 方法转换列数据：

```swift
let sheet = Sheet<Product>(name: "产品", dataProvider: { products }) {
    // 将价格范围转换为类别
    Column(name: "价格类别", keyPath: \.price)
        .defaultValue(0.0)
        .toString { (price: Double) in
            switch price {
            case 0..<50: "经济型"
            case 50..<200: "中档"
            default: "高端"
            }
        }
    
    // 将库存水平转换为状态
    Column(name: "库存状态", keyPath: \.stock)
        .defaultValue(0)
        .toString { (stock: Int) in
            stock == 0 ? "缺货" : 
            stock < 10 ? "库存不足" : "有库存"
        }
    
    // 将可选折扣转换为显示格式
    Column(name: "折扣信息", keyPath: \.discount)
        .toString { (discount: Double?) in
            guard let discount = discount else { return "无折扣" }
            return String(format: "%.0f%% 折扣", discount * 100)
        }
}
```

### 灵活的空值处理

控制如何处理可选值：

```swift
let sheet = Sheet<Employee>(name: "员工", dataProvider: { employees }) {
    // 选项 1：使用默认值
    Column(name: "薪资", keyPath: \.salary)
        .defaultValue(0.0)  // nil 变为 0.0
    
    // 选项 2：保持空单元格（默认行为）
    Column(name: "奖金", keyPath: \.bonus)
        // nil 值将显示为空单元格
    
    // 选项 3：使用自定义空值处理进行转换
    Column(name: "薪资等级", keyPath: \.salary)
        .toString { (salary: Double?) in
            guard let salary = salary else { return "未指定" }
            return salary > 50000 ? "高级" : "标准"
        }
}
```

### 方法链式调用

优雅地组合多个配置：

```swift
let sheet = Sheet<Employee>(name: "员工", dataProvider: { employees }) {
    Column(name: "薪资等级", keyPath: \.salary)
        .defaultValue(0.0)                    // 处理 nil 值
        .toString { $0 > 50000 ? "高级" : "初级" }  // 转换为类别
        .width(15)                            // 设置列宽
        .bodyStyle(CellStyle(                 // 应用样式
            font: Font(bold: true),
            fill: Fill.solid(.lightBlue)
        ))
}
```

## 🎨 样式与格式化

### 专业样式

```swift
// 创建自定义标题样式
let headerStyle = CellStyle(
    font: Font(size: 14, name: "Arial", bold: true, color: .white),
    fill: Fill.solid(.blue),
    alignment: Alignment(horizontal: .center, vertical: .center),
    border: Border.all(style: .thin, color: .black)
)

// 创建数据单元格样式
let dataStyle = CellStyle(
    font: Font(size: 11, name: "Calibri"),
    alignment: Alignment(horizontal: .left, wrapText: true),
    border: Border.outline(style: .thin, color: .gray)
)

// 使用增强 API 将样式应用到工作表
let styledSheet = Sheet<Person>(name: "样式员工", dataProvider: { people }) {
    Column(name: "姓名", keyPath: \.name)
        .width(20)
        .headerStyle(headerStyle)
        .bodyStyle(dataStyle)
    
    Column(name: "年龄", keyPath: \.age)
        .width(8)
        .headerStyle(headerStyle)
        .bodyStyle(CellStyle(alignment: Alignment(horizontal: .center)))
}
```

### 颜色自定义

```swift
// 预定义颜色
let redFill = Fill.solid(.red)
let blueFill = Fill.solid(.blue)

// 自定义颜色
let customColor = Color(red: 255, green: 128, blue: 0) // 橙色
let hexColor = Color(hex: "#FF5733") // 十六进制字符串
let transparentColor = Color(red: 255, green: 0, blue: 0, alpha: .medium) // 50% 透明红色

// 渐变填充（高级）
let gradientFill = Fill.gradient(
    .linear(angle: 90),
    colors: [.blue, .white, .red]
)
```

## 📈 多工作表

为不同数据类型创建包含多个工作表的工作簿：

```swift
struct Customer: Sendable {
    let name: String
    let email: String?
    let registrationDate: Date
}

// 使用增强 API 创建多个工作表
let customersSheet = Sheet<Customer>(name: "客户", dataProvider: { customers }) {
    Column(name: "客户姓名", keyPath: \.name)
        .width(25)
    
    Column(name: "邮箱", keyPath: \.email)
        .defaultValue("no-email@company.com")
        .width(30)
    
    Column(name: "注册日期", keyPath: \.registrationDate)
        .width(15)
}

// 在工作簿中合并工作表
let book = Book(style: BookStyle()) {
    productsSheet
    customersSheet
}

try book.write(to: outputURL)
```

## 📊 进度跟踪

监控同步和异步操作的 Excel 生成进度：

```swift
let book = Book(style: BookStyle()) {
    // 混合同步和异步工作表
    Sheet<Product>(name: "产品", dataProvider: { products }) {
        Column(name: "名称", keyPath: \.name)
        Column(name: "价格", keyPath: \.price)
    }
    
    Sheet<Employee>(name: "员工", asyncDataProvider: fetchEmployeesAsync) {
        Column(name: "姓名", keyPath: \.name)
        Column(name: "部门", keyPath: \.department)
    }
}

// 监控进度
Task {
    for await progress in book.progressStream {
        print("进度: \(Int(progress.progressPercentage * 100))%")
        print("当前步骤: \(progress.description)")
        
        if progress.isFinal {
            print("✅ Excel 文件生成完成！")
            break
        }
    }
}

// 同步生成文件
Task {
    do {
        try book.write(to: outputURL)
        print("📁 文件已保存到: \(outputURL.path)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 或异步生成文件（支持异步数据提供器）
Task {
    do {
        let outputURL = try await book.writeAsync(to: outputURL)
        print("📁 异步文件已保存到: \(outputURL.path)")
    } catch {
        print("❌ 错误: \(error)")
    }
}
```

## 🔧 高级配置

### 工作目录管理

Objects2XLSX 提供灵活控制 XLSX 生成过程中临时工作文件存储位置的功能。这在处理临时目录时特别有用，可避免文件系统污染：

```swift
// 默认行为 - 工作目录在输出文件旁边
try book.write(to: outputURL)
// 输出：/path/to/report.xlsx
// 工作目录：/path/to/report.temp/

// 系统临时目录 - 推荐用于临时输出
try book.write(to: outputURL, workingDirectory: .systemTemp)
// 输出：/path/to/report.xlsx
// 工作目录：/tmp/Objects2XLSX_UUID/

// 自定义工作目录
let workspaceURL = URL(fileURLWithPath: "/custom/workspace")
try book.write(to: outputURL, workingDirectory: .custom(workspaceURL))
// 输出：/path/to/report.xlsx
// 工作目录：/custom/workspace/Objects2XLSX_UUID/
```

**临时目录使用最佳实践：**

```swift
extension Book {
    /// 智能写入，自动选择合适的工作目录
    func writeSmartly(to url: URL) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        
        if url.path.hasPrefix(tempDir.path) {
            // 输出在临时目录 - 使用隔离工作空间
            return try write(to: url, workingDirectory: .systemTemp)
        } else {
            // 输出在常规目录 - 使用默认行为
            return try write(to: url)
        }
    }
}

// 使用示例
let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let tempURL = FileManager.default.temporaryDirectory

// ✅ 好：文档目录使用默认行为
try book.write(to: documentsURL.appendingPathComponent("report.xlsx"))

// ✅ 好：临时目录使用隔离工作空间
try book.write(
    to: tempURL.appendingPathComponent("report.xlsx"), 
    workingDirectory: .systemTemp
)

// ✅ 好：智能自动选择
try book.writeSmartly(to: outputURL)
```

**工作目录策略：**

- **`.alongsideOutput`（默认）**：在输出文件旁创建 `.temp` 文件夹
  - ✅ 适用于：文档、下载、自定义目录
  - ⚠️ 避免用于：系统临时目录（会造成污染）

- **`.systemTemp`**：使用隔离的临时目录
  - ✅ 适用于：系统临时目录中的任何输出
  - ✅ 防止：临时目录结构污染
  - 🚀 推荐：当输出路径以临时目录开头时

- **`.custom(URL)`**：使用指定目录存放工作文件
  - ✅ 适用于：自定义构建系统、特定工作空间要求
  - 🔧 控制：完全控制工作文件位置

### 异步数据加载与线程安全

Objects2XLSX 为复杂场景提供线程安全的异步数据加载：

```swift
// 线程安全的异步数据获取
class EmployeeDataService {
    private let coreDataStack: CoreDataStack
    
    @Sendable
    func fetchEmployeesAsync() async -> [EmployeeData] {
        await withCheckedContinuation { continuation in
            // 切换到 Core Data 的线程
            coreDataStack.viewContext.perform {
                do {
                    let request: NSFetchRequest<Employee> = Employee.fetchRequest()
                    let employees = try self.coreDataStack.viewContext.fetch(request)
                    
                    // 转换为 Sendable DTO
                    let employeeData = employees.map { EmployeeData(from: $0) }
                    continuation.resume(returning: employeeData)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }
}

// 使用异步数据提供器
let service = EmployeeDataService(coreDataStack: stack)

let book = Book(style: BookStyle()) {
    // 同步工作表
    Sheet<Product>(name: "产品", dataProvider: { loadProducts() }) {
        Column(name: "名称", keyPath: \.name)
        Column(name: "价格", keyPath: \.price)
    }
    
    // 异步工作表 - 在 Core Data 线程中获取数据
    Sheet<EmployeeData>(name: "员工", asyncDataProvider: service.fetchEmployeesAsync) {
        Column(name: "姓名", keyPath: \.name)
        Column(name: "部门", keyPath: \.department)
        Column(name: "薪资", keyPath: \.salary)
    }
}

// 使用异步支持生成
let outputURL = try await book.writeAsync(to: URL(fileURLWithPath: "/path/to/report.xlsx"))
```

**线程安全指南：**

- ✅ **在任何线程创建 Book** - Book 创建是线程安全的
- ✅ **在正确上下文中获取数据** - 异步提供器处理线程切换
- ✅ **混合同步/异步工作表** - 无缝结合两种类型
- ⚠️ **对异步提供器使用 `writeAsync()`** - 确保正确的异步数据加载

## 📋 要求

- **Swift 6.0+**
- **平台**: macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, Linux
- **依赖**: 无（除可选的 SimpleLogger 用于日志记录）

## 👨‍💻 作者

**Fatbobman (东坡肘子)**

- 博客: [https://fatbobman.com](https://fatbobman.com)
- GitHub: [@fatbobman](https://github.com/fatbobman)
- X: [@fatbobman](https://x.com/fatbobman)
- LinkedIn: [@fatbobman](https://www.linkedin.com/in/fatbobman/)
- Mastodon: [@fatbobman@mastodon.social](https://mastodon.social/@fatbobman)
- BlueSky: [@fatbobman.com](https://bsky.app/profile/fatbobman.com)

### 📰 保持联系

不要错过关于 Swift、SwiftUI、Core Data 和 SwiftData 的最新更新和优秀文章。订阅 **[Fatbobman's Swift Weekly](https://weekly.fatbobman.com)**，每周在你的收件箱中获得深入见解和有价值的内容。

## 💖 支持项目

如果你觉得 Objects2XLSX 有用并想支持其持续开发：

- [☕️ Buy Me A Coffee](https://buymeacoffee.com/fatbobman) - 通过小额捐赠支持开发
- [💳 PayPal](https://www.paypal.com/paypalme/fatbobman) - 替代捐赠方式

你的支持有助于维护和改进这个开源项目。谢谢！🙏

## 📄 许可证

Objects2XLSX 在 Apache License 2.0 下发布。详见 [LICENSE](LICENSE)。

### 第三方依赖

此项目包含以下第三方软件：

- **[SimpleLogger](https://github.com/fatbobman/SimpleLogger)** - MIT License
  - 适用于 Swift 的轻量级日志库
  - 版权所有 (c) 2024 Fatbobman

## 🙏 致谢

- 使用 Swift 6 的现代并发功能用❤️构建
- 受 Swift 中类型安全 Excel 生成需求的启发
- 感谢 Swift 社区的反馈和贡献

## 📖 文档

要获得详细的 API 文档、示例和高级使用模式，请探索库附带的综合 DocC 文档。导入包后可以直接在 Xcode 中访问它，或使用以下命令本地构建：

```bash
swift package generate-documentation --target Objects2XLSX
```

该库包含所有公共 API 的广泛内联文档，包含使用示例和最佳实践。

---

**由 Swift 社区用❤️制作**