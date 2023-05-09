//
//  WidgetTimelineReloader.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/9.
//

import Foundation
import SwiftUI
import WidgetKit

extension View {
    func checkAndReloadWidgetTimeline() -> some View {
        modifier(WidgetTimelineReloader())
    }
}

// MARK: - WidgetTimelineReloader

private struct WidgetTimelineReloader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                guard let latestRefreshTime = Defaults[\.widgetTimelineLatestStartAppRefreshTime] else {
                    reloadAllTimelines()
                    return
                }
                let hoursSinceLatestRefresh = Date()
                    .hoursSince(
                        latestRefreshTime
                    )
                let shouldRefreshAfterHour = Defaults[\.widgetRefreshFrequencyInHour]
                if hoursSinceLatestRefresh > shouldRefreshAfterHour {
                    reloadAllTimelines()
                }
            }
    }

    func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
        Defaults[\.widgetTimelineLatestStartAppRefreshTime] = Date()
    }
}
