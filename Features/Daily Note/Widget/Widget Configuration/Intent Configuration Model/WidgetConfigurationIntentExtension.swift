//
//  WidgetConfigurationIntentExtension.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - RectangularWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension RectangularWidgetConfigurationIntent: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
    static let backgroundFolderName = AppConfig.rectangularBackgroundImageFolderName
}

// MARK: - LargeSquareWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension LargeSquareWidgetConfigurationIntent: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
    static let backgroundFolderName = AppConfig.squareBackgroundImageFolderName
}

// MARK: - SmallSquareWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension SmallSquareWidgetConfigurationIntent: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
    static let backgroundFolderName = AppConfig.squareBackgroundImageFolderName
}

// MARK: - LargeSquareWidgetConfigurationIntent + RandomBackgroundDrawable

extension LargeSquareWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - LargeSquareWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension LargeSquareWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}

// MARK: - SmallSquareWidgetConfigurationIntent + RandomBackgroundDrawable

extension SmallSquareWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - SmallSquareWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension SmallSquareWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {
    var showExpedition: NSNumber? {
        false
    }

    var staminaPosition: IntentStaminaPosition {
        .left
    }
}

// MARK: - RectangularWidgetConfigurationIntent + RandomBackgroundDrawable

extension RectangularWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - RectangularWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension RectangularWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}
