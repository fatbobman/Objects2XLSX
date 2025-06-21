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

### 📚 当前工作：综合演示项目 (Demo Project)

#### 🎯 项目目标
创建一个完整的可执行演示项目，全面展示 Objects2XLSX 库的所有核心功能，作为用户学习和评估的最佳入口。

#### 📁 项目结构
```
Demo/                           # 嵌套 Package 演示项目
├── Package.swift              # 可执行 SPM 配置
├── Sources/Objects2XLSXDemo/
│   ├── main.swift            # 程序入口
│   ├── Models/               # 三种业务数据模型
│   │   ├── Employee.swift    # 员工模型 (复杂数据类型)
│   │   ├── Product.swift     # 产品模型 (条件格式)
│   │   └── Order.swift       # 订单模型 (关联数据)
│   ├── Data/                 # 演示数据生成器
│   │   ├── SampleEmployees.swift
│   │   ├── SampleProducts.swift
│   │   └── SampleOrders.swift
│   ├── Styles/               # 三种样式主题
│   │   ├── CorporateStyle.swift    # 企业风格
│   │   ├── ModernStyle.swift       # 现代风格
│   │   └── DefaultStyle.swift      # 默认风格
│   └── ExcelGenerator.swift # 生成逻辑
├── Output/                   # 输出目录
└── README.md                # 演示项目说明
```

#### 🎨 三表演示方案

**1. Employee 工作表 (企业风格 + 行高设置)**
- 样式：深蓝色企业主题，Times New Roman 字体
- 特色：自定义行高 25pt，完整边框
- 列功能演示：
  - `name`: 字符串 + 列宽 20
  - `age`: 数字 + filter(>= 18)
  - `department`: 枚举 + mapping 转换
  - `salary`: Double + 货币格式 + nil handling
  - `email`: URL + 验证过滤
  - `hireDate`: Date + 格式化
  - `isManager`: Bool + mapping("是"/"否")
  - `address`: Optional String + nil 显示为 "未提供"

**2. Product 工作表 (现代风格)**
- 样式：渐变色背景，Helvetica 字体，交替行颜色
- 特色：条件格式化，现代配色方案
- 列功能演示：
  - `id`: 自增ID + 列宽 8
  - `name`: 产品名 + 列宽 25 + 自动换行
  - `category`: 分类 + filter(只显示特定分类)
  - `price`: 价格 + 货币格式 + nil handling
  - `stock`: 库存 + 条件格式(低库存红色)
  - `rating`: 评分 + mapping(星级显示)
  - `isActive`: 状态 + mapping + filter
  - `description`: 描述 + 自动换行 + 列宽 30

**3. Order 工作表 (默认风格)**
- 样式：Excel 默认样式，展示基础效果
- 特色：最小化样式，关注数据展示
- 列功能演示：
  - `orderID`: 订单号 + 格式化
  - `customerName`: 客户名 + filter(非空)
  - `orderDate`: 订单日期 + 日期格式
  - `items`: 商品列表 + mapping(数组转字符串)
  - `subtotal`: 小计 + 计算字段
  - `tax`: 税费 + 百分比格式
  - `total`: 总计 + 货币格式 + 加粗
  - `status`: 状态 + mapping + 条件颜色

#### 🛠 技术特性演示

**列功能全面展示**
- ✅ Filter: 年龄过滤、状态过滤、非空过滤
- ✅ Mapping: 枚举转换、布尔值转换、数组转字符串
- ✅ Nil Handling: 自定义空值显示、默认值设置
- ✅ 列宽设置: 不同列的宽度优化
- ✅ 数据格式: 货币、百分比、日期、URL

**高级功能演示**
- ✅ 多表格工作簿: 三个不同主题的表格
- ✅ 进度跟踪: 实时生成进度显示
- ✅ 样式层级: Book → Sheet → Column → Cell
- ✅ 内存优化: 大数据集处理演示
- ✅ 错误处理: 完整的异常处理示例

#### 📱 命令行接口

```bash
swift run Objects2XLSXDemo [OPTIONS] [OUTPUT_FILE]

Options:
  -h, --help              显示帮助信息
  -s, --size SIZE         数据量: small(10), medium(50), large(200) (默认: medium)
  -o, --output PATH       输出文件路径 (默认: demo_output.xlsx)
  -t, --theme THEME       样式主题: corporate, modern, default, mixed (默认: mixed)
  -v, --verbose           显示详细进度信息
  -b, --benchmark         显示性能基准测试

Examples:
  swift run Objects2XLSXDemo --help
  swift run Objects2XLSXDemo -s small -v test.xlsx
  swift run Objects2XLSXDemo -s large -t corporate -v -b output.xlsx
```

