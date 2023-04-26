//
//  TimeTools.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  时间工具

import Foundation

func secondsToHoursMinutes(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        let cn = "%lld天"
        return String(
            format: NSLocalizedString(cn, comment: "day"),
            seconds / (3600 * 24)
        )
    }
    let cn = "%lld小时%lld分钟"
    return String(
        format: NSLocalizedString(cn, comment: "day"),
        seconds / 3600,
        (seconds % 3600) / 60
    )
}

func secondsToHrOrDay(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        return "\(seconds / (3600 * 24))天"
    } else if seconds / 3600 > 0 {
        return "\(seconds / 3600)小时"
    } else {
        return "\((seconds % 3600) / 60)分钟"
    }
}

extension Date {
    func adding(seconds: Int) -> Date {
        Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

func relativeTimePointFromNow(second: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    dateFormatter.locale = Locale(identifier: Locale.current.identifier)

    let date = Calendar.current.date(
        byAdding: .second,
        value: second,
        to: Date()
    )!

    return dateFormatter.string(from: date)
}

// 计算日期相差天数
extension Date {
    static func - (
        recent: Date,
        previous: Date
    )
        -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents(
            [.day],
            from: previous,
            to: recent
        ).day
        let month = Calendar.current.dateComponents(
            [.month],
            from: previous,
            to: recent
        ).month
        let hour = Calendar.current.dateComponents(
            [.hour],
            from: previous,
            to: recent
        ).hour
        let minute = Calendar.current.dateComponents(
            [.minute],
            from: previous,
            to: recent
        ).minute
        let second = Calendar.current.dateComponents(
            [.second],
            from: previous,
            to: recent
        ).second

        return (
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
    }
}
