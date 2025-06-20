//
// CorporateStyle.swift
// Objects2XLSXDemo
//
// Corporate styling theme for Employee worksheet
//

import Foundation
import Objects2XLSX

// MARK: - Corporate Style Configuration

/// Corporate styling theme for professional business documents
/// 
/// This theme implements a conservative, professional appearance suitable for
/// corporate environments and formal business reporting. It emphasizes readability,
/// clear hierarchy, and traditional corporate design principles.
struct CorporateStyle {
    
    // MARK: - Color Palette
    
    /// Deep corporate blue for headers and accents (#003366)
    static let corporateBlue = Color(red: 0, green: 51, blue: 102)
    
    /// Clean white for backgrounds and text contrast
    static let corporateWhite = Color(red: 255, green: 255, blue: 255)
    
    /// Professional dark gray for text (#333333)
    static let corporateGray = Color(red: 51, green: 51, blue: 51)
    
    /// Light gray for alternating rows and subtle backgrounds (#F8F9FA)
    static let lightGray = Color(red: 248, green: 249, blue: 250)
    
    // MARK: - Typography
    
    /// Standard corporate font family
    static let corporateFontFamily = "Times New Roman"
    
    /// Header font - Times New Roman, 12pt, bold, white
    static let headerFont = Font(
        size: 12,
        name: corporateFontFamily,
        bold: true,
        color: corporateWhite
    )
    
    /// Data font - Times New Roman, 11pt, dark gray
    static let dataFont = Font(
        size: 11,
        name: corporateFontFamily,
        bold: false,
        color: corporateGray
    )
    
    // MARK: - Style Creation Methods
    
    /// Create corporate-themed book style
    /// 
    /// Establishes document-wide corporate styling defaults including professional
    /// fonts, conservative colors, and business-appropriate formatting.
    static func createBookStyle() -> BookStyle {
        return BookStyle(
            sheetStyle: createSheetStyle(),
            bodyCellStyle: createDataStyle(),
            headerCellStyle: createHeaderStyle()
        )
    }
    
    /// Create corporate-themed sheet style
    /// 
    /// Configures worksheet-level settings for professional appearance including
    /// custom row heights, appropriate column widths, and corporate visual elements.
    static func createSheetStyle() -> SheetStyle {
        return SheetStyle(
            defaultColumnWidth: 12.0,           // Professional column width
            defaultRowHeight: 25.0,             // Spacious row height for readability
            showGridlines: false,               // Clean corporate look without gridlines
            showRowAndColumnHeadings: true,     // Keep Excel headers for navigation
            columnHeaderStyle: createHeaderStyle(),
            columnBodyStyle: createDataStyle()
        )
    }
    
    /// Create corporate header cell style
    /// 
    /// Defines the appearance of column headers with corporate branding colors,
    /// professional typography, and clear visual hierarchy.
    static func createHeaderStyle() -> CellStyle {
        return CellStyle(
            font: headerFont,
            fill: Fill.solid(corporateBlue),    // Deep blue corporate background
            alignment: Alignment(
                horizontal: .center,             // Center-aligned headers
                vertical: .center,               // Vertically centered text
                wrapText: false                  // No text wrapping in headers
            ),
            border: Border.all(                 // Complete border around headers
                style: .medium,
                color: corporateWhite
            )
        )
    }
    
    /// Create corporate data cell style
    /// 
    /// Establishes the standard appearance for data cells with readable fonts,
    /// appropriate alignment, and subtle but professional borders.
    static func createDataStyle() -> CellStyle {
        return CellStyle(
            font: dataFont,
            fill: Fill.solid(corporateWhite),   // Clean white background
            alignment: Alignment(
                horizontal: .left,               // Left-aligned data (standard for text)
                vertical: .center,               // Vertically centered for readability
                wrapText: false                  // Prevent text wrapping for clean lines
            ),
            border: Border.all(                 // Thin borders for data separation
                style: .thin,
                color: Color(red: 200, green: 200, blue: 200) // Light gray borders
            )
        )
    }
    
    // MARK: - Specialized Styles
    
    /// Create style for currency/salary columns
    /// 
    /// Specialized styling for financial data with right alignment and
    /// appropriate number formatting hints.
    static func createCurrencyStyle() -> CellStyle {
        return CellStyle(
            font: dataFont,
            fill: Fill.solid(corporateWhite),
            alignment: Alignment(
                horizontal: .right,              // Right-align currency values
                vertical: .center,
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: Color(red: 200, green: 200, blue: 200)
            )
        )
    }
    
    /// Create style for date columns
    /// 
    /// Professional date formatting with appropriate alignment and
    /// corporate styling consistency.
    static func createDateStyle() -> CellStyle {
        return CellStyle(
            font: dataFont,
            fill: Fill.solid(corporateWhite),
            alignment: Alignment(
                horizontal: .center,             // Center-align dates
                vertical: .center,
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: Color(red: 200, green: 200, blue: 200)
            )
        )
    }
    
    /// Create style for boolean/status columns
    /// 
    /// Clean styling for yes/no and status indicator columns with
    /// center alignment for visual consistency.
    static func createStatusStyle() -> CellStyle {
        return CellStyle(
            font: Font(
                size: 11,
                name: corporateFontFamily,
                bold: true,                      // Bold for emphasis on status
                color: corporateGray
            ),
            fill: Fill.solid(corporateWhite),
            alignment: Alignment(
                horizontal: .center,             // Center-align status indicators
                vertical: .center,
                wrapText: false
            ),
            border: Border.all(
                style: .thin,
                color: Color(red: 200, green: 200, blue: 200)
            )
        )
    }
}