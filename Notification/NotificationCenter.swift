//
//  NotificationCenter.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  通知功能提供

import Foundation
import HBMihoyoAPI
import UserNotifications

class UserNotificationCenter {
    // MARK: Lifecycle

    private init() {
        userDefaults?.register(defaults: [
            "allowResinNotification": true,
            "resinNotificationNum": 140,
            "allowFullResinNotification": true,
            "allowHomeCoinNotification": true,
            "homeCoinNotificationHourBeforeFull": 8.0,
            "noticeExpeditionMethodRawValue": 1,
            "allowWeeklyBossesNotification": true,
            "weeklyBossesNotificationTimePointData": try! JSONEncoder()
                .encode(DateComponents(
                    calendar: .current,
                    hour: 19,
                    minute: 0,
                    weekday: 7
                )),
            "allowTransformerNotification": true,
            "allowDailyTaskNotification": true,
            "dailyTaskNotificationTimePointData": try! JSONEncoder()
                .encode(DateComponents(
                    calendar: .current,
                    hour: 19,
                    minute: 0
                )),
            "notificationIgnoreUidsData": try! JSONEncoder().encode([String]()),
        ])
        center.setNotificationCategories([normalNotificationCategory])
    }

    // MARK: Internal

    enum Object: String, CaseIterable {
        case resin
        case resinFull
        case homeCoin
        case expedition
        case weeklyBosses
        case transformer
        case dailyTask
    }

    static let shared: UserNotificationCenter = .init()

    let userDefaults = UserDefaults(suiteName: "group.GenshinPizzaHelper")

    // Define the custom actions.
    let openGenshin = UNNotificationAction(
        identifier: "OPEN_GENSHIN_ACTION",
        title: "打开《原神》".localized,
        options: [.foreground]
    )
    let openNotificationSetting = UNNotificationAction(
        identifier: "OPEN_NOTIFICATION_SETTING_ACTION",
        title: "通知设置".localized,
        options: [.foreground]
    )
    let center = UNUserNotificationCenter.current()

