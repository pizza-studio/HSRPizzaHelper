//
//  GIStyleSquareTimelineProvider.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import WidgetKit

// MARK: - GIStyleSquareTimelineProvider

struct GIStyleSquareTimelineProvider {}

// MARK: HasDefaultAccount

extension GIStyleSquareTimelineProvider: HasDefaultAccount {}

// MARK: GIStyleTimelineProvider

extension GIStyleSquareTimelineProvider: GIStyleTimelineProvider {
    typealias Intent = GIStyleSquareWidgetConfigurationIntent
}
