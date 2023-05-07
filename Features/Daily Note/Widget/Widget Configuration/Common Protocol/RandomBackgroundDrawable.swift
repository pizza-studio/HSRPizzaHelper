//
//  RandomBackgroundDrawable.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - RandomBackgroundDrawable

protocol RandomBackgroundDrawable: HasDefaultBackground, CanProvideWidgetBackground {
    func drawRandomBackground() -> WidgetBackground
}

extension RandomBackgroundDrawable {
    func drawRandomBackground() -> WidgetBackground {
        (try? Self.allAvailableBackgrounds().randomElement()) ?? Self.defaultBackground
    }
}
