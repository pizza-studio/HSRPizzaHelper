//
//  Account+Server.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI

extension Account {
    /// Get the account's current server
    var server: Server {
        get {
            .init(rawValue: serverRawValue ?? "") ?? .china
        } set {
            serverRawValue = newValue.rawValue
        }
    }
}
