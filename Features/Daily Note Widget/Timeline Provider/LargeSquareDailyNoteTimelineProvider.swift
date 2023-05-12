//
//  SquareDailyNoteTimelineProvider.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import WidgetKit

// MARK: - LargeSquareDailyNoteTimelineProvider

struct LargeSquareDailyNoteTimelineProvider {}

// MARK: HasDefaultAccount

extension LargeSquareDailyNoteTimelineProvider: HasDefaultAccount {}

// MARK: DailyNoteTimelineProvider

extension LargeSquareDailyNoteTimelineProvider: DailyNoteTimelineProvider {
    typealias Intent = LargeSquareWidgetConfigurationIntent
}
