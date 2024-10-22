//
//  PZProfileSendable.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2024/10/22.
//

import CoreData
import HBMihoyoAPI
import UIKit

// MARK: - PZProfileSendable

public struct PZProfileSendable: Sendable, Codable {
    public var game = "HSR"
    public let server: Server
    public let uid: String
    public let uuid: UUID
    public let allowNotification: Bool
    public let cookie: String
    public let deviceFingerPrint: String
    public let name: String
    public let priority: Int
    public let serverRawValue: String
    public let sTokenV2: String?
    public let deviceID: String
}

extension Account {
    public var asPZProfile: PZProfileSendable {
        .init(
            server: server,
            uid: uid,
            uuid: uuid,
            allowNotification: allowNotification.boolValue,
            cookie: cookie,
            deviceFingerPrint: deviceFingerPrint,
            name: name,
            priority: priority?.intValue ?? 0,
            serverRawValue: serverRawValue ?? server.rawValue,
            sTokenV2: nil,
            deviceID: (UIDevice.current.identifierForVendor ?? UUID()).uuidString
        )
    }
}
