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
                reloadAllTimelines()
//                guard let latestRefreshTime = Defaults[\.widgetTimelineLatestStartAppRefreshTime] else {
//                    reloadAllTimelines()
//                    return
//                }
//                let hoursSinceLatestRefresh = Date()
//                    .minutesSince(
//                        latestRefreshTime
//                    )
//                let shouldRefreshAfterMinute = AppConfig.enterAppShouldRefreshWidgetAfterMinute
//                if hoursSinceLatestRefresh > shouldRefreshAfterMinute {
//                    reloadAllTimelines()
//                }
            }
    }

    func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
        Defaults[\.widgetTimelineLatestStartAppRefreshTime] = Date()
    }
}
