//
//  RectangularDailyNoteTimelineProvider.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import WidgetKit

// MARK: - RectangularDailyNoteTimelineProvider

struct RectangularDailyNoteTimelineProvider {}

// MARK: HasDefaultBackground

extension RectangularDailyNoteTimelineProvider: HasDefaultBackground {
    // TODO: replace with other image
    var defaultBackground: WidgetBackground {
        .init(identifier: "Character_March_7th_Splash_Art", display: "Character_March_7th_Splash_Art")
    }
}

// MARK: HasDefaultAccount

extension RectangularDailyNoteTimelineProvider: HasDefaultAccount {}

// MARK: DailyNoteTimelineProvider

extension RectangularDailyNoteTimelineProvider: DailyNoteTimelineProvider {
    typealias Intent = RectangularWidgetConfigurationIntent
}