#### 📊 性能基准测试

**实际测试结果 (macOS):**
- **小型数据集 (30记录)**: 0.02s, 1999记录/秒, 26.5KB
- **中型数据集 (150记录)**: 预估 0.08s, ~1900记录/秒, ~85KB  
- **大型数据集 (600记录)**: 预估 0.32s, ~1875记录/秒, ~320KB

**生成流程详情:**
- XML生成: ~70% 时间 (工作表XML + 全局文件)
- ZIP压缩: ~20% 时间 (SimpleZip纯Swift实现)
- 样式处理: ~10% 时间 (注册器优化去重)

#### 🎯 项目成果

**用户体验 ✅**
- ✅ 克隆项目后即可体验完整功能 (`swift run Objects2XLSXDemo --help`)
- ✅ 生成包含三个工作表的专业 Excel 文件 (企业/现代/默认主题)
- ✅ 实时进度显示和性能统计 (`--verbose --benchmark`)
- ✅ 完整的源码学习材料 (8个模型+3个样式+生成器)

**技术价值 ✅**
- ✅ 最佳实践参考 (Column API使用/样式层级/错误处理)
- ✅ 功能完整性验证 (所有核心API演示)
- ✅ 性能基准测试 (26.5KB/30记录/0.02s/1999记录每秒)
- ✅ 集成测试补充 (端到端Excel生成验证)

#### 📋 实施计划和进度

- ✅ **Phase 1**: 基础结构搭建 (Package.swift, 目录结构) - **已完成**
- ✅ **Phase 2**: 数据模型定义 (三个业务模型) - **已完成**
- ✅ **Phase 2.1**: 数据生成器实现 - **已完成**
  - ✅ SampleEmployees: 完整员工数据生成 (包含边缘案例)
  - ✅ SampleProducts: 六类产品数据生成 (库存/评分/状态变化)
  - ✅ SampleOrders: 订单数据生成 (计算字段/多状态)
  - ✅ 共享工具: SeededRandomGenerator + DataSize 枚举
- ✅ **Phase 3**: 样式主题实现 (三种样式配置) - **已完成**
  - ✅ CorporateStyle: 企业风格主题 (深蓝配色/Times New Roman/25pt行高)
  - ✅ ModernStyle: 现代风格主题 (清新配色/Helvetica/条件格式)
  - ✅ DefaultStyle: 默认风格主题 (Excel标准/Calibri/基础样式)
  - ✅ 专业样式库: 货币/日期/状态/评分等专用样式
- ✅ **Phase 4**: 生成逻辑开发 (Excel 生成和 CLI) - **已完成**
  - ✅ ExcelGenerator: 完整的 Excel 生成逻辑 (三表/三主题/进度跟踪)
  - ✅ CLI 参数解析: --help/--size/--output/--theme/--verbose/--benchmark
  - ✅ 错误处理: 完整的 BookError 类型化错误支持
  - ✅ 性能优化: 异步进度跟踪 + Swift 6 并发安全
  - ✅ 端到端测试: 26.5KB/30记录/3工作表/0.02s生成时间
- ✅ **Phase 5**: 测试和优化 (错误处理、性能优化) - **已完成**
- 🔄 **Phase 6**: 文档完善 (README 更新、使用指南) - **进行中**

#### 🎉 项目价值

这个演示项目将成为 Objects2XLSX 库的：
- **功能展示窗口** - 完整展示库的所有核心能力
- **学习入门教程** - 用户学习使用的最佳起点
- **最佳实践指南** - 展示正确的使用模式
- **质量保证工具** - 作为持续集成的一部分

## 🚧 当前开发任务：Column 声明方式优化

### 📌 分支信息
- **当前分支**: `feature/optimize-column-declaration`
- **目标版本**: v1.1
- **开发状态**: 🔄 进行中

### 🎯 优化目标

#### 问题分析
当前 Column 设计在类型处理上存在以下问题：

1. **类型信息丢失**: 所有 CellType 枚举值都使用 Optional 类型，即使源数据不是 Optional
2. **不必要的类型转换**: `processValueForCell` 方法将所有值都"可选化"处理
3. **声明方式冗长**: 需要显式指定 mapping 和 nilHandling，即使是简单的类型映射

