//
//  HSRPizzaHelperWidgetConfigurationIntentHandler.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import Intents

class SquareWidgetConfigurationIntentHandler: INExtension, SquareWidgetConfigurationIntentHandling {
    func provideAccountOptionsCollection(for intent: SquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: SquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        .init(
            items: try SquareWidgetConfigurationIntent.allAvailableBackgrounds()
        )
    }
}
