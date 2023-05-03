//
//  Account+Server.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI

extension Account {
    var server: Server {
        get {
            .init(rawValue: serverRawValue ?? "") ?? .china
        } set {
            self.serverRawValue = newValue.rawValue
        }
    }
}
