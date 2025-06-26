//
// ZipArchiver.swift
// Created by Claude on 2025-06-26.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// Protocol for creating ZIP archives from directory contents.
///
/// This protocol defines the interface for ZIP archive creation,
/// allowing different ZIP implementations to be used interchangeably.
public protocol ZipArchiver: Sendable {
    /// Creates a ZIP archive from all files in the specified directory.
    ///
    /// - Parameters:
    ///   - directoryURL: The source directory to archive
    ///   - outputURL: The file URL where the ZIP archive will be written
    /// - Throws: Implementation-specific errors if the operation fails
    func createArchive(from directoryURL: URL, to outputURL: URL) throws

    /// Creates a ZIP archive from all files in the specified directory with compression statistics.
    ///
    /// - Parameters:
    ///   - directoryURL: The source directory to archive
    ///   - outputURL: The file URL where the ZIP archive will be written
    /// - Returns: Compression statistics for the created archive
    /// - Throws: Implementation-specific errors if the operation fails
    func createArchiveWithStats(from directoryURL: URL, to outputURL: URL) throws -> ZipCompressionStats
}

/// Compression statistics for a ZIP archive operation.
public struct ZipCompressionStats: Sendable {
    /// Total size of all original (uncompressed) data in bytes
    public let originalSize: Int

    /// Total size of all compressed data in bytes
    public let compressedSize: Int

    /// Compression ratio as a percentage between 0 and 100
    public var compressionPercentage: Double {
        guard originalSize > 0 else { return 0.0 }
        return (1.0 - (Double(compressedSize) / Double(originalSize))) * 100
    }

    /// Creates compression statistics
    /// - Parameters:
    ///   - originalSize: Total original size in bytes
    ///   - compressedSize: Total compressed size in bytes
    public init(originalSize: Int, compressedSize: Int) {
        self.originalSize = originalSize
        self.compressedSize = compressedSize
    }
}

// MARK: - SimpleZip Adapter

/// Adapter that makes SimpleZip conform to the ZipArchiver protocol.
public struct SimpleZipArchiver: ZipArchiver {
    /// Creates a new SimpleZip archiver instance
    public init() {}

    public func createArchive(from directoryURL: URL, to outputURL: URL) throws {
        try SimpleZip.createFromDirectory(directoryURL: directoryURL, outputURL: outputURL)
    }

    public func createArchiveWithStats(from directoryURL: URL, to outputURL: URL) throws -> ZipCompressionStats {
        let stats = try SimpleZip.createFromDirectoryWithStats(directoryURL: directoryURL, outputURL: outputURL)
        return ZipCompressionStats(
            originalSize: stats.originalSize,
            compressedSize: stats.compressedSize)
    }
}
