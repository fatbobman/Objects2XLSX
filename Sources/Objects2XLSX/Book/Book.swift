//
// Book.swift
// Created by Xu Yang on 2025-06-18.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import SimpleLogger

/// Represents an Excel Workbook that contains multiple worksheets and manages XLSX file generation.
///
/// `Book` is the main entry point for creating XLSX files from Swift objects. It manages a
/// collection
/// of worksheets, handles styling, and provides real-time progress reporting during file
/// generation.
/// The class follows a builder pattern for easy configuration and supports both synchronous and
/// asynchronous operations.
///
/// ## Key Features
/// - **Type-safe sheet management**: Stores heterogeneous sheets through type erasure
/// - **Progress reporting**: Real-time updates via AsyncStream during file generation
/// - **Flexible styling**: Supports book-level, sheet-level, and cell-level styling
/// - **Memory efficient**: Streams data processing to handle large datasets
/// - **Thread-safe progress**: Progress monitoring can be observed from any thread
///
/// ## ⚠️ Concurrency and Thread Safety
/// **IMPORTANT**: `Book` itself is NOT thread-safe. You must ensure that:
/// - The `Book` instance is used on the same thread as your data objects
/// - All data access operations are performed on the correct thread context
/// - Only the `progressStream` can be safely observed from other threads
///
/// ### Core Data Usage
/// When working with Core Data objects, always use `Book` within the appropriate `perform` block:
/// ```swift
/// privateContext.perform {
///     let employees = // fetch Core Data objects
///     let book = Book(style: BookStyle()) {
///         Sheet<Employee>(name: "Staff", dataProvider: { employees }) {
///             Column(name: "Name", keyPath: \.name)
///             Column(name: "Department", keyPath: \.department?.name)
///         }
///     }
///     try book.write(to: outputURL)
/// }
/// ```
///
/// ### SwiftData Usage
/// When working with SwiftData objects, use `Book` within a `@ModelActor`:
/// ```swift
/// @ModelActor
/// actor DataExporter {
///     func exportEmployees() async throws -> URL {
///         let employees = // fetch SwiftData objects
///         let book = Book(style: BookStyle()) {
///             Sheet<Employee>(name: "Staff", dataProvider: { employees }) {
///                 Column(name: "Name", keyPath: \.name)
///                 Column(name: "Department", keyPath: \.department?.name)
///             }
///         }
///         return try book.write(to: outputURL)
///     }
/// }
/// ```
///
/// ## Usage
/// ```swift
/// let book = Book(style: BookStyle()) {
///     Sheet<Person>(name: "Employees", dataProvider: { employees }) {
///         Column(name: "Name", keyPath: \.name)
///         Column(name: "Department", keyPath: \.department)
///     }
/// }
///
/// let outputURL = try book.write(to: URL(fileURLWithPath: "/path/to/output.xlsx"))
/// ```
public final class Book {
    /// The styling configuration for the entire workbook
    public private(set) var style: BookStyle

    /// Collection of worksheets in the workbook (type-erased for heterogeneous storage)
    public private(set) var sheets: [AnySheet]

    /// Logger instance for debugging and monitoring (supports custom implementations)
    public var logger: LoggerManagerProtocol

    /// AsyncStream for real-time progress reporting during XLSX generation
    public let progressStream: AsyncStream<BookGenerationProgress>

    /// Internal continuation for sending progress updates (thread-safe)
    private let progressContinuation: AsyncStream<BookGenerationProgress>.Continuation

    /// Internal storage for sheet metadata (populated during processing)
    var sheetMetas: [SheetMeta] = []

    /// ZIP archiver implementation (defaults to SimpleZip)
    private let zipArchiver: ZipArchiver

    /// Creates a new Book instance with the specified configuration.
    ///
    /// - Parameters:
    ///   - style: The styling configuration for the entire workbook
    ///   - sheets: Initial collection of worksheets (defaults to empty)
    ///   - logger: Custom logger implementation (uses default if not provided)
    ///   - zipArchiver: Custom ZIP archiver implementation (uses SimpleZip if not provided)
    public init(
        style: BookStyle,
        sheets: [AnySheet] = [],
        logger: LoggerManagerProtocol? = nil,
        zipArchiver: ZipArchiver? = nil)
    {
        // Create AsyncStream for progress reporting
        let (stream, continuation) = AsyncStream.makeStream(of: BookGenerationProgress.self)
        progressStream = stream
        progressContinuation = continuation

        self.style = style
        self.sheets = sheets
        self.logger = logger ?? Self.defaultLogger
        self.zipArchiver = zipArchiver ?? SimpleZipArchiver()
    }

    /// Convenience initializer using the SheetBuilder pattern for declarative sheet configuration.
    ///
    /// - Parameters:
    ///   - style: The styling configuration for the entire workbook
    ///   - logger: Custom logger implementation (uses default if not provided)
    ///   - zipArchiver: Custom ZIP archiver implementation (uses SimpleZip if not provided)
    ///   - sheets: Closure that returns an array of sheets using the @SheetBuilder
    public convenience init(
        style: BookStyle,
        logger: LoggerManagerProtocol? = nil,
        zipArchiver: ZipArchiver? = nil,
        @SheetBuilder sheets: () -> [AnySheet])
    {
        self.init(style: style, sheets: sheets(), logger: logger, zipArchiver: zipArchiver)
    }

    /// Default logger implementation (console in debug, system logger in release)
    private static let defaultLogger: LoggerManagerProtocol = {
        #if DEBUG
            return .console(verbosity: .minimal)
        #else
            return .default(subsystem: "com.objects2xlsx.fatbobman", category: "generation")
        #endif
    }()

    /// Sends progress updates to observers (thread-safe)
    /// - Parameter progress: The current generation progress state
    private func sendProgress(_ progress: BookGenerationProgress) {
        progressContinuation.yield(progress)
        logger.debug("Progress update: \(progress.description)")
    }

    /// Completes progress reporting and closes the stream
    private func completeProgress() {
        progressContinuation.finish()
    }

    /// Appends a strongly-typed sheet to the workbook
    /// - Parameter sheet: The typed sheet to append (will be type-erased for storage)
    public func append<ObjectType>(sheet: Sheet<ObjectType>) {
        sheets.append(sheet.eraseToAnySheet())
    }

    /// Appends multiple sheets using the SheetBuilder pattern
    /// - Parameter sheets: Closure that returns an array of sheets to append
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
    /// - Returns: The actual URL where the XLSX file was written. This may differ from the input
    /// URL
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
    /// **CRITICAL**: This method is NOT thread-safe. You must ensure that:
    /// - The `Book` instance and all its data objects are accessed from the same thread
    /// - For Core Data: Call this method within the appropriate `perform` or `performAndWait` block
    /// - For SwiftData: Call this method within a `@ModelActor` context
    /// - Progress monitoring via `progressStream` is thread-safe and can be observed from any
    /// thread
    ///
    /// **Violating thread safety requirements may result in crashes or data corruption.**
    ///
    /// ## Performance
    /// The method uses streaming processing to minimize memory usage. Large datasets are processed
    /// incrementally, making it suitable for generating files with thousands of rows while
    /// maintaining reasonable memory consumption.
    @discardableResult
    public func write(to url: URL) throws(BookError) -> URL {
        return try generateXLSX(to: url, useAsync: false)
    }

