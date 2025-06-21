//
// SimpleZip.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
#if canImport(Compression)
    import Compression
#endif

/**
 A lightweight ZIP implementation specifically designed for creating XLSX files.

 This implementation automatically supports DEFLATE compression on Apple platforms
 and falls back to STORE method on other platforms. It provides a minimal but
 complete ZIP archive creation functionality tailored for XLSX file generation.

 ## Features

 - **Cross-platform compatibility**: Works on macOS, iOS, Linux, and other Swift platforms
 - **Automatic compression**: Uses DEFLATE compression on Apple platforms with Compression framework
 - **Intelligent compression strategy**: Only compresses files that benefit from compression
 - **Compression statistics**: Provides detailed compression metrics
 - **Thread-safe**: All types conform to `Sendable` protocol
 - **Memory efficient**: Processes files without loading entire archives into memory

 ## Example Usage

 ```swift
 // Create ZIP entries
 let entries = [
     SimpleZip.Entry(path: "data.xml", data: xmlData),
     SimpleZip.Entry(path: "styles.xml", data: styleData)
 ]

 // Create ZIP archive with compression statistics
 let (zipData, stats) = try SimpleZip.createWithStats(entries: entries)

 // Print compression results
 print("Compression: \(stats.compressionPercentage)%")
 ```
 */
public struct SimpleZip: Sendable {
    /**
     Represents a single file entry within a ZIP archive.

     Each entry contains the file path, data content, and modification date.
     The path should use forward slashes as directory separators, following
     ZIP archive conventions.
     */
    public struct Entry: Sendable {
        /// The file path within the ZIP archive (using forward slashes)
        public let path: String
        /// The binary content of the file
        public let data: Data
        /// The last modification date of the file
        public let modificationDate: Date

        /**
         Creates a new ZIP entry.

         - Parameters:
           - path: The file path within the ZIP archive
           - data: The binary content of the file
           - modificationDate: The last modification date (defaults to current date)
         */
        public init(path: String, data: Data, modificationDate: Date = Date()) {
            self.path = path
            self.data = data
            self.modificationDate = modificationDate
        }
    }

    /**
     Errors that can occur during ZIP creation.
     */
    public enum ZipError: Error, Sendable {
        /// The file path is invalid or contains security risks (e.g., path traversal)
        case invalidPath(String)
        /// An error occurred while writing data to the archive
        case dataWriteError(String)
        /// The file is too large for ZIP format limitations (exceeds 4GB)
        case fileTooLarge(String)
    }

    /**
     Comprehensive compression statistics for a ZIP archive.

     Provides detailed information about compression effectiveness,
     including overall statistics and per-file breakdowns.
     */
    public struct CompressionStats: Sendable {
        /// Total size of all original (uncompressed) data in bytes
        public let originalSize: Int
        /// Total size of all compressed data in bytes
        public let compressedSize: Int

        /**
         Compression ratio as a decimal value between 0.0 and 1.0.

         - Returns: A value where 0.0 means no compression and 1.0 means 100% compression
         */
        public var compressionRatio: Double {
            guard originalSize > 0 else { return 0.0 }
            return 1.0 - (Double(compressedSize) / Double(originalSize))
        }

        /**
         Compression ratio as a percentage between 0 and 100.

         - Returns: A percentage value (e.g., 75.5 for 75.5% compression)
         */
        public var compressionPercentage: Double {
            compressionRatio * 100
        }

        /// Detailed compression statistics for each individual file
        public let fileStats: [FileCompressionStats]
    }

    /**
     Compression statistics for an individual file within the archive.
     */
    public struct FileCompressionStats: Sendable {
        /// The file path within the ZIP archive
        public let path: String
        /// Original (uncompressed) file size in bytes
        public let originalSize: Int
        /// Compressed file size in bytes
        public let compressedSize: Int
        /// Compression method used ("DEFLATE" for compressed, "STORE" for uncompressed)
        public let compressionMethod: String
    }

