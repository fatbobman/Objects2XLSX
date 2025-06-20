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
- ✅ 完整的 SheetXML 生成功能（表头 + 数据行）
- ✅ 数据行生成逻辑（generateDataRows、generateDataRow、generateDataCell）
- ✅ 样式合并和优先级处理（列样式 > 工作表样式 > 工作簿样式）
- ✅ 共享字符串支持（String 和 URL 类型）
- ✅ 自动边框区域计算和应用
- ✅ 简化的边框系统（DataBorderSettings）

### 待实现功能

- ❌ Book.write() 方法 - 生成实际的 XLSX 文件
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

## 下一步工作重点

1. 完成 Book.write() 方法
2. 添加 XLSX 文件打包功能
3. 实现必需的 Excel 文件组件（workbook.xml、styles.xml、sharedStrings.xml）
4. 补充集成测试和性能测试

## XLSX 全局文件生成计划

### 实现顺序（按依赖关系）

1. **xl/workbook.xml** - 工作簿定义文件 ✅ **已实现**
   - 使用 collectedMetas 中的 name, sheetId, relationshipId
   - 定义所有工作表的基本信息
   - 添加测试验证 XML 结构和内容

2. **xl/styles.xml** - 样式定义文件 ✅ **已实现**
   - styleRegister.generateXML() 已完成
   - 直接写入文件即可

3. **xl/sharedStrings.xml** - 共享字符串文件 ✅ **已实现**
   - shareStringRegister.generateXML() 已完成
   - 直接写入文件即可

4. **[Content_Types].xml** - 内容类型定义 ✅ **已实现**
   - 定义文件扩展名与 MIME 类型的映射
   - 根据工作表数量生成对应的 worksheet 条目
   - 添加测试验证动态内容生成

5. **xl/_rels/workbook.xml.rels** - 工作簿关系文件 ✅ **已实现**
   - 定义工作簿与工作表、样式、共享字符串的关系
   - 使用 collectedMetas 生成每个工作表的关系条目
   - 添加测试验证关系正确性

6. **_rels/.rels** - 根关系文件 ✅ **已实现**
   - 定义根级别的关系（app.xml, core.xml, workbook.xml）
   - 固定内容，直接生成
   - 添加测试验证文件结构

7. **docProps/app.xml** - 应用程序属性 ✅ **已实现**
   - 包含应用程序信息、工作表名称列表
   - 使用 collectedMetas 中的工作表名称
   - 添加测试验证属性正确性

8. **docProps/core.xml** - 核心属性 ✅ **已实现**
   - 包含文档元数据（标题、作者、创建时间等）
   - 使用 style.properties 中的信息
   - 添加测试验证元数据正确性

### 实现策略

- 每个文件单独实现，包含生成方法和对应测试
- 使用扩展方式组织代码，保持 Book 类清晰
- 所有 XML 生成遵循 Office Open XML 规范
- 每完成一个文件进行测试验证
