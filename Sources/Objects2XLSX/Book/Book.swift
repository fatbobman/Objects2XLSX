//
// Book.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import SimpleLogger

// 对应 Excel 的 Workbook 对象
public final class Book {
    public var style: BookStyle
    public var sheets: [AnySheet]
    
    /// 日志管理器，支持自定义实现
    public let logger: LoggerManagerProtocol
    
    /// 进度报告的 AsyncStream
    public let progressStream: AsyncStream<BookGenerationProgress>
    
    /// 进度报告的 Continuation，用于发送进度更新
    private let progressContinuation: AsyncStream<BookGenerationProgress>.Continuation

    var sheetMetas: [SheetMeta] = []

    public init(style: BookStyle, sheets: [AnySheet] = [], logger: LoggerManagerProtocol? = nil) {
        // 创建 AsyncStream 用于进度报告
        let (stream, continuation) = AsyncStream.makeStream(of: BookGenerationProgress.self)
        self.progressStream = stream
        self.progressContinuation = continuation
        
        self.style = style
        self.sheets = sheets
        self.logger = logger ?? Self.defaultLogger
    }

    public convenience init(style: BookStyle, logger: LoggerManagerProtocol? = nil, @SheetBuilder sheets: () -> [AnySheet]) {
        self.init(style: style, sheets: sheets(), logger: logger)
    }
    
    /// 默认日志实现
    private static let defaultLogger: LoggerManagerProtocol = {
        #if DEBUG
        return .console()
        #else
        return .default(subsystem: "com.objects2xlsx.fatbobman", category: "generation")
        #endif
    }()

    public func append(sheet: AnySheet) {
        sheets.append(sheet)
    }

    public func append(sheets: [AnySheet]) {
        self.sheets.append(contentsOf: sheets)
    }
    
    /// 发送进度更新（线程安全）
    private func sendProgress(_ progress: BookGenerationProgress) {
        progressContinuation.yield(progress)
        logger.debug("Progress update: \(progress.description)")
    }
    
    /// 完成进度报告并关闭流
    private func completeProgress() {
        progressContinuation.finish()
    }

    public func append<ObjectType>(sheet: Sheet<ObjectType>) {
        sheets.append(sheet.eraseToAnySheet())
    }

    public func append(@SheetBuilder sheets: () -> [AnySheet]) {
        self.sheets.append(contentsOf: sheets())
    }

