//
//  GIStyleRectangularTimelineProvider.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import WidgetKit

// MARK: - GIStyleRectangularTimelineProvider

struct GIStyleRectangularTimelineProvider {}

// MARK: HasDefaultAccount

extension GIStyleRectangularTimelineProvider: HasDefaultAccount {}

// MARK: GIStyleTimelineProvider

extension GIStyleRectangularTimelineProvider: GIStyleTimelineProvider {
    typealias Intent = GIStyleRectangularWidgetConfigurationIntent
}
