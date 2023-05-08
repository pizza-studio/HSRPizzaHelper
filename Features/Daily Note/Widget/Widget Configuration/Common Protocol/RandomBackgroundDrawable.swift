//
//  RandomBackgroundDrawable.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

// MARK: - RandomBackgroundDrawable

protocol RandomBackgroundDrawable: ContainingWidgetBackground {
    func drawRandomBackground() -> WidgetBackground
}

extension RandomBackgroundDrawable {
    func drawRandomBackground() -> WidgetBackground {
        // swiftlint:disable:next force_try
        try! allAvailableBackgroundsOptions().first!
    }
}