    /// Asynchronously writes the workbook to an XLSX file at the specified URL.
    ///
    /// This method generates a complete XLSX file by processing all sheets, creating the necessary
    /// XML structure, and packaging everything into a standard XLSX format. It supports both
    /// synchronous and asynchronous data providers, with async providers taking precedence.
    /// The operation includes real-time progress reporting through the `progressStream` property.
    ///
    /// - Parameter url: The target URL where the XLSX file should be written. If the URL doesn't
    ///   have a `.xlsx` extension, it will be automatically appended. The parent directory will be
    ///   created if it doesn't exist.
    ///
    /// - Returns: The actual URL where the XLSX file was written. This may differ from the input
    /// URL
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
    ///     Sheet<Person>(name: "People", asyncDataProvider: {
    ///         await fetchPeopleFromAPI()
    ///     }) {
    ///         Column(name: "Name", keyPath: \.name)
    ///         Column(name: "Age", keyPath: \.age)
    ///     }
    /// }
    ///
    /// // Write to a specific location asynchronously
    /// let outputURL = try await book.writeAsync(to: URL(fileURLWithPath: "/path/to/report"))
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
    /// ## Async Data Loading
    /// When a sheet has an async data provider, this method will:
    /// 1. Use the async data provider for data loading
    /// 2. Fall back to sync data provider if no async provider is available
    /// 3. Process sheets with mixed sync/async providers seamlessly
    ///
    /// ## Thread Safety
    /// **CRITICAL**: While this method is async, the Book instance itself is NOT thread-safe.
    /// You must ensure that:
    /// - The `Book` instance and all its data objects are accessed from the same actor/thread
    /// - For SwiftData: Call this method within a `@ModelActor` context
    /// - Progress monitoring via `progressStream` is thread-safe and can be observed from any
    /// thread
    @discardableResult
    public func writeAsync(to url: URL) async throws(BookError) -> URL {
        return try await generateXLSXAsync(to: url, useAsync: true)
    }

    /// Core XLSX generation logic (synchronous version)
    /// - Parameters:
    ///   - url: Target URL for the XLSX file
    ///   - useAsync: Whether to use async data loading (ignored in sync version)
    /// - Returns: The actual URL where the XLSX file was written
    /// - Throws: BookError if generation fails
    private func generateXLSX(to url: URL, useAsync: Bool) throws(BookError) -> URL {
        // Ensure the URL has proper .xlsx extension and directory structure
        let outputURL = try prepareOutputURL(url)

        // Begin progress reporting
        sendProgress(.started)

        do {
            // Create registries for optimization
            let styleRegister = StyleRegister()
            let shareStringRegister = ShareStringRegister()

            // Create temporary directory for building XLSX package structure
            sendProgress(.creatingDirectory)
            let tempDir = outputURL.deletingPathExtension().appendingPathExtension("temp")
            try createXLSXDirectoryStructure(at: tempDir)

            // Process sheets and collect metadata
            let collectedMetas = try processSheets(
                tempDir: tempDir,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister,
                useAsync: false)

            // Generate global files and create final package
            try finalizeXLSX(
                outputURL: outputURL,
                tempDir: tempDir,
                collectedMetas: collectedMetas,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)

            return outputURL

        } catch {
            // Send error status and complete stream
            let bookError: BookError = if let existingBookError = error as? BookError {
                existingBookError
            } else {
                BookError.xmlGenerationError("Unknown error: \(error)")
            }
            sendProgress(.failed(error: bookError))
            completeProgress()
            throw bookError
        }
    }

    /// Core XLSX generation logic (asynchronous version)
    /// - Parameters:
    ///   - url: Target URL for the XLSX file
    ///   - useAsync: Whether to use async data loading
    /// - Returns: The actual URL where the XLSX file was written
    /// - Throws: BookError if generation fails
    private func generateXLSXAsync(to url: URL, useAsync: Bool) async throws(BookError) -> URL {
        // Ensure the URL has proper .xlsx extension and directory structure
        let outputURL = try prepareOutputURL(url)

        // Begin progress reporting
        sendProgress(.started)

        do {
            // Create registries for optimization
            let styleRegister = StyleRegister()
            let shareStringRegister = ShareStringRegister()

            // Create temporary directory for building XLSX package structure
            sendProgress(.creatingDirectory)
            let tempDir = outputURL.deletingPathExtension().appendingPathExtension("temp")
            try createXLSXDirectoryStructure(at: tempDir)

            // Process sheets and collect metadata (async version)
            let collectedMetas = try await processSheetsAsync(
                tempDir: tempDir,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)

            // Generate global files and create final package
            try finalizeXLSX(
                outputURL: outputURL,
                tempDir: tempDir,
                collectedMetas: collectedMetas,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)

            return outputURL

        } catch {
            // Send error status and complete stream
            let bookError: BookError = if let existingBookError = error as? BookError {
                existingBookError
            } else {
                BookError.xmlGenerationError("Unknown error: \(error)")
            }
            sendProgress(.failed(error: bookError))
            completeProgress()
            throw bookError
        }
    }

