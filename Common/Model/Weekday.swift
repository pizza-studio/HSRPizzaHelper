//
//  DayOfWeek.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/8.
//

import Foundation

enum Weekday: Int, CaseIterable, CustomStringConvertible {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var description: String {
        switch self {
        case .sunday:
            return "sys.weekday.sunday"
        case .monday:
            return "sys.weekday.monday"
        case .tuesday:
            return "sys.weekday.tuesday"
        case .wednesday:
            return "sys.weekday.wednesday"
        case .thursday:
            return "sys.weekday.thursday"
        case .friday:
            return "sys.weekday.friday"
        case .saturday:
            return "sys.weekday.saturday"
        }
    }
}
