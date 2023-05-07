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
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: RectangularWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        // TODO: replace documents folder name
        try await WidgetBackgroundOptionsProvider
            .provideBackgroundOptionsCollection(
                bundleFolder: "Rectangular Widget Background",
                documentsFolder: "Rectangular Widget Background"
            )
    }
}
