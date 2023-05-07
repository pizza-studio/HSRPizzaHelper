//
//  WidgetConfigurationIntentExtension.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - RectangularWidgetConfigurationIntent + CanProvideWidgetBackground

extension RectangularWidgetConfigurationIntent: CanProvideWidgetBackground {
    static let bundleBackgroundFolder = "Rectangular Widget Background"
    static let documentsBackgroundFolder = "Rectangular Widget Background"
}

// MARK: - SquareWidgetConfigurationIntent + CanProvideWidgetBackground

extension SquareWidgetConfigurationIntent: CanProvideWidgetBackground {
    static let bundleBackgroundFolder = "Square Widget Background"
    static let documentsBackgroundFolder = "Square Widget Background"
}

// MARK: - SquareWidgetConfigurationIntent + RandomBackgroundDrawable

extension SquareWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - SquareWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension SquareWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}

// MARK: - RectangularWidgetConfigurationIntent + RandomBackgroundDrawable

extension RectangularWidgetConfigurationIntent: RandomBackgroundDrawable {}

// MARK: - RectangularWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension RectangularWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}

// MARK: - SquareWidgetConfigurationIntent + HasDefaultBackground

extension SquareWidgetConfigurationIntent: HasDefaultBackground {
    static var defaultBackground: WidgetBackground {
        // swiftlint:disable:next force_try
        try! Self.allAvailableBackgrounds().first!
    }
}

// MARK: - RectangularWidgetConfigurationIntent + HasDefaultBackground

extension RectangularWidgetConfigurationIntent: HasDefaultBackground {
    static var defaultBackground: WidgetBackground {
        // swiftlint:disable:next force_try
        try! Self.allAvailableBackgrounds().first!
    }
}
