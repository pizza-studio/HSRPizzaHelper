//
//  CanProvideWidgetBackground.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - CanProvideWidgetBackground

protocol CanProvideWidgetBackground {
    static var bundleBackgroundFolder: String { get }
    static var documentsBackgroundFolder: String { get }
}

extension CanProvideWidgetBackground {
    static func allAvailableBackgrounds() throws -> [WidgetBackground] {
        try WidgetBackgroundOptionsProvider.provideBackgroundOptionsCollection(
            bundleFolder: SquareWidgetConfigurationIntent.bundleBackgroundFolder,
            documentsFolder: SquareWidgetConfigurationIntent.documentsBackgroundFolder
        )
    }
}
