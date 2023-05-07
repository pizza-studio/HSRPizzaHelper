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

// MARK: HasDefaultAccount

extension SquareDailyNoteTimelineProvider: HasDefaultAccount {}

// MARK: DailyNoteTimelineProvider

extension SquareDailyNoteTimelineProvider: DailyNoteTimelineProvider {
    typealias Intent = SquareWidgetConfigurationIntent
}
