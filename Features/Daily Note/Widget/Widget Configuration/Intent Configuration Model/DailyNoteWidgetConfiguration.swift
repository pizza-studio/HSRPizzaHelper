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

    init(account: IntentAccount?, background: WidgetBackground) {
        self.background = background
        self.account = account
    }

    // MARK: Internal

    let background: WidgetBackground

    var account: IntentAccount? {
        get {
            _account
        } set {
            if let newAccount = newValue,
               newAccount.identifier != nil {
                _account = newValue
            } else if let account = IntentAccountProvider.getFirstAccount() {
                _account = account
            } else {
                _account = nil
            }
        }
    }

    // MARK: Private

    private var _account: IntentAccount?
}

// MARK: - DailyNoteWidgetConfigurationErasable

protocol DailyNoteWidgetConfigurationErasable: HasDefaultBackground, RandomBackgroundDrawable {
    var background: [WidgetBackground]? { get }
    var randomBackground: NSNumber? { get }
    var account: IntentAccount? { get }
}

extension DailyNoteWidgetConfigurationErasable {
    func getBackground() -> WidgetBackground {
        let background: WidgetBackground
        if randomBackground as? Bool ?? false {
            background = drawRandomBackground()
        } else {
            background = self.background?.randomElement() ?? defaultBackground
        }
        return background
    }

    func eraseToDailyNoteWidgetConfiguration() -> DailyNoteWidgetConfiguration {
        .init(account: account, background: getBackground())
    }
}
