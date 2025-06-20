//
// SimpleZip.swift
// Created by Claude on 2025-06-20.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// 轻量级 ZIP 实现，专门用于创建 XLSX 文件
/// 仅支持 STORE 方法（无压缩），足够 XLSX 使用
public struct SimpleZip: Sendable {
    
    /// ZIP 文件条目
    public struct Entry: Sendable {
        public let path: String
        public let data: Data
        public let modificationDate: Date
        
        public init(path: String, data: Data, modificationDate: Date = Date()) {
            self.path = path
            self.data = data
            self.modificationDate = modificationDate
        }
    }
    
    /// ZIP 创建错误
    public enum ZipError: Error, Sendable {
        case invalidPath(String)
        case dataWriteError(String)
        case fileTooLarge(String)
    }
    
    /// 创建 ZIP 文件数据
    /// - Parameter entries: 文件条目列表
    /// - Returns: ZIP 文件的二进制数据
    public static func create(entries: [Entry]) throws -> Data {
        var zipData = Data()
        var centralDirectory = Data()
        var localHeaderOffset: UInt32 = 0
        
        for entry in entries {
            // 验证路径
            guard !entry.path.isEmpty, !entry.path.contains("..") else {
                throw ZipError.invalidPath("Invalid path: \(entry.path)")
            }
            
            // 验证文件大小（ZIP 格式限制）
            guard entry.data.count <= UInt32.max else {
                throw ZipError.fileTooLarge("File too large: \(entry.path)")
            }
            
            let pathData = entry.path.data(using: .utf8) ?? Data()
            let fileData = entry.data
            let crc32 = calculateCRC32(data: fileData)
            let dosDateTime = toDosDateTime(date: entry.modificationDate)
            
            // 创建本地文件头
            let localHeader = createLocalFileHeader(
                pathData: pathData,
                fileData: fileData,
                crc32: crc32,
                dosDateTime: dosDateTime
            )
            
            // 添加到 ZIP 数据
            zipData.append(localHeader)
            zipData.append(fileData)
            
            // 创建中央目录条目
            let centralEntry = createCentralDirectoryEntry(
                pathData: pathData,
                fileData: fileData,
                crc32: crc32,
                dosDateTime: dosDateTime,
                localHeaderOffset: localHeaderOffset
            )
            
            centralDirectory.append(centralEntry)
            localHeaderOffset = UInt32(zipData.count)
        }
        
        // 添加中央目录
        let centralDirOffset = UInt32(zipData.count)
        zipData.append(centralDirectory)
        
        // 创建中央目录结束记录
        let endRecord = createEndOfCentralDirectory(
            entryCount: UInt16(entries.count),
            centralDirSize: UInt32(centralDirectory.count),
            centralDirOffset: centralDirOffset
        )
        
        zipData.append(endRecord)
        return zipData
    }
    
    /// 从目录创建 ZIP 文件
    /// - Parameters:
    ///   - directoryURL: 源目录
    ///   - outputURL: 输出 ZIP 文件路径
    public static func createFromDirectory(directoryURL: URL, outputURL: URL) throws {
        let entries = try collectEntries(from: directoryURL)
        let zipData = try create(entries: entries)
        try zipData.write(to: outputURL)
    }
    
    /// 收集目录中的所有文件
    private static func collectEntries(from directoryURL: URL) throws -> [Entry] {
        let fileManager = FileManager.default
        var entries: [Entry] = []
        
        let enumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .contentModificationDateKey])
            
            if resourceValues.isRegularFile == true {
                let relativePath = String(fileURL.path.dropFirst(directoryURL.path.count + 1))
                let data = try Data(contentsOf: fileURL)
                let modificationDate = resourceValues.contentModificationDate ?? Date()
                
                entries.append(Entry(path: relativePath, data: data, modificationDate: modificationDate))
            }
        }
        
        // 按路径排序以确保一致性
        return entries.sorted { $0.path < $1.path }
    }
}

// MARK: - Private Helper Methods

extension SimpleZip {
    
