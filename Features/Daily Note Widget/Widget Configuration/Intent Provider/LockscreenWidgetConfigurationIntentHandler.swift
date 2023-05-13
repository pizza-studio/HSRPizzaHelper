//
//  LockscreenWidgetConfigurationIntentHandler.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/14.
//

import Foundation
import Intents

class LockscreenWidgetConfigurationIntentHandler: INExtension, LockscreenWidgetConfigurationIntentHandling {
    func provideAccountOptionsCollection(for intent: LockscreenWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }
}
