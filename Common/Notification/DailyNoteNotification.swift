//
//  DailyNoteNotification.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import HBMihoyoAPI
import UserNotifications

private var center: UNUserNotificationCenter { HSRNotificationCenter.center }

extension HSRNotificationCenter {
    static func scheduleNotification(for account: Account, dailyNote: DailyNote) {
        DailyNoteNotificationSender(account: account, dailyNote: dailyNote)
            .send()
    }
}

// MARK: - DailyNoteNotificationSender

private struct DailyNoteNotificationSender {
    // MARK: Lifecycle

    init(account: Account, dailyNote: DailyNote) {
        self.account = account
        self.dailyNote = dailyNote
    }

    // MARK: Internal

    func send() {}

    // MARK: Private

    private enum NotificationType: String {
        case stamina
        case staminaFull
        case expeditionSummary
        case expeditionEach
    }

    private let account: Account
    private let dailyNote: DailyNote

    private func scheduleStaminaFullNotification() {
        let information = dailyNote.staminaInformation

        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = ""

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: information.remainingTime, repeats: false)

        let id = getId(for: .staminaFull)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func scheduleStaminaNotification(to staminaNumber: Int) {
        let information = dailyNote.staminaInformation

        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = ""

        let timeInterval = information.remainingTime - Double(staminaNumber) * StaminaInformation.eachStaminaRecoveryTime
        guard timeInterval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let id = getId(for: .stamina)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func scheduleExpeditionSummaryNotification() {
        let information = dailyNote.expeditionInformation

        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = ""

        guard let timeInterval = information.expeditions.map(\.remainingTime).min() else {
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
        content.title = ""
        content.body = ""

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: expedition.remainingTime,
            repeats: false
        )

        let id = getId(for: .expeditionEach, extraId: expedition.name)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func getId(for type: NotificationType, extraId: String = "") -> String {
        account.uuid.uuidString + type.rawValue + extraId
    }
}


