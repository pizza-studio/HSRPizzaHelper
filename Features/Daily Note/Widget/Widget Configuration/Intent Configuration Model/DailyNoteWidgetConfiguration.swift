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

    init(account: IntentAccount, background: Background) {
        self.background = background
        self.account = account
    }

    // MARK: Internal

    enum Background {
        case useRandomBackground
        case useSpecificBackgrounds([WidgetBackground])
    }

    let background: Background

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

protocol DailyNoteWidgetConfigurationErasable {
    func eraseToDailyNoteWidgetConfiguration() -> DailyNoteWidgetConfiguration
}

// MARK: - SquareWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension SquareWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {
    func eraseToDailyNoteWidgetConfiguration() -> DailyNoteWidgetConfiguration {
        let background: DailyNoteWidgetConfiguration.Background
        // swiftlint:disable:next force_cast
        if randomBackground as! Bool {
            background = .useRandomBackground
        } else {
            background = .useSpecificBackgrounds(self.background!)
        }

        return .init(account: account!, background: background)
    }
}

// MARK: - RectangularWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension RectangularWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {
    func eraseToDailyNoteWidgetConfiguration() -> DailyNoteWidgetConfiguration {
        let background: DailyNoteWidgetConfiguration.Background
        // swiftlint:disable:next force_cast
        if randomBackground as! Bool {
            background = .useRandomBackground
        } else {
            background = .useSpecificBackgrounds(self.background!)
        }

        return .init(account: account!, background: background)
    }
}
