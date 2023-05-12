//
//  SmallSquareDailyNoteTimelineProvider.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation
import WidgetKit

// MARK: - SmallSquareDailyNoteTimelineProvider

struct SmallSquareDailyNoteTimelineProvider {}

// MARK: HasDefaultAccount

extension SmallSquareDailyNoteTimelineProvider: HasDefaultAccount {}

// MARK: DailyNoteTimelineProvider

extension SmallSquareDailyNoteTimelineProvider: DailyNoteTimelineProvider {
    typealias Intent = SmallSquareWidgetConfigurationIntent
}
