//
//  DailyNoteWidgetConfiguration.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import Intents

// MARK: - DailyNoteWidgetConfiguration

struct DailyNoteWidgetConfiguration {
    // MARK: Lifecycle

    init(account: IntentAccount?, background: WidgetBackground, backgroundFolderName: String) {
        self.background = background
        if let account = account,
           account.identifier != nil {
            self.account = account
        } else if let account = IntentAccountProvider.getFirstAccount() {
            self.account = account
        } else {
            self.account = nil
        }
        self.backgroundFolderName = backgroundFolderName
    }

    // MARK: Internal

    let background: WidgetBackground

    let account: IntentAccount?

    let backgroundFolderName: String
}

// MARK: CanProvideWidgetBackground

extension DailyNoteWidgetConfiguration: CanProvideWidgetBackground {}

// MARK: - DailyNoteWidgetConfigurationErasable

protocol DailyNoteWidgetConfigurationErasable: HasDefaultBackground, RandomBackgroundDrawable,
    ContainingWidgetBackground {
    var background: [WidgetBackground]? { get }
    var randomBackground: NSNumber? { get }
    var account: IntentAccount? { get }

    var backgroundFolderName: String { get }
}

extension DailyNoteWidgetConfigurationErasable {
    private func getBackground() -> WidgetBackground {
        let background: WidgetBackground
        if randomBackground as? Bool ?? false {
            background = drawRandomBackground()
        } else {
            background = self.background?.randomElement() ?? Self.defaultBackground
        }
        return background
    }

    func eraseToDailyNoteWidgetConfiguration() -> DailyNoteWidgetConfiguration {
        .init(account: account, background: getBackground(), backgroundFolderName: backgroundFolderName)
    }
}
