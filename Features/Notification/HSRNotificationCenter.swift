//
//  HSRNotificationCenter.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/12.
//

import Foundation
import HBMihoyoAPI
import UserNotifications

// MARK: - HSRNotificationCenter

enum HSRNotificationCenter {
    static let center = UNUserNotificationCenter.current()

    static func printAllNotifications() async {
        await center.pendingNotificationRequests().forEach { request in
            print(request.content.title)
            print(request.content.body)
            print(request.identifier)
            print(request.trigger ?? "")
        }
    }

    static func getAllNotificationsDescriptions() async -> [String] {
        var strings = [String]()
        await center.pendingNotificationRequests().forEach { request in
            let description = """
            [\(request.identifier)\n\(request.content.title)]\n\(
                request.content
                    .body
            )\n(\(String(describing: request.trigger?.description)))\n
            """
            strings.append(description)
        }
        return strings
    }
}
