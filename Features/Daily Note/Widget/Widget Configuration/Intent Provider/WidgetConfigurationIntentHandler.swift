//
//  AccountIntentHandler.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import Intents

enum IntentAccountCollectionProvider {
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
}
