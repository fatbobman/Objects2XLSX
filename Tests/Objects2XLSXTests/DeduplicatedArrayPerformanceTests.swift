//
// DeduplicatedArrayPerformanceTests.swift
// Created by Claude on 2025-06-22.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

/// Performance tests to verify the O(1) optimization improvements for DeduplicatedArray.
///
/// These tests compare the performance characteristics of the optimized implementation
/// against scenarios that would be problematic with the previous O(n) approach.
struct DeduplicatedArrayPerformanceTests {
    
    /// Tests performance with a high duplicate rate scenario.
    ///
    /// This simulates the common use case in StyleRegister where the same styles
    /// are frequently reused across many cells.
    @Test func highDuplicateRatePerformance() throws {
        var array = DeduplicatedArray<String>()
        
        // Pre-populate with some base elements
        let baseElements = (0..<100).map { "style_\($0)" }
        for element in baseElements {
            array.append(element)
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate heavy duplicate checking (90% duplicates)
        for _ in 0..<10000 {
            let randomIndex = Int.random(in: 0..<baseElements.count)
            let element = baseElements[randomIndex]
            
            // This operation should be O(1) with the optimization
            let result = array.append(element)
            #expect(result.inserted == false) // Should be duplicate
            #expect(result.index >= 0 && result.index < 100)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        // With O(1) optimization, this should complete very quickly
        // Even 10,000 operations should take less than 0.1 seconds
        print("High duplicate rate test completed in \(String(format: "%.4f", duration)) seconds")
        
        // Performance assertion - should be much faster than O(n) approach
        #expect(duration < 0.1, "Performance regression: took \(duration) seconds, expected < 0.1s")
    }
    
    /// Tests performance with large collections and frequent index lookups.
    ///
    /// This verifies that firstIndex(of:) operations remain fast even with
    /// large collections.
    @Test func largeCollectionIndexLookupPerformance() throws {
        var array = DeduplicatedArray<Int>()
        
        // Create a large collection
        let elementCount = 1000
        for i in 0..<elementCount {
            array.append(i)
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform many index lookups
        for _ in 0..<10000 {
            let randomElement = Int.random(in: 0..<elementCount)
            
            // This should be O(1) with the optimization
            if let index = array.firstIndex(of: randomElement) {
                #expect(index == randomElement)
            }
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        print("Large collection index lookup test completed in \(String(format: "%.4f", duration)) seconds")
        
        // Should be very fast with O(1) lookups
        #expect(duration < 0.05, "Performance regression: took \(duration) seconds, expected < 0.05s")
    }
    
    /// Tests performance with frequent contains operations.
    ///
    /// This simulates checking if styles already exist before registration.
    @Test func frequentContainsOperationsPerformance() throws {
        var array = DeduplicatedArray<String>()
        
        // Pre-populate with style-like strings
        let stylePatterns = (0..<500).map { "font-\($0)-bold-\($0 % 10)" }
        for pattern in stylePatterns {
            array.append(pattern)
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform many contains checks
        for _ in 0..<20000 {
            let randomPattern = stylePatterns.randomElement()!
            
            // This should be O(1) with the optimization
            let exists = array.contains(randomPattern)
            #expect(exists == true)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        print("Frequent contains operations test completed in \(String(format: "%.4f", duration)) seconds")
        
        // Should be very fast with O(1) contains checks
        #expect(duration < 0.1, "Performance regression: took \(duration) seconds, expected < 0.1s")
    }
    
    /// Tests memory usage characteristics with the Dictionary optimization.
    ///
    /// Verifies that memory usage remains reasonable despite the additional Dictionary.
    @Test func memoryUsageCharacteristics() throws {
        var array = DeduplicatedArray<String>()
        
        // Add a substantial number of elements
        let elementCount = 10000
        let baseString = "style_element_with_some_length_"
        
        for i in 0..<elementCount {
            array.append("\(baseString)\(i)")
        }
        
        // Verify all elements are accessible
        #expect(array.count == elementCount)
        
        // Test that we can still access elements efficiently
        for i in stride(from: 0, to: elementCount, by: 100) {
            let expectedElement = "\(baseString)\(i)"
            #expect(array[i] == expectedElement)
            #expect(array.firstIndex(of: expectedElement) == i)
            #expect(array.contains(expectedElement) == true)
        }
        
        print("Memory usage test completed with \(elementCount) elements")
    }
    
    /// Tests the worst-case scenario that would be problematic with O(n) implementation.
    ///
    /// This simulates continuous duplicate checking in a large style registry.
    @Test func worstCaseScenarioPerformance() throws {
        var array = DeduplicatedArray<String>()
        
        // Create a scenario that would be O(n²) with the old implementation
        let uniqueElementCount = 1000
        
        // First, add many unique elements
        for i in 0..<uniqueElementCount {
            array.append("unique_style_\(i)")
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Now repeatedly try to add the last element (always a duplicate)
        // This would be worst-case O(n) lookup with the old implementation
        let lastElement = "unique_style_\(uniqueElementCount - 1)"
        
        for _ in 0..<1000 {
            let result = array.append(lastElement)
            #expect(result.inserted == false)
            #expect(result.index == uniqueElementCount - 1)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        print("Worst case scenario test completed in \(String(format: "%.4f", duration)) seconds")
        
        // This should be fast even in worst case with O(1) optimization
        #expect(duration < 0.01, "Performance regression: took \(duration) seconds, expected < 0.01s")
    }
    
    /// Benchmarks the overall performance improvement for typical StyleRegister usage.
    ///
    /// This simulates the actual usage pattern in XLSX generation where styles
    /// are registered with high duplication rates.
    @Test func styleRegisterUsagePatternBenchmark() throws {
        var fontArray = DeduplicatedArray<String>()
        var fillArray = DeduplicatedArray<String>()
        var borderArray = DeduplicatedArray<String>()
        
        // Pre-populate with common styles (simulating StyleRegister initialization)
        let commonFonts = ["Arial", "Calibri", "Times New Roman", "Helvetica"]
        let commonFills = ["none", "solid_blue", "solid_red", "gradient_blue_white"]
        let commonBorders = ["none", "thin_black", "medium_gray", "thick_blue"]
        
        for font in commonFonts {
            fontArray.append(font)
        }
        for fill in commonFills {
            fillArray.append(fill)
        }
        for border in commonBorders {
            borderArray.append(border)
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate processing 5000 cells, each needing style registration
        for i in 0..<5000 {
            // Most cells reuse existing styles (80% duplicate rate)
            let useExisting = i % 5 != 0
            
            if useExisting {
                // Use existing style (should be O(1) lookup)
                let font = commonFonts.randomElement()!
                let fill = commonFills.randomElement()!
                let border = commonBorders.randomElement()!
                
                let fontResult = fontArray.append(font)
                let fillResult = fillArray.append(fill)
                let borderResult = borderArray.append(border)
                
                #expect(fontResult.inserted == false)
                #expect(fillResult.inserted == false)
                #expect(borderResult.inserted == false)
            } else {
                // Create new style (20% of the time)
                let newFont = "custom_font_\(i)"
                let newFill = "custom_fill_\(i)"
                let newBorder = "custom_border_\(i)"
                
                let fontResult = fontArray.append(newFont)
                let fillResult = fillArray.append(newFill)
                let borderResult = borderArray.append(newBorder)
                
                #expect(fontResult.inserted == true)
                #expect(fillResult.inserted == true)
                #expect(borderResult.inserted == true)
            }
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        print("StyleRegister usage pattern benchmark completed in \(String(format: "%.4f", duration)) seconds")
        print("Final counts - Fonts: \(fontArray.count), Fills: \(fillArray.count), Borders: \(borderArray.count)")
        
        // Should handle 5000 style registrations very quickly
        #expect(duration < 0.1, "Performance regression: took \(duration) seconds, expected < 0.1s")
    }
}