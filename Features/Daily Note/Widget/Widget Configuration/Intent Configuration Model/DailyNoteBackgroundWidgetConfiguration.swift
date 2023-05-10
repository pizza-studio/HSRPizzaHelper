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

/// A struct representing the configuration of a daily note background widget.
struct DailyNoteBackgroundWidgetConfiguration {
    // MARK: Lifecycle

    /// Initializes a new instance of `DailyNoteBackgroundWidgetConfiguration`.
    /// - Parameters:
    ///   - account: The `IntentAccount` to display in the widget.
    ///   - background: The `WidgetBackground` to use as the widget background.
    ///   - backgroundFolderName: The name of the folder containing the background.
    ///   - useAccessibilityBackground: A boolean indicating whether to use the accessibility version of the background.
    ///   - textColor: The color to use for the text in the widget.
    ///   - expeditionDisplayMode: The mode for displaying expeditions in the widget.
    ///   - showAccountName: A boolean indicating whether to show the name of the account in the widget.
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

    /// An enum representing the mode for displaying expeditions in the widget.
    enum ExpeditionDisplayMode {
        case display
        case hide(staminaPosition: StaminaPosition)
    }

    /// An enum representing the position of the stamina bar in the widget.
    enum StaminaPosition {
        case left
        case right
        case center
    }

    /// The `WidgetBackground` to use as the widget background.
    let background: WidgetBackground

    /// The `IntentAccount` to display in the widget.
    let account: IntentAccount?

    /// The name of the folder containing the background.
    let backgroundFolderName: String

    /// A boolean indicating whether to use the accessibility version of the background.
    let useAccessibilityBackground: Bool

    /// The color to use for the text in the widget.
    let textColor: Color

    /// The mode for displaying expeditions in the widget.
    let expeditionDisplayMode: ExpeditionDisplayMode

    /// A boolean indicating whether to show the name of the account in the widget.
    let showAccountName: Bool
}

// MARK: CanProvideWidgetBackground

extension DailyNoteBackgroundWidgetConfiguration: CanProvideWidgetBackground {}

// MARK: - DailyNoteWidgetConfigurationErasable

/// A protocol for erasing to a `DailyNoteBackgroundWidgetConfiguration`. Usually an `Intent`.
protocol DailyNoteWidgetConfigurationErasable: HasDefaultBackground, RandomBackgroundDrawable,
    ContainingWidgetBackground {
    /// The widget background.
    var background: [WidgetBackground]? { get }

    /// A boolean indicating whether to use a random background.
    var randomBackground: NSNumber? { get }

    /// The account to display in the widget.
    var account: IntentAccount? { get }

    /// The name of the folder containing the widget background.
    var backgroundFolderName: String { get }

    /// A boolean indicating whether to use the accessibility version of the widget background.
    var useAccessibilityBackground: NSNumber? { get }

    /// The color to use for the text in the widget.
    var textColor: IntentWidgetTextColor { get }

    /// A boolean indicating whether to show the expedition in the widget.
    var showExpedition: NSNumber? { get }

    /// The position of the stamina bar in the widget.
    var staminaPosition: IntentStaminaPosition { get }

    /// A boolean indicating whether to show the name of the account in the widget.
    var showAccountName: NSNumber? { get }
}

extension DailyNoteWidgetConfigurationErasable {
    /// Returns the widget background.
    private func getBackground() -> WidgetBackground {
        let background: WidgetBackground
        if randomBackground as? Bool ?? false {
            background = drawRandomBackground()
        } else {
            background = self.background?.randomElement() ?? Self.defaultBackground
        }
        return background
    }

    /// Erases to a `DailyNoteBackgroundWidgetConfiguration`.
    /// - Returns: A `DailyNoteBackgroundWidgetConfiguration`.
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
                        case .center:
                            return .center
                        }
                    }())
                }
            }(),
            showAccountName: showAccountName as? Bool ?? true
        )
    }
}
