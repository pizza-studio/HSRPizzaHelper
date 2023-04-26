//
//  DailyTaskDetail.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  每日委托信息

import Foundation

public struct DailyTaskInfo: Codable {
    public let totalTaskNum: Int
    public let finishedTaskNum: Int
    public let isTaskRewardReceived: Bool

    public var score: Float {
        let isTimePast8PM: Bool = Date() > Calendar.current
            .date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        if finishedTaskNum == totalTaskNum, !isTaskRewardReceived {
            return 1
        } else if !isTaskRewardReceived, isTimePast8PM {
            return 0.8
        } else { return 0 }
    }
}