    /// Writes the workbook to an XLSX file at the specified URL.
    ///
    /// This method generates a complete XLSX file by processing all sheets, creating the necessary
    /// XML structure, and packaging everything into a standard XLSX format. The operation includes
    /// real-time progress reporting through the `progressStream` property.
    ///
    /// - Parameter url: The target URL where the XLSX file should be written. If the URL doesn't 
    ///   have a `.xlsx` extension, it will be automatically appended. The parent directory will be 
    ///   created if it doesn't exist.
    ///
    /// - Returns: The actual URL where the XLSX file was written. This may differ from the input URL
    ///   if the `.xlsx` extension was automatically added.
    ///
    /// - Throws: `BookError` if any step of the generation process fails, including:
    ///   - `BookError.dataProviderError`: When sheet data cannot be loaded
    ///   - `BookError.xmlGenerationError`: When XML content generation fails
    ///   - `BookError.fileWriteError`: When file system operations fail
    ///   - `BookError.encodingError`: When text encoding fails
    ///   - `BookError.xmlValidationError`: When generated XML is invalid
    ///
    /// ## Usage Example
    /// ```swift
    /// let book = Book(style: BookStyle()) {
    ///     Sheet<Person>(name: "People", dataProvider: { people }) {
    ///         Column(name: "Name", keyPath: \.name)
    ///         Column(name: "Age", keyPath: \.age)
    ///     }
    /// }
    /// 
    /// // Write to a specific location
    /// let outputURL = try book.write(to: URL(fileURLWithPath: "/path/to/report"))
    /// // outputURL will be "/path/to/report.xlsx"
    /// 
    /// // Monitor progress during generation
    /// Task {
    ///     for await progress in book.progressStream {
    ///         print("Progress: \(Int(progress.progressPercentage * 100))%")
    ///         if progress.isFinal { break }
    ///     }
    /// }
    /// ```
    ///
    /// ## Generation Process
    /// The method performs the following steps:
    /// 1. **Validation**: Ensures the output URL has proper extension and directory structure
    /// 2. **Sheet Processing**: Loads data and generates XML for each worksheet
    /// 3. **Global Files**: Creates all required XLSX components (styles, relationships, etc.)
    /// 4. **Packaging**: Compresses everything into a standard XLSX ZIP archive
    /// 5. **Cleanup**: Removes temporary files and reports completion
    ///
    /// ## Thread Safety
    /// This method is not thread-safe. The `Book` instance should only be accessed from a single
    /// thread during the write operation. However, progress monitoring via `progressStream` is
    /// thread-safe and can be observed from any thread.
    ///
    /// ## Performance
    /// The method uses streaming processing to minimize memory usage. Large datasets are processed
    /// incrementally, making it suitable for generating files with thousands of rows while
    /// maintaining reasonable memory consumption.
    @discardableResult
    public func write(to url: URL) throws(BookError) -> URL {
        // Ensure the URL has proper .xlsx extension and directory structure
        let outputURL = try prepareOutputURL(url)
        
        // 开始生成进度报告
        sendProgress(.started)
        
        do {
            // 创建注册器
            let styleRegister = StyleRegister()
            let shareStringRegister = ShareStringRegister()

            // 创建临时目录用于构建 XLSX 包结构
            sendProgress(.creatingDirectory)
            let tempDir = outputURL.deletingPathExtension().appendingPathExtension("temp")
            try createXLSXDirectoryStructure(at: tempDir)
            
            // 流式处理：一次性完成数据加载、元数据收集和XML生成
            sendProgress(.processingSheets(totalCount: sheets.count))
            var collectedMetas: [SheetMeta] = []

            for (index, sheet) in sheets.enumerated() {
                let sheetId = index + 1
                let sheetName = sheet.name
                
                // 发送当前 sheet 处理进度
                sendProgress(.processingSheet(current: sheetId, total: sheets.count, sheetName: sheetName))

                // 加载数据一次
                sheet.loadData()

                // 生成元数据
                let meta = sheet.makeSheetMeta(sheetId: sheetId)
                collectedMetas.append(meta)

                // 立即生成并写入 XML
                try generateAndWriteSheetXML(
                    sheet: sheet,
                    meta: meta,
                    tempDir: tempDir,
                    styleRegister: styleRegister,
                    shareStringRegister: shareStringRegister)
            }

            // 完成 Sheet 处理
            sendProgress(.sheetsCompleted(totalCount: sheets.count))

            // 使用收集的元数据生成全局文件
            sendProgress(.generatingGlobalFiles)
            
            sendProgress(.generatingContentTypes)
            try writeContentTypesXML(to: tempDir, sheetCount: collectedMetas.count)
            
            sendProgress(.generatingRootRelationships)
            try writeRootRelsXML(to: tempDir)
            
            sendProgress(.generatingWorkbook)
            try writeWorkbookXML(to: tempDir, metas: collectedMetas)
            
            sendProgress(.generatingWorkbookRelationships)
            try writeWorkbookRelsXML(to: tempDir, metas: collectedMetas)
            
            sendProgress(.generatingStyles)
            try writeStylesXML(to: tempDir, styleRegister: styleRegister)
            
            sendProgress(.generatingSharedStrings)
            try writeSharedStringsXML(to: tempDir, shareStringRegister: shareStringRegister)
            
            sendProgress(.generatingCoreProperties)
            try writeCorePropsXML(to: tempDir)
            
            sendProgress(.generatingAppProperties)
            try writeAppPropsXML(to: tempDir, metas: collectedMetas)
            
            // 打包为 ZIP 文件并重命名为 .xlsx
            sendProgress(.preparingPackage)
            try createZipArchive(from: tempDir, to: outputURL)
            
            // 清理临时目录
            sendProgress(.cleaningUp)
            try FileManager.default.removeItem(at: tempDir)
            
            // 完成所有操作
            sendProgress(.completed)
            completeProgress()
            
            return outputURL
            
        } catch {
            // 发送错误状态并完成流
            let bookError: BookError
            if let existingBookError = error as? BookError {
                bookError = existingBookError
            } else {
                bookError = BookError.xmlGenerationError("Unknown error: \(error)")
            }
            sendProgress(.failed(error: bookError))
            completeProgress()
            throw bookError
        }
    }

    func generateAndWriteSheetXML(
        sheet: AnySheet,
        meta: SheetMeta,
        tempDir: URL,
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister) throws(BookError)
    {
        guard let sheetXML = sheet.makeSheetXML(
            bookStyle: style,
            styleRegister: styleRegister,
            shareStringRegister: shareStringRegister)
        else {
            throw BookError.dataProviderError("Sheet \(sheet.name) has no data provider")
        }

        // 生成 XML 内容
        let xmlString = sheetXML.generateXML()

        // 验证 XML 内容不为空
        guard !xmlString.isEmpty else {
            throw BookError.xmlGenerationError("Generated XML for sheet '\(sheet.name)' is empty")
        }

        // 将 XML 字符串转换为数据
        guard let xmlData = xmlString.data(using: .utf8) else {
            throw BookError.encodingError("Failed to encode XML for sheet '\(sheet.name)' as UTF-8")
        }

        // 创建完整的文件路径
        let sheetFileURL = tempDir.appendingPathComponent(meta.filePath)
        
        // 确保父目录存在
        let parentDir = sheetFileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        } catch {
            throw BookError.fileWriteError(error)
        }
        
        // 写入 XML 文件
        do {
            try xmlData.write(to: sheetFileURL)
        } catch {
            throw BookError.fileWriteError(error)
        }

        // 验证生成的 XML 包含必要的元素
        try validateSheetXML(xmlString: xmlString, meta: meta)
        
