//
//  DailyNoteNotification.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import HBMihoyoAPI
import SwiftyUserDefaults
import UserNotifications

private var center: UNUserNotificationCenter { HSRNotificationCenter.center }

extension HSRNotificationCenter {
    static func scheduleNotification(for account: Account, dailyNote: DailyNote) {
        DailyNoteNotificationSender(account: account, dailyNote: dailyNote)
            .send()
    }

    static func deleteDailyNoteNotification(for account: Account) {
        Task {
            let requests = await center.pendingNotificationRequests()
            center.removePendingNotificationRequests(
                withIdentifiers: requests
                    .map(\.identifier)
                    .filter { id in
                        id.contains(account.uuid.uuidString)
                    }
            )
        }
    }

    static func deleteDailyNoteNotification(for type: DailyNoteNotificationType) {
        Task {
            let requests = await center.pendingNotificationRequests()
            center.removePendingNotificationRequests(
                withIdentifiers: requests
                    .map(\.identifier)
                    .filter { id in
                        id.starts(with: type.rawValue)
                    }
            )
        }
    }
}

// MARK: - DailyNoteNotificationType

enum DailyNoteNotificationType: String {
    case stamina
    case staminaFull
    case expeditionSummary
    case expeditionEach
}

// MARK: - DailyNoteNotificationSender

private struct DailyNoteNotificationSender {
    // MARK: Lifecycle

    init(account: Account, dailyNote: DailyNote) {
        self.account = account
        self.dailyNote = dailyNote
    }

    // MARK: Internal

    var allowStaminaNotification: Bool {
        Defaults[\.allowStaminaNotification]
    }

    var staminaAdditionalNotificationNumbers: [Int] {
        Defaults[\.staminaAdditionalNotificationNumbers]
    }

    var allowExpeditionNotification: Bool {
        Defaults[\.allowExpeditionNotification]
    }

    var expeditionNotificationSetting: DailyNoteNotificationSetting.ExpeditionNotificationSetting {
        Defaults[\.expeditionNotificationSetting]
    }

    func send() {
        guard (account.allowNotification as? Bool) ?? false else { return }
        if allowStaminaNotification {
            scheduleStaminaFullNotification()
            staminaAdditionalNotificationNumbers.forEach { number in
                scheduleStaminaNotification(to: number)
            }
        }
        if allowExpeditionNotification {
            switch expeditionNotificationSetting {
            case .onlySummary:
                scheduleExpeditionSummaryNotification()
            case .forEachExpedition:
                dailyNote.expeditionInformation.expeditions.forEach { expedition in
                    scheduleEachExpeditionNotification(expedition: expedition)
                }
            }
        }
    }

    // MARK: Private

    private let account: Account
    private let dailyNote: DailyNote

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private func scheduleStaminaFullNotification() {
        let information = dailyNote.staminaInformation

        let content = UNMutableNotificationContent()
        content.title = String(
            format: "notification.stamina.title"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.body = String(
            format: "notification.stamina.full.body"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.badge = 1

        guard information.remainingTime > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: information.remainingTime, repeats: false)

        let id = getId(for: .staminaFull)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func scheduleStaminaNotification(to staminaNumber: Int) {
        let information = dailyNote.staminaInformation

        let content = UNMutableNotificationContent()
        content.title = String(
            format: "notification.stamina.title"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.body = String(
            format: "notification.stamina.customize.body"
                .localized(comment: "%@ now have %lld power, will recover at %@. "),
            account.name,
            staminaNumber,
            dateFormatter.string(from: information.fullTime)
        )
        content.badge = 1

        let timeInterval = information.remainingTime - Double(staminaNumber) * StaminaInformation
            .eachStaminaRecoveryTime
        guard timeInterval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let id = getId(for: .stamina, extraId: "\(staminaNumber)")

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func scheduleExpeditionSummaryNotification() {
        let information = dailyNote.expeditionInformation

        let content = UNMutableNotificationContent()
        content.title = String(
            format: "notification.expedition.title"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.body = String(
            format: "notification.expedition.summary.body"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.badge = 1

        guard let timeInterval = information.expeditions.map(\.remainingTime).max(), timeInterval > 0 else {
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let id = getId(for: .expeditionSummary)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func scheduleEachExpeditionNotification(expedition: ExpeditionInformation.Expedition) {
        let content = UNMutableNotificationContent()
        content.title = String(
            format: "notification.expedition.title"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.body = String(
            format: "notification.expedition.each.body"
                .localized(comment: "%@'s assignment 'xxx' is finished"),
            account.name,
            expedition.name
        )

        content.badge = 1

        guard expedition.remainingTime > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: expedition.remainingTime,
            repeats: false
        )

        let id = getId(for: .expeditionEach, extraId: expedition.name)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func getId(for type: DailyNoteNotificationType, extraId: String = "") -> String {
        type.rawValue + account.uuid.uuidString + extraId
    }
}

// MARK: - DailyNoteNotificationSetting

enum DailyNoteNotificationSetting {
    enum ExpeditionNotificationSetting: String, DefaultsSerializable, CustomStringConvertible, CaseIterable {
        case onlySummary
        case forEachExpedition

        // MARK: Internal

        var description: String {
            switch self {
            case .onlySummary:
                return "setting.notification.expedition.method.summary".localized()
            case .forEachExpedition:
                return "setting.notification.expedition.method.each".localized()
            }
        }
    }
}

extension DefaultsKeys {
    var allowStaminaNotification: DefaultsKey<Bool> {
        .init("allowStaminaNotification", defaultValue: true)
    }

    var staminaAdditionalNotificationNumbers: DefaultsKey<[Int]> {
        .init("staminaAdditionalNotificationNumber", defaultValue: [150])
    }

    var expeditionNotificationSetting: DefaultsKey<DailyNoteNotificationSetting.ExpeditionNotificationSetting> {
        .init("expeditionNotificationSetting", defaultValue: .onlySummary)
    }

    var allowExpeditionNotification: DefaultsKey<Bool> {
        .init("allowExpeditionNotification", defaultValue: true)
    }
}
