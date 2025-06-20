//
// DefaultStyle.swift
// Objects2XLSXDemo
//
// Default styling theme for Order worksheet
//

import Foundation
import Objects2XLSX

// MARK: - Default Style Configuration

/// Default styling theme using Excel's built-in styles
/// 
/// This theme provides minimal styling that closely matches Excel's default
/// appearance. It's designed to demonstrate the library's capabilities without
/// overwhelming custom styling, letting the data speak for itself.
struct DefaultStyle {
    
    // MARK: - Default Colors and Fonts
    
    /// Standard Excel font (Calibri)
    static let defaultFontFamily = "Calibri"
    
    /// Standard black text color
    static let standardBlack = Color(red: 0, green: 0, blue: 0)
    
    /// Standard white background
    static let standardWhite = Color(red: 255, green: 255, blue: 255)
    
    /// Light gray for subtle borders
    static let lightGray = Color(red: 217, green: 217, blue: 217)
    
    /// Medium gray for headers
    static let mediumGray = Color(red: 166, green: 166, blue: 166)
    
    /// Excel's default header font - Calibri, 11pt, bold
    static let defaultHeaderFont = Font(
        size: 11,
        name: defaultFontFamily,
        bold: true,
        color: standardBlack
    )
    
    /// Excel's default data font - Calibri, 11pt, regular
    static let defaultDataFont = Font(
        size: 11,
        name: defaultFontFamily,
        bold: false,
        color: standardBlack
    )
    
    // MARK: - Style Creation Methods
    
    /// Create default book style
    /// 
    /// Provides minimal book-level styling that relies primarily on Excel's
    /// built-in defaults for maximum compatibility and familiarity.
    static func createBookStyle() -> BookStyle {
        return BookStyle(
            sheetStyle: createSheetStyle(),
            bodyCellStyle: createDataStyle(),
            headerCellStyle: createHeaderStyle()
        )
    }
    
    /// Create default sheet style
    /// 
    /// Uses Excel's standard sheet configuration with minimal customization.
    /// This provides a familiar experience for users accustomed to Excel defaults.
    static func createSheetStyle() -> SheetStyle {
        return SheetStyle(
            defaultColumnWidth: 8.43,           // Excel's standard column width
            defaultRowHeight: 15.0,             // Excel's standard row height
            showGridlines: true,                // Standard Excel gridlines
            showRowAndColumnHeadings: true,     // Standard Excel headers
            columnHeaderStyle: createHeaderStyle(),
            columnBodyStyle: createDataStyle()
        )
    }
    
    /// Create simple header cell style
    /// 
    /// Basic header styling that provides clear visual hierarchy without
    /// complex formatting. Uses standard fonts and minimal decoration.
    static func createHeaderStyle() -> CellStyle {
        return CellStyle(
            font: defaultHeaderFont,
            fill: Fill.solid(Color(red: 242, green: 242, blue: 242)), // Very light gray
            alignment: Alignment(
                horizontal: .center,             // Center-aligned headers
                vertical: .center,               // Vertically centered
                wrapText: false                  // No text wrapping
            ),
            border: Border.all(                 // Simple border all around
                style: .thin,
                color: lightGray
            )
        )
    }
    
    /// Create basic data cell style
    /// 
    /// Minimal data cell styling that matches Excel's default appearance.
    /// Focuses on readability and familiarity over visual impact.
    static func createDataStyle() -> CellStyle {
        return CellStyle(
            font: defaultDataFont,
            fill: Fill.solid(standardWhite),    // Standard white background
            alignment: Alignment(
                horizontal: .left,               // Left-aligned data (Excel default)
                vertical: .bottom,               // Bottom-aligned (Excel default)
                wrapText: false                  // No text wrapping by default
            ),
            border: Border.all(                 // Thin borders for basic structure
                style: .thin,
                color: lightGray
            )
        )
    }
    
    // MARK: - Specialized Default Styles
    
    /// Create style for currency columns
    /// 
    /// Simple right-aligned styling for monetary values, following
    /// standard Excel conventions for financial data.
    static func createCurrencyStyle() -> CellStyle {
        return CellStyle(
            font: defaultDataFont,
            fill: Fill.solid(standardWhite),
            alignment: Alignment(
                horizontal: .right,              // Right-align currency values
                vertical: .bottom,               // Excel default vertical alignment
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: lightGray
            )
        )
    }
    
    /// Create style for date columns
    /// 
    /// Standard center-aligned styling for dates with default formatting.
    static func createDateStyle() -> CellStyle {
        return CellStyle(
            font: defaultDataFont,
            fill: Fill.solid(standardWhite),
            alignment: Alignment(
                horizontal: .center,             // Center-align dates
                vertical: .bottom,               // Excel default vertical alignment
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: lightGray
            )
        )
    }
    
    /// Create style for status columns
    /// 
    /// Simple center-aligned styling for status indicators and
    /// categorical data.
    static func createStatusStyle() -> CellStyle {
        return CellStyle(
            font: defaultDataFont,
            fill: Fill.solid(standardWhite),
            alignment: Alignment(
                horizontal: .center,             // Center-align status values
                vertical: .bottom,               // Excel default vertical alignment
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: lightGray
            )
        )
    }
    
    /// Create style for numeric columns
    /// 
    /// Right-aligned styling for numerical data following standard
    /// spreadsheet conventions.
    static func createNumericStyle() -> CellStyle {
        return CellStyle(
            font: defaultDataFont,
            fill: Fill.solid(standardWhite),
            alignment: Alignment(
                horizontal: .right,              // Right-align numbers
                vertical: .bottom,               // Excel default vertical alignment
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: lightGray
            )
        )
    }
    
    /// Create style for text columns with wrapping
    /// 
    /// Left-aligned styling with text wrapping enabled for longer
    /// content like descriptions or comments.
    static func createTextWrapStyle() -> CellStyle {
        return CellStyle(
            font: defaultDataFont,
            fill: Fill.solid(standardWhite),
            alignment: Alignment(
                horizontal: .left,               // Left-align text
                vertical: .top,                  // Top-align for multi-line content
                wrapText: true                   // Enable text wrapping
            ),
            border: Border.all(
                style: .thin,
                color: lightGray
            )
        )
    }
}