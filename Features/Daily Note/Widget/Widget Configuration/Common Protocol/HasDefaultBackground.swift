//
//  HasDefaultBackground.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import Intents

// MARK: - HasDefaultBackground

protocol HasDefaultBackground: CanProvideWidgetBackground {
    static var defaultBackground: WidgetBackground { get }
}

extension HasDefaultBackground {
    static var defaultBackground: WidgetBackground {
        // swiftlint:disable:next force_try
        try! Self.allAvailableBackgrounds().first(where: { background in
            background.identifier == "Character_March_7th_Splash_Art"
        })!
    }
}
