import Foundation

// 添加这个调试代码到你的项目中测试
func debugPathResolution() {
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.xlsx")
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("Objects2XLSX_DEBUG")
    
    print("🔍 路径调试信息：")
    print("1. tempURL.path: \(tempURL.path)")
    print("2. tempURL.resolvingSymlinksInPath().path: \(tempURL.resolvingSymlinksInPath().path)")
    print("3. tempDir.path: \(tempDir.path)")
    print("4. tempDir.resolvingSymlinksInPath().path: \(tempDir.resolvingSymlinksInPath().path)")
    
    // 创建一个测试文件来验证路径
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    let testFile = tempDir.appendingPathComponent("test.xml")
    try? "test".write(to: testFile, atomically: true, encoding: .utf8)
    
    print("5. testFile.path: \(testFile.path)")
    print("6. testFile.resolvingSymlinksInPath().path: \(testFile.resolvingSymlinksInPath().path)")
    
    // 检查前缀匹配
    let resolved1 = tempDir.resolvingSymlinksInPath().path
    let resolved2 = testFile.resolvingSymlinksInPath().path
    print("7. hasPrefix check: \(resolved2.hasPrefix(resolved1))")
    
    // 清理
    try? FileManager.default.removeItem(at: tempDir)
}