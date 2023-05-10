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

    /// Convert a `Account` instance to an `IntentAccount` instance.
    /// - Parameter account: The `Account` instance to be converted.
    /// - Returns: The `IntentAccount` instance converted from `account`.
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

    /// The name of the account.
    var name: String {
        displayString
    }

    /// The server of the account.
    var server: Server {
        get {
            .init(rawValue: serverRawValue!)!
        } set {
            serverRawValue = newValue.rawValue
        }
    }
}
