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

// MARK: HasDefaultAccount

extension RectangularDailyNoteTimelineProvider: HasDefaultAccount {}

// MARK: DailyNoteTimelineProvider

extension RectangularDailyNoteTimelineProvider: DailyNoteTimelineProvider {
    typealias Intent = RectangularWidgetConfigurationIntent
}
