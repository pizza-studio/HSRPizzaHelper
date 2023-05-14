//
//  WidgetConfigurationIntentExtension.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

// swiftlint:disable line_length

import Foundation

// MARK: - RectangularWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension RectangularWidgetConfigurationIntent: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
    static let backgroundFolderName = AppConfig.rectangularBackgroundImageFolderName
}

// MARK: - GIStyleRectangularWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension GIStyleRectangularWidgetConfigurationIntent: StaticContainingProvideWidgetBackground,
    ContainingWidgetBackground {
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

// MARK: - GIStyleSquareWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension GIStyleSquareWidgetConfigurationIntent: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
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

// MARK: - GIStyleSquareWidgetConfigurationIntent + RandomBackgroundDrawable

extension GIStyleSquareWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - GIStyleSquareWidgetConfigurationIntent + GIStyleWidgetConfigurationErasable

extension GIStyleSquareWidgetConfigurationIntent: GIStyleWidgetConfigurationErasable {}

// MARK: - GIStyleRectangularWidgetConfigurationIntent + RandomBackgroundDrawable

extension GIStyleRectangularWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - GIStyleRectangularWidgetConfigurationIntent + GIStyleWidgetConfigurationErasable

extension GIStyleRectangularWidgetConfigurationIntent: GIStyleWidgetConfigurationErasable {}

// swiftlint:enable line_length
