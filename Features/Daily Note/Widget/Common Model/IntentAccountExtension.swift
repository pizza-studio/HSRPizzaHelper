//
//  IntentAccount.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import HBMihoyoAPI
import Intents

extension IntentAccount {
    /// Convert `Account` to `IntentAccount`
    static func fromAccount(_ account: Account) -> IntentAccount {
        let intentAccount = IntentAccount(
            identifier: account.uuid.uuidString,
            display: account.name
        )
        intentAccount.cookie = account.cookie
        intentAccount.serverRawValue = account.server.rawValue
        intentAccount.uid = account.uid
        return intentAccount
    }

    var name: String {
        displayString
    }

    var server: Server {
        .init(rawValue: serverRawValue!)!
    }
}
