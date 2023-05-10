//
//  DailyNoteWidgetConfiguration.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import Intents
import SwiftUI

// MARK: - DailyNoteBackgroundWidgetConfiguration

struct DailyNoteBackgroundWidgetConfiguration {
    // MARK: Lifecycle

    init(
        account: IntentAccount?,
        background: WidgetBackground,
        backgroundFolderName: String,
        useAccessibilityBackground: Bool,
        textColor: Color,
        expeditionDisplayMode: ExpeditionDisplayMode,
        showAccountName: Bool
    ) {
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
        self.useAccessibilityBackground = useAccessibilityBackground
        self.textColor = textColor
        self.expeditionDisplayMode = expeditionDisplayMode
        self.showAccountName = showAccountName
    }

    // MARK: Internal

    enum ExpeditionDisplayMode {
        case display
        case hide(staminaPosition: StaminaPosition)
    }

    enum StaminaPosition {
        case left
        case right
    }

    let background: WidgetBackground

    let account: IntentAccount?

    let backgroundFolderName: String

    let useAccessibilityBackground: Bool

    let textColor: Color

    let expeditionDisplayMode: ExpeditionDisplayMode

    let showAccountName: Bool
}

// MARK: CanProvideWidgetBackground

extension DailyNoteBackgroundWidgetConfiguration: CanProvideWidgetBackground {}

// MARK: - DailyNoteWidgetConfigurationErasable

protocol DailyNoteWidgetConfigurationErasable: HasDefaultBackground, RandomBackgroundDrawable,
    ContainingWidgetBackground {
    var background: [WidgetBackground]? { get }
    var randomBackground: NSNumber? { get }
    var account: IntentAccount? { get }

    var backgroundFolderName: String { get }

    var useAccessibilityBackground: NSNumber? { get }
    var textColor: IntentWidgetTextColor { get }

    var showExpedition: NSNumber? { get }
    var staminaPosition: IntentStaminaPosition { get }

    var showAccountName: NSNumber? { get }
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

    func eraseToDailyNoteWidgetConfiguration() -> DailyNoteBackgroundWidgetConfiguration {
        .init(
            account: account,
            background: getBackground(),
            backgroundFolderName: backgroundFolderName,
            useAccessibilityBackground: useAccessibilityBackground as? Bool ?? true,
            textColor: { () -> Color in
                switch textColor {
                case .followSystem, .unknown:
                    return .primary
                case .black:
                    return .black
                case .white:
                    return .white
                }
            }(),
            expeditionDisplayMode: {
                if showExpedition as? Bool ?? true {
                    return .display
                } else {
                    return .hide(staminaPosition: {
                        switch staminaPosition {
                        case .left, .unknown:
                            return .left
                        case .right:
                            return .right
                        }
                    }())
                }
            }(),
            showAccountName: showAccountName as? Bool ?? true
        )
//        .init(
//            account: account,
//            background: getBackground(),
//            backgroundFolderName: backgroundFolderName)
    }
}
