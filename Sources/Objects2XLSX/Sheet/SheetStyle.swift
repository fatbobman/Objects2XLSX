//
// SheetStyle.swift
// Created by Xu Yang on 2025-06-17.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Comprehensive styling configuration for Excel worksheets.

 `SheetStyle` provides complete control over the visual appearance and behavior
 of individual worksheets within an Excel workbook. It encompasses everything from
 basic dimensions and display options to advanced features like freeze panes,
 custom borders, and print settings.

 ## Overview

 This structure serves as the primary styling interface for worksheet customization,
 supporting Excel's extensive formatting capabilities while maintaining type safety
 and ease of use. All style properties can be configured independently and are
 properly merged when multiple style sources are involved.

 ## Style Categories

 - **Dimensions**: Default row heights, column widths, and custom sizing
 - **Display Options**: Gridlines, headers, formulas, and visual elements
 - **Layout Features**: Freeze panes, zoom levels, and tab colors
 - **Data Borders**: Automated border application around data regions
 - **Print Configuration**: Page setup, margins, and print-specific settings
 - **Cell Styling**: Default styles for headers and data cells

 ## Usage Examples

 ### Basic Configuration
 ```swift
 let style = SheetStyle()
     .defaultRowHeight(20)
     .showGridlines(false)
     .tabColor(.blue)
 ```

 ### Advanced Styling
 ```swift
 let advancedStyle = SheetStyle(
     defaultColumnWidth: 12.0,
     defaultRowHeight: 18.0,
     columnHeaderStyle: headerStyle,
     columnBodyStyle: dataStyle
 )
 .freezePanes(.freezeTopRow())
 .zoom(.custom(150))
 .dataBorder(.withHeader(style: .medium))
 ```

 ## Integration

 `SheetStyle` integrates seamlessly with the style hierarchy:
 - **Book Level**: Provides workbook-wide defaults
 - **Sheet Level**: This structure - worksheet-specific overrides
 - **Column Level**: Column-specific styling enhancements
 - **Cell Level**: Individual cell styling (highest priority)

 - Note: All properties use Excel-compatible units and conventions
 */
public struct SheetStyle: Equatable, Hashable, Sendable {
    // MARK: - Nested Types

    /**
     Configuration for custom column widths in Excel-compatible units.

     Defines the width specification for individual columns, supporting both
     character-based and point-based measurements as used by Excel.
     */
    public struct ColumnWidth: Equatable, Hashable, Sendable {
        /// The width value in the specified unit
        public let width: Double

        /// The unit of measurement (characters or points)
        public let unit: Unit

        /// Whether this represents a custom width (as opposed to auto-calculated)
        public let isCustomWidth: Bool
    }

    /**
     Print-specific configuration for worksheet output.

     Comprehensive print settings that control how the worksheet appears
     when printed, including paper selection, scaling, and repeat regions.
     */
    public struct PrintSettings: Equatable, Hashable, Sendable {
        /// Paper size for printing (A4, Letter, Legal, etc.)
        public let paperSize: PaperSize

        /// Page orientation (portrait or landscape)
        public let orientation: Orientation

        /// Print scaling factor (as percentage)
        public let scale: Double

        /// Whether to scale content to fit on pages
        public let fitToPage: Bool

        /// Page margins configuration
        public let margins: Margins

        /// Row indices to repeat on each printed page
        public let repeatRows: [Int]?

        /// Column indices to repeat on each printed page
        public let repeatColumns: [Int]?
    }

    /**
     Page layout and header/footer configuration for printing.

     Controls the overall page appearance and content that appears
     outside the main data area when printing.
     */
    public struct PageSetup: Equatable, Hashable, Sendable {
        /// Custom header text (appears at top of each page)
        public let header: String?

        /// Custom footer text (appears at bottom of each page)
        public let footer: String?

        /// Whether to center content horizontally on the page
        public let centerHorizontally: Bool

        /// Whether to center content vertically on the page
        public let centerVertically: Bool

        /// Whether to print worksheet gridlines
        public let printGridlines: Bool

        /// Whether to print row and column headings (A, B, C... and 1, 2, 3...)
        public let printRowAndColumnHeadings: Bool
    }

    /**
     Definition of merged cell regions within the worksheet.

     Specifies rectangular areas where multiple cells should be
     combined into a single logical cell for display and editing.
     */
    public struct MergedCell: Equatable, Hashable, Sendable {
        /// Starting row index (1-based Excel indexing)
        public let startRow: Int

        /// Starting column index (1-based Excel indexing)
        public let startColumn: Int

        /// Ending row index (1-based Excel indexing)
        public let endRow: Int

        /// Ending column index (1-based Excel indexing)
        public let endColumn: Int
    }

    /**
     Freeze panes configuration for fixed row and column display.

     Controls which rows and columns remain visible when scrolling,
     providing context for large datasets. Supports various freeze
     patterns including top row, first column, and custom regions.
     */
    public struct FreezePanes: Equatable, Hashable, Sendable {
        /// Number of rows to freeze from the top
        public let frozenRows: Int

        /// Number of columns to freeze from the left
        public let frozenColumns: Int

        /// Whether to freeze only the top row (simplified mode)
        public let freezeTopRow: Bool

        /// Whether to freeze only the first column (simplified mode)
        public let freezeFirstColumn: Bool
    }

    /**
     Zoom level configuration for worksheet display.

     Controls the display scaling of the worksheet in Excel,
     affecting how much content is visible at once without
     changing the actual cell dimensions.
     */
    public struct Zoom: Equatable, Hashable, Sendable {
        /// Zoom scale percentage (10-400)
        public let scale: Int

        /// Whether this is a custom zoom level
        public let isCustomScale: Bool
    }

    /**
     Data region boundary definition for border and formatting application.

     Defines the rectangular area that contains actual data,
     used for automated border application and data region highlighting.
     */
    public struct DataRange: Equatable, Hashable, Sendable {
        /// Starting row of the data region
        public let startRow: Int

        /// Starting column of the data region
        public let startColumn: Int

        /// Ending row of the data region
        public let endRow: Int

        /// Ending column of the data region
        public let endColumn: Int
    }

    /**
     Automated border application settings for data regions.

     Provides intelligent border application around data areas,
     with options for including headers and customizing border styles.
     This feature automatically applies consistent borders without
     manual cell-by-cell configuration.
     */
    public struct DataBorderSettings: Equatable, Hashable, Sendable {
        /// Whether to enable automatic data region borders
        public let enabled: Bool

        /// Whether borders should include the header row
        public let includeHeader: Bool

        /// The border style to apply around the data region
        public let borderStyle: BorderStyle

        /**
         Creates a new data border configuration.

         - Parameters:
            - enabled: Whether to enable automatic border application
            - includeHeader: Whether to include header rows in the border region
            - borderStyle: The style of border to apply
         */
        public init(enabled: Bool = false, includeHeader: Bool = true, borderStyle: BorderStyle = .thin) {
            self.enabled = enabled
            self.includeHeader = includeHeader
            self.borderStyle = borderStyle
        }

        /// Default configuration with borders disabled
        public static let `default` = DataBorderSettings()

        /**
         Creates a configuration with borders enabled and headers included.

         - Parameter style: The border style to use (defaults to thin)
         - Returns: A configured `DataBorderSettings` with headers included
         */
        public static func withHeader(style: BorderStyle = .thin) -> DataBorderSettings {
            DataBorderSettings(enabled: true, includeHeader: true, borderStyle: style)
        }

        /**
         Creates a configuration with borders enabled but headers excluded.

         - Parameter style: The border style to use (defaults to thin)
         - Returns: A configured `DataBorderSettings` with headers excluded
         */
        public static func withoutHeader(style: BorderStyle = .thin) -> DataBorderSettings {
            DataBorderSettings(enabled: true, includeHeader: false, borderStyle: style)
        }
    }

    // MARK: - Properties

    /// Custom column width settings, keyed by column index (1-based)
    public var columnWidths: [Int: ColumnWidth] = [:]

    /// Custom row height settings, keyed by row index (1-based)
    public var rowHeights: [Int: Double] = [:]

    /// Print-specific configuration
    public var printSettings: PrintSettings?

    /// Page layout configuration for printing
    public var pageSetup: PageSetup?

    /// Default width for columns without custom settings (in character units)
    public var defaultColumnWidth: Double = 8.43

    /// Default height for rows without custom settings (in points)
    public var defaultRowHeight: Double = 15.0

    /// Whether to display worksheet gridlines
    public var showGridlines: Bool = true

    /// Whether to display row and column headings (A, B, C... and 1, 2, 3...)
    public var showRowAndColumnHeadings: Bool = true

    /// Whether to display cells containing zero values
    public var showZeros: Bool = true

    /// Whether to display formulas instead of calculated values
    public var showFormulas: Bool = false

    /// Whether to display outline symbols for grouped rows/columns
    public var showOutlineSymbols: Bool = true

    /// Whether to display page break indicators
    public var showPageBreaks: Bool = false

    /// Color for the worksheet tab (appears at bottom of Excel)
    public var tabColor: Color?

    /// Freeze panes configuration for fixed row/column display
    public var freezePanes: FreezePanes?

    /// Zoom level configuration
    public var zoom: Zoom?

    /// Data region definition for automated border application
    public var dataRange: DataRange?

    /// Automated data border configuration
    public var dataBorder: DataBorderSettings = .default

    /// Default styling for column header cells
    public var columnHeaderStyle: CellStyle?

    /// Default styling for data cells
    public var columnBodyStyle: CellStyle?

    // MARK: - Initialization

    /**
     Creates a new sheet style with default settings.

     All properties are initialized to Excel-compatible defaults that
     provide a clean, professional appearance.
     */
    public init() {}

    /// Default sheet style instance with standard Excel appearance
    public static let `default` = SheetStyle()

    /**
     Creates a customized sheet style with specified base properties.

     This initializer provides control over the most commonly configured
     sheet properties while using sensible defaults for advanced features.

     - Parameters:
        - defaultColumnWidth: Default width for columns (in character units)
        - defaultRowHeight: Default height for rows (in points)
        - showGridlines: Whether to display worksheet gridlines
        - showRowAndColumnHeadings: Whether to display row/column labels
        - showZeros: Whether to display zero values in cells
        - showFormulas: Whether to display formulas instead of values
        - showOutlineSymbols: Whether to display grouping symbols
        - showPageBreaks: Whether to display page break indicators
        - columnHeaderStyle: Default styling for header cells
        - columnBodyStyle: Default styling for data cells

     ## Usage
     ```swift
     let customStyle = SheetStyle(
         defaultRowHeight: 18.0,
         showGridlines: false,
         columnHeaderStyle: boldHeaderStyle
     )
     ```
     */
    public init(
        defaultColumnWidth: Double = 8.43,
        defaultRowHeight: Double = 15.0,
        showGridlines: Bool = true,
        showRowAndColumnHeadings: Bool = true,
        showZeros: Bool = true,
        showFormulas: Bool = false,
        showOutlineSymbols: Bool = true,
        showPageBreaks: Bool = false,
        columnHeaderStyle: CellStyle? = nil,
        columnBodyStyle: CellStyle? = nil)
    {
        self.defaultColumnWidth = defaultColumnWidth
        self.defaultRowHeight = defaultRowHeight
        self.showGridlines = showGridlines
        self.showRowAndColumnHeadings = showRowAndColumnHeadings
        self.showZeros = showZeros
        self.showFormulas = showFormulas
        self.showOutlineSymbols = showOutlineSymbols
        self.showPageBreaks = showPageBreaks
        self.columnHeaderStyle = columnHeaderStyle
        self.columnBodyStyle = columnBodyStyle
    }
}

// MARK: - Mutation Methods

extension SheetStyle {
    /**
     Sets a custom width for a specific column.

     Updates the column width configuration for the specified column index,
     overriding any previous width setting for that column.

     - Parameters:
        - width: The column width configuration to apply
        - index: The 1-based column index (Excel convention)

     ## Usage
     ```swift
     var style = SheetStyle()
     let customWidth = SheetStyle.ColumnWidth(
         width: 15.0,
         unit: .characters,
         isCustomWidth: true
     )
     style.setColumnWidth(customWidth, at: 3) // Set width for column C
     ```
     */
    public mutating func setColumnWidth(_ width: ColumnWidth, at index: Int) {
        columnWidths[index] = width
    }

    /**
     Sets a custom height for a specific row.

     Updates the row height configuration for the specified row index,
     overriding any previous height setting for that row.

     - Parameters:
        - height: The row height in points
        - index: The 1-based row index (Excel convention)

     ## Usage
     ```swift
     var style = SheetStyle()
     style.setRowHeight(25.0, at: 1) // Set height for row 1 (header)
     ```
     */
    public mutating func setRowHeight(_ height: Double, at index: Int) {
        rowHeights[index] = height
    }