    /// Processes all sheets synchronously and collects their metadata
    /// - Parameters:
    ///   - tempDir: Temporary directory for XML files
    ///   - styleRegister: Style registry for optimization
    ///   - shareStringRegister: Shared string registry for optimization
    ///   - useAsync: Whether to use async data loading (ignored in sync version)
    /// - Returns: Array of collected sheet metadata
    /// - Throws: BookError if sheet processing fails
    private func processSheets(
        tempDir: URL,
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister,
        useAsync: Bool) throws(BookError) -> [SheetMeta]
    {
        // Stream processing: complete data loading, metadata collection, and XML generation
        sendProgress(.processingSheets(totalCount: sheets.count))
        var collectedMetas: [SheetMeta] = []

        for (index, sheet) in sheets.enumerated() {
            let sheetId = index + 1
            let sheetName = sheet.name

            // Send current sheet processing progress
            sendProgress(.processingSheet(
                current: sheetId,
                total: sheets.count,
                sheetName: sheetName))

            // Load data once (synchronous)
            sheet.loadData()

            // Generate metadata
            let meta = sheet.makeSheetMeta(sheetId: sheetId)
            collectedMetas.append(meta)

            // Immediately generate and write XML
            try generateAndWriteSheetXML(
                sheet: sheet,
                meta: meta,
                tempDir: tempDir,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)
        }

        // Complete sheet processing
        sendProgress(.sheetsCompleted(totalCount: sheets.count))
        return collectedMetas
    }

    /// Processes all sheets asynchronously and collects their metadata
    /// - Parameters:
    ///   - tempDir: Temporary directory for XML files
    ///   - styleRegister: Style registry for optimization
    ///   - shareStringRegister: Shared string registry for optimization
    /// - Returns: Array of collected sheet metadata
    /// - Throws: BookError if sheet processing fails
    private func processSheetsAsync(
        tempDir: URL,
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister) async throws(BookError) -> [SheetMeta]
    {
        // Stream processing: complete data loading, metadata collection, and XML generation
        sendProgress(.processingSheets(totalCount: sheets.count))
        var collectedMetas: [SheetMeta] = []

        for (index, sheet) in sheets.enumerated() {
            let sheetId = index + 1
            let sheetName = sheet.name

            // Send current sheet processing progress
            sendProgress(.processingSheet(
                current: sheetId,
                total: sheets.count,
                sheetName: sheetName))

            // Load data once (asynchronous if available, falls back to sync)
            await sheet.loadDataAsync()

            // Generate metadata
            let meta = sheet.makeSheetMeta(sheetId: sheetId)
            collectedMetas.append(meta)

            // Immediately generate and write XML
            try generateAndWriteSheetXML(
                sheet: sheet,
                meta: meta,
                tempDir: tempDir,
                styleRegister: styleRegister,
                shareStringRegister: shareStringRegister)
        }

        // Complete sheet processing
        sendProgress(.sheetsCompleted(totalCount: sheets.count))
        return collectedMetas
    }

    /// Finalizes XLSX generation by creating global files and packaging
    /// - Parameters:
    ///   - outputURL: Final output URL for the XLSX file
    ///   - tempDir: Temporary directory containing generated files
    ///   - collectedMetas: Array of sheet metadata
    ///   - styleRegister: Style registry for optimization
    ///   - shareStringRegister: Shared string registry for optimization
    /// - Throws: BookError if finalization fails
    private func finalizeXLSX(
        outputURL: URL,
        tempDir: URL,
        collectedMetas: [SheetMeta],
        styleRegister: StyleRegister,
        shareStringRegister: ShareStringRegister) throws(BookError)
    {
        // Generate global files using collected metadata
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

        sendProgress(.generatingTheme)
        try writeThemeXML(to: tempDir)

        sendProgress(.generatingCoreProperties)
        try writeCorePropsXML(to: tempDir)

        sendProgress(.generatingAppProperties)
        try writeAppPropsXML(to: tempDir, metas: collectedMetas)

        // Package as ZIP file and rename to .xlsx
        sendProgress(.preparingPackage)
        try createZipArchive(from: tempDir, to: outputURL)

        // Clean up temporary directory
        sendProgress(.cleaningUp)
        do {
            try FileManager.default.removeItem(at: tempDir)
        } catch {
            throw BookError.fileWriteError(error)
        }

        // Complete all operations
        sendProgress(.completed)
        completeProgress()
    }

