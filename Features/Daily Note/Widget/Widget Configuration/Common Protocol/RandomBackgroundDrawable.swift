//
//  RandomBackgroundDrawable.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

protocol RandomBackgroundDrawable: HasDefaultBackground {
    func drawRandomBackground() -> WidgetBackground
}
