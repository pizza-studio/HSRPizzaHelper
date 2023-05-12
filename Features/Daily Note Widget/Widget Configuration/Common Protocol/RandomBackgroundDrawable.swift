//
//  RandomBackgroundDrawable.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - RandomBackgroundDrawable

/// A protocol for objects that can draw a random background.
protocol RandomBackgroundDrawable: ContainingWidgetBackground {
    /// Draws a random background.
    /// - Returns: A `WidgetBackground` object representing the drawn background.
    func drawRandomBackground() -> WidgetBackground
}

extension RandomBackgroundDrawable {
    func drawRandomBackground() -> WidgetBackground {
        // swiftlint:disable:next force_try
        try! allAvailableBackgroundsOptions().first!
    }
}
