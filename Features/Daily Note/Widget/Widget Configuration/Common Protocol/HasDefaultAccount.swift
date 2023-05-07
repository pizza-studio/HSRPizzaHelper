//
//  HasDefaultAccount.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import Intents

// MARK: - HasDefaultAccount

protocol HasDefaultAccount {
    var defaultAccount: IntentAccount { get }
}

extension HasDefaultAccount {
    var defaultAccount: IntentAccount {
        let intentAccount = IntentAccount(
            identifier: UUID().uuidString,
            display: "Lava"
        )
        intentAccount.cookie = ""
        intentAccount.server = .china
        intentAccount.uid = "118774161"
        return intentAccount
    }
}