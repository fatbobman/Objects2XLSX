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

### 已完成功能

- ✅ 完整的样式系统实现
- ✅ XML 生成器（Cell、Row、Sheet、Font、Fill、Border、Alignment）
- ✅ 类型安全的列定义系统
- ✅ Builder 模式（SheetBuilder、ColumnBuilder）
- ✅ 数据类型支持（string、int、double、date、boolean、url、percentage）

### 待实现功能

- ❌ Book.write() 方法 - 生成实际的 XLSX 文件
- ❌ Sheet.makeSheetData() 方法 - 将对象转换为 SheetXML
- ❌ XLSX 文件打包逻辑
- ❌ 必需的 Excel 文件组件（workbook.xml、styles.xml、sharedStrings.xml 等）

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

- 单元测试覆盖 XML 生成逻辑
- 集成测试验证完整的文件生成流程（待实现）
- 性能测试确保大数据集处理能力（待实现）

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
4. 共享字符串用于优化文件大小

## 下一步工作重点

1. 实现 Sheet.makeSheetData() 方法
2. 完成 Book.write() 方法
3. 添加 XLSX 打包功能
4. 补充集成测试
