//
//  HSRPizzaHelperWidgetConfigurationIntentHandler.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Foundation
import Intents

class SquareWidgetConfigurationIntentHandler: INExtension, LargeSquareWidgetConfigurationIntentHandling,
    SmallSquareWidgetConfigurationIntentHandling,
    GIStyleSquareWidgetConfigurationIntentHandling {
    // MARK: Internal

    func provideAccountOptionsCollection(for intent: SmallSquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await provideAccountOptionsCollection()
    }

    func provideAccountOptionsCollection(for intent: LargeSquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }

    func provideAccountOptionsCollection(for intent: GIStyleSquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: SmallSquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        try await provideBackgroundOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: LargeSquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        try await provideBackgroundOptionsCollection()
    }

    func provideBackgroundOptionsCollection(for intent: GIStyleSquareWidgetConfigurationIntent) async throws
        -> INObjectCollection<WidgetBackground> {
        try await provideBackgroundOptionsCollection()
    }

    // MARK: Private

    // MARK: Account

    private func provideAccountOptionsCollection() async throws
        -> INObjectCollection<IntentAccount> {
        try await IntentAccountProvider.provideAccountOptionsCollection()
    }

    private func provideBackgroundOptionsCollection() async throws
        -> INObjectCollection<WidgetBackground> {
        .init(
            items: try LargeSquareWidgetConfigurationIntent.allAvailableBackgrounds()
        )
    }
}