    /// 创建本地文件头
    private static func createLocalFileHeader(
        pathData: Data,
        fileData: Data,
        crc32: UInt32,
        dosDateTime: UInt32
    ) -> Data {
        var header = Data()
        
        // 本地文件头签名 (0x04034b50)
        header.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        
        // 提取所需版本 (2.0)
        header.append(contentsOf: [0x14, 0x00])
        
        // 通用标志位
        header.append(contentsOf: [0x00, 0x00])
        
        // 压缩方法 (0 = STORE, 无压缩)
        header.append(contentsOf: [0x00, 0x00])
        
        // 最后修改时间和日期
        header.append(withUnsafeBytes(of: dosDateTime.littleEndian) { Data($0) })
        
        // CRC-32
        header.append(withUnsafeBytes(of: crc32.littleEndian) { Data($0) })
        
        // 压缩大小
        header.append(withUnsafeBytes(of: UInt32(fileData.count).littleEndian) { Data($0) })
        
        // 未压缩大小
        header.append(withUnsafeBytes(of: UInt32(fileData.count).littleEndian) { Data($0) })
        
        // 文件名长度
        header.append(withUnsafeBytes(of: UInt16(pathData.count).littleEndian) { Data($0) })
        
        // 额外字段长度
        header.append(contentsOf: [0x00, 0x00])
        
        // 文件名
        header.append(pathData)
        
        return header
    }
    
    /// 创建中央目录条目
    private static func createCentralDirectoryEntry(
        pathData: Data,
        fileData: Data,
        crc32: UInt32,
        dosDateTime: UInt32,
        localHeaderOffset: UInt32
    ) -> Data {
        var entry = Data()
        
        // 中央目录签名 (0x02014b50)
        entry.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        
        // 制作版本 (Unix, version 2.0)
        entry.append(contentsOf: [0x14, 0x03])
        
        // 提取所需版本 (2.0)
        entry.append(contentsOf: [0x14, 0x00])
        
        // 通用标志位
        entry.append(contentsOf: [0x00, 0x00])
        
        // 压缩方法 (0 = STORE)
        entry.append(contentsOf: [0x00, 0x00])
        
        // 最后修改时间和日期
        entry.append(withUnsafeBytes(of: dosDateTime.littleEndian) { Data($0) })
        
        // CRC-32
        entry.append(withUnsafeBytes(of: crc32.littleEndian) { Data($0) })
        
        // 压缩大小
        entry.append(withUnsafeBytes(of: UInt32(fileData.count).littleEndian) { Data($0) })
        
        // 未压缩大小
        entry.append(withUnsafeBytes(of: UInt32(fileData.count).littleEndian) { Data($0) })
        
        // 文件名长度
        entry.append(withUnsafeBytes(of: UInt16(pathData.count).littleEndian) { Data($0) })
        
        // 额外字段长度
        entry.append(contentsOf: [0x00, 0x00])
        
        // 文件注释长度
        entry.append(contentsOf: [0x00, 0x00])
        
        // 磁盘号
        entry.append(contentsOf: [0x00, 0x00])
        
        // 内部文件属性
        entry.append(contentsOf: [0x00, 0x00])
        
        // 外部文件属性 (regular file, 644 permissions)
        entry.append(contentsOf: [0x00, 0x00, 0x81, 0x00])
        
        // 本地文件头相对偏移
        entry.append(withUnsafeBytes(of: localHeaderOffset.littleEndian) { Data($0) })
        
        // 文件名
        entry.append(pathData)
        
        return entry
    }
    
    /// 创建中央目录结束记录
    private static func createEndOfCentralDirectory(
        entryCount: UInt16,
        centralDirSize: UInt32,
        centralDirOffset: UInt32
    ) -> Data {
        var endRecord = Data()
        
        // 中央目录结束签名 (0x06054b50)
        endRecord.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        
        // 此磁盘号
        endRecord.append(contentsOf: [0x00, 0x00])
        
        // 中央目录开始磁盘号
        endRecord.append(contentsOf: [0x00, 0x00])
        
        // 此磁盘上的中央目录条目数
        endRecord.append(withUnsafeBytes(of: entryCount.littleEndian) { Data($0) })
        
        // 中央目录总条目数
        endRecord.append(withUnsafeBytes(of: entryCount.littleEndian) { Data($0) })
        
        // 中央目录大小
        endRecord.append(withUnsafeBytes(of: centralDirSize.littleEndian) { Data($0) })
        
        // 中央目录偏移
        endRecord.append(withUnsafeBytes(of: centralDirOffset.littleEndian) { Data($0) })
        
        // ZIP 文件注释长度
        endRecord.append(contentsOf: [0x00, 0x00])
        
        return endRecord
    }
    
    /// 计算 CRC32 校验码
    private static func calculateCRC32(data: Data) -> UInt32 {
        // 简化的 CRC32 实现
        var crc: UInt32 = 0xFFFFFFFF
        
        for byte in data {
            crc = crc ^ UInt32(byte)
            for _ in 0..<8 {
                if (crc & 1) != 0 {
                    crc = (crc >> 1) ^ 0xEDB88320
                } else {
                    crc = crc >> 1
                }
            }
        }
        
        return crc ^ 0xFFFFFFFF
    }
    
    /// 将 Date 转换为 DOS 日期时间格式
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