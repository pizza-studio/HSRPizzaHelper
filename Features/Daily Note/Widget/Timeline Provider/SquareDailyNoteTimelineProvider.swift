//
//  SquareDailyNoteTimelineProvider.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import WidgetKit

// MARK: - SquareDailyNoteTimelineProvider

struct SquareDailyNoteTimelineProvider {}

// MARK: HasDefaultBackground

extension SquareDailyNoteTimelineProvider: HasDefaultBackground {
    // TODO: replace with other image
    var defaultBackground: WidgetBackground {
        .init(identifier: "Character_March_7th_Splash_Art", display: "Character_March_7th_Splash_Art")
    }
}

// MARK: HasDefaultAccount

extension SquareDailyNoteTimelineProvider: HasDefaultAccount {}

// MARK: DailyNoteTimelineProvider

extension SquareDailyNoteTimelineProvider: DailyNoteTimelineProvider {
    typealias Intent = SquareWidgetConfigurationIntent
}
