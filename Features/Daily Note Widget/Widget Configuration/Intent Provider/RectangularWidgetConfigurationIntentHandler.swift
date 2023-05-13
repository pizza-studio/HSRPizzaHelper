//
//  RectangularWidgetConfigurationIntentHandler.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import Intents

class RectangularWidgetConfigurationIntentHandler: INExtension, RectangularWidgetConfigurationIntentHandling,
    GIStyleRectangularWidgetConfigurationIntentHandling {
    func provideAccountOptionsCollection(for intent: RectangularWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: RectangularWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        .init(
            items: try RectangularWidgetConfigurationIntent.allAvailableBackgrounds()
        )
    }

    func provideAccountOptionsCollection(for intent: GIStyleRectangularWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: GIStyleRectangularWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        .init(
            items: try RectangularWidgetConfigurationIntent.allAvailableBackgrounds()
        )
    }
}