        logger.info("Created sheet file: \(meta.filePath) - XML size: \(xmlData.count) bytes, Data range: \(meta.dataRange?.excelRange ?? "None")")
    }

    /// 验证生成的 Sheet XML 是否符合基本要求
    private func validateSheetXML(xmlString: String, meta: SheetMeta) throws(BookError) {
        // 检查基本的 XML 结构
        guard xmlString.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"") else {
            throw BookError.xmlValidationError("Missing XML declaration in sheet '\(meta.name)'")
        }

        guard xmlString.contains("<worksheet") && xmlString.contains("</worksheet>") else {
            throw BookError.xmlValidationError("Missing worksheet tags in sheet '\(meta.name)'")
        }

        // 如果有数据，检查是否包含 sheetData
        if meta.estimatedDataRowCount > 0 || meta.hasHeader {
            guard xmlString.contains("<sheetData>") && xmlString.contains("</sheetData>") else {
                throw BookError.xmlValidationError("Missing sheetData in non-empty sheet '\(meta.name)'")
            }
        }

        logger.debug("XML validation passed for sheet '\(meta.name)'")
    }
    
    /// 创建 XLSX 包的目录结构
    func createXLSXDirectoryStructure(at tempDir: URL) throws(BookError) {
        do {
            let fileManager = FileManager.default
            
            // 删除已存在的临时目录
            if fileManager.fileExists(atPath: tempDir.path) {
                try fileManager.removeItem(at: tempDir)
            }
            
            // 创建根目录
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
            
            // 创建必要的子目录
            let directories = [
                "_rels",
                "docProps",
                "xl",
                "xl/_rels",
                "xl/worksheets"
            ]
            
            for dir in directories {
                let dirURL = tempDir.appendingPathComponent(dir)
                try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true)
            }
            
            logger.info("Created XLSX directory structure at: \(tempDir.path)")
            
        } catch {
            throw BookError.fileWriteError(error)
        }
    }
    
    /// Prepares the output URL by ensuring proper .xlsx extension and creating parent directories
    /// - Parameter url: The input URL provided by the user
    /// - Returns: The prepared output URL with .xlsx extension
    /// - Throws: BookError.fileWriteError if directory creation fails
    private func prepareOutputURL(_ url: URL) throws(BookError) -> URL {
        // Ensure .xlsx extension
        let outputURL = ensureXLSXExtension(url)
        
        // Create parent directory if needed
        try createParentDirectoryIfNeeded(outputURL)
        
        return outputURL
    }
    
    /// Ensures the URL has a .xlsx extension
    /// - Parameter url: The input URL
    /// - Returns: URL with .xlsx extension (replaces existing extension if different)
    private func ensureXLSXExtension(_ url: URL) -> URL {
        let pathExtension = url.pathExtension.lowercased()
        
        // If already has .xlsx extension, return as-is
        if pathExtension == "xlsx" {
            return url
        }
        
        // If has no extension, add .xlsx
        if pathExtension.isEmpty {
            return url.appendingPathExtension("xlsx")
        }
        
        // If has different extension, replace it with .xlsx
        return url.deletingPathExtension().appendingPathExtension("xlsx")
    }
    
    /// Creates parent directory if it doesn't exist
    /// - Parameter url: The output URL whose parent directory should be created
    /// - Throws: BookError.fileWriteError if directory creation fails
    private func createParentDirectoryIfNeeded(_ url: URL) throws(BookError) {
        let parentDirectory = url.deletingLastPathComponent()
        
        // Check if parent directory exists
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: parentDirectory.path, isDirectory: &isDirectory)
        
        if !exists {
            // Parent directory doesn't exist, create it
            do {
                try FileManager.default.createDirectory(
                    at: parentDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                logger.info("Created parent directory: \(parentDirectory.path)")
            } catch {
                logger.error("Failed to create parent directory: \(parentDirectory.path) - \(error)")
                throw BookError.fileWriteError(error)
            }
        } else if !isDirectory.boolValue {
            // Path exists but is not a directory
            let error = NSError(
                domain: "Objects2XLSX",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Parent path exists but is not a directory: \(parentDirectory.path)"]
            )
            logger.error("Parent path is not a directory: \(parentDirectory.path)")
            throw BookError.fileWriteError(error)
        }
    }
    
    /// 使用 SimpleZip 创建 XLSX 文件
    func createZipArchive(from tempDir: URL, to outputURL: URL) throws(BookError) {
        do {
            try SimpleZip.createFromDirectory(directoryURL: tempDir, outputURL: outputURL)
            
            let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
            logger.info("Created XLSX file: \(outputURL.path) - Size: \(fileSize) bytes")
            
        } catch let zipError as SimpleZip.ZipError {
            logger.error("ZIP creation failed: \(zipError)")
            throw BookError.fileWriteError(zipError)
        } catch {
            logger.error("Unexpected error during ZIP creation: \(error)")
            throw BookError.fileWriteError(error)
        }
    }
}

extension Book {
    public func author(name: String) {
        style.properties.author = name
    }

    public func title(name: String) {
        style.properties.title = name
    }
}

public enum BookError: Error, Sendable {
    case fileWriteError(Error)
    case dataProviderError(String)
    case xmlGenerationError(String)
    case encodingError(String)
    case xmlValidationError(String)
}