    /// Creates the XLSX package directory structure
    /// - Parameter tempDir: The temporary directory URL where the structure will be created
    /// - Throws: BookError.fileWriteError if directory operations fail
    func createXLSXDirectoryStructure(at tempDir: URL) throws(BookError) {
        do {
            let fileManager = FileManager.default

            // Remove existing temporary directory if it exists
            if fileManager.fileExists(atPath: tempDir.path) {
                try fileManager.removeItem(at: tempDir)
            }

            // Create root directory
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)

            // Create necessary subdirectories
            let directories = [
                "_rels",
                "docProps",
                "xl",
                "xl/_rels",
                "xl/worksheets",
                "xl/theme",
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
        let exists = FileManager.default.fileExists(
            atPath: parentDirectory.path,
            isDirectory: &isDirectory)

        if !exists {
            // Parent directory doesn't exist, create it
            do {
                try FileManager.default.createDirectory(
                    at: parentDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil)
                logger.info("Created parent directory: \(parentDirectory.path)")
            } catch {
                logger
                    .error("Failed to create parent directory: \(parentDirectory.path) - \(error)")
                throw BookError.fileWriteError(error)
            }
        } else if !isDirectory.boolValue {
            // Path exists but is not a directory
            let error = NSError(
                domain: "Objects2XLSX",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Parent path exists but is not a directory: \(parentDirectory.path)",
                ])
            logger.error("Parent path is not a directory: \(parentDirectory.path)")
            throw BookError.fileWriteError(error)
        }
    }

    /// Creates XLSX file using the configured ZIP archiver
    /// - Parameters:
    ///   - tempDir: Source directory containing XLSX package structure
    ///   - outputURL: Target URL for the final XLSX file
    /// - Throws: BookError.fileWriteError if ZIP creation fails
    func createZipArchive(from tempDir: URL, to outputURL: URL) throws(BookError) {
        do {
            let stats = try zipArchiver.createArchiveWithStats(from: tempDir, to: outputURL)

            let fileSize = try FileManager.default
                .attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
            logger.info("Created XLSX file: \(outputURL.path) - Size: \(fileSize) bytes")

            // Log compression statistics
            if stats.originalSize > 0 {
                logger
                    .info(
                        "Compression stats: \(ByteCountFormatter.string(fromByteCount: Int64(stats.originalSize), countStyle: .file)) → \(ByteCountFormatter.string(fromByteCount: Int64(stats.compressedSize), countStyle: .file)) (\(String(format: "%.1f", stats.compressionPercentage))% compression)") // swiftlint:disable:this line_length
            }

        } catch {
            logger.error("ZIP creation failed: \(error)")
            throw BookError.fileWriteError(error)
        }
    }
}

// MARK: - Document Properties & Sheet Management

extension Book {
    /// Sets the author of the document properties
    /// - Parameter name: The author name to be stored in the XLSX metadata
    public func author(name: String) {
        style.properties.author = name
    }

    /// Sets the title of the document properties
    /// - Parameter name: The document title to be stored in the XLSX metadata
    public func title(name: String) {
        style.properties.title = name
    }

    /// Appends multiple sheets to the workbook
    /// - Parameter sheets: Array of sheets to append to the workbook
    public func append(sheets: [AnySheet]) {
        self.sheets.append(contentsOf: sheets)
    }

    /// Sets the logger for the workbook
    /// - Parameter logger: The logger to be used for the workbook
    public func setLogger(_ logger: LoggerManagerProtocol) {
        self.logger = logger
    }
}

// MARK: - Error Types

/// Errors that can occur during XLSX generation and file operations
public enum BookError: Error, Sendable {
    /// File system operation failed (directory creation, file writing, etc.)
    case fileWriteError(Error)

    /// Sheet data provider is missing or failed to load data
    case dataProviderError(String)

    /// XML generation process failed
    case xmlGenerationError(String)

    /// Text encoding operation failed (typically UTF-8 encoding)
    case encodingError(String)

    /// Generated XML failed validation checks
    case xmlValidationError(String)
}
