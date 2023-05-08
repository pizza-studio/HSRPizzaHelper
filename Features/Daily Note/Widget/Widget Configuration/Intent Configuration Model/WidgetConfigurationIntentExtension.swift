//
//  WidgetConfigurationIntentExtension.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - RectangularWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension RectangularWidgetConfigurationIntent: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
    static let backgroundFolderName = "rectangular_widget_background"
}

// MARK: - SquareWidgetConfigurationIntent + StaticContainingProvideWidgetBackground, ContainingWidgetBackground

extension SquareWidgetConfigurationIntent: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
    static let backgroundFolderName = "square_widget_background"
}

// MARK: - SquareWidgetConfigurationIntent + RandomBackgroundDrawable

extension SquareWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - SquareWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension SquareWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}

// MARK: - RectangularWidgetConfigurationIntent + RandomBackgroundDrawable

extension RectangularWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - RectangularWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension RectangularWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}
