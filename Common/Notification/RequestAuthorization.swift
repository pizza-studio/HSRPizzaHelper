//
//  RequestAuthorization.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import UserNotifications

private var center: UNUserNotificationCenter { HSRNotificationCenter.center }

extension HSRNotificationCenter {
    static func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }
}
