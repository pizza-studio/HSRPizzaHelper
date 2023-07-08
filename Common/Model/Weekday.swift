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

    // MARK: Internal

    var description: String {
        switch self {
        case .sunday:
            return "sys.weekday.sunday".localized()
        case .monday:
            return "sys.weekday.monday".localized()
        case .tuesday:
            return "sys.weekday.tuesday".localized()
        case .wednesday:
            return "sys.weekday.wednesday".localized()
        case .thursday:
            return "sys.weekday.thursday".localized()
        case .friday:
            return "sys.weekday.friday".localized()
        case .saturday:
            return "sys.weekday.saturday".localized()
        }
    }
}