    // Define the notification type
    var normalNotificationCategory: UNNotificationCategory {
        UNNotificationCategory(
            identifier: "NORMAL_NOTIFICATION",
            actions: [openGenshin, openNotificationSetting],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
    }

    var ignoreUids: [String] {
        let data = userDefaults?
            .data(forKey: "notificationIgnoreUidsData") ??
            (try! JSONEncoder().encode([String]()))
        let ignoreUids: [String] = try! JSONDecoder()
            .decode([String].self, from: data)
        return ignoreUids
    }

    func printAllNotificationRequest() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
                print(request.content.title, request.content.body)
            }
        })
    }

    func testNotification() {
        let timeInterval = TimeInterval(5)
        let id = "12345678"

        let content = createNotificationContent(
            object: .resin,
            title: "hi",
            body: "hh"
        )

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request)
        print(request)
        print("user notification: success create ")
    }

    func askPermission() {
        center
            .requestAuthorization(options: [
                .alert,
                .sound,
                .badge,
            ]) { _, error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }

    func deleteNotification(
        for uid: String,
        object: Object,
        idSuffix: String = ""
    ) {
        let id = uid + object.rawValue + idSuffix
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func deleteAllNotification() {
        center.getDeliveredNotifications { notifications in
            let ids = notifications.map { notification in
                notification.request.identifier
            }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func deleteAllNotification(for uid: String) {
        Object.allCases.forEach { object in
            center.getDeliveredNotifications { notifications in
                notifications.forEach { notification in
                    if notification.request.identifier
                        .contains(uid + object.rawValue) {
                        self.center
                            .removePendingNotificationRequests(
                                withIdentifiers: [
                                    notification
                                        .request.identifier,
                                ]
                            )
                    }
                }
            }
        }
    }

    func deleteAllNotification(object: Object) {
        center.getDeliveredNotifications { notifications in
            let ids = notifications.filter { notification in
                notification.request.identifier.contains(object.rawValue)
            }.map { notification in
                notification.request.identifier
            }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func createAllNotification(
        for accountName: String,
        with userData: UserData,
        uid: String
    ) {
        print("Creating all notification")
        guard !ignoreUids.contains(uid) else { return }
        createResinNotification(
            for: accountName,
            with: userData.resinInfo,
            uid: uid
        )
        createFullResinNotification(
            for: accountName,
            with: userData.resinInfo,
            uid: uid
        )
        createHomeCoinNotification(
            for: accountName,
            with: userData.homeCoinInfo,
            uid: uid
        )
        createWeeklyBossesNotification(
            for: accountName,
            with: userData.weeklyBossesInfo,
            uid: uid
        )
        createTransformerNotification(
            for: accountName,
            with: userData.transformerInfo,
            uid: uid
        )
        createDailyTaskNotification(
            for: accountName,
            with: userData.dailyTaskInfo,
            uid: uid
        )
    }

    func createAllNotification(
        for accountName: String,
        with simplifiedUserData: SimplifiedUserData,
        uid: String
    ) {
        print("Creating all notification")
        guard !ignoreUids.contains(uid) else { return }
        createResinNotification(
            for: accountName,
            with: simplifiedUserData.resinInfo,
            uid: uid
        )
        createFullResinNotification(
            for: accountName,
            with: simplifiedUserData.resinInfo,
            uid: uid
        )
        createHomeCoinNotification(
            for: accountName,
            with: simplifiedUserData.homeCoinInfo,
            uid: uid
        )
        createDailyTaskNotification(
            for: accountName,
            with: simplifiedUserData.dailyTaskInfo,
            uid: uid
        )
    }

    // MARK: Private

//    private func imageURL(of object: Object) -> URL? {
//        switch object {
//        case .resin:
//            return Bundle.main.url(forResource: "树脂", withExtension: "png")
//        case .homeCoin:
//            return Bundle.main.url(forResource: "洞天宝钱", withExtension: "png")
//        case .expedition:
//            return Bundle.main.url(forResource: "派遣探索", withExtension: "png")
//        case .weeklyBosses:
//            return Bundle.main.url(forResource: "周本", withExtension: "png")
//        case .transformer:
//            return Bundle.main.url(forResource: "参量质变仪", withExtension: "png")
//        case .dailyTask:
//            return Bundle.main.url(forResource: "每日任务", withExtension: "png")
//        }
//    }

    // 树脂
    private var allowResinNotification: Bool {
        userDefaults?.bool(forKey: "allowResinNotification") ?? true
    }

    private var resinNotificationNum: Double {
        userDefaults?.double(forKey: "resinNotificationNum") ?? 150
    }

    private var allowFullResinNotification: Bool {
        userDefaults?.bool(forKey: "allowFullResinNotification") ?? true
    }

    private var allowHomeCoinNotification: Bool {
        userDefaults?.bool(forKey: "allowHomeCoinNotification") ?? true
    }

    private var homeCoinNotificationHourBeforeFull: Double {
        userDefaults?.double(forKey: "homeCoinNotificationHourBeforeFull") ?? 8
    }

    private var homeCoinNotificationTimeFromFull: Int {
        Int(homeCoinNotificationHourBeforeFull) * 60 * 60
    }

    private var homeCoinNotificationTimeDescription: String {
        relativeTimePointFromNow(second: homeCoinNotificationTimeFromFull)
    }

    private var allowExpeditionNotification: Bool {
        userDefaults?.bool(forKey: "allowExpeditionNotification") ?? true
    }

//    private var noticeExpeditionBy: ExpeditionNoticeMethod {
//        .init(
//            rawValue: userDefaults?
//                .integer(forKey: "noticeExpeditionMethodRawValue") ?? 1
//        )!
//    }

    private var allowWeeklyBossesNotification: Bool {
        userDefaults?.bool(forKey: "allowWeeklyBossesNotification") ?? true
    }

    private var weeklyBossesNotificationTimePoint: DateComponents {
        let data = userDefaults?
            .data(forKey: "weeklyBossesNotificationTimePointData") ??
            (
                try! JSONEncoder()
                    .encode(DateComponents(
                        calendar: .current,
                        hour: 19,
                        minute: 0,
                        weekday: 7
                    ))
            )
        let dateComponents = try! JSONDecoder()
            .decode(DateComponents.self, from: data)
        return dateComponents
    }

    private var allowTransformerNotification: Bool {
        userDefaults?.bool(forKey: "allowTransformerNotification") ?? true
    }

    private var allowDailyTaskNotification: Bool {
        userDefaults?.bool(forKey: "allowDailyTaskNotification") ?? true
    }

    private var dailyTaskNotificationDateComponents: DateComponents {
        let data = userDefaults?
            .data(forKey: "dailyTaskNotificationTimePointData") ??
            (
                try! JSONEncoder()
                    .encode(DateComponents(
                        calendar: .current,
                        hour: 19,
                        minute: 0
                    ))
            )
        let dateComponents = try! JSONDecoder()
            .decode(DateComponents.self, from: data)
        return dateComponents
    }

    private func createNotificationContent(
        object: Object,
        title: String?,
        body: String
    )
        -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = title
        }
        content.body = body
        content.categoryIdentifier = "NORMAL_NOTIFICATION"
        content.sound = .default
        content.badge = 1

        return content
    }

    private func createNotification(
        in second: Int,
        for accountName: String,
        object: Object,
        title: String,
        body: String,
        uid: String,
        idSuffix: String = ""
    ) {
        guard second > 0 else { return }
        let timeInterval = TimeInterval(second)
        let id = uid + object.rawValue + idSuffix

        let content = createNotificationContent(
            object: object,
            title: title,
            body: body
        )

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request)
        print(request)
        print("user notification: success create ")
    }

    private func createNotification(
        at date: DateComponents,
        for accountName: String,
        object: Object,
        title: String,
        body: String,
        uid: String,
        idSuffix: String = ""
    ) {
        let id = uid + object.rawValue + idSuffix

        let content = createNotificationContent(
            object: object,
            title: title,
            body: body
        )

        print("Create User Notification on \(date)")
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: date,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request)
        print("Adding user notification: \(request)")
    }

    private func createResinNotification(
        for accountName: String,
        with resinInfo: ResinInfo,
        uid: String
    ) {
        let resinNotificationTimeFromFull = (
            resinInfo
                .maxResin - Int(resinNotificationNum)
        ) * 8 * 60
        var resinNotificationTimeDescription: String {
            relativeTimePointFromNow(second: resinInfo.recoveryTime.second)
        }
        guard resinInfo.currentResin < Int(resinNotificationNum),
              allowResinNotification else {
            deleteNotification(for: uid, object: .resin); return
        }

        let titleCN = "「%@」原粹树脂提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        let bodyCN = "「%@」现有%lld原粹树脂，将在%@ 回满。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "noti body"),
            accountName,
            Int(resinNotificationNum),
            resinNotificationTimeDescription
        )
        createNotification(
            in: resinInfo.recoveryTime.second - resinNotificationTimeFromFull,
            for: accountName,
            object: .resin,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createFullResinNotification(
        for accountName: String,
        with resinInfo: ResinInfo,
        uid: String
    ) {
        guard resinInfo.currentResin < 160, allowFullResinNotification,
              allowResinNotification else {
            deleteNotification(for: uid, object: .resin); return
        }
        let titleCN = "「%@」原粹树脂提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        let bodyCN = "「%@」的原粹树脂已回满。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "noti body"),
            accountName
        )
        createNotification(
            in: resinInfo.recoveryTime.second,
            for: accountName,
            object: .resinFull,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createHomeCoinNotification(
        for accountName: String,
        with homeCoinInfo: HomeCoinInfo,
        uid: String
    ) {
        guard homeCoinInfo.recoveryTime
            .second > homeCoinNotificationTimeFromFull,
            allowHomeCoinNotification else {
            deleteNotification(for: uid, object: .homeCoin); return
        }
        guard allowHomeCoinNotification else { return }

        var currentHomeCoinWhenNotify: Int {
            let totalTime = Double(homeCoinInfo.recoveryTime.second) /
                (1.0 - homeCoinInfo.percentage)
            var recoveryPercentageWhenNotify: Double {
                1 - (Double(homeCoinNotificationTimeFromFull) / totalTime)
            }
            return Int(
                Double(homeCoinInfo.maxHomeCoin) *
                    recoveryPercentageWhenNotify
            )
        }

        let titleCN = "「%@」洞天宝钱提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        let bodyCN = "「%@」的洞天财瓮现有%lld洞天宝钱，将在%@ 填满。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "no body"),
            accountName,
            currentHomeCoinWhenNotify,
            homeCoinNotificationTimeDescription
        )

        createNotification(
            in: homeCoinInfo.recoveryTime
                .second - homeCoinNotificationTimeFromFull,
            for: accountName,
            object: .homeCoin,
            title: title,
            body: body,
            uid: uid
        )
    }

//    private func createExpeditionNotification(
//        for accountName: String,
//        with expeditionInfo: ExpeditionInfo,
//        uid: String
//    ) {
//        switch noticeExpeditionBy {
//        case .allCompleted, .unknown:
//            guard !expeditionInfo.allCompleted,
//                  allowExpeditionNotification else {
//                deleteNotification(for: uid, object: .expedition); return
//            }
//            let object: Object = .expedition
//            let titleCN = "「%@」探索派遣提醒"
//            let title = String(
//                format: NSLocalizedString(titleCN, comment: "noti title"),
//                accountName
//            )
//            let bodyCN = "「%@」的探索派遣已全部完成。"
//            let body = String(
//                format: NSLocalizedString(bodyCN, comment: "noti body"),
//                accountName
//            )
//            createNotification(
//                in: expeditionInfo.allCompleteTime.second,
//                for: accountName,
//                object: object,
//                title: title,
//                body: body,
//                uid: uid
//            )
//        case .nextCompleted:
//            guard !expeditionInfo.allCompleted,
//                  allowExpeditionNotification else {
//                deleteNotification(for: uid, object: .expedition); return
//            }
//            expeditionInfo.expeditions.forEach { expedition in
//                guard !expedition.isComplete else {
//                    deleteNotification(
//                        for: uid,
//                        object: .expedition,
//                        idSuffix: expedition.charactersEnglishName
//                    ); return
//                }
//                let charID = expedition.charactersEnglishName
//                let charName = expedition.characterName
//                let object: Object = .expedition
//                let titleCN = "「%@」探索派遣提醒"
//                let title = String(
//                    format: NSLocalizedString(titleCN, comment: "noti title"),
//                    accountName
//                )
//                let bodyCN = "%@的探索派遣已完成。"
//                let body = String(
//                    format: NSLocalizedString(bodyCN, comment: "noti body"),
//                    charName
//                )
//
//                createNotification(
//                    in: expedition.recoveryTime.second,
//                    for: accountName,
//                    object: object,
//                    title: title,
//                    body: body,
//                    uid: uid,
//                    idSuffix: charID
//                )
//            }
//        }
//    }

    private func createWeeklyBossesNotification(
        for accountName: String,
        with weeklyBossesInfo: WeeklyBossesInfo,
        uid: String
    ) {
        guard Date() < Calendar.current.nextDate(
            after: Date(),
            matching: weeklyBossesNotificationTimePoint,
            matchingPolicy: .nextTime
        )! else { return }
        guard weeklyBossesInfo.remainResinDiscountNum != 0 else {
            deleteNotification(for: uid, object: .weeklyBosses); return
        }
        guard allowWeeklyBossesNotification else { return }
        let titleCN = "「%@」周本折扣提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "notification title"),
            accountName
        )
        let bodyCN = "「%@」的周本树脂折扣树脂折扣还剩%lld次。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "notification body"),
            accountName,
            weeklyBossesInfo.remainResinDiscountNum
        )

        createNotification(
            at: weeklyBossesNotificationTimePoint,
            for: accountName,
            object: .weeklyBosses,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createTransformerNotification(
        for accountName: String,
        with transformerInfo: TransformerInfo,
        uid: String
    ) {
        guard !transformerInfo.isComplete, allowTransformerNotification,
              transformerInfo.obtained else {
            deleteNotification(for: uid, object: .transformer); return
        }
        let titleCN = "「%@」参量质变仪提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "notification title"),
            accountName
        )
        let bodyCN = "「%@」的参量质变仪已经可以使用。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "body"),
            accountName
        )
        let object: Object = .transformer

        createNotification(
            in: transformerInfo.recoveryTime.second,
            for: accountName,
            object: object,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createDailyTaskNotification(
        for accountName: String,
        with dailyTaskInfo: DailyTaskInfo,
        uid: String
    ) {
        guard Date() < Calendar.current.nextDate(
            after: Date(),
            matching: dailyTaskNotificationDateComponents,
            matchingPolicy: .nextTime
        )! else { return }
        guard !dailyTaskInfo.isTaskRewardReceived else {
            deleteNotification(for: uid, object: .dailyTask); return
        }
        guard allowDailyTaskNotification else { return }
        let titleCN = "「%@」每日委托提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        var body: String {
            if dailyTaskInfo.totalTaskNum - dailyTaskInfo.finishedTaskNum != 0 {
                let cn = "「%@」的每日委托还剩余%lld个未完成。"
                return String(
                    format: NSLocalizedString(cn, comment: "cn"),
                    accountName,
                    dailyTaskInfo.totalTaskNum - dailyTaskInfo.finishedTaskNum
                )
            } else {
                let cn = "「%@」的每日委托奖励还未领取。"
                return String(
                    format: NSLocalizedString(cn, comment: "cn"),
                    accountName
                )
            }
        }

        createNotification(
            at: dailyTaskNotificationDateComponents,
            for: accountName,
            object: .dailyTask,
            title: title,
            body: body,
            uid: uid
        )
    }
}
