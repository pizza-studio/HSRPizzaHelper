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
        textColor: Color
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
    }

    // MARK: Internal

    let background: WidgetBackground

    let account: IntentAccount?

    let backgroundFolderName: String

    let useAccessibilityBackground: Bool

    let textColor: Color
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
            }()
        )
//        .init(
//            account: account,
//            background: getBackground(),
//            backgroundFolderName: backgroundFolderName)
    }
}