    /**
     Configures print settings for the worksheet.

     Updates the print configuration, affecting how the worksheet appears
     when printed or exported to PDF.

     - Parameter printSettings: The print configuration to apply

     ## Usage
     ```swift
     var style = SheetStyle()
     let printConfig = SheetStyle.PrintSettings(
         paperSize: .a4,
         orientation: .landscape,
         scale: 0.8,
         fitToPage: false,
         margins: standardMargins,
         repeatRows: [1], // Repeat header row
         repeatColumns: nil
     )
     style.setPrintSettings(printConfig)
     ```
     */
    public mutating func setPrintSettings(_ printSettings: PrintSettings) {
        self.printSettings = printSettings
    }

    /**
     Configures page setup for printing.

     Updates the page layout configuration, including headers, footers,
     and centering options for printed output.

     - Parameter pageSetup: The page setup configuration to apply

     ## Usage
     ```swift
     var style = SheetStyle()
     let pageConfig = SheetStyle.PageSetup(
         header: "Company Report - &D",
         footer: "Page &P of &N",
         centerHorizontally: true,
         centerVertically: false,
         printGridlines: true,
         printRowAndColumnHeadings: false
     )
     style.setPageSetup(pageConfig)
     ```
     */
    public mutating func setPageSetup(_ pageSetup: PageSetup) {
        self.pageSetup = pageSetup
    }
}

// MARK: - Fluent Modifiers

extension SheetStyle {
    /**
     Sets the default column width for the worksheet.

     This width applies to all columns that don't have a custom width setting.
     The value is specified in character units, following Excel conventions.

     - Parameter width: The default column width in character units
     - Returns: A new `SheetStyle` instance with the updated default column width

     ## Usage
     ```swift
     let style = SheetStyle()
         .defaultColumnWidth(12.0)
     ```
     */
    public func defaultColumnWidth(_ width: Double) -> Self {
        var newSelf = self
        newSelf.defaultColumnWidth = width
        return newSelf
    }

    /**
     Sets the default row height for the worksheet.

     This height applies to all rows that don't have a custom height setting.
     The value is specified in points, following Excel conventions.

     - Parameter height: The default row height in points
     - Returns: A new `SheetStyle` instance with the updated default row height

     ## Usage
     ```swift
     let style = SheetStyle()
         .defaultRowHeight(18.0)
     ```
     */
    public func defaultRowHeight(_ height: Double) -> Self {
        var newSelf = self
        newSelf.defaultRowHeight = height
        return newSelf
    }

    /**
     Configures whether to display worksheet gridlines.

     Gridlines are the light gray lines that separate cells in Excel.
     They can be hidden for a cleaner appearance when the data has
     its own borders or when a more minimal look is desired.

     - Parameter show: Whether to display gridlines
     - Returns: A new `SheetStyle` instance with the updated gridline setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .showGridlines(false) // Hide gridlines for clean appearance
     ```
     */
    public func showGridlines(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showGridlines = show
        return newSelf
    }

    /**
     Configures whether to display row and column headings.

     Row and column headings are the labels (A, B, C... and 1, 2, 3...)
     that appear along the edges of the worksheet. These can be hidden
     for a cleaner presentation or when the sheet will be embedded.

     - Parameter show: Whether to display row and column headings
     - Returns: A new `SheetStyle` instance with the updated heading setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .showRowAndColumnHeadings(false) // Hide for embedded use
     ```
     */
    public func showRowAndColumnHeadings(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showRowAndColumnHeadings = show
        return newSelf
    }

    /**
     Configures whether to display cells containing zero values.

     When disabled, cells containing zero will appear empty rather than
     displaying "0". This can improve readability for datasets with
     many zero values.

     - Parameter show: Whether to display zero values
     - Returns: A new `SheetStyle` instance with the updated zero display setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .showZeros(false) // Hide zeros for cleaner appearance
     ```
     */
    public func showZeros(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showZeros = show
        return newSelf
    }

    /**
     Configures whether to display formulas instead of calculated values.

     When enabled, cells will show their formulas (e.g., "=A1+B1") instead
     of the calculated results. This is useful for debugging or educational
     purposes.

     - Parameter show: Whether to display formulas
     - Returns: A new `SheetStyle` instance with the updated formula display setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .showFormulas(true) // Show formulas for debugging
     ```
     */
    public func showFormulas(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showFormulas = show
        return newSelf
    }

