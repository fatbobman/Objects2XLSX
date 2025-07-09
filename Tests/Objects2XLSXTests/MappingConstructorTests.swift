//
// MappingConstructorTests.swift
// Created by Claude on 2025-07-09.
// Test suite for new generic mapping constructors in Column
//

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Generic Mapping Constructor Tests")
struct MappingConstructorTests {
    // Test data models
    enum Priority: String, CaseIterable, Sendable {
        case low
        case medium
        case high
    }

    enum Status: String, CaseIterable, Sendable {
        case pending
        case inProgress = "in_progress"
        case completed
    }

    struct TestTask: Sendable {
        let title: String
        let priority: Priority
        let status: Status
        let progress: Double
        let dueDate: Date
        let assignee: String?
        let estimatedHours: Int
        let isUrgent: Bool
    }

    let sampleTasks = [
        TestTask(
            title: "Implement Feature A",
            priority: .high,
            status: .inProgress,
            progress: 0.75,
            dueDate: Date(),
            assignee: "Alice",
            estimatedHours: 8,
            isUrgent: true),
        TestTask(
            title: "Write Documentation",
            priority: .medium,
            status: .pending,
            progress: 0.0,
            dueDate: Date().addingTimeInterval(86400 * 7), // 7 days later
            assignee: nil,
            estimatedHours: 4,
            isUrgent: false),
        TestTask(
            title: "Bug Fix #123",
            priority: .low,
            status: .completed,
            progress: 1.0,
            dueDate: Date().addingTimeInterval(-86400), // 1 day ago
            assignee: "Bob",
            estimatedHours: 2,
            isUrgent: false)
    ]

    @Test("Enum to Text mapping constructor")
    func enumToTextMapping() throws {
        // Test Priority enum to text
        let priorityColumn = Column<TestTask, Priority, TextColumnType>(
            name: "Priority Level",
            keyPath: \.priority,
            transform: { priority in
                TextColumnType(TextColumnConfig(value: priority.rawValue.capitalized))
            })

        #expect(priorityColumn.name == "Priority Level", "Column name should match")

        // Test data extraction and transformation
        let task1Cell = priorityColumn.generateCellValue(for: sampleTasks[0])
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "High", "High priority should be capitalized")
            default:
                Issue.record("Expected stringValue enum case for Priority enum")
        }

        let task2Cell = priorityColumn.generateCellValue(for: sampleTasks[1])
        switch task2Cell {
            case let .stringValue(value):
                #expect(value == "Medium", "Medium priority should be capitalized")
            default:
                Issue.record("Expected stringValue enum case for Priority enum")
        }
    }

    @Test("Status enum with custom logic mapping")
    func statusEnumWithCustomLogic() throws {
        // Test Status enum with custom display logic
        let statusColumn = Column<TestTask, Status, TextColumnType>(
            name: "Current Status",
            keyPath: \.status,
            transform: { status in
                let displayText = switch status {
                    case .pending: "📋 Pending"
                    case .inProgress: "🔄 In Progress"
                    case .completed: "✅ Completed"
                    default: "Unknown"
                }
                return TextColumnType(TextColumnConfig(value: displayText))
            })

        #expect(statusColumn.name == "Current Status", "Column name should match")

        // Test transformations
        let task1Cell = statusColumn.generateCellValue(for: sampleTasks[0]) // inProgress
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "🔄 In Progress", "In progress should have correct emoji")
            default:
                Issue.record("Expected stringValue enum case for Status enum")
        }

        let task3Cell = statusColumn.generateCellValue(for: sampleTasks[2]) // completed
        switch task3Cell {
            case let .stringValue(value):
                #expect(value == "✅ Completed", "Completed should have correct emoji")
            default:
                Issue.record("Expected stringValue enum case for Status enum")
        }
    }

    @Test("Double to Text with conditional logic")
    func doubleToTextConditionalLogic() throws {
        // Test progress Double to status text
        let progressColumn = Column<TestTask, Double, TextColumnType>(
            name: "Progress Status",
            keyPath: \.progress,
            transform: { progress in
                let statusText = switch progress {
                    case 0.0: "Not Started"
                    case 0.0 ..< 0.3: "Getting Started"
                    case 0.3 ..< 0.7: "In Progress"
                    case 0.7 ..< 1.0: "Almost Done"
                    case 1.0: "Completed"
                    default: "Unknown"
                }
                return TextColumnType(TextColumnConfig(value: statusText))
            })

        #expect(progressColumn.name == "Progress Status", "Column name should match")

        // Test various progress levels
        let task1Cell = progressColumn.generateCellValue(for: sampleTasks[0]) // 0.75
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "Almost Done", "0.75 progress should be 'Almost Done'")
            default:
                Issue.record("Expected stringValue enum case for progress mapping")
        }

        let task2Cell = progressColumn.generateCellValue(for: sampleTasks[1]) // 0.0
        switch task2Cell {
            case let .stringValue(value):
                #expect(value == "Not Started", "0.0 progress should be 'Not Started'")
            default:
                Issue.record("Expected stringValue enum case for progress mapping")
        }

        let task3Cell = progressColumn.generateCellValue(for: sampleTasks[2]) // 1.0
        switch task3Cell {
            case let .stringValue(value):
                #expect(value == "Completed", "1.0 progress should be 'Completed'")
            default:
                Issue.record("Expected stringValue enum case for progress mapping")
        }
    }

    @Test("Date to Text formatting")
    func dateToTextFormatting() throws {
        // Test Date to formatted year string
        let yearColumn = Column<TestTask, Date, TextColumnType>(
            name: "Due Year",
            keyPath: \.dueDate,
            transform: { date in
                let year = Calendar.current.component(.year, from: date)
                return TextColumnType(TextColumnConfig(value: String(year)))
            })

        #expect(yearColumn.name == "Due Year", "Column name should match")

        // Test data extraction
        let task1Cell = yearColumn.generateCellValue(for: sampleTasks[0])
        switch task1Cell {
            case let .stringValue(value):
                let currentYear = Calendar.current.component(.year, from: Date())
                #expect(value == String(currentYear), "Should extract current year")
            default:
                Issue.record("Expected stringValue enum case for date formatting")
        }
    }

    @Test("Int to Text categorization")
    func intToTextCategorization() throws {
        // Test estimated hours to effort level
        let effortColumn = Column<TestTask, Int, TextColumnType>(
            name: "Effort Level",
            keyPath: \.estimatedHours,
            transform: { hours in
                let effortLevel = switch hours {
                    case 0 ... 2: "Quick Task"
                    case 3 ... 6: "Medium Task"
                    case 7 ... 12: "Large Task"
                    default: "Epic Task"
                }
                return TextColumnType(TextColumnConfig(value: effortLevel))
            })

        #expect(effortColumn.name == "Effort Level", "Column name should match")

        // Test categorization logic
        let task1Cell = effortColumn.generateCellValue(for: sampleTasks[0]) // 8 hours
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "Large Task", "8 hours should be 'Large Task'")
            default:
                Issue.record("Expected stringValue enum case for hours categorization")
        }

        let task2Cell = effortColumn.generateCellValue(for: sampleTasks[1]) // 4 hours
        switch task2Cell {
            case let .stringValue(value):
                #expect(value == "Medium Task", "4 hours should be 'Medium Task'")
            default:
                Issue.record("Expected stringValue enum case for hours categorization")
        }

        let task3Cell = effortColumn.generateCellValue(for: sampleTasks[2]) // 2 hours
        switch task3Cell {
            case let .stringValue(value):
                #expect(value == "Quick Task", "2 hours should be 'Quick Task'")
            default:
                Issue.record("Expected stringValue enum case for hours categorization")
        }
    }

    @Test("Bool to Text custom expressions")
    func boolToTextCustomExpressions() throws {
        // Test Bool to custom text expressions
        let urgencyColumn = Column<TestTask, Bool, TextColumnType>(
            name: "Urgency Flag",
            keyPath: \.isUrgent,
            transform: { isUrgent in
                let urgencyText = isUrgent ? "🚨 URGENT" : "📅 Normal"
                return TextColumnType(TextColumnConfig(value: urgencyText))
            })

        #expect(urgencyColumn.name == "Urgency Flag", "Column name should match")

        // Test transformations
        let task1Cell = urgencyColumn.generateCellValue(for: sampleTasks[0]) // true
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "🚨 URGENT", "Urgent task should show alarm emoji")
            default:
                Issue.record("Expected stringValue enum case for Bool transformation")
        }

        let task2Cell = urgencyColumn.generateCellValue(for: sampleTasks[1]) // false
        switch task2Cell {
            case let .stringValue(value):
                #expect(value == "📅 Normal", "Non-urgent task should show normal")
            default:
                Issue.record("Expected stringValue enum case for Bool transformation")
        }
    }

    @Test("Optional String handling")
    func optionalStringHandling() throws {
        // Test optional String to text with nil handling
        let assigneeColumn = Column<TestTask, String?, TextColumnType>(
            name: "Assigned To",
            keyPath: \.assignee,
            transform: { assignee in
                let displayName = assignee ?? "Unassigned"
                return TextColumnType(TextColumnConfig(value: "👤 \(displayName)"))
            })

        #expect(assigneeColumn.name == "Assigned To", "Column name should match")

        // Test non-nil assignee
        let task1Cell = assigneeColumn.generateCellValue(for: sampleTasks[0]) // "Alice"
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "👤 Alice", "Should show assigned person with emoji")
            default:
                Issue.record("Expected stringValue enum case for assignee")
        }

        // Test nil assignee
        let task2Cell = assigneeColumn.generateCellValue(for: sampleTasks[1]) // nil
        switch task2Cell {
            case let .stringValue(value):
                #expect(value == "👤 Unassigned", "Should show 'Unassigned' for nil")
            default:
                Issue.record("Expected stringValue enum case for nil assignee")
        }
    }

    @Test("Complex multi-field transformation")
    func complexMultiFieldTransformation() throws {
        // Test complex transformation using multiple fields through closure
        let summaryColumn = Column<TestTask, TestTask, TextColumnType>(
            name: "Task Summary",
            keyPath: \.self,
            transform: { task in
                let priorityPrefix = switch task.priority {
                    case .high: "[HIGH]"
                    case .medium: "[MED]"
                    case .low: "[LOW]"
                }

                let progressPercent = Int(task.progress * 100)
                let summary = "\(priorityPrefix) \(task.title) (\(progressPercent)%)"
                return TextColumnType(TextColumnConfig(value: summary))
            })

        #expect(summaryColumn.name == "Task Summary", "Column name should match")

        // Test complex transformation
        let task1Cell = summaryColumn.generateCellValue(for: sampleTasks[0])
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "[HIGH] Implement Feature A (75%)", "Should combine priority, title, and progress")
            default:
                Issue.record("Expected stringValue enum case for complex transformation")
        }

        let task3Cell = summaryColumn.generateCellValue(for: sampleTasks[2])
        switch task3Cell {
            case let .stringValue(value):
                #expect(value == "[LOW] Bug Fix #123 (100%)", "Should combine priority, title, and progress")
            default:
                Issue.record("Expected stringValue enum case for complex transformation")
        }
    }

    @Test("Mapping to different output types")
    func mappingToDifferentOutputTypes() throws {
        // Test mapping to DoubleColumnType
        let priorityScoreColumn = Column<TestTask, Priority, DoubleColumnType>(
            name: "Priority Score",
            keyPath: \.priority,
            transform: { priority in
                let score = switch priority {
                    case .low: 1.0
                    case .medium: 5.0
                    case .high: 10.0
                    default: 0.0
                }
                return DoubleColumnType(DoubleColumnConfig(value: score))
            })

        #expect(priorityScoreColumn.name == "Priority Score", "Column name should match")

        // Test transformation to Double
        let task1Cell = priorityScoreColumn.generateCellValue(for: sampleTasks[0]) // high priority
        switch task1Cell {
            case let .doubleValue(value):
                #expect(value == 10.0, "High priority should map to 10.0")
            default:
                Issue.record("Expected doubleValue enum case for priority score")
        }

        let task2Cell = priorityScoreColumn.generateCellValue(for: sampleTasks[1]) // medium priority
        switch task2Cell {
            case let .doubleValue(value):
                #expect(value == 5.0, "Medium priority should map to 5.0")
            default:
                Issue.record("Expected doubleValue enum case for priority score")
        }
    }

    @Test("Chaining with width and style")
    func chainingWithWidthAndStyle() throws {
        let style = CellStyle(font: Font(bold: true))

        // Test that new constructor works with chaining
        let priorityColumn = Column<TestTask, Priority, TextColumnType>(
            name: "Priority",
            keyPath: \.priority,
            transform: { priority in
                TextColumnType(TextColumnConfig(value: priority.rawValue.uppercased()))
            })
            .width(12)
            .bodyStyle(style)

        #expect(priorityColumn.name == "Priority", "Column name should match")
        #expect(priorityColumn.width == 12, "Width should be preserved")
        #expect(priorityColumn.bodyStyle == style, "Style should be preserved")

        // Test functionality still works
        let task1Cell = priorityColumn.generateCellValue(for: sampleTasks[0])
        switch task1Cell {
            case let .stringValue(value):
                #expect(value == "HIGH", "Priority should be uppercased")
            default:
                Issue.record("Expected stringValue enum case after chaining")
        }
    }

    @Test("Integration with Sheet")
    func integrationWithSheet() throws {
        // Create sheet using new mapping constructors
        let sheet = Sheet<TestTask>(
            name: "Tasks",
            dataProvider: { sampleTasks })
        {
            Column(name: "Title", keyPath: \.title)

            Column<TestTask, Priority, TextColumnType>(
                name: "Priority",
                keyPath: \.priority,
                transform: { priority in
                    TextColumnType(TextColumnConfig(value: priority.rawValue.capitalized))
                })
                .width(10)

            Column<TestTask, Status, TextColumnType>(
                name: "Status",
                keyPath: \.status,
                transform: { status in
                    let emoji = switch status {
                        case .pending: "📋"
                        case .inProgress: "🔄"
                        case .completed: "✅"
                    }
                    return TextColumnType(TextColumnConfig(value: "\(emoji) \(status.rawValue)"))
                })
                .width(15)

            Column<TestTask, Double, TextColumnType>(
                name: "Progress",
                keyPath: \.progress,
                transform: { progress in
                    let percent = Int(progress * 100)
                    return TextColumnType(TextColumnConfig(value: "\(percent)%"))
                })
                .width(8)
        }

        #expect(sheet.name == "Tasks", "Sheet name should match")

        // Test that sheet can generate XML without errors
        let styleRegister = StyleRegister()
        let shareStringRegister = ShareStringRegister()

        let sheetXML = sheet.makeSheetXML(
            with: sampleTasks,
            bookStyle: BookStyle(),
            styleRegister: styleRegister,
            shareStringRegistor: shareStringRegister)

        #expect(sheetXML != nil, "Sheet should generate SheetXML")

        guard let xml = sheetXML else {
            Issue.record("Expected non-nil SheetXML")
            return
        }

        let xmlString = xml.generateXML()
        #expect(!xmlString.isEmpty, "Sheet should generate non-empty XML")

        // Verify shared strings contain transformed values
        let sharedStrings = shareStringRegister.allStrings
        #expect(sharedStrings.contains("High"), "Transformed priority should be in shared strings")
        #expect(sharedStrings.contains("✅ completed"), "Transformed status should be in shared strings")
        #expect(sharedStrings.contains("75%"), "Transformed progress should be in shared strings")
    }
}
