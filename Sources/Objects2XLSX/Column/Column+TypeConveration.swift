//
// Column+TypeConveration.swift
// Created by Xu Yang on 2025-06-21.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

// MARK: - Value Transformation Methods

extension Column {
    /// Transforms column values to String using a custom conversion closure.
    ///
    /// This method provides a universal way to convert any column output type to string representations.
    /// The closure receives the processed value based on the column's nilHandling configuration:
    /// - For columns with `.keepEmpty`: receives T? (may be nil)
    /// - For columns with `.defaultValue`: receives T (never nil, default applied)
    ///
    /// Example usage:
    /// ```swift
    /// // For optional values without defaultValue
    /// Column(name: "Bonus", keyPath: \.bonus)
    ///     .toString { (bonus: Double?) in
    ///         guard let bonus = bonus else { return "No Bonus" }
    ///         return bonus > 1000 ? "High" : "Low"
    ///     }
    ///
    /// // For optional values with defaultValue
    /// Column(name: "Salary", keyPath: \.salary)
    ///     .defaultValue(0.0)
    ///     .toString { (salary: Double) in  // Non-optional after defaultValue!
    ///         salary < 50000 ? "Standard" : "Premium"
    ///     }
    ///
    /// // For non-optional values
    /// Column(name: "Age", keyPath: \.age)
    ///     .toString { (age: Int) in
    ///         age < 18 ? "Minor" : "Adult"
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the processed value to String
    /// - Returns: A new column that outputs TextColumnType with transformed values
    public func toString<T>(
        _ transform: @escaping (T) -> String) -> Column<ObjectType, InputType, TextColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, TextColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { input in
                // First apply the original mapping
                let originalOutput = self.mapping(input)

                // Apply nilHandling logic to get the final processed output
                let processedOutput = switch self.nilHandling {
                    case .keepEmpty:
                        originalOutput
                    case let .defaultValue(defaultValue):
                        OutputType.withDefaultValue(defaultValue, config: originalOutput.config)
                }

                // Extract the value from the processed output (now with defaults applied)
                let finalValue = processedOutput.config.value

                // Apply the transformation - when defaultValue is used, finalValue is guaranteed to be non-nil
                let stringValue: String = switch self.nilHandling {
                    case .keepEmpty:
                        // For keepEmpty, we need to handle nil safely
                        if let finalValue {
                            transform(finalValue)
                        } else {
                            // This shouldn't happen with the current API, but handle gracefully
                            transform(finalValue!)
                        }
                    case .defaultValue:
                        // For defaultValue, finalValue is guaranteed to be non-nil
                        transform(finalValue!)
                }

                // Return TextColumnType
                return TextColumnType(TextColumnConfig(value: stringValue))
            },
            nilHandling: .keepEmpty // String output is never nil
        )
    }

    /// Transforms column values to String using a custom conversion closure that handles optional values.
    ///
    /// This overload is for columns that may contain nil values (when nilHandling is .keepEmpty).
    /// Use this when you need to explicitly handle nil cases in your transformation.
    ///
    /// Example usage:
    /// ```swift
    /// // For handling optional values explicitly
    /// Column(name: "Bonus", keyPath: \.bonus)
    ///     .toString { (bonus: Double?) in
    ///         guard let bonus = bonus else { return "No Bonus" }
    ///         return bonus > 1000 ? "High" : "Low"
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the optional value to String
    /// - Returns: A new column that outputs TextColumnType with transformed values
    public func toString<T>(
        _ transform: @escaping (T?) -> String) -> Column<ObjectType, InputType, TextColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, TextColumnType>(
            name: name,
            keyPath: keyPath,
            width: width,
            bodyStyle: bodyStyle,
            headerStyle: headerStyle,
            mapping: { input in
                // First apply the original mapping
                let originalOutput = self.mapping(input)

                // Apply nilHandling logic to get the final processed output
                let processedOutput = switch self.nilHandling {
                    case .keepEmpty:
                        originalOutput
                    case let .defaultValue(defaultValue):
                        OutputType.withDefaultValue(defaultValue, config: originalOutput.config)
                }

                // Extract the value from the processed output
                let finalValue = processedOutput.config.value

                // Apply the transformation with optional handling
                let stringValue = transform(finalValue)

                // Return TextColumnType
                return TextColumnType(TextColumnConfig(value: stringValue))
            },
            nilHandling: .keepEmpty // String output is never nil
        )
    }
}
