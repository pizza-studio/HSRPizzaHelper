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
        .init(items: [
            .init(identifier: "1", display: "!"),
        ])
    }
}
