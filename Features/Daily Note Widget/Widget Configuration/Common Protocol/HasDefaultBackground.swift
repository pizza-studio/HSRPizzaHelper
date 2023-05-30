//
//  HasDefaultBackground.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import Intents

// MARK: - HasDefaultBackground

/// A protocol for objects that have a default background.
protocol HasDefaultBackground: StaticContainingProvideWidgetBackground, ContainingWidgetBackground {
    /// The default background.
    static var defaultBackground: WidgetBackground { get }
}

extension HasDefaultBackground {
    static var defaultBackground: WidgetBackground {
        // swiftlint:disable:next force_try
        try! Self.allAvailableBackgrounds().first(where: { background in
            background.identifier == "Widget_Background_Marth7th.heic"
        })!
    }
}
