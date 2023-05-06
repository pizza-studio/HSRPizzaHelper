//
//  RectangularWidgetConfigurationIntentHandler.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import Intents

class RectangularWidgetConfigurationIntentHandler: INExtension, RectangularWidgetConfigurationIntentHandling {
    func provideAccountOptionsCollection(for intent: RectangularWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountCollectionProvider.provideAccountOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: RectangularWidgetConfigurationIntent) async throws
        -> INObjectCollection<RectangularWidgetBackground> {
        .init(items: [
            .init(identifier: "1", display: "1"),
        ])
    }
}