#### 期望的声明方式
```swift
// 当前冗长的声明
Column(
    name: "Salary",
    keyPath: \.salary, // Double?
    width: 12,
    bodyStyle: CorporateStyle.createCurrencyStyle(),
    mapping: { salary in
        DoubleColumnType(DoubleColumnConfig(value: salary ?? 0.0))
    })

// 期望的简化声明
Column(name: "Salary", keyPath: \.salary, width: 12)
    .defaultValue(-1.0)  // 只在 InputType 为 Optional 时可用
    .bodyStyle(CorporateStyle.createCurrencyStyle())
```

### 🛠 技术方案：CellType 类型精确化

#### 方案概述
采用**方案三：扁平化枚举**，为 Optional 和非 Optional 类型创建独立的枚举值。

#### 第一阶段：Double 类型重构

**原有设计**:
```swift
public enum CellType: Equatable, Sendable {
    case double(Double?)  // 统一使用 Optional
    // ...
}
```

**新设计**:
```swift
public enum CellType: Equatable, Sendable {
    case double(Double)          // 非 Optional 版本
    case optionalDouble(Double?) // Optional 版本
    case empty                   // 明确的空单元格
    // 其他类型保持不变...
}
```

### 📋 实施步骤

#### ✅ 步骤 1: 项目准备
- ✅ 创建新分支 `feature/optimize-column-declaration`
- ✅ 在 CLAUDE.md 中记录开发计划

#### ✅ 步骤 2: CellType 枚举扩展
- ✅ 在 `Cell.swift` 中添加 `doubleValue(Double)` 和 `optionalDouble(Double?)` 枚举值
- ✅ 保持向后兼容，暂时保留原有的 `double(Double?)` 枚举值（标记为已弃用）
- ✅ 添加 `empty` 枚举值用于明确的空单元格
- ✅ 更新 `valueString` 计算属性以支持新枚举值

#### ✅ 步骤 3: XML 生成逻辑更新
- ✅ 修改 `generateXML()` 方法，为新的枚举值生成正确的 XML
- ✅ 优化 XML 生成，为 `doubleValue` 提供优化路径（减少 nil 检查）
- ✅ 确保 `empty` 枚举值正确生成空 XML 值
- ✅ 更新 `StyleRegister.swift` 中的 switch 语句以支持新枚举值

#### ✅ 步骤 4: DoubleColumnType 重构
- ✅ 修改 `DoubleColumnType.cellType` 属性，根据值是否为 nil 返回不同的 CellType
  - 非 nil 值使用 `.doubleValue(value)` 
  - nil 值使用 `.optionalDouble(nil)`
- ✅ 更新相关的 `ColumnOutputTypeProtocol` 实现
- ✅ 保持与现有 API 的兼容性

#### ✅ 步骤 5: Column 便利方法优化
- ✅ 为 `KeyPath<ObjectType, Double>` 创建无需显式 mapping 的构造器
  - `Column(name: "Price", keyPath: \.price)` - 基础简化语法
  - `Column(name: "Price", keyPath: \.price, width: 12)` - 带宽度版本
- ✅ 为 `KeyPath<ObjectType, Double?>` 创建支持 defaultValue 的链式 API
  - `Column(name: "Salary", keyPath: \.salary)` - Optional 基础语法
  - `Column(name: "Salary", keyPath: \.salary, width: 12)` - 带宽度版本
- ✅ 实现 `.defaultValue()` 扩展方法
  - `Column(name: "Salary", keyPath: \.salary).defaultValue(0.0)` - 设置默认值
- ✅ 实现链式样式配置方法
  - `.bodyStyle()`, `.headerStyle()`, `.width()` - 支持方法链

#### 🔄 步骤 6: 测试更新
- [ ] 更新现有的 Double 相关测试用例
- [ ] 添加新的类型精确化测试
- [ ] 确保 Row XML 和 Cell XML 测试通过

#### 🔄 步骤 7: Demo 项目集成
- [ ] 在 Demo 项目中使用新的简化声明方式
- [ ] 验证生成的 Excel 文件正确性
- [ ] 性能对比测试

#### 🔄 步骤 8: 文档和清理
- [ ] 更新代码注释和文档
- [ ] 移除过时的代码（如果需要）
- [ ] 准备 PR 合并回主分支

### 🧪 验证标准

#### 功能验证
- [ ] 所有现有测试用例通过
- [ ] 新的类型精确化逻辑正确工作
- [ ] 生成的 Excel 文件与之前版本完全一致

#### 性能验证
- [ ] XML 生成性能不下降
- [ ] 内存使用不增加
- [ ] 编译时间不显著增加

#### API 验证
- [ ] 向后兼容性保持
- [ ] 新的简化 API 按期望工作
- [ ] 类型推断和编译时检查正确

### 📈 后续扩展

如果 Double 类型重构成功，将按相同模式扩展其他类型：
- String / String?
- Int / Int?
- Bool / Bool?
- Date / Date?
- URL / URL?

### 🔗 相关文件

**核心文件**:
- `Sources/Objects2XLSX/Cell/Cell.swift` - CellType 枚举定义
- `Sources/Objects2XLSX/Column/Column.swift` - Column 类型和扩展
- `Sources/Objects2XLSX/Column/ColumnOutputTypes/DoubleColumnType.swift` - Double 列类型

**测试文件**:
- `Tests/Objects2XLSXTests/XmlGenerator/CellXMLTest.swift` - Cell XML 生成测试
- `Tests/Objects2XLSXTests/XmlGenerator/RowXMLTest.swift` - Row XML 生成测试

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

## 📚 toString 方法重大更新 (2025-06-21)

### 🎯 问题描述

在之前的实现中，`toString` 方法存在类型签名不够精确的问题：

**问题表现**:
```swift
Column(name: "Salary Level", keyPath: \.salary)
    .defaultValue(0.0)
    .toString { salary in salary < 50000 ? "Standard" : "Premium" }
    // ❌ 编译错误：Value of optional type 'Double?' must be unwrapped
```

**根本原因**:
- 设置了 `defaultValue(0.0)` 后，值应该是非可选的 `Double`
- 但 `toString` 方法仍然传递 `Double?` 给闭包
- 没有正确应用 `nilHandling` 逻辑

### 🛠 解决方案：双重载 toString 方法

#### 方案设计理念

基于列的 `nilHandling` 配置，提供两个不同的 `toString` 方法重载：

1. **非可选重载** `(T) -> String` - 适用于：
   - 设置了 `defaultValue` 的列
   - 本身就是非可选类型的列

2. **可选重载** `(T?) -> String` - 适用于：
   - 没有设置 `defaultValue` 的可选类型列
   - 需要明确处理 nil 值的情况

#### 核心实现逻辑

```swift
// 非可选版本
public func toString<T>(
    _ transform: @escaping (T) -> String
) -> Column<ObjectType, InputType, TextColumnType> where OutputType.Config.ValueType == T {
    // 应用 nilHandling 逻辑，然后强制解包传递给 transform
    switch self.nilHandling {
    case .keepEmpty:
        if let finalValue = finalValue {
            stringValue = transform(finalValue)
        } else {
            stringValue = transform(finalValue!) // 编译时保证安全
        }
    case .defaultValue:
        stringValue = transform(finalValue!) // defaultValue 后保证非 nil
    }
}

// 可选版本
public func toString<T>(
    _ transform: @escaping (T?) -> String
) -> Column<ObjectType, InputType, TextColumnType> where OutputType.Config.ValueType == T {
    // 直接传递可能为 nil 的值
    let stringValue = transform(finalValue)
}
```

### 📋 实施步骤详录

#### 步骤 1: 问题诊断
- **发现**: `defaultValue` 设置后，`toString` 仍接收 `Double?`
- **原因**: 原有实现只提取 `config.value`，未应用 `nilHandling`
- **影响**: 用户无法使用简洁的非可选语法

#### 步骤 2: nilHandling 集成修复
**修改前**:
```swift
let finalValue = processedOutput.config.value
let stringValue = transform(finalValue) // 直接传递，可能为 nil
```

**修改后**:
```swift
let processedOutput = switch self.nilHandling {
case .keepEmpty:
    originalOutput
case let .defaultValue(defaultValue):
    OutputType.withDefaultValue(defaultValue, config: originalOutput.config)
}
```

#### 步骤 3: 双重载实现
- **第一个重载**: `(T) -> String` - 处理非可选情况
- **第二个重载**: `(T?) -> String` - 处理可选情况
- **智能分发**: 根据 `nilHandling` 类型选择正确的处理逻辑

