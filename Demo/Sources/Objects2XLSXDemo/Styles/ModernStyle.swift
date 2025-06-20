//
// ModernStyle.swift
// Objects2XLSXDemo
//
// Modern styling theme for Product worksheet
//

import Foundation
import Objects2XLSX

// MARK: - Modern Style Configuration

/// Modern styling theme for contemporary documents
/// 
/// This theme implements a clean, contemporary design suitable for modern
/// business applications and user-facing reports. It emphasizes visual
/// hierarchy, subtle colors, and excellent readability.
struct ModernStyle {
    
    // MARK: - Color Palette
    
    /// Primary modern blue for headers and accents (#4A90E2)
    static let modernBlue = Color(red: 74, green: 144, blue: 226)
    
    /// Secondary teal accent color (#50C8A3)
    static let modernTeal = Color(red: 80, green: 200, blue: 163)
    
    /// Soft gray for backgrounds and subtle elements (#F8F9FA)
    static let softGray = Color(red: 248, green: 249, blue: 250)
    
    /// Medium gray for text and borders (#6C757D)
    static let mediumGray = Color(red: 108, green: 117, blue: 125)
    
    /// Dark charcoal for primary text (#343A40)
    static let darkCharcoal = Color(red: 52, green: 58, blue: 64)
    
    /// Clean white for backgrounds
    static let cleanWhite = Color(red: 255, green: 255, blue: 255)
    
    /// Warning orange for low stock alerts (#FF6B35)
    static let warningOrange = Color(red: 255, green: 107, blue: 53)
    
    /// Success green for high stock (#28A745)
    static let successGreen = Color(red: 40, green: 167, blue: 69)
    
    // MARK: - Typography
    
    /// Modern font family - prioritize system fonts
    static let modernFontFamily = "Helvetica"
    
    /// Header font - Helvetica, 12pt, bold, white
    static let headerFont = Font(
        size: 12,
        name: modernFontFamily,
        bold: true,
        color: cleanWhite
    )
    
    /// Data font - Helvetica, 10pt, dark charcoal
    static let dataFont = Font(
        size: 10,
        name: modernFontFamily,
        bold: false,
        color: darkCharcoal
    )
    
    /// Emphasis font - Helvetica, 10pt, bold, for important data
    static let emphasisFont = Font(
        size: 10,
        name: modernFontFamily,
        bold: true,
        color: darkCharcoal
    )
    
    // MARK: - Style Creation Methods
    
    /// Create modern-themed book style
    /// 
    /// Establishes document-wide modern styling defaults with contemporary
    /// colors, clean typography, and minimalist design principles.
    static func createBookStyle() -> BookStyle {
        return BookStyle(
            sheetStyle: createSheetStyle(),
            bodyCellStyle: createDataStyle(),
            headerCellStyle: createHeaderStyle()
        )
    }
    
    /// Create modern-themed sheet style
    /// 
    /// Configures worksheet-level settings for contemporary appearance with
    /// optimized dimensions, clean borders, and modern visual elements.
    static func createSheetStyle() -> SheetStyle {
        return SheetStyle(
            defaultColumnWidth: 14.0,           // Wider columns for modern readability
            defaultRowHeight: 20.0,             // Compact but comfortable row height
            showGridlines: true,                // Keep subtle gridlines for structure
            showRowAndColumnHeadings: true,     // Maintain Excel navigation
            columnHeaderStyle: createHeaderStyle(),
            columnBodyStyle: createDataStyle()
        )
    }
    
    /// Create modern header cell style
    /// 
    /// Defines contemporary header appearance with gradient-style colors,
    /// clean typography, and minimal but effective borders.
    static func createHeaderStyle() -> CellStyle {
        return CellStyle(
            font: headerFont,
            fill: Fill.solid(modernBlue),       // Modern blue gradient-style background
            alignment: Alignment(
                horizontal: .center,             // Center-aligned headers
                vertical: .center,               // Vertically centered
                wrapText: false                  // No wrapping for clean lines
            ),
            border: Border.outline(             // Clean outline only
                style: .thin,
                color: Color(red: 220, green: 220, blue: 220)
            )
        )
    }
    