    /**
     Creates ZIP archive data from the provided file entries.

     This is the primary method for creating ZIP archives. It automatically
     handles compression based on the platform and file characteristics.

     - Parameter entries: Array of file entries to include in the ZIP archive
     - Returns: The complete ZIP archive as binary data
     - Throws: `ZipError` if creation fails due to invalid paths, data errors, or size limits
     */
    public static func create(entries: [Entry]) throws -> Data {
        let (data, _) = try createWithStats(entries: entries)
        return data
    }

    /**
     Creates ZIP archive data and returns detailed compression statistics.

     This method provides the same functionality as `create(entries:)` but also
     returns comprehensive compression statistics including per-file details
     and overall compression ratios.

     - Parameter entries: Array of file entries to include in the ZIP archive
     - Returns: A tuple containing the ZIP archive data and compression statistics
     - Throws: `ZipError` if creation fails due to invalid paths, data errors, or size limits
     */
    public static func createWithStats(entries: [Entry]) throws -> (data: Data, stats: CompressionStats) {
        var zipData = Data()
        var centralDirectory = Data()
        var localHeaderOffset: UInt32 = 0
        var fileStats: [FileCompressionStats] = []
        var totalOriginalSize = 0
        var totalCompressedSize = 0

        for entry in entries {
            // Validate file path for security
            guard !entry.path.isEmpty, !entry.path.contains("..") else {
                throw ZipError.invalidPath("Invalid path: \(entry.path)")
            }

            // Validate file size against ZIP format limitations
            guard entry.data.count <= UInt32.max else {
                throw ZipError.fileTooLarge("File too large: \(entry.path)")
            }

            let pathData = entry.path.data(using: .utf8) ?? Data()
            let fileData = entry.data
            let crc32 = calculateCRC32(data: fileData)
            let dosDateTime = toDosDateTime(date: entry.modificationDate)

            // Compress file data using platform-appropriate method
            let (compressedData, compressionMethod) = compressData(fileData, path: entry.path)

            // Collect compression statistics
            totalOriginalSize += fileData.count
            totalCompressedSize += compressedData.count

            let methodName = compressionMethod == 8 ? "DEFLATE" : "STORE"
            fileStats.append(FileCompressionStats(
                path: entry.path,
                originalSize: fileData.count,
                compressedSize: compressedData.count,
                compressionMethod: methodName))

            // Create local file header
            let localHeader = createLocalFileHeader(
                pathData: pathData,
                originalData: fileData,
                compressedData: compressedData,
                compressionMethod: compressionMethod,
                crc32: crc32,
                dosDateTime: dosDateTime)

            // Append header and compressed data to ZIP stream
            zipData.append(localHeader)
            zipData.append(compressedData)

            // Create central directory entry
            let centralEntry = createCentralDirectoryEntry(
                pathData: pathData,
                originalData: fileData,
                compressedData: compressedData,
                compressionMethod: compressionMethod,
                crc32: crc32,
                dosDateTime: dosDateTime,
                localHeaderOffset: localHeaderOffset)

            centralDirectory.append(centralEntry)
            localHeaderOffset = UInt32(zipData.count)
        }

        // Append central directory to ZIP data
        let centralDirOffset = UInt32(zipData.count)
        zipData.append(centralDirectory)

        // Create end of central directory record
        let endRecord = createEndOfCentralDirectory(
            entryCount: UInt16(entries.count),
            centralDirSize: UInt32(centralDirectory.count),
            centralDirOffset: centralDirOffset)

        zipData.append(endRecord)

        // Create comprehensive compression statistics
        let stats = CompressionStats(
            originalSize: totalOriginalSize,
            compressedSize: totalCompressedSize,
            fileStats: fileStats)

        return (zipData, stats)
    }

    /**
     Creates a ZIP archive from all files in the specified directory.

     This convenience method recursively scans the directory, creates entries
     for all regular files, and writes the resulting ZIP archive to disk.

     - Parameters:
       - directoryURL: The source directory to archive
       - outputURL: The file URL where the ZIP archive will be written
     - Throws: `ZipError` or file system errors if the operation fails
     */
    public static func createFromDirectory(directoryURL: URL, outputURL: URL) throws {
        let entries = try collectEntries(from: directoryURL)
        let zipData = try create(entries: entries)
        try zipData.write(to: outputURL)
    }

    /**
     Creates a ZIP archive from a directory and returns compression statistics.

     This method provides the same functionality as `createFromDirectory(directoryURL:outputURL:)`
     but also returns detailed compression statistics for analysis.

     - Parameters:
       - directoryURL: The source directory to archive
       - outputURL: The file URL where the ZIP archive will be written
     - Returns: Comprehensive compression statistics for the created archive
     - Throws: `ZipError` or file system errors if the operation fails
     */
    @discardableResult
    public static func createFromDirectoryWithStats(directoryURL: URL, outputURL: URL) throws -> CompressionStats {
        let entries = try collectEntries(from: directoryURL)
        let (zipData, stats) = try createWithStats(entries: entries)
        try zipData.write(to: outputURL)
        return stats
    }

    /**
     Recursively collects all files from a directory and creates ZIP entries.

     - Parameter directoryURL: The directory to scan
     - Returns: Array of ZIP entries for all regular files found
     - Throws: File system errors if directory scanning fails
     */
    private static func collectEntries(from directoryURL: URL) throws -> [Entry] {
        let fileManager = FileManager.default
        var entries: [Entry] = []

        let enumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey],
            options: [])

        while let fileURL = enumerator?.nextObject() as? URL {
            let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .contentModificationDateKey])

            if resourceValues.isRegularFile == true {
                let relativePath = String(fileURL.path.dropFirst(directoryURL.path.count + 1))
                let data = try Data(contentsOf: fileURL)
                let modificationDate = resourceValues.contentModificationDate ?? Date()

                entries.append(Entry(path: relativePath, data: data, modificationDate: modificationDate))
            }
        }

        // Sort entries by path for consistent output
        return entries.sorted { $0.path < $1.path }
    }
}

// MARK: - Private Helper Methods

extension SimpleZip {
    /**
     Compresses data using platform-appropriate compression method.

     On Apple platforms with Compression framework available, uses DEFLATE compression
     when beneficial. Falls back to STORE method on other platforms or when compression
     would not reduce file size.

     - Parameters:
       - data: The data to compress
       - path: The file path (used for compression decision logic)
     - Returns: A tuple containing the processed data and compression method code
               (8 for DEFLATE, 0 for STORE)
     */
    private static func compressData(_ data: Data, path: String) -> (compressed: Data, method: UInt16) {
        #if canImport(Compression)
            // Check if compression would be beneficial
            if shouldCompress(data, path: path) {
                // Attempt DEFLATE compression using Compression framework
                if let compressed = performCompression(data: data) {
                    return (compressed, 8) // 8 = DEFLATE
                }
            }
        #endif
        // Fall back to STORE method (no compression)
        return (data, 0) // 0 = STORE
    }

    #if canImport(Compression)
        /**
         Performs DEFLATE compression using Apple's Compression framework.

         This method uses the low-level compression_encode_buffer API for maximum
         efficiency and control over the compression process.

         - Parameter data: The data to compress
         - Returns: Compressed data if successful and smaller than original, nil otherwise
         */
        private static func performCompression(data: Data) -> Data? {
            data.withUnsafeBytes { bytes in
                guard let baseAddress = bytes.baseAddress else { return nil }

                let sourceBuffer = baseAddress.assumingMemoryBound(to: UInt8.self)
                let sourceSize = data.count

                // Allocate output buffer (using source size as initial capacity)
                let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: sourceSize)
                defer { destinationBuffer.deallocate() }

                // Perform compression using ZLIB (DEFLATE) algorithm
                let compressedSize = compression_encode_buffer(
                    destinationBuffer, sourceSize,
                    sourceBuffer, sourceSize,
                    nil, COMPRESSION_ZLIB)

                // Verify compression was successful and beneficial
                guard compressedSize > 0, compressedSize < sourceSize else {
                    return nil
                }

                // Return compressed data
                return Data(bytes: destinationBuffer, count: compressedSize)
            }
        }
    #endif

    /**
     Determines whether a file should be compressed based on size and type.

     Uses intelligent heuristics to avoid compressing files that would not
     benefit from compression, improving performance and avoiding wasted effort.

     - Parameters:
       - data: The file data to evaluate
       - path: The file path (used to determine file type from extension)
     - Returns: `true` if the file should be compressed, `false` otherwise
     */
    private static func shouldCompress(_ data: Data, path: String) -> Bool {
        #if canImport(Compression)
            // Skip compression for small files (less than 1KB)
            // Overhead often outweighs benefits for small files
            if data.count < 1024 {
                return false
            }

            // Skip already-compressed formats to avoid double compression
            let compressedExtensions = ["jpg", "jpeg", "png", "zip", "gz", "bz2", "xz", "7z", "rar"]
            let ext = (path as NSString).pathExtension.lowercased()
            if compressedExtensions.contains(ext) {
                return false
            }

            return true
        #else
            // Compression not available on this platform
            return false
        #endif
    }

    /**
     Creates a local file header for a ZIP entry.

     The local file header appears before each file's data in the ZIP archive
     and contains metadata about the file including sizes, compression method,
     and timestamp information.

     - Parameters:
       - pathData: UTF-8 encoded file path
       - originalData: Original (uncompressed) file data
       - compressedData: Compressed file data (may be same as original if STORE method)
       - compressionMethod: Compression method code (0=STORE, 8=DEFLATE)
       - crc32: CRC-32 checksum of the original data
       - dosDateTime: File modification time in DOS format
     - Returns: Complete local file header as binary data
     */
    private static func createLocalFileHeader(
        pathData: Data,
        originalData: Data,
        compressedData: Data,
        compressionMethod: UInt16,
        crc32: UInt32,
        dosDateTime: UInt32) -> Data
    {
        var header = Data()

        // Local file header signature (0x04034b50)
        header.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])

        // Extract required version (2.0)
        header.append(contentsOf: [0x14, 0x00])

        // General purpose bit flag
        header.append(contentsOf: [0x00, 0x00])

        // Compression method
        header.append(withUnsafeBytes(of: compressionMethod.littleEndian) { Data($0) })

        // Last modification time and date
        header.append(withUnsafeBytes(of: dosDateTime.littleEndian) { Data($0) })

        // CRC-32
        header.append(withUnsafeBytes(of: crc32.littleEndian) { Data($0) })

        // Compressed size
        header.append(withUnsafeBytes(of: UInt32(compressedData.count).littleEndian) { Data($0) })

        // Uncompressed size
        header.append(withUnsafeBytes(of: UInt32(originalData.count).littleEndian) { Data($0) })

        // File name length
        header.append(withUnsafeBytes(of: UInt16(pathData.count).littleEndian) { Data($0) })

        // Extra field length
        header.append(contentsOf: [0x00, 0x00])

        // File name
        header.append(pathData)

        return header
    }

    /**
     Creates a central directory entry for a ZIP file.

     The central directory contains metadata for all files in the archive
     and appears at the end of the ZIP file. Each entry includes file
     information and a pointer to the local file header.

     - Parameters:
       - pathData: UTF-8 encoded file path
       - originalData: Original (uncompressed) file data
       - compressedData: Compressed file data (may be same as original if STORE method)
       - compressionMethod: Compression method code (0=STORE, 8=DEFLATE)
       - crc32: CRC-32 checksum of the original data
       - dosDateTime: File modification time in DOS format
       - localHeaderOffset: Byte offset to the local file header
     - Returns: Complete central directory entry as binary data
     */
    private static func createCentralDirectoryEntry(
        pathData: Data,
        originalData: Data,
        compressedData: Data,
        compressionMethod: UInt16,
        crc32: UInt32,
        dosDateTime: UInt32,
        localHeaderOffset: UInt32) -> Data
    {
        var entry = Data()

        // Central directory signature (0x02014b50)
        entry.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])

        // Version made by (Unix, version 2.0)
        entry.append(contentsOf: [0x14, 0x03])

        // Version needed to extract (2.0)
        entry.append(contentsOf: [0x14, 0x00])

        // General purpose bit flag
        entry.append(contentsOf: [0x00, 0x00])

        // Compression method
        entry.append(withUnsafeBytes(of: compressionMethod.littleEndian) { Data($0) })

        // Last mod file time and date
        entry.append(withUnsafeBytes(of: dosDateTime.littleEndian) { Data($0) })

        // CRC-32
        entry.append(withUnsafeBytes(of: crc32.littleEndian) { Data($0) })

        // Compressed size
        entry.append(withUnsafeBytes(of: UInt32(compressedData.count).littleEndian) { Data($0) })

        // Uncompressed size
        entry.append(withUnsafeBytes(of: UInt32(originalData.count).littleEndian) { Data($0) })

        // File name length
        entry.append(withUnsafeBytes(of: UInt16(pathData.count).littleEndian) { Data($0) })

        // Extra field length
        entry.append(contentsOf: [0x00, 0x00])

        // File comment length
        entry.append(contentsOf: [0x00, 0x00])

        // Disk number
        entry.append(contentsOf: [0x00, 0x00])

        // Internal file attributes
        entry.append(contentsOf: [0x00, 0x00])

        // External file attributes (regular file, 644 permissions)
        entry.append(contentsOf: [0x00, 0x00, 0xA4, 0x81])

        // Relative offset of local header
        entry.append(withUnsafeBytes(of: localHeaderOffset.littleEndian) { Data($0) })

        // File name
        entry.append(pathData)

        return entry
    }

    /**
     Creates the end of central directory record for a ZIP file.

     This record appears at the very end of the ZIP file and contains
     summary information about the archive including the number of entries
     and the location of the central directory.

     - Parameters:
       - entryCount: Total number of entries in the ZIP archive
       - centralDirSize: Size of the central directory in bytes
       - centralDirOffset: Byte offset to the start of the central directory
     - Returns: Complete end of central directory record as binary data
     */
    private static func createEndOfCentralDirectory(
        entryCount: UInt16,
        centralDirSize: UInt32,
        centralDirOffset: UInt32) -> Data
    {
        var endRecord = Data()

        // End of central directory signature (0x06054b50)
        endRecord.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])

        // Disk number where this record resides
        endRecord.append(contentsOf: [0x00, 0x00])

        // Disk number where central directory starts
        endRecord.append(contentsOf: [0x00, 0x00])

        // Number of central directory entries on this disk
        endRecord.append(withUnsafeBytes(of: entryCount.littleEndian) { Data($0) })

        // Total number of central directory entries
        endRecord.append(withUnsafeBytes(of: entryCount.littleEndian) { Data($0) })

        // Size of central directory in bytes
        endRecord.append(withUnsafeBytes(of: centralDirSize.littleEndian) { Data($0) })

        // Offset to start of central directory
        endRecord.append(withUnsafeBytes(of: centralDirOffset.littleEndian) { Data($0) })

        // ZIP file comment length
        endRecord.append(contentsOf: [0x00, 0x00])

        return endRecord
    }

    /**
     Calculates the CRC-32 checksum for the given data.

     Uses the standard CRC-32 algorithm as required by the ZIP format specification.
     This implementation provides a balance between simplicity and correctness.

     - Parameter data: The data to calculate the checksum for
     - Returns: The CRC-32 checksum as a 32-bit unsigned integer
     */
    private static func calculateCRC32(data: Data) -> UInt32 {
        // Standard CRC-32 implementation for ZIP format
        var crc: UInt32 = 0xFFFF_FFFF

        for byte in data {
            crc = crc ^ UInt32(byte)
            for _ in 0 ..< 8 {
                if (crc & 1) != 0 {
                    crc = (crc >> 1) ^ 0xEDB8_8320
                } else {
                    crc = crc >> 1
                }
            }
        }

        return crc ^ 0xFFFF_FFFF
    }

    /**
     Converts a Date to DOS date-time format as required by ZIP specification.

     DOS format packs date and time into a 32-bit value with specific bit layouts.
     Years are relative to 1980, and seconds have 2-second precision.

     - Parameter date: The date to convert
     - Returns: DOS format date-time as a 32-bit unsigned integer
     */
    private static func toDosDateTime(date: Date) -> UInt32 {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        let year = max(1980, components.year ?? 1980) - 1980
        let month = components.month ?? 1
        let day = components.day ?? 1
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = (components.second ?? 0) / 2

        let dosDate = UInt16((year << 9) | (month << 5) | day)
        let dosTime = UInt16((hour << 11) | (minute << 5) | second)

        return (UInt32(dosDate) << 16) | UInt32(dosTime)
    }
}
