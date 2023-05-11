//
//  IntentAccount.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import HBMihoyoAPI
import Intents
import SwifterSwift

extension IntentAccount {
    /// Convert a `Account` instance to an `IntentAccount` instance.
    /// - Parameter account: The `Account` instance to be converted.
    /// - Returns: The `IntentAccount` instance converted from `account`.
    static func fromAccount(_ account: Account) -> IntentAccount {
        let intentAccount = IntentAccount(
            identifier: account.uuid.uuidString,
            display: account.name
        )
        return intentAccount
    }

    func toAccount() -> Account? {
        let viewContext = AccountPersistenceController.shared.container.viewContext
        let request = Account.fetchRequest()
        guard let uuid = identifier else { return nil }
        request.predicate = NSPredicate(
            format: "%K == %@", #keyPath(Account.uuid), uuid
        )
        return try? viewContext.fetch(request).first
    }
}
