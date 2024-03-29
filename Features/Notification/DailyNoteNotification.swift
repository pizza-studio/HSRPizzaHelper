//
//  DailyNoteNotification.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Defaults
import DefaultsKeys
import Foundation
import HBMihoyoAPI
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
                        id.contains(account.uuid?.uuidString ?? "")
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

    static func deleteDailyNoteNotification(account: Account, type: DailyNoteNotificationType) {
        Task {
            let requests = await center.pendingNotificationRequests()
            center.removePendingNotificationRequests(
                withIdentifiers: requests
                    .map(\.identifier)
                    .filter { id in
                        id.starts(with: type.rawValue) && id.contains(account.uuid?.uuidString ?? "")
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
    case dailyTraining
    case simulatedUniverse
}

// MARK: - DailyNoteNotificationSender

private struct DailyNoteNotificationSender {
    // MARK: Lifecycle

    init(account: Account, dailyNote: DailyNote) {
        self.account = account
        self.dailyNote = dailyNote
    }

    // MARK: Internal

    @Default(.allowStaminaNotification) var allowStaminaNotification: Bool

    @Default(.staminaAdditionalNotificationNumbers) var staminaAdditionalNotificationNumbers: [Int]

    @Default(.allowExpeditionNotification) var allowExpeditionNotification: Bool

    @Default(.expeditionNotificationSetting) var expeditionNotificationSetting: DailyNoteNotificationSetting
        .ExpeditionNotificationSetting

    @Default(.dailyTrainingNotificationSetting) var dailyTrainingNotificationSetting: DailyNoteNotificationSetting
        .DailyTrainingNotificationSetting

    @Default(
        .simulatedUniverseNotificationSetting
    ) var simulatedUniverseNotificationSetting: DailyNoteNotificationSetting
        .SimulatedUniverseNotificationSetting

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
        if let dailyNote = dailyNote as? WidgetDailyNote {
            if case let .notifyAt(hour, minute) = dailyTrainingNotificationSetting {
                scheduleDailyTrainingNotification(hour: hour, minute: minute, dailyNote: dailyNote)
            }
            if case let .notifyAt(weekday, hour, minute) = simulatedUniverseNotificationSetting {
                scheduleSimulatedUniverseNotification(
                    weekday: weekday,
                    hour: hour,
                    minute: minute,
                    dailyNote: dailyNote
                )
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

        let timeInterval = information
            .remainingTime - Double(information.maxStamina - staminaNumber) * StaminaInformation
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

    private func scheduleDailyTrainingNotification(hour: Int, minute: Int, dailyNote: WidgetDailyNote) {
        let dailyTraining = dailyNote.dailyTrainingInformation
        guard dailyTraining.currentScore < dailyTraining.maxScore else {
            HSRNotificationCenter.deleteDailyNoteNotification(account: account, type: .dailyTraining)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(
            format: "notification.daily_training.title"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.body = String(
            format: "notification.daily_training.body"
                .localized(comment: "%@'s score... / current progress is %lld/%lld"),
            account.name,
            dailyTraining.currentScore,
            dailyTraining.maxScore
        )

        content.badge = 1

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(calendar: .current, hour: hour, minute: minute),
            repeats: false
        )

        let id = getId(for: .dailyTraining)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func scheduleSimulatedUniverseNotification(
        weekday: Int,
        hour: Int,
        minute: Int,
        dailyNote: WidgetDailyNote
    ) {
        let simulatedUniverse = dailyNote.simulatedUniverseInformation
        guard simulatedUniverse.currentScore < simulatedUniverse.maxScore else {
            HSRNotificationCenter.deleteDailyNoteNotification(account: account, type: .simulatedUniverse)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(
            format: "notification.simulated_universe.title"
                .localized(comment: "%@'s ..."),
            account.name
        )
        content.body = String(
            format: "notification.simulated_universe.body"
                .localized(comment: "%@'s score... / current is %lld/%lld"),
            account.name,
            simulatedUniverse.currentScore,
            simulatedUniverse.maxScore
        )

        content.badge = 1

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute, weekday: weekday),
            repeats: false
        )

        let id = getId(for: .simulatedUniverse)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func getId(for type: DailyNoteNotificationType, extraId: String = "") -> String {
        type.rawValue + account.uuid.uuidString + extraId
    }
}

// MARK: - DailyNoteNotificationSetting

enum DailyNoteNotificationSetting {
    enum ExpeditionNotificationSetting: String, _DefaultsSerializable, CustomStringConvertible, CaseIterable {
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

    enum DailyTrainingNotificationSetting: Codable, _DefaultsSerializable {
        case disallowed
        case notifyAt(hour: Int, minute: Int)
    }

    enum SimulatedUniverseNotificationSetting: Codable, _DefaultsSerializable {
        case disallowed
        case notifyAt(weekday: Int, hour: Int, minute: Int)
    }
}

extension Defaults.Keys {
    static let allowStaminaNotification = Key<Bool>("allowStaminaNotification", default: true, suite: .hsrSuite)

    static let staminaAdditionalNotificationNumbers = Key<[Int]>(
        "staminaAdditionalNotificationNumber",
        default: [150],
        suite: .hsrSuite
    )

    static let expeditionNotificationSetting = Key<DailyNoteNotificationSetting.ExpeditionNotificationSetting>(
        "expeditionNotificationSetting",
        default: .onlySummary,
        suite: .hsrSuite
    )

    static let allowExpeditionNotification = Key<Bool>("allowExpeditionNotification", default: true, suite: .hsrSuite)

    static let dailyTrainingNotificationSetting = Key<DailyNoteNotificationSetting.DailyTrainingNotificationSetting>(
        "dailyTrainingNotificationSetting",
        default: .notifyAt(hour: 19, minute: 0),
        suite: .hsrSuite
    )

    static let simulatedUniverseNotificationSetting =
        Key<DailyNoteNotificationSetting.SimulatedUniverseNotificationSetting>(
            "simulatedUniverseNotificationSetting",
            default: .notifyAt(weekday: 7, hour: 19, minute: 0),
            suite: .hsrSuite
        )
}
