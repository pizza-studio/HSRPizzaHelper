//
//  AccountIntentHandler.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import Intents

enum IntentAccountProvider {
    static func provideAccountOptionsCollection() async throws
        -> INObjectCollection<IntentAccount> {
        let accountPersistenceController = AccountPersistenceController.shared
        let viewContext = accountPersistenceController.container.viewContext
        let request = Account.fetchRequest()
        let accounts = try viewContext.fetch(request)
        return .init(
            items: accounts.map { .fromAccount($0) }
        )
    }

    static func getFirstAccount() -> IntentAccount? {
        let accountPersistenceController = AccountPersistenceController.shared
        let viewContext = accountPersistenceController.container.viewContext
        let request = Account.fetchRequest()
        let accounts = try? viewContext.fetch(request)
        if let account = accounts?.first {
            return .fromAccount(account)
        } else {
            return nil
        }
    }
}
