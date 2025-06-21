#!/usr/bin/env swift

import Foundation

// Example showing the simplified column mapping syntax for Objects2XLSX

struct Employee {
    let name: String
    let age: Int
    let salary: Double?
    let hireDate: Date
    let isManager: Bool
    let email: URL
}

// ====== OLD VERBOSE SYNTAX ======

/*
Column(
    name: "Salary",
    keyPath: \.salary,
    width: 12,
    bodyStyle: currencyStyle,
    mapping: { salary in
        DoubleColumnType(DoubleColumnConfig(value: salary ?? 0.0))
    })

Column(
    name: "Tax Rate", 
    keyPath: \.taxRate,
    width: 10,
    bodyStyle: numericStyle,
    mapping: { rate in
        PercentageColumnType(PercentageColumnConfig(value: rate, precision: 1))
    })
*/

// ====== NEW SIMPLIFIED SYNTAX ======

/*
// For non-optional Double properties:
Column(name: "Tax Rate", keyPath: \.taxRate)
    .percentage(precision: 1)
    .width(10)
    .bodyStyle(numericStyle)

// For optional Double properties (still need explicit mapping):
Column(
    name: "Salary",
    keyPath: \.salary,
    width: 12,
    bodyStyle: currencyStyle,
    mapping: { salary in
        DoubleColumnType(DoubleColumnConfig(value: salary ?? 0.0))
    })

// Other simplified syntax examples:
Column(name: "Name", keyPath: \.name).text()
Column(name: "Age", keyPath: \.age).int() 
Column(name: "Hire Date", keyPath: \.hireDate).date(timeZone: .utc)
Column(name: "Is Manager", keyPath: \.isManager).boolean(expressions: .yesAndNo)
Column(name: "Email", keyPath: \.email).url()
Column(name: "Price", keyPath: \.price).double()
*/

// The simplified syntax provides cleaner, more readable column definitions
// while maintaining full type safety and configurability.

print("✅ Simplified column mapping syntax implemented!")
print("📄 New syntax: Column(name: 'Rate', keyPath: \\.rate).percentage(precision: 1)")
print("📄 Old syntax: Column(name: 'Rate', keyPath: \\.rate, mapping: { PercentageColumnType(...) })")