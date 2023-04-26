//
//  UserData.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//  小组件和主页用到的各类数据和处理工具

import Foundation

// MARK: - UserData

public struct UserData: SimplifiedUserDataContainer {
    // MARK: Lifecycle

    init(fetchData: FetchData) {
        self.resinInfo = ResinInfo(
            fetchData.currentResin,
            fetchData.maxResin,
            Int(fetchData.resinRecoveryTime)!
        )
        self.dailyTaskInfo = DailyTaskInfo(
            totalTaskNum: fetchData.totalTaskNum,
            finishedTaskNum: fetchData.finishedTaskNum,
            isTaskRewardReceived: fetchData.isExtraTaskRewardReceived
        )
        self.weeklyBossesInfo = WeeklyBossesInfo(
            remainResinDiscountNum: fetchData.remainResinDiscountNum,
            resinDiscountNumLimit: fetchData.resinDiscountNumLimit
        )
        self.expeditionInfo = ExpeditionInfo(
            currentExpedition: fetchData.currentExpeditionNum,
            maxExpedition: fetchData.maxExpeditionNum,
            expeditions: fetchData.expeditions
        )
        self.homeCoinInfo = HomeCoinInfo(
            fetchData.currentHomeCoin,
            fetchData.maxHomeCoin,
            Int(fetchData.homeCoinRecoveryTime)!
        )
        self.transformerInfo = TransformerInfo(fetchData.transformer)
    }

    init(
        resinInfo: ResinInfo,
        dailyTaskInfo: DailyTaskInfo,
        weeklyBossesInfo: WeeklyBossesInfo,
        expeditionInfo: ExpeditionInfo,
        homeCoinInfo: HomeCoinInfo,
        transformerInfo: TransformerInfo
    ) {
        self.resinInfo = resinInfo
        self.dailyTaskInfo = dailyTaskInfo
        self.weeklyBossesInfo = weeklyBossesInfo
        self.expeditionInfo = expeditionInfo
        self.homeCoinInfo = homeCoinInfo
        self.transformerInfo = transformerInfo
    }

    // MARK: Public

    public let resinInfo: ResinInfo

    public let dailyTaskInfo: DailyTaskInfo

    public let weeklyBossesInfo: WeeklyBossesInfo

    public let expeditionInfo: ExpeditionInfo

    public let homeCoinInfo: HomeCoinInfo

    public let transformerInfo: TransformerInfo
}

public typealias SimplifiedUserDataResult = Result<
    SimplifiedUserData,
    FetchError
>
public typealias SimplifiedUserDataContainerResult<T> = Result<T, FetchError>
    where T: SimplifiedUserDataContainer

// MARK: - SimplifiedUserData

public struct SimplifiedUserData: Codable, SimplifiedUserDataContainer {
    // MARK: Lifecycle

    init(
        resinInfo: ResinInfo,
        dailyTaskInfo: DailyTaskInfo,
        expeditionInfo: ExpeditionInfo,
        homeCoinInfo: HomeCoinInfo
    ) {
        self.resinInfo = resinInfo
        self.dailyTaskInfo = dailyTaskInfo
        self.expeditionInfo = expeditionInfo
        self.homeCoinInfo = homeCoinInfo
    }

    init?(widgetUserData: WidgetUserData) {
        guard let resin: String = widgetUserData.data.data
            .first(where: { $0.name == "原粹树脂" })?.value,
            let expedition: String = widgetUserData.data.data
            .first(where: { $0.name == "探索派遣" })?.value,
            let task: String = widgetUserData.data.data
            .first(where: { $0.name == "每日委托进度" })?.value ?? widgetUserData
            .data.data.first(where: { $0.name == "每日委托奖励" })?.value,
            let homeCoin: String = widgetUserData.data.data
            .first(where: { $0.name == "洞天财瓮" })?.value
        else { return nil }

        let resinStr = resin.split(separator: "/")
        guard let currentResin = Int(resinStr.first ?? ""),
              let maxResin = Int(resinStr.last ?? "")
        else { return nil }
        let resinRecoveryTime: Int = (maxResin - currentResin) * 8 * 60
        self.resinInfo = .init(currentResin, maxResin, resinRecoveryTime)

        let taskStr = task.split(separator: "/")
        if taskStr.count == 1 {
            let isTaskRewardReceived: Bool = (task != "尚未领取")
            self.dailyTaskInfo = .init(
                totalTaskNum: 4,
                finishedTaskNum: 4,
                isTaskRewardReceived: isTaskRewardReceived
            )
        } else {
            guard let finishedTaskNum = Int(taskStr.first ?? ""),
                  let totalTaskNum = Int(taskStr.last ?? "")
            else { return nil }
            let isTaskRewardReceived = (finishedTaskNum == totalTaskNum)
            self.dailyTaskInfo = .init(
                totalTaskNum: totalTaskNum,
                finishedTaskNum: finishedTaskNum,
                isTaskRewardReceived: isTaskRewardReceived
            )
        }

        let expeditionStr = expedition.split(separator: "/")
        guard let currentExpeditionNum = Int(expeditionStr.first ?? ""),
              let maxExpeditionNum = Int(expeditionStr.last ?? "")
        else { return nil }
        self.expeditionInfo = .init(
            currentExpedition: currentExpeditionNum,
            maxExpedition: maxExpeditionNum,
            expeditions: []
        )

        let homeCoinStr = homeCoin.split(separator: "/")
        if homeCoinStr.count == 1 {
            self.homeCoinInfo = .init(0, 300, 0)
        } else {
            guard let currentHomeCoin = Int(homeCoinStr.first ?? ""),
                  let maxHomeCoin = Int(homeCoinStr.last ?? "")
            else { return nil }
            if UserDefaults(suiteName: "group.GenshinPizzaHelper")?
                .double(forKey: "homeCoinRefreshFrequencyInHour") == 0 {
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .set(30.0, forKey: "homeCoinRefreshFrequencyInHour")
            }
            var homeCoinRefreshFrequencyInHour =
                Int(
                    UserDefaults(suiteName: "group.GenshinPizzaHelper")?
                        .double(forKey: "homeCoinRefreshFrequencyInHour") ??
                        30.0
                )
            // 我也不知道为什么有时候这玩意取到0，反正给个默认值30吧
            homeCoinRefreshFrequencyInHour = !(4 ... 30)
                .contains(homeCoinRefreshFrequencyInHour) ? 30 :
                homeCoinRefreshFrequencyInHour
            let homeCoinRecoveryHour: Int = (maxHomeCoin - currentHomeCoin) /
                homeCoinRefreshFrequencyInHour
            let homeCoinRecoverySecond: Int = homeCoinRecoveryHour * 60 * 60
            self.homeCoinInfo = .init(
                currentHomeCoin,
                maxHomeCoin,
                homeCoinRecoverySecond
            )
        }
    }

    // MARK: Public

    public let resinInfo: ResinInfo
    public let dailyTaskInfo: DailyTaskInfo
    public let expeditionInfo: ExpeditionInfo
    public let homeCoinInfo: HomeCoinInfo
}

extension UserData {
    public static let defaultData = UserData(
        fetchData: FetchData(
            currentResin: 90,
            maxResin: 160,
            resinRecoveryTime: "\((160 - 90) * 8)",

            finishedTaskNum: 3,
            totalTaskNum: 4,
            isExtraTaskRewardReceived: false,

            remainResinDiscountNum: 2,
            resinDiscountNumLimit: 3,

            currentExpeditionNum: 2,
            maxExpeditionNum: 5,
            expeditions: Expedition.defaultExpeditions,

            currentHomeCoin: 1200,
            maxHomeCoin: 2400,
            homeCoinRecoveryTime: "123",

            transformer: TransformerData(
                recoveryTime: TransformerData
                    .TransRecoveryTime(day: 4, hour: 3, minute: 0, second: 0),
                obtained: true
            )
        )
    )
}

extension Expedition {
    public static let defaultExpedition: Expedition = .init(
        avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Sara.png",
        remainedTimeStr: "0",
        statusStr: "Finished"
    )

    public static let defaultExpeditions: [Expedition] = [
        Expedition(
            avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Yelan.png",
            remainedTimeStr: "0",
            statusStr: "Finished"
        ),
        Expedition(
            avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Fischl.png",
            remainedTimeStr: "37036",
            statusStr: "Ongoing"
        ),
        Expedition(
            avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Fischl.png",
            remainedTimeStr: "22441",
            statusStr: "Ongoing"
        ),
        Expedition(
            avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Keqing.png",
            remainedTimeStr: "22441",
            statusStr: "Ongoing"
        ),
        Expedition(
            avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Bennett.png",
            remainedTimeStr: "22441",
            statusStr: "Ongoing"
        ),
    ]
}

// MARK: - SimplifiedUserDataContainer

public protocol SimplifiedUserDataContainer {
    var resinInfo: ResinInfo { get }
    var homeCoinInfo: HomeCoinInfo { get }
    var expeditionInfo: ExpeditionInfo { get }
    var dailyTaskInfo: DailyTaskInfo { get }

    func dataAfter(_ second: TimeInterval) -> Self
}

extension UserData {
    public func dataAfter(_ second: TimeInterval) -> UserData {
        guard second != 0 else {
            return self
        }
        var resinRecoveryTime = resinInfo.recoveryTime.second - Int(second)
        if resinRecoveryTime < 0 { resinRecoveryTime = 0 }
        var currentResin = 160 -
            Int(ceil(Double(resinRecoveryTime) / (8.0 * 60.0)))
        if currentResin < 0 { currentResin = 0 }

        let currentExpeditionNum: Int = expeditionInfo.expeditions
            .filter { expedition in
                Double(expedition.remainedTimeStr)! - second > 0
            }.count
        let expeditions: [Expedition] = expeditionInfo.expeditions
            .map { expedition in
                var remainTime: Int = expedition.recoveryTime
                    .second - Int(second)
                if remainTime < 0 { remainTime = 0 }
                return .init(
                    avatarSideIcon: expedition.avatarSideIcon,
                    remainedTimeStr: String(remainTime),
                    statusStr: expedition.statusStr
                )
            }

        let totalTime: Double
        if homeCoinInfo.recoveryTime.second == 0 {
            totalTime = 0
        } else {
            totalTime = Double(homeCoinInfo.recoveryTime.second) /
                (1.0 - homeCoinInfo.percentage)
        }
        var remainHomeCoinTimeToFull = Double(
            homeCoinInfo.recoveryTime.second
        ) -
            second
        if remainHomeCoinTimeToFull < 0 { remainHomeCoinTimeToFull = 0 }
        var currentHomeCoinPercentage: Double
        if totalTime != 0 {
            currentHomeCoinPercentage = 1 -
                (remainHomeCoinTimeToFull / totalTime)
        } else {
            currentHomeCoinPercentage = 1
        }
        let currentHomeCoin =
            Int(Double(homeCoinInfo.maxHomeCoin) * currentHomeCoinPercentage)
        let homeCoinRecoveryTime =
            Int(totalTime * (1 - currentHomeCoinPercentage))

        return .init(
            resinInfo: .init(
                currentResin,
                resinInfo.maxResin,
                resinRecoveryTime
            ),
            dailyTaskInfo: dailyTaskInfo,
            weeklyBossesInfo: weeklyBossesInfo,
            expeditionInfo: .init(
                currentExpedition: currentExpeditionNum,
                maxExpedition: expeditionInfo.maxExpedition,
                expeditions: expeditions
            ),
            homeCoinInfo: .init(
                currentHomeCoin,
                homeCoinInfo.maxHomeCoin,
                homeCoinRecoveryTime
            ),
            transformerInfo: transformerInfo
        )
    }
}

extension SimplifiedUserData {
    public func dataAfter(_ second: TimeInterval) -> SimplifiedUserData {
        guard second != 0 else {
            return self
        }
        var resinRecoveryTime = resinInfo.recoveryTime.second - Int(second)
        if resinRecoveryTime < 0 { resinRecoveryTime = 0 }
        var currentResin = 160 -
            Int(ceil(Double(resinRecoveryTime) / (8.0 * 60.0)))
        if currentResin < 0 { currentResin = 0 }

        let totalTime: Double
        if homeCoinInfo.recoveryTime.second == 0 {
            totalTime = 0
        } else {
            totalTime = Double(homeCoinInfo.recoveryTime.second) /
                (1.0 - homeCoinInfo.percentage)
        }
        var remainHomeCoinTimeToFull = Double(
            homeCoinInfo.recoveryTime.second
        ) -
            second
        if remainHomeCoinTimeToFull < 0 { remainHomeCoinTimeToFull = 0 }
        var currentHomeCoinPercentage: Double
        if totalTime != 0 {
            currentHomeCoinPercentage = 1 -
                (remainHomeCoinTimeToFull / totalTime)
        } else {
            currentHomeCoinPercentage = 1
        }
        let currentHomeCoin =
            Int(Double(homeCoinInfo.maxHomeCoin) * currentHomeCoinPercentage)
        let homeCoinRecoveryTime =
            Int(totalTime * (1 - currentHomeCoinPercentage))

        return .init(
            resinInfo: .init(
                currentResin,
                resinInfo.maxResin,
                resinRecoveryTime
            ),
            dailyTaskInfo: dailyTaskInfo,
            expeditionInfo: expeditionInfo,
            homeCoinInfo: .init(
                currentHomeCoin,
                homeCoinInfo.maxHomeCoin,
                homeCoinRecoveryTime
            )
        )
    }
}

// MARK: - FetchData

public struct FetchData: Codable {
    // MARK: Lifecycle

    init(
        // 用于测试和提供小组件预览视图的默认数据
        currentResin: Int,
        maxResin: Int,
        resinRecoveryTime: String,

        finishedTaskNum: Int,
        totalTaskNum: Int,
        isExtraTaskRewardReceived: Bool,

        remainResinDiscountNum: Int,
        resinDiscountNumLimit: Int,

        currentExpeditionNum: Int,
        maxExpeditionNum: Int,
        expeditions: [Expedition],

        currentHomeCoin: Int,
        maxHomeCoin: Int,
        homeCoinRecoveryTime: String,

        transformer: TransformerData
    ) {
        self.currentResin = currentResin
        self.maxResin = maxResin
        self.resinRecoveryTime = resinRecoveryTime

        self.finishedTaskNum = finishedTaskNum
        self.totalTaskNum = totalTaskNum
        self.isExtraTaskRewardReceived = isExtraTaskRewardReceived

        self.remainResinDiscountNum = remainResinDiscountNum
        self.resinDiscountNumLimit = resinDiscountNumLimit

        self.currentExpeditionNum = currentExpeditionNum
        self.maxExpeditionNum = maxExpeditionNum
        self.expeditions = expeditions

        self.currentHomeCoin = currentHomeCoin
        self.maxHomeCoin = maxHomeCoin
        self.homeCoinRecoveryTime = homeCoinRecoveryTime

        self.transformer = transformer
    }

    // MARK: Internal

    // 树脂
    // decode
    let currentResin: Int
    let maxResin: Int
    let resinRecoveryTime: String

    // 每日任务
    let finishedTaskNum: Int
    let totalTaskNum: Int
    let isExtraTaskRewardReceived: Bool

    // 周本
    let remainResinDiscountNum: Int
    let resinDiscountNumLimit: Int

    // 派遣探索
    let currentExpeditionNum: Int
    let maxExpeditionNum: Int
    let expeditions: [Expedition]

    // 洞天宝钱
    let currentHomeCoin: Int
    let maxHomeCoin: Int
    let homeCoinRecoveryTime: String

    // 参量质变仪
    let transformer: TransformerData
}
