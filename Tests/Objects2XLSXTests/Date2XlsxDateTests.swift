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
        #expect(Date.isExcelDateEqual(excelDate, "45822.34957175926", tolerance: 0.000001))

        let date2 = dateFormatter.date(from: "2025/6/14 00:00:00")!
        let excelDate2 = date2.excelDate(timeZone: .init(identifier: "Asia/Shanghai")!)
        #expect(Date.isExcelDateEqual(excelDate2, "45822", tolerance: 0.000001))

        let date3 = dateFormatter.date(from: "2025/6/14 12:00:00")!
        let excelDate3 = date3.excelDate(timeZone: .init(identifier: "Asia/Shanghai")!)
        #expect(Date.isExcelDateEqual(excelDate3, "45822.5", tolerance: 0.000001))

        let date4 = dateFormatter.date(from: "2025/6/14 23:58:05")!
        let excelDate4 = date4.excelDate(timeZone: .init(identifier: "Asia/Shanghai")!)
        #expect(Date.isExcelDateEqual(excelDate4, "45822.998668981483", tolerance: 0.000001))
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

    // MARK: - Time Zones and Daylight Saving

    private static func date(_ text: String, in zone: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: zone)
        return formatter.date(from: text)!
    }

    @Test("A date's serial is its calendar date and clock time in the zone, in any zone")
    func serialIsLocalWallClock() {
        // 2025-06-14 is day 45822 in every zone; only the clock time counts
        for zone in ["UTC", "Europe/Stockholm", "America/New_York", "Asia/Tokyo", "Asia/Kolkata", "Australia/Sydney"] {
            let midnight = Self.date("2025/06/14 00:00:00", in: zone)
            let noon = Self.date("2025/06/14 12:00:00", in: zone)
            #expect(midnight.excelDate(timeZone: TimeZone(identifier: zone)!) == "45822.00000000", "\(zone)")
            #expect(noon.excelDate(timeZone: TimeZone(identifier: zone)!) == "45822.50000000", "\(zone)")
        }
    }

    @Test("Summer and winter dates both keep their clock time where daylight saving applies")
    func daylightSaving() {
        let stockholm = TimeZone(identifier: "Europe/Stockholm")!
        // Summer time (UTC+2) and winter time (UTC+1)
        #expect(Self.date("2026/07/01 00:30:00", in: "Europe/Stockholm").excelDate(timeZone: stockholm)
            == String(format: "%.8f", 46204 + 1800.0 / 86400))
        #expect(Self.date("2026/01/15 23:59:00", in: "Europe/Stockholm").excelDate(timeZone: stockholm)
            == String(format: "%.8f", 46037 + 86340.0 / 86400))
        // The day the clocks go back has 25 hours; 23:00 is still 23:00
        #expect(Self.date("2026/10/25 23:00:00", in: "Europe/Stockholm").excelDate(timeZone: stockholm)
            == String(format: "%.8f", 46320 + 23.0 / 24))
    }

    @Test("A date round-trips through its serial in any zone")
    func roundTrip() {
        let dates = ["1900/03/01 00:00:00", "1999/12/31 23:59:59", "2026/03/29 03:30:00", "2026/07/01 00:30:00", "2099/02/28 12:34:56"]
        for zone in ["UTC", "Europe/Stockholm", "America/Los_Angeles", "Asia/Shanghai"] {
            let timeZone = TimeZone(identifier: zone)!
            for text in dates {
                let date = Self.date(text, in: zone)
                let serial = Double(date.excelDate(timeZone: timeZone))!
                let back = Date.from(excelDate: serial, timeZone: timeZone)!
                #expect(abs(back.timeIntervalSince(date)) < 0.001, "\(text) in \(zone)")
            }
        }
    }

    @Test("A serial that is not a number gives no date")
    func notANumber() {
        #expect(Date.from(excelDate: .nan) == nil)
        #expect(Date.from(excelDate: .infinity) == nil)
    }
}
