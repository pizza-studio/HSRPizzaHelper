//
//  GIStyleWidgetConfiguration.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import Intents
import SwiftUI

// MARK: - GIStyleWidgetConfiguration

/// A struct representing the configuration of a daily note background widget.
struct GIStyleWidgetConfiguration {
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
        textColor: Color,
        showAccountName: Bool,
        showExpedition: Bool
    ) {
        self.background = background
        if let account = account?.toAccount() {
            self.account = account
        } else if let account = IntentAccountProvider.getFirstAccount() {
            self.account = account
        } else {
            self.account = nil
        }
        self.backgroundFolderName = backgroundFolderName
        self.textColor = textColor
        self.showAccountName = showAccountName
        self.showExpedition = showExpedition
    }

    // MARK: Internal

    /// An enum representing the position of the stamina bar in the widget.
    enum StaminaPosition {
        case left
        case right
        case center
    }

    /// The `WidgetBackground` to use as the widget background.
    let background: WidgetBackground

    /// The `IntentAccount` to display in the widget.
    let account: Account?

    /// The name of the folder containing the background.
    let backgroundFolderName: String

    /// The color to use for the text in the widget.
    let textColor: Color

    /// A boolean indicating whether to show the name of the account in the widget.
    let showAccountName: Bool

    let showExpedition: Bool
}

// MARK: CanProvideWidgetBackground

extension GIStyleWidgetConfiguration: CanProvideWidgetBackground {}

// MARK: - GIStyleWidgetConfigurationErasable

/// A protocol for erasing to a `DailyNoteBackgroundWidgetConfiguration`. Usually an `Intent`.
protocol GIStyleWidgetConfigurationErasable: HasDefaultBackground, RandomBackgroundDrawable,
    ContainingWidgetBackground {
    /// The widget background.
    var background: [WidgetBackground]? { get }

    /// A boolean indicating whether to use a random background.
    var randomBackground: NSNumber? { get }

    /// The account to display in the widget.
    var account: IntentAccount? { get }

    /// The name of the folder containing the widget background.
    var backgroundFolderName: String { get }

    /// The color to use for the text in the widget.
    var textColor: IntentWidgetTextColor { get }

    /// A boolean indicating whether to show the name of the account in the widget.
    var showAccountName: NSNumber? { get }

    var showExpedition: NSNumber? { get }
}

extension GIStyleWidgetConfigurationErasable {
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
    func eraseToGIStyleWidgetConfiguration() -> GIStyleWidgetConfiguration {
        .init(
            account: account,
            background: getBackground(),
            backgroundFolderName: backgroundFolderName,
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
            showAccountName: showAccountName as? Bool ?? true,
            showExpedition: showExpedition as? Bool ?? true
        )
    }
}
