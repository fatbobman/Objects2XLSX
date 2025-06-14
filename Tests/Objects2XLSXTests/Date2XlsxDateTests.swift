//
// Date2XlsxDateTests.swift
// Created by Xu Yang on 2025-06-14.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import Objects2XLSX
import Testing

@Suite("Date2XlsxDate Tests")
struct Date2XlsxDateTests {
    @Test("Date to excelDate")
    func excelDate() throws {
        // 45822.34957175926 -> 2025/6/14  08:23:23
        // 45822 -> 2025/6/14  00:00:00
        // 45822.5 -> 2025/6/14  12:00:00
        // 45822.998668981483 -> 2025/6/14  23:58:05

        let dateFormatter = DateFormatter()
        dateFormatter
            .dateFormat = "yyyy/MM/dd HH:mm:ss" // M and d handle both single and double digits
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        let date = dateFormatter.date(from: "2025/6/14 08:23:23")!
        let excelDate = date.excelDate(timeZone: .init(identifier: "Asia/Shanghai")!)
        #expect(Date.isExcelDateEqual(excelDate, "45822.34957175926", tolerance: 0.0001))

        let date2 = dateFormatter.date(from: "2025/6/14 00:00:00")!
        let excelDate2 = date2.excelDate(timeZone: .init(identifier: "Asia/Shanghai")!)
        #expect(Date.isExcelDateEqual(excelDate2, "45822", tolerance: 0.01))

        let date3 = dateFormatter.date(from: "2025/6/14 12:00:00")!
        let excelDate3 = date3.excelDate(timeZone: .init(identifier: "Asia/Shanghai")!)
        #expect(Date.isExcelDateEqual(excelDate3, "45822.5", tolerance: 0.01))

        let date4 = dateFormatter.date(from: "2025/6/14 23:58:05")!
        let excelDate4 = date4.excelDate(timeZone: .init(identifier: "Asia/Shanghai")!)
        #expect(Date.isExcelDateEqual(excelDate4, "45822.998668981483", tolerance: 0.01))
    }

    @Test("ExcelDate to Date")
    func execlDateToDate() throws {
        // 45822.34957175926 -> 2025/6/14  08:23:23
        // 45822 -> 2025/6/14  00:00:00
        // 45822.5 -> 2025/6/14  12:00:00
        // 45822.998668981483 -> 2025/6/14  23:58:05

        let shanghaiTimeZone = TimeZone(identifier: "Asia/Shanghai")!
        let date1 = Date.from(excelDate: 45822.34957175926, timeZone: shanghaiTimeZone)

        #expect(date1 != nil, "Date conversion should succeed")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.timeZone = shanghaiTimeZone

        let shanghaiTimeString = formatter.string(from: date1!)
        #expect(shanghaiTimeString == "2025/06/14 08:23:23", "Shanghai time should match")

        let date2 = Date.from(excelDate: 45822, timeZone: shanghaiTimeZone)
        #expect(date2 != nil, "Date conversion should succeed")
        let shanghaiTimeString2 = formatter.string(from: date2!)
        #expect(shanghaiTimeString2 == "2025/06/14 00:00:00", "Shanghai time should match")
        let date3 = Date.from(excelDate: 45822.5, timeZone: shanghaiTimeZone)
        #expect(date3 != nil, "Date conversion should succeed")
        let shanghaiTimeString3 = formatter.string(from: date3!)
        #expect(shanghaiTimeString3 == "2025/06/14 12:00:00", "Shanghai time should match")
        let date4 = Date.from(excelDate: 45822.998668981483, timeZone: shanghaiTimeZone)
        #expect(date4 != nil, "Date conversion should succeed")
        let shanghaiTimeString4 = formatter.string(from: date4!)
        #expect(shanghaiTimeString4 == "2025/06/14 23:58:05", "Shanghai time should match")
    }
}
