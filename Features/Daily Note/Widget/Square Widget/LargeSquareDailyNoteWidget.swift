//
//  DailyNoteSquareWidget.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import SwiftUI
import WidgetKit

struct LargeSquareDailyNoteWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.LargeSquareDailyNoteWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: LargeSquareWidgetConfigurationIntent.self,
            provider: LargeSquareDailyNoteTimelineProvider()
        ) { entry in
            LargeSquareDailyNoteWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.large.display")
        .description("widget.large.desc")
        .supportedFamilies([.systemLarge])
    }
}
