//
//  WidgetConfigurationIntentExtension.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - RectangularWidgetConfigurationIntent + CanProvideWidgetBackground

// TODO: replace documents folder name

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

extension SquareWidgetConfigurationIntent: RandomBackgroundDrawable {
    func drawRandomBackground() -> WidgetBackground {
        (try? Self.allAvailableBackgrounds().randomElement()) ?? defaultBackground
    }
}

// MARK: - SquareWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension SquareWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}

// MARK: - RectangularWidgetConfigurationIntent + RandomBackgroundDrawable

extension RectangularWidgetConfigurationIntent: RandomBackgroundDrawable {
    func drawRandomBackground() -> WidgetBackground {
        (try? Self.allAvailableBackgrounds().randomElement()) ?? defaultBackground
    }
}

// MARK: - RectangularWidgetConfigurationIntent + DailyNoteWidgetConfigurationErasable

extension RectangularWidgetConfigurationIntent: DailyNoteWidgetConfigurationErasable {}

// MARK: - SquareWidgetConfigurationIntent + HasDefaultBackground

extension SquareWidgetConfigurationIntent: HasDefaultBackground {
    // TODO: replace with other image
    var defaultBackground: WidgetBackground {
        try! Self.allAvailableBackgrounds().first!
    }
}

// MARK: - RectangularWidgetConfigurationIntent + HasDefaultBackground

extension RectangularWidgetConfigurationIntent: HasDefaultBackground {
    // TODO: replace with other image
    var defaultBackground: WidgetBackground {
        try! Self.allAvailableBackgrounds().first!
    }
}
