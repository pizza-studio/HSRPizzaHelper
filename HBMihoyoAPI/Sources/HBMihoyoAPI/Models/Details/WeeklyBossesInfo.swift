//
//  WeeklyBossesInfo.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  周本信息

import Foundation

public struct WeeklyBossesInfo {
    public let remainResinDiscountNum: Int
    public let resinDiscountNumLimit: Int

    public var hasUsedResinDiscountNum: Int {
        resinDiscountNumLimit - remainResinDiscountNum
    }

    public var isComplete: Bool { remainResinDiscountNum == 0 }

    public var score: Float {
        if Calendar.current.isDateInWeekend(Date()), !isComplete {
            return Float(0.5)
        } else { return 0 }
    }
}
