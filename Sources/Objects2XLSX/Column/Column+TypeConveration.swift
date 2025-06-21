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

    /// Transforms column values to Int using a custom conversion closure.
    ///
    /// This method provides a universal way to convert any column output type to integer values.
    /// The closure receives the processed value based on the column's nilHandling configuration:
    /// - For columns with `.keepEmpty`: receives T? (may be nil)
    /// - For columns with `.defaultValue`: receives T (never nil, default applied)
    ///
    /// Example usage:
    /// ```swift
    /// // Convert string to Int with defaultValue
    /// Column(name: "Score", keyPath: \.scoreString)
    ///     .defaultValue("0")
    ///     .toInt { (scoreStr: String) in  // Non-optional after defaultValue!
    ///         Int(scoreStr) ?? 0
    ///     }
    ///
    /// // Convert Double to Int
    /// Column(name: "Rounded Price", keyPath: \.price)
    ///     .toInt { (price: Double) in
    ///         Int(price.rounded())
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the processed value to Int
    /// - Returns: A new column that outputs IntColumnType with transformed values
    public func toInt<T>(
        _ transform: @escaping (T) -> Int) -> Column<ObjectType, InputType, IntColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, IntColumnType>(
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
                let intValue: Int = switch self.nilHandling {
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

                // Return IntColumnType
                return IntColumnType(IntColumnConfig(value: intValue))
            },
            nilHandling: .keepEmpty // Int output is never nil
        )
    }

    /// Transforms column values to Int using a custom conversion closure that handles optional values.
    ///
    /// This overload is for columns that may contain nil values (when nilHandling is .keepEmpty).
    /// Use this when you need to explicitly handle nil cases in your transformation.
    ///
    /// Example usage:
    /// ```swift
    /// // For handling optional values explicitly
    /// Column(name: "Priority", keyPath: \.priority)
    ///     .toInt { (priority: String?) in
    ///         guard let priority = priority else { return 0 }
    ///         return Int(priority) ?? 0
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the optional value to Int
    /// - Returns: A new column that outputs IntColumnType with transformed values
    public func toInt<T>(
        _ transform: @escaping (T?) -> Int) -> Column<ObjectType, InputType, IntColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, IntColumnType>(
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
                let intValue = transform(finalValue)

                // Return IntColumnType
                return IntColumnType(IntColumnConfig(value: intValue))
            },
            nilHandling: .keepEmpty // Int output is never nil
        )
    }

    /// Transforms column values to Double using a custom conversion closure.
    ///
    /// This method provides a way to convert any column output type to Double values.
    /// The closure receives the processed value based on the column's nilHandling configuration:
    /// - For columns with `.keepEmpty`: receives T? (may be nil)
    /// - For columns with `.defaultValue`: receives T (never nil, default applied)
    ///
    /// Example usage:
    /// ```swift
    /// // Convert String to Double
    /// Column(name: "Price String", keyPath: \.priceString)
    ///     .toDouble { (priceStr: String) in
    ///         Double(priceStr) ?? 0.0
    ///     }
    ///
    /// // Convert Int to Double
    /// Column(name: "Count", keyPath: \.count)
    ///     .toDouble { (count: Int) in
    ///         Double(count)
    ///     }
    ///
    /// // Convert optional values with defaultValue
    /// Column(name: "Score", keyPath: \.score)
    ///     .defaultValue("0")
    ///     .toDouble { (score: String) in  // Non-optional after defaultValue!
    ///         Double(score) ?? 0.0
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the processed value to Double
    /// - Returns: A new column that outputs DoubleColumnType with transformed values
    public func toDouble<T>(
        _ transform: @escaping (T) -> Double) -> Column<ObjectType, InputType, DoubleColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, DoubleColumnType>(
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
                let doubleValue: Double = switch self.nilHandling {
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

                // Return DoubleColumnType
                return DoubleColumnType(DoubleColumnConfig(value: doubleValue))
            },
            nilHandling: .keepEmpty // Double output is never nil
        )
    }

    /// Transforms column values to Double using a custom conversion closure that handles optional values.
    ///
    /// This overload is for columns that may contain nil values (when nilHandling is .keepEmpty).
    /// Use this when you need to explicitly handle nil cases in your transformation.
    ///
    /// Example usage:
    /// ```swift
    /// // Convert optional String to optional Double
    /// Column(name: "Price", keyPath: \.priceString)
    ///     .toDouble { (priceStr: String?) in
    ///         guard let priceStr = priceStr else { return nil }
    ///         return Double(priceStr)
    ///     }
    ///
    /// // Convert with custom nil handling
    /// Column(name: "Rating", keyPath: \.rating)
    ///     .toDouble { (rating: String?) in
    ///         rating.flatMap { Double($0) } ?? -1.0
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the optional value to optional Double
    /// - Returns: A new column that outputs DoubleColumnType with transformed values
    public func toDouble<T>(
        _ transform: @escaping (T?) -> Double?) -> Column<ObjectType, InputType, DoubleColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, DoubleColumnType>(
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
                let doubleValue = transform(finalValue)

                // Return DoubleColumnType
                return DoubleColumnType(DoubleColumnConfig(value: doubleValue))
            },
            nilHandling: .keepEmpty // Double output may be nil
        )
    }

    /// Transforms column values to Date using a custom conversion closure.
    ///
    /// This method provides a way to convert any column output type to Date values.
    /// The closure receives the processed value based on the column's nilHandling configuration:
    /// - For columns with `.keepEmpty`: receives T? (may be nil)
    /// - For columns with `.defaultValue`: receives T (never nil, default applied)
    ///
    /// Example usage:
    /// ```swift
    /// // Convert String to Date
    /// Column(name: "Date String", keyPath: \.dateString)
    ///     .toDate { (dateStr: String) in
    ///         ISO8601DateFormatter().date(from: dateStr) ?? Date()
    ///     }
    ///
    /// // Convert timestamp to Date
    /// Column(name: "Timestamp", keyPath: \.timestamp)
    ///     .toDate { (timestamp: Double) in
    ///         Date(timeIntervalSince1970: timestamp)
    ///     }
    ///
    /// // Convert optional values with defaultValue
    /// Column(name: "Created", keyPath: \.createdString)
    ///     .defaultValue("2024-01-01")
    ///     .toDate { (dateStr: String) in  // Non-optional after defaultValue!
    ///         ISO8601DateFormatter().date(from: dateStr) ?? Date()
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the processed value to Date
    /// - Returns: A new column that outputs DateColumnType with transformed values
    public func toDate<T>(
        _ transform: @escaping (T) -> Date) -> Column<ObjectType, InputType, DateColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, DateColumnType>(
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
                let dateValue: Date = switch self.nilHandling {
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

                // Return DateColumnType with current timezone
                return DateColumnType(DateColumnConfig(value: dateValue, timeZone: TimeZone.current))
            },
            nilHandling: .keepEmpty // Date output is never nil
        )
    }

    /// Transforms column values to Date using a custom conversion closure that handles optional values.
    ///
    /// This overload is for columns that may contain nil values (when nilHandling is .keepEmpty).
    /// Use this when you need to explicitly handle nil cases in your transformation.
    ///
    /// Example usage:
    /// ```swift
    /// // Convert optional String to optional Date
    /// Column(name: "Date", keyPath: \.dateString)
    ///     .toDate { (dateStr: String?) in
    ///         guard let dateStr else { return nil }
    ///         return ISO8601DateFormatter().date(from: dateStr)
    ///     }
    ///
    /// // Convert with custom nil handling
    /// Column(name: "Modified", keyPath: \.modifiedString)
    ///     .toDate { (dateStr: String?) in
    ///         dateStr.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the optional value to optional Date
    /// - Returns: A new column that outputs DateColumnType with transformed values
    public func toDate<T>(
        _ transform: @escaping (T?) -> Date?) -> Column<ObjectType, InputType, DateColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, DateColumnType>(
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
                let dateValue = transform(finalValue)

                // Return DateColumnType with current timezone
                return DateColumnType(DateColumnConfig(value: dateValue, timeZone: TimeZone.current))
            },
            nilHandling: .keepEmpty // Date output may be nil
        )
    }

    /// Transforms column values to URL using a custom conversion closure.
    ///
    /// This method provides a way to convert any column output type to URL values.
    /// The closure receives the processed value based on the column's nilHandling configuration:
    /// - For columns with `.keepEmpty`: receives T? (may be nil)
    /// - For columns with `.defaultValue`: receives T (never nil, default applied)
    ///
    /// Example usage:
    /// ```swift
    /// // Convert String to URL
    /// Column(name: "Website", keyPath: \.websiteString)
    ///     .toURL { (urlStr: String) in
    ///         URL(string: urlStr) ?? URL(string: "https://example.com")!
    ///     }
    ///
    /// // Convert domain to full URL
    /// Column(name: "Domain", keyPath: \.domain)
    ///     .toURL { (domain: String) in
    ///         URL(string: "https://\(domain)")!
    ///     }
    ///
    /// // Convert optional values with defaultValue
    /// Column(name: "Link", keyPath: \.linkString)
    ///     .defaultValue("https://default.com")
    ///     .toURL { (urlStr: String) in  // Non-optional after defaultValue!
    ///         URL(string: urlStr) ?? URL(string: "https://fallback.com")!
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the processed value to URL
    /// - Returns: A new column that outputs URLColumnType with transformed values
    public func toURL<T>(
        _ transform: @escaping (T) -> URL) -> Column<ObjectType, InputType, URLColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, URLColumnType>(
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
                let urlValue: URL = switch self.nilHandling {
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

                // Return URLColumnType
                return URLColumnType(URLColumnConfig(value: urlValue))
            },
            nilHandling: .keepEmpty // URL output is never nil
        )
    }

    /// Transforms column values to URL using a custom conversion closure that handles optional values.
    ///
    /// This overload is for columns that may contain nil values (when nilHandling is .keepEmpty).
    /// Use this when you need to explicitly handle nil cases in your transformation.
    ///
    /// Example usage:
    /// ```swift
    /// // Convert optional String to optional URL
    /// Column(name: "Website", keyPath: \.websiteString)
    ///     .toURL { (urlStr: String?) in
    ///         guard let urlStr else { return nil }
    ///         return URL(string: urlStr)
    ///     }
    ///
    /// // Convert with custom nil handling
    /// Column(name: "Link", keyPath: \.link)
    ///     .toURL { (urlStr: String?) in
    ///         urlStr.flatMap { URL(string: $0) } ?? URL(string: "https://default.com")!
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the optional value to optional URL
    /// - Returns: A new column that outputs URLColumnType with transformed values
    public func toURL<T>(
        _ transform: @escaping (T?) -> URL?) -> Column<ObjectType, InputType, URLColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, URLColumnType>(
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
                let urlValue = transform(finalValue)

                // Return URLColumnType
                return URLColumnType(URLColumnConfig(value: urlValue))
            },
            nilHandling: .keepEmpty // URL output may be nil
        )
    }

    /// Transforms column values to Bool using a custom conversion closure.
    ///
    /// This method provides a way to convert any column output type to Boolean values.
    /// The closure receives the processed value based on the column's nilHandling configuration:
    /// - For columns with `.keepEmpty`: receives T? (may be nil)
    /// - For columns with `.defaultValue`: receives T (never nil, default applied)
    ///
    /// Example usage:
    /// ```swift
    /// // Convert String to Bool
    /// Column(name: "Status", keyPath: \.statusString)
    ///     .toBoolean { (status: String) in
    ///         status.lowercased() == "active"
    ///     }
    ///
    /// // Convert number to Bool
    /// Column(name: "Score", keyPath: \.score)
    ///     .toBoolean { (score: Int) in
    ///         score > 50
    ///     }
    ///
    /// // Convert optional values with defaultValue
    /// Column(name: "Priority", keyPath: \.priorityString)
    ///     .defaultValue("low")
    ///     .toBoolean { (priority: String) in  // Non-optional after defaultValue!
    ///         priority.lowercased() == "high"
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the processed value to Bool
    /// - Returns: A new column that outputs BoolColumnType with transformed values
    public func toBoolean<T>(
        _ transform: @escaping (T) -> Bool) -> Column<ObjectType, InputType, BoolColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, BoolColumnType>(
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
                let boolValue: Bool = switch self.nilHandling {
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

                // Return BoolColumnType with default settings
                return BoolColumnType(BoolColumnConfig(value: boolValue, booleanExpressions: .oneAndZero, caseStrategy: .upper))
            },
            nilHandling: .keepEmpty // Bool output is never nil
        )
    }

    /// Transforms column values to Bool using a custom conversion closure that handles optional values.
    ///
    /// This overload is for columns that may contain nil values (when nilHandling is .keepEmpty).
    /// Use this when you need to explicitly handle nil cases in your transformation.
    ///
    /// Example usage:
    /// ```swift
    /// // Convert optional String to optional Bool
    /// Column(name: "Active", keyPath: \.activeString)
    ///     .toBoolean { (status: String?) in
    ///         guard let status else { return nil }
    ///         return status.lowercased() == "yes"
    ///     }
    ///
    /// // Convert with custom nil handling
    /// Column(name: "Premium", keyPath: \.premiumFlag)
    ///     .toBoolean { (flag: String?) in
    ///         flag?.lowercased() == "true" ?? false
    ///     }
    /// ```
    ///
    /// - Parameter transform: A closure that converts the optional value to optional Bool
    /// - Returns: A new column that outputs BoolColumnType with transformed values
    public func toBoolean<T>(
        _ transform: @escaping (T?) -> Bool?) -> Column<ObjectType, InputType, BoolColumnType> where OutputType.Config.ValueType == T
    {
        Column<ObjectType, InputType, BoolColumnType>(
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
                let boolValue = transform(finalValue)

                // Return BoolColumnType with default settings
                return BoolColumnType(BoolColumnConfig(value: boolValue, booleanExpressions: .oneAndZero, caseStrategy: .upper))
            },
            nilHandling: .keepEmpty // Bool output may be nil
        )
    }
}