    /**
     Configures whether to display outline symbols for grouped rows/columns.

     Outline symbols are the +/- controls that appear when rows or columns
     are grouped. They can be hidden for a cleaner appearance when grouping
     controls aren't needed.

     - Parameter show: Whether to display outline symbols
     - Returns: A new `SheetStyle` instance with the updated outline symbol setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .showOutlineSymbols(false) // Hide grouping controls
     ```
     */
    public func showOutlineSymbols(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showOutlineSymbols = show
        return newSelf
    }

    /**
     Configures whether to display page break indicators.

     Page break indicators show where pages will split when printing.
     They can be hidden for screen-focused worksheets or when page
     layout isn't a concern.

     - Parameter show: Whether to display page break indicators
     - Returns: A new `SheetStyle` instance with the updated page break setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .showPageBreaks(true) // Show page breaks for print layout
     ```
     */
    public func showPageBreaks(_ show: Bool) -> Self {
        var newSelf = self
        newSelf.showPageBreaks = show
        return newSelf
    }

    /**
     Sets the color for the worksheet tab.

     The tab color appears at the bottom of Excel and helps distinguish
     between different worksheets in a workbook. This is purely visual
     and doesn't affect functionality.

     - Parameter color: The color for the worksheet tab
     - Returns: A new `SheetStyle` instance with the updated tab color

     ## Usage
     ```swift
     let style = SheetStyle()
         .tabColor(.blue) // Blue tab for identification
     ```
     */
    public func tabColor(_ color: Color) -> Self {
        var newSelf = self
        newSelf.tabColor = color
        return newSelf
    }

    /**
     Configures freeze panes for the worksheet.

     Freeze panes keep specified rows and columns visible while scrolling,
     providing context for large datasets. Common patterns include freezing
     the top row (headers) or first column (labels).

     - Parameter freezePanes: The freeze panes configuration
     - Returns: A new `SheetStyle` instance with the updated freeze panes setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .freezePanes(.freezeTopRow()) // Keep header row visible

     // Or freeze custom region
     let customFreeze = SheetStyle.FreezePanes(
         frozenRows: 2,
         frozenColumns: 1,
         freezeTopRow: false,
         freezeFirstColumn: false
     )
     let advancedStyle = SheetStyle()
         .freezePanes(customFreeze)
     ```
     */
    public func freezePanes(_ freezePanes: FreezePanes) -> Self {
        var newSelf = self
        newSelf.freezePanes = freezePanes
        return newSelf
    }

    /**
     Configures the zoom level for the worksheet.

     The zoom level affects how much content is visible at once without
     changing the actual cell dimensions. Useful for improving readability
     or fitting more data on screen.

     - Parameter zoom: The zoom configuration
     - Returns: A new `SheetStyle` instance with the updated zoom setting

     ## Usage
     ```swift
     let style = SheetStyle()
         .zoom(.custom(125)) // 125% zoom for better readability

     // Or use default zoom
     let defaultStyle = SheetStyle()
         .zoom(.default) // 100% zoom
     ```
     */
    public func zoom(_ zoom: Zoom) -> Self {
        var newSelf = self
        newSelf.zoom = zoom
        return newSelf
    }
}

// MARK: - Style Merging

extension SheetStyle {
    /**
     Merges two sheet styles with configurable precedence handling.

     This method combines two `SheetStyle` instances, with the additional style
     taking precedence over the base style. The merging behavior can be configured
     to use intelligent merging (only non-default values override) or force
     override (all values from additional override base).

     - Parameters:
        - base: The base style providing fallback values
        - additional: The additional style with higher priority values
        - forceOverride: Whether to force all additional values to override base (defaults to false)

     - Returns: A merged `SheetStyle`, or `nil` if both inputs are `nil`

     ## Merging Strategy

     ### Intelligent Merging (default, `forceOverride: false`)
     For basic properties (dimensions, display flags), only values that differ from
     the default `SheetStyle` will override the base style. This preserves intentional
     base style configurations.

     ### Force Override (`forceOverride: true`)
     All values from the additional style override the base style, regardless of
     whether they're default values or not.

     ### Always Override
     Certain properties always use the additional value if present:
     - Dictionary properties (column widths, row heights) are merged
     - Optional properties use additional if non-nil, otherwise base
     - Data borders use additional if enabled, otherwise base
     - Cell styles are recursively merged

     ## Usage Examples

     ```swift
     // Intelligent merging (recommended)
     let merged = SheetStyle.merge(
         base: bookDefaultStyle,
         additional: sheetCustomStyle
     )

     // Force override for template scenarios
     let templateMerged = SheetStyle.merge(
         base: userStyle,
         additional: templateStyle,
         forceOverride: true
     )
     ```
     */
    public static func merge(base: SheetStyle?, additional: SheetStyle?, forceOverride: Bool = false) -> SheetStyle? {
        // Return nil if both inputs are nil
        guard base != nil || additional != nil else { return nil }

        // Return the non-nil style if only one is provided
        guard let base else { return additional }
        guard let additional else { return base }

        // Both are non-nil, perform property-by-property merging
        // Additional style values override base style values with proper precedence
        var merged = base

        // Merge dictionary properties by combining both dictionaries (additional takes precedence)
        merged.columnWidths = base.columnWidths.merging(additional.columnWidths) { _, new in new }
        merged.rowHeights = base.rowHeights.merging(additional.rowHeights) { _, new in new }

        // Data border settings: use additional if enabled, otherwise use base
        merged.dataBorder = additional.dataBorder.enabled ? additional.dataBorder : base.dataBorder

        // Merge optional properties: use additional if non-nil, otherwise fall back to base
        merged.printSettings = additional.printSettings ?? base.printSettings
        merged.pageSetup = additional.pageSetup ?? base.pageSetup
        merged.tabColor = additional.tabColor ?? base.tabColor
        merged.freezePanes = additional.freezePanes ?? base.freezePanes
        merged.zoom = additional.zoom ?? base.zoom
        merged.dataRange = additional.dataRange ?? base.dataRange

        // Recursively merge cell styles
        merged.columnHeaderStyle = CellStyle.merge(base: base.columnHeaderStyle, additional: additional.columnHeaderStyle)
        merged.columnBodyStyle = CellStyle.merge(base: base.columnBodyStyle, additional: additional.columnBodyStyle)

        // Handle basic properties based on merging strategy
        if forceOverride {
            // Force override mode: all additional values override base
            merged.defaultColumnWidth = additional.defaultColumnWidth
            merged.defaultRowHeight = additional.defaultRowHeight
            merged.showGridlines = additional.showGridlines
            merged.showRowAndColumnHeadings = additional.showRowAndColumnHeadings
            merged.showZeros = additional.showZeros
            merged.showFormulas = additional.showFormulas
            merged.showOutlineSymbols = additional.showOutlineSymbols
            merged.showPageBreaks = additional.showPageBreaks
        } else {
            // Intelligent merging mode: only non-default values from additional override base
            let defaultStyle = SheetStyle()

            if additional.defaultColumnWidth != defaultStyle.defaultColumnWidth {
                merged.defaultColumnWidth = additional.defaultColumnWidth
            }
            if additional.defaultRowHeight != defaultStyle.defaultRowHeight {
                merged.defaultRowHeight = additional.defaultRowHeight
            }
            if additional.showGridlines != defaultStyle.showGridlines {
                merged.showGridlines = additional.showGridlines
            }
            if additional.showRowAndColumnHeadings != defaultStyle.showRowAndColumnHeadings {
                merged.showRowAndColumnHeadings = additional.showRowAndColumnHeadings
            }
            if additional.showZeros != defaultStyle.showZeros {
                merged.showZeros = additional.showZeros
            }
            if additional.showFormulas != defaultStyle.showFormulas {
                merged.showFormulas = additional.showFormulas
            }
            if additional.showOutlineSymbols != defaultStyle.showOutlineSymbols {
                merged.showOutlineSymbols = additional.showOutlineSymbols
            }
            if additional.showPageBreaks != defaultStyle.showPageBreaks {
                merged.showPageBreaks = additional.showPageBreaks
            }
        }

        return merged
    }

    /**
     Merges multiple sheet styles with cascading precedence.

     This convenience method merges an array of styles where later styles
     have higher precedence than earlier ones. It's useful for building
     a final style from multiple sources in a clear, hierarchical manner.

     - Parameter styles: Variable number of styles, ordered from lowest to highest precedence
     - Returns: A merged `SheetStyle` combining all input styles, or `nil` if all inputs are `nil`

     ## Usage Examples

     ```swift
     // Build final style from hierarchy
     let finalStyle = SheetStyle.merge(
         book.defaultSheetStyle,      // Lowest precedence
         template.sheetStyle,         // Medium precedence
         customSheetStyle             // Highest precedence
     )

     // Handle optional styles gracefully
     let mergedStyle = SheetStyle.merge(
         baseStyle,
         conditionalStyle,
         nil,                         // Ignored safely
         overrideStyle
     )
     ```

     ## Precedence Order

     Styles are merged from left to right, so rightmost styles have the highest
     precedence. This matches the intuitive expectation that "later overrides earlier".

     - Note: Uses intelligent merging internally, preserving intentional configurations
     */
    public static func merge(_ styles: SheetStyle?...) -> SheetStyle? {
        styles.reduce(nil) { result, style in
            merge(base: result, additional: style, forceOverride: false)
        }
    }
}

// MARK: - Internal Methods

extension SheetStyle {
    /**
     Creates a data range configuration for border application.

     This internal method is used during XML generation to define the
     rectangular area where data borders should be applied. It assumes
     a single-column data range extending from the start to end row.

     - Parameters:
        - startRow: The first row of the data range (1-based)
        - startColumn: The starting column (1-based)
        - endRow: The last row of the data range (1-based)

     - Returns: A new `SheetStyle` with the configured data range

     - Note: This method is used internally during Excel generation
     */
    func dataRange(
        startRow: Int,
        startColumn: Int,
        endRow: Int) -> Self
    {
        var newSelf = self
        newSelf.dataRange = DataRange(
            startRow: startRow,
            startColumn: startColumn,
            endRow: endRow,
            endColumn: startColumn)
        return newSelf
    }
}

// MARK: - Supporting Types

extension SheetStyle {
    /**
     Units of measurement for Excel dimensions.

     Excel supports different units for various measurements. This enum
     provides type-safe options for specifying measurement units.
     */
    public enum Unit: String, Sendable, CaseIterable, Hashable, Equatable {
        /// Points (1/72 of an inch) - used for row heights
        case points
        /// Character units (based on default font) - used for column widths
        case characters
    }

    /**
     Standard paper sizes for printing.

     Supports common paper formats used in different regions.
     Additional sizes can be added as needed.
     */
    public enum PaperSize: String, Sendable, CaseIterable, Hashable, Equatable {
        /// A4 paper (210 × 297 mm) - common in most countries
        case a4
        /// Letter paper (8.5 × 11 inches) - common in North America
        case letter
        /// Legal paper (8.5 × 14 inches) - used for legal documents
        case legal
    }

    /**
     Page orientation options for printing.

     Controls whether the page is taller than wide (portrait) or
     wider than tall (landscape).
     */
    public enum Orientation: String, Sendable, CaseIterable, Hashable, Equatable {
        /// Portrait orientation (taller than wide)
        case portrait
        /// Landscape orientation (wider than tall)
        case landscape
    }

    /**
     Page margin configuration for printing.

     Defines the space around the content area on printed pages.
     All measurements are in the same unit as specified in print settings.
     */
    public struct Margins: Equatable, Hashable, Sendable {
        /// Top margin (above content)
        public let top: Double
        /// Bottom margin (below content)
        public let bottom: Double
        /// Left margin (to the left of content)
        public let left: Double
        /// Right margin (to the right of content)
        public let right: Double
        /// Header margin (above header area)
        public let header: Double
        /// Footer margin (below footer area)
        public let footer: Double
    }
}

/**
 Represents a rectangular range of cells within a worksheet.

 `CellRange` defines a rectangular area using Excel's coordinate system
 (1-based indexing). It's used for various operations including data
 borders, merged cells, and print ranges.

 ## Coordinate System

 - **Rows**: Numbered starting from 1 (Excel convention)
 - **Columns**: Numbered starting from 1 (Excel convention)
 - **Ranges**: Inclusive on all boundaries

 ## Usage Examples

 ```swift
 // Single cell
 let singleCell = CellRange.cell(row: 1, column: 1) // A1

 // Multi-cell range
 let dataRange = CellRange(
     startRow: 1, startColumn: 1,
     endRow: 10, endColumn: 5
 ) // A1:E10

 // Row range
 let headerRows = CellRange.rows(start: 1, end: 2, column: 1) // A1:A2

 // Column range
 let nameColumns = CellRange.columns(start: 1, end: 3, row: 1) // A1:C1
 ```
 */
public struct CellRange: Equatable, Hashable, Sendable {
    /// Starting row index (1-based, inclusive)
    public let startRow: Int
    /// Starting column index (1-based, inclusive)
    public let startColumn: Int
    /// Ending row index (1-based, inclusive)
    public let endRow: Int
    /// Ending column index (1-based, inclusive)
    public let endColumn: Int

    /**
     Creates a new cell range with the specified boundaries.

     - Parameters:
        - startRow: The first row (1-based)
        - startColumn: The first column (1-based)
        - endRow: The last row (1-based, inclusive)
        - endColumn: The last column (1-based, inclusive)
     */
    public init(
        startRow: Int,
        startColumn: Int,
        endRow: Int,
        endColumn: Int)
    {
        self.startRow = startRow
        self.startColumn = startColumn
        self.endRow = endRow
        self.endColumn = endColumn
    }

    /**
     Creates a range containing a single cell.

     - Parameters:
        - row: The row index (1-based)
        - column: The column index (1-based)

     - Returns: A `CellRange` representing the single cell
     */
    public static func cell(row: Int, column: Int) -> Self {
        Self(
            startRow: row,
            startColumn: column,
            endRow: row,
            endColumn: column)
    }

    /**
     Creates a range spanning multiple rows in a single column.

     - Parameters:
        - start: The starting row index (1-based)
        - end: The ending row index (1-based, inclusive)
        - column: The column index (1-based)

     - Returns: A `CellRange` representing the row span
     */
    public static func rows(start: Int, end: Int, column: Int) -> Self {
        Self(
            startRow: start,
            startColumn: column,
            endRow: end,
            endColumn: column)
    }

    /**
     Creates a range spanning multiple columns in a single row.

     - Parameters:
        - start: The starting column index (1-based)
        - end: The ending column index (1-based, inclusive)
        - row: The row index (1-based)

     - Returns: A `CellRange` representing the column span
     */
    public static func columns(start: Int, end: Int, row: Int) -> Self {
        Self(
            startRow: row,
            startColumn: start,
            endRow: row,
            endColumn: end)
    }
}

// MARK: - Convenience Factory Methods

extension SheetStyle.FreezePanes {
    /**
     Creates a freeze panes configuration that freezes only the top row.

     This is the most common freeze panes setup, keeping header rows
     visible while scrolling through data.

     - Returns: A `FreezePanes` configuration for top row freezing
     */
    public static func freezeTopRow() -> Self {
        Self(frozenRows: 1, frozenColumns: 0, freezeTopRow: true, freezeFirstColumn: false)
    }

    /**
     Creates a freeze panes configuration that freezes only the first column.

     Useful when the first column contains row labels or identifiers
     that should remain visible while scrolling horizontally.

     - Returns: A `FreezePanes` configuration for first column freezing
     */
    public static func freezeFirstColumn() -> Self {
        Self(frozenRows: 0, frozenColumns: 1, freezeTopRow: false, freezeFirstColumn: true)
    }

    /**
     Creates a custom freeze panes configuration.

     Allows freezing any number of rows and columns simultaneously,
     providing maximum flexibility for complex layouts.

     - Parameters:
        - rows: Number of rows to freeze from the top
        - columns: Number of columns to freeze from the left

     - Returns: A `FreezePanes` configuration for the specified region
     */
    public static func freeze(rows: Int, columns: Int) -> Self {
        Self(frozenRows: rows, frozenColumns: columns, freezeTopRow: false, freezeFirstColumn: false)
    }
}

extension SheetStyle.Zoom {
    /// Default zoom level (100%) for normal viewing
    public static let `default` = Self(scale: 100, isCustomScale: false)

    /**
     Creates a custom zoom level configuration.

     The zoom scale is automatically clamped to Excel's supported range
     of 10% to 400% to ensure compatibility.

     - Parameter scale: The zoom percentage (will be clamped to 10-400)
     - Returns: A `Zoom` configuration with the specified scale

     ## Usage
     ```swift
     let zoomedIn = SheetStyle.Zoom.custom(150)   // 150% zoom
     let zoomedOut = SheetStyle.Zoom.custom(75)   // 75% zoom
     let maxZoom = SheetStyle.Zoom.custom(500)    // Clamped to 400%
     ```
     */
    public static func custom(_ scale: Int) -> Self {
        Self(scale: max(10, min(400, scale)), isCustomScale: true)
    }
}
