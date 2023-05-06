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
        try await IntentAccountCollectionProvider.provideAccountOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: SquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        // TODO: replace documents folder name
        try await WidgetBackgroundOptionsProvider
            .provideBackgroundOptionsCollection(
                bundleFolder: "Square Widget Background",
                documentsFolder: "Square Widget Background"
            )
    }
}
