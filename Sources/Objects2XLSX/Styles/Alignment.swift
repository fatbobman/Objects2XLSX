//
// Alignment.swift
// Created by Xu Yang on 2025-06-16.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/**
 Cell alignment configuration for Excel worksheets.

 `Alignment` provides comprehensive control over text positioning and formatting
 within Excel cells, supporting all Excel alignment options including horizontal
 and vertical positioning, text wrapping, indentation, and rotation.

 ## Overview

 This structure encapsulates Excel's alignment capabilities, offering type-safe
 configuration for text layout within cells. All properties are optional,
 allowing for precise control over which alignment aspects to modify while
 leaving others as Excel defaults.

 ## Key Features

 - **Horizontal Alignment**: Left, center, right, justify, fill, and distributed options
 - **Vertical Alignment**: Top, center, bottom, justify, and distributed positioning
 - **Text Wrapping**: Automatic line breaking within cells
 - **Indentation**: Left and right indentation with Excel-compatible limits
 - **Text Rotation**: Angle-based rotation (-90° to 90°) plus vertical text mode

 ## Usage Examples

 ### Basic Alignment
 ```swift
 let centerAlignment = Alignment(horizontal: .center, vertical: .center)
 let leftAlignment = Alignment(horizontal: .left)
 ```

 ### Advanced Formatting
 ```swift
 let wrappedText = Alignment(
     horizontal: .left,
     vertical: .top,
     wrapText: true,
     indent: 2
 )

 let rotatedText = Alignment(textRotation: 45)
 let verticalText = Alignment(textRotation: 255) // Special vertical mode
 ```

 ## Excel Compatibility

 All alignment settings are fully compatible with Excel's native alignment system:
 - Indentation values are automatically clamped to Excel's 0-250 range
 - Text rotation angles are validated to Excel's supported range
 - Horizontal alignment affects indentation availability
 - XML generation follows Excel's Open XML specification

 - Note: Some alignment combinations may not be visually supported in all Excel versions
 */
public struct Alignment: Equatable, Sendable, Hashable {
    /// Horizontal alignment
    public let horizontal: HorizontalAlignment?
    /// Vertical alignment
    public let vertical: VerticalAlignment?
    /// Wrap text
    public let wrapText: Bool?
    /// Indent level (0-250)
    public let indent: Int?
    /// Text rotation angle (-90 to 90, or 255 means vertical text)
    public let textRotation: Int?

    public init(
        horizontal: HorizontalAlignment? = nil,
        vertical: VerticalAlignment? = nil,
        wrapText: Bool? = nil,
        indent: Int? = nil,
        textRotation: Int? = nil)
    {
        self.horizontal = horizontal
        self.vertical = vertical
        self.wrapText = wrapText

        // Validate indent value within Excel's supported range
        if let indent, indent > 0 {
            self.indent = max(0, min(250, indent))
        } else {
            self.indent = nil
        }

        // Validate text rotation angle within Excel's supported range
        if let rotation = textRotation,
           rotation == 255 || (rotation >= -90 && rotation <= 90)
        {
            self.textRotation = rotation
        } else {
            self.textRotation = nil
        }
    }
}

extension Alignment {
    /// Default alignment (no specific settings)
    public static let `default`: Alignment? = nil

    /// Center alignment (both horizontal and vertical)
    public static let center = Alignment(horizontal: .center, vertical: .center)

    /// Top-left alignment
    public static let topLeft = Alignment(horizontal: .left, vertical: .top)

    /// Bottom-right alignment
    public static let bottomRight = Alignment(horizontal: .right, vertical: .bottom)

    /// Left alignment with text wrapping enabled
    public static let leftWrap = Alignment(horizontal: .left, wrapText: true)

    /// Center alignment with text wrapping enabled
    public static let centerWrap = Alignment(horizontal: .center, vertical: .center, wrapText: true)

    /// Vertical text orientation (special rotation value of 255)
    public static let verticalText = Alignment(textRotation: 255)

    /// Creates left alignment with specified indentation level.
    ///
    /// The indentation level is automatically validated and clamped to Excel's
    /// supported range (0-250). Invalid values are adjusted to the nearest valid value.
    ///
    /// - Parameter level: Indentation level (0-250)
    /// - Returns: Left-aligned `Alignment` with validated indentation
    public static func leftIndented(_ level: Int) -> Alignment {
        Alignment(horizontal: .left, indent: level)
    }

    /// Creates alignment with specified text rotation angle.
    ///
    /// The rotation angle is automatically validated against Excel's supported range.
    /// Valid angles are -90 to 90 degrees, or 255 for vertical text orientation.
    /// Invalid angles are ignored and result in no rotation.
    ///
    /// - Parameter angle: Rotation angle in degrees (-90 to 90, or 255 for vertical)
    /// - Returns: `Alignment` with validated text rotation
    public static func rotated(_ angle: Int) -> Alignment {
        Alignment(textRotation: angle)
    }
}

extension Alignment: Identifiable {
    public var id: String {
        var components: [String] = []

        if let horizontal {
            components.append("h:\(horizontal.rawValue)")
        }
        if let vertical {
            components.append("v:\(vertical.rawValue)")
        }
        if let wrapText, wrapText {
            components.append("wrap:1")
        }
        if let indent, indent > 0 {
            components.append("indent:\(indent)")
        }
        if let textRotation, textRotation != 0 {
            components.append("rotation:\(textRotation)")
        }

        return components.isEmpty ? "default" : components.joined(separator: "_")
    }
}

/**
 Horizontal text alignment options for Excel cells.

 These values correspond directly to Excel's horizontal alignment options,
 providing type-safe access to all supported horizontal positioning modes.

 ## Alignment Behaviors

 - **general**: Excel's default alignment (left for text, right for numbers)
 - **left**: Left-aligned text with optional indentation support
 - **center**: Horizontally centered text
 - **right**: Right-aligned text with optional indentation support
 - **fill**: Repeats text to fill the entire cell width
 - **justify**: Distributes text evenly across cell width (multi-line text)
 - **centerContinuous**: Centers text across multiple selected cells
 - **distributed**: Similar to justify but with different spacing rules

 - Note: Indentation is only effective with left, right, and distributed alignments
 */
public enum HorizontalAlignment: String, CaseIterable, Sendable {
    case general // General (default)
    case left // Left alignment
    case center // Center alignment
    case right // Right alignment
    case fill // Fill
    case justify // Justify
    case centerContinuous // Center across selection
    case distributed // Distributed
}

/**
 Vertical text alignment options for Excel cells.

 These values correspond directly to Excel's vertical alignment options,
 controlling how text is positioned within the cell's height.

 ## Alignment Behaviors

 - **top**: Aligns text to the top of the cell
 - **center**: Vertically centers text within the cell
 - **bottom**: Aligns text to the bottom of the cell (Excel default)
 - **justify**: Distributes text evenly across cell height (multi-line text)
 - **distributed**: Similar to justify but with different spacing rules

 - Note: Vertical alignment is most noticeable when cells have custom row heights
 */
public enum VerticalAlignment: String, CaseIterable, Sendable {
    case top // Top alignment
    case center // Center alignment
    case bottom // Bottom alignment (default)
    case justify // Justify
    case distributed // Distributed
}

// MARK: - Alignment XML Generation

extension Alignment {
    /// Generate XML for this alignment
    var xmlContent: String {
        var attributes: [String] = []

        // Horizontal alignment attribute
        if let horizontal {
            attributes.append("horizontal=\"\(horizontal.rawValue)\"")
        }

        // Vertical alignment attribute
        if let vertical {
            attributes.append("vertical=\"\(vertical.rawValue)\"")
        }

        // Text wrapping attribute
        if let wrapText, wrapText {
            attributes.append("wrapText=\"1\"")
        }

        // Text indentation (only valid with specific horizontal alignments)
        if let indent,
           indent > 0,
           let horizontal,
           [.left, .right, .distributed].contains(horizontal)
        {
            let validIndent = max(0, min(250, indent)) // Excel 限制：0-250
            attributes.append("indent=\"\(validIndent)\"")
        }

        // Text rotation (validated range)
        if let textRotation,
           isValidTextRotation(textRotation)
        {
            attributes.append("textRotation=\"\(textRotation)\"")
        }

        // Return empty string if no attributes (use Excel defaults)
        guard !attributes.isEmpty else {
            return ""
        }

        return "<alignment \(attributes.joined(separator: " "))/>"
    }

    /// Validates whether the text rotation angle is within Excel's supported range.
    ///
    /// Excel supports rotation angles from -90 to 90 degrees, plus a special
    /// value of 255 that represents vertical text orientation.
    ///
    /// - Parameter rotation: The rotation angle to validate
    /// - Returns: `true` if the angle is valid, `false` otherwise
    private func isValidTextRotation(_ rotation: Int) -> Bool {
        rotation == 255 || (rotation >= -90 && rotation <= 90)
    }
}
