# Git Hooks + SwiftFormat 集成设置

本项目已配置了 Git hooks 与 SwiftFormat 的集成，确保代码格式的一致性。

## 🚀 已安装的功能

### 1. Post-Merge Hook (自动运行)

- **位置**: `.git/hooks/post-merge`
- **触发时机**: 每次 `git pull` 或 `git merge` 成功后
- **功能**: 自动对 `Sources/` 和 `Tests/` 目录运行 SwiftFormat
- **行为**: 显示格式化的文件，但不自动提交更改

### 2. Pre-Push Hook (自动运行)

- **位置**: `.git/hooks/pre-push`
- **触发时机**: 每次 `git push` 之前
- **功能**: 检查代码格式，如有需要则进行格式化
- **行为**: 如果格式化后有变更，会阻止推送并要求先提交格式化更改

### 3. 自定义 Pre-Pull 脚本 (手动运行)

- **位置**: `scripts/git-pull-with-format.sh`
- **别名**: `git pullf`
- **功能**: 在拉取代码前先运行 SwiftFormat
- **优势**: 提供多种处理格式化更改的选项

### 4. Git 别名

```bash
git pullf  # 等同于 ./scripts/git-pull-with-format.sh
```

## 📋 使用方法

### 推荐工作流程

1. **拉取最新代码**:

   ```bash
   git pullf  # 会先格式化，再拉取
   ```

2. **进行代码修改**

3. **提交代码**:

   ```bash
   git add -A
   git commit -m "your commit message"
   ```

4. **推送代码** (自动格式化检查):

   ```bash
   git push  # Pre-push hook 会自动检查格式
   ```

   > 💡 如果 pre-push hook 发现格式问题，会自动格式化并阻止推送，你需要先提交格式化更改再重新推送

### 可用命令

| 命令 | 功能 |
|------|------|
| `git pullf` | 格式化后拉取代码 |
| `swiftformat Sources Tests` | 手动格式化所有文件 |
| `swiftformat --lint Sources` | 检查格式问题（干运行） |
| `./scripts/test-hooks.sh` | 测试集成设置 |

## ⚙️ SwiftFormat 配置

项目使用 `.swiftformat` 文件中的配置，主要设置：

- **缩进**: 4 个空格
- **行宽**: 200 字符
- **导入排序**: 字母顺序
- **括号风格**: 闭包使用同行
- **文档注释**: 声明前
- **移除 self**: 启用

## 🔧 Pre-Pull 脚本功能

运行 `git pullf` 时的选项：

1. **提交格式化更改并拉取** - 推荐用于团队协作
2. **暂存更改，拉取后恢复** - 保持工作目录干净
3. **保持未提交状态继续** - 快速操作
4. **中止操作** - 取消当前操作

## 🧪 测试设置

运行测试脚本验证所有组件：

```bash
./scripts/test-hooks.sh
```

该脚本会检查：

- ✅ SwiftFormat 安装状态
- ✅ 配置文件存在
- ✅ Git hooks 安装
- ✅ 自定义脚本可执行
- ✅ Git 别名配置
- ✅ 示例文件格式状态

## 📁 文件结构

```bash
Objects2XLSX/
├── .swiftformat                    # SwiftFormat 配置
├── .git/hooks/post-merge          # 拉取后自动格式化
├── .git/hooks/pre-push            # 推送前自动格式化检查
├── scripts/
│   ├── git-pull-with-format.sh    # 自定义 pull 脚本
│   ├── test-hooks.sh              # 测试脚本
│   └── README.md                  # 详细文档
└── GIT_HOOKS_SETUP.md             # 本文件
```

## 🔨 手动安装 (如果需要)

如果 hooks 丢失，可以重新安装：

```bash
# 创建 post-merge hook
cat > .git/hooks/post-merge << 'EOF'
#!/bin/bash
echo "Running SwiftFormat on Swift files..."
if command -v swiftformat &> /dev/null; then
    PROJECT_ROOT="$(git rev-parse --show-toplevel)"
    swiftformat "$PROJECT_ROOT/Sources" "$PROJECT_ROOT/Tests"
    if ! git diff --quiet; then
        echo "SwiftFormat made changes to the following files:"
        git diff --name-only
    else
        echo "No formatting changes needed."
    fi
else
    echo "Warning: swiftformat not found. Install with: brew install swiftformat"
fi
EOF

# 创建 pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
echo "Running SwiftFormat before push..."
if command -v swiftformat &> /dev/null; then
    PROJECT_ROOT="$(git rev-parse --show-toplevel)"
    swiftformat "$PROJECT_ROOT/Sources" "$PROJECT_ROOT/Tests"
    if ! git diff --quiet; then
        echo "❌ Push cancelled: Files were reformatted."
        echo "Please commit the formatting changes first:"
        echo "  git add -A && git commit -m 'style: Apply SwiftFormat'"
        exit 1
    fi
else
    echo "Warning: swiftformat not found. Install with: brew install swiftformat"
fi
EOF

# 设置可执行权限
chmod +x .git/hooks/post-merge
chmod +x .git/hooks/pre-push

# 设置 git 别名
git config alias.pullf '!./scripts/git-pull-with-format.sh'
```

## 💡 提示

- **首次使用**: 运行 `./scripts/test-hooks.sh` 确保设置正确
- **团队协作**: 建议所有团队成员使用 `git pullf` 而不是 `git pull`
- **CI/CD**: 可以在 CI 中运行 `swiftformat --lint Sources Tests` 检查格式
- **IDE 集成**: 考虑安装 SwiftFormat 的 IDE 扩展以实现实时格式化

## ❓ 故障排除

### SwiftFormat 未找到

```bash
brew install swiftformat
```

### Hook 不执行

```bash
chmod +x .git/hooks/post-merge
```

### Git 别名失效

```bash
git config alias.pullf '!./scripts/git-pull-with-format.sh'
```

---

🎉 现在你的项目已经完全集成了自动代码格式化功能！