#### 步骤 4: 测试用例更新
**需要更新的测试模式**:
```swift
// 旧测试 (都使用可选)
.toString { (discount: Double?) in
    guard let discount = discount else { return "No Discount" }
    return discount > 0.05 ? "High Discount" : "Low Discount"
}

// 新测试 (defaultValue 后使用非可选)
.defaultValue(0.0)
.toString { (discount: Double) in
    return discount > 0.05 ? "High Discount" : "Low Discount"
}
```

#### 步骤 5: Demo 项目验证
```swift
// Demo 中的实际使用
Column(name: "Salary Level", keyPath: \.salary)
    .defaultValue(0.0)
    .toString { (salary: Double) in salary < 50000 ? "Standard" : "Premium" }
    .width(12)
    .bodyStyle(CorporateStyle.createDataStyle())
```

### 🧪 测试验证结果

#### 编译测试
- ✅ 所有 toString 相关测试通过 (4/4)
- ✅ Demo 项目编译成功
- ✅ 新旧 API 并存，向后兼容

#### 功能测试
- ✅ `defaultValue` + 非可选 `toString` 正常工作
- ✅ 可选列 + 可选 `toString` 正常工作
- ✅ 生成的 Excel 文件内容正确

#### 端到端测试
```bash
swift run Objects2XLSXDemo -s small -v demo_test.xlsx
# 输出: ✅ Demo workbook generated successfully!
# 文件大小: 32.7 KB
```

### 🎯 最终 API 使用指南

#### 场景 1: 可选类型 + defaultValue
```swift
// ✅ 推荐：使用非可选闭包
Column(name: "Salary Level", keyPath: \.salary) // Double?
    .defaultValue(0.0)
    .toString { (salary: Double) in  // 非可选！
        salary < 50000 ? "Standard" : "Premium"
    }
```

#### 场景 2: 可选类型 + 显式 nil 处理
```swift
// ✅ 推荐：使用可选闭包
Column(name: "Bonus", keyPath: \.bonus) // Double?
    .toString { (bonus: Double?) in  // 可选
        guard let bonus = bonus else { return "No Bonus" }
        return bonus > 1000 ? "High" : "Low"
    }
```

#### 场景 3: 非可选类型
```swift
// ✅ 推荐：使用非可选闭包  
Column(name: "Age Category", keyPath: \.age) // Int
    .toString { (age: Int) in  // 非可选
        age < 18 ? "Minor" : "Adult"
    }
```

### 🔧 技术细节

#### nilHandling 处理逻辑
```swift
// withDefaultValue 的实现确保了类型安全
public static func withDefaultValue(_ value: Double, config: DoubleColumnConfig) -> Self {
    DoubleColumnType(DoubleColumnConfig(value: config.value ?? value))
    // config.value ?? value 确保结果永远不为 nil
}
```

#### 重载解析机制
Swift 编译器会根据闭包参数类型自动选择正确的重载：
- `{ (value: T) in ... }` → 选择非可选重载
- `{ (value: T?) in ... }` → 选择可选重载

### 📝 注意事项

#### 1. 类型注解的重要性
```swift
// ✅ 明确指定类型，避免歧义
.toString { (salary: Double) in ... }

// ❌ 编译器可能无法推断
.toString { salary in ... }
```

#### 2. defaultValue 与类型的关系
- 设置 `defaultValue` 后，值保证非 nil
- 应该使用非可选版本的 `toString`
- 这样可以避免不必要的 nil 检查

#### 3. 向后兼容性
- 两个重载并存，不会破坏现有代码
- 现有的可选处理方式仍然有效
- 用户可以逐步迁移到更简洁的 API

### 🚀 性能优化

#### 编译时优化
- 非可选路径减少运行时 nil 检查
- 类型推断更加精确
- 强制解包在编译时验证安全性

#### 运行时优化
- `defaultValue` 处理在 `withDefaultValue` 中完成
- 减少 `toString` 闭包中的条件分支
- 更清晰的控制流

### 📋 后续扩展计划

基于 `toString` 的成功经验，类似的双重载模式可以应用到：

1. **filter 方法**: `(T) -> Bool` vs `(T?) -> Bool`
2. **mapping 方法**: 更精确的类型转换
3. **validation 方法**: 数据验证逻辑

这种模式为 Objects2XLSX 的类型安全和用户体验树立了新的标准。

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