    /// Create modern data cell style
    /// 
    /// Establishes clean, readable appearance for data cells with subtle
    /// styling that emphasizes content over decoration.
    static func createDataStyle() -> CellStyle {
        return CellStyle(
            font: dataFont,
            fill: Fill.solid(cleanWhite),       // Clean white background
            alignment: Alignment(
                horizontal: .left,               // Left-aligned for readability
                vertical: .center,               // Vertically centered
                wrapText: true                   // Allow text wrapping for descriptions
            ),
            border: Border.horizontal(          // Horizontal lines only for clean look
                style: .thin,
                color: Color(red: 240, green: 240, blue: 240)
            )
        )
    }
    
    // MARK: - Specialized Modern Styles
    
    /// Create conditional style for low stock items
    /// 
    /// Eye-catching warning style for inventory alerts with appropriate
    /// contrast and emphasis for critical information.
    static func createLowStockStyle() -> CellStyle {
        return CellStyle(
            font: Font(
                size: 10,
                name: modernFontFamily,
                bold: true,                      // Bold for warning emphasis
                color: cleanWhite               // White text for contrast
            ),
            fill: Fill.solid(warningOrange),    // Warning orange background
            alignment: Alignment(
                horizontal: .center,             // Center-align warning indicators
                vertical: .center,
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: Color(red: 200, green: 85, blue: 42) // Darker orange border
            )
        )
    }
    
    /// Create style for high stock items
    /// 
    /// Success styling for well-stocked items with positive visual cues.
    static func createHighStockStyle() -> CellStyle {
        return CellStyle(
            font: Font(
                size: 10,
                name: modernFontFamily,
                bold: true,
                color: cleanWhite
            ),
            fill: Fill.solid(successGreen),     // Success green background
            alignment: Alignment(
                horizontal: .center,
                vertical: .center,
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: Color(red: 32, green: 134, blue: 56) // Darker green border
            )
        )
    }
    
    /// Create alternating row style for modern appearance
    /// 
    /// Subtle alternating row styling that improves readability without
    /// overwhelming the content.
    static func createAlternatingRowStyle() -> CellStyle {
        return CellStyle(
            font: dataFont,
            fill: Fill.solid(softGray),         // Very light gray for subtle alternation
            alignment: Alignment(
                horizontal: .left,
                vertical: .center,
                wrapText: true
            ),
            border: Border.horizontal(
                style: .thin,
                color: Color(red: 240, green: 240, blue: 240)
            )
        )
    }
    
    /// Create style for product descriptions
    /// 
    /// Special styling for longer text content with appropriate wrapping
    /// and spacing for optimal readability.
    static func createDescriptionStyle() -> CellStyle {
        return CellStyle(
            font: Font(
                size: 9,                         // Slightly smaller for descriptions
                name: modernFontFamily,
                bold: false,
                color: mediumGray               // Medium gray for secondary text
            ),
            fill: Fill.solid(cleanWhite),
            alignment: Alignment(
                horizontal: .left,
                vertical: .top,                  // Top-align for multi-line content
                wrapText: true                   // Enable wrapping for descriptions
            ),
            border: Border.horizontal(
                style: .thin,
                color: Color(red: 240, green: 240, blue: 240)
            )
        )
    }
    
    /// Create style for rating/star columns
    /// 
    /// Distinctive styling for star ratings and review scores with
    /// appropriate emphasis and visual appeal.
    static func createRatingStyle() -> CellStyle {
        return CellStyle(
            font: Font(
                size: 11,                        // Slightly larger for star visibility
                name: modernFontFamily,
                bold: false,
                color: Color(red: 255, green: 193, blue: 7) // Golden color for stars
            ),
            fill: Fill.solid(cleanWhite),
            alignment: Alignment(
                horizontal: .center,             // Center-align star ratings
                vertical: .center,
                wrapText: false
            ),
            border: Border.horizontal(
                style: .thin,
                color: Color(red: 240, green: 240, blue: 240)
            )
        )
    }
    
    /// Create style for price columns
    /// 
    /// Professional styling for pricing information with appropriate
    /// alignment and emphasis.
    static func createPriceStyle() -> CellStyle {
        return CellStyle(
            font: emphasisFont,                 // Bold emphasis for prices
            fill: Fill.solid(cleanWhite),
            alignment: Alignment(
                horizontal: .right,              // Right-align monetary values
                vertical: .center,
                wrapText: false
            ),
            border: Border.horizontal(
                style: .thin,
                color: Color(red: 240, green: 240, blue: 240)
            )
        )
    }
}