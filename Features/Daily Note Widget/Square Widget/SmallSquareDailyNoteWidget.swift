//
//  SmallSquareDailyNoteWidget.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation
import Intents
import SwiftUI
import WidgetKit

struct SmallSquareDailyNoteWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.SmallSquareDailyNoteWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SmallSquareWidgetConfigurationIntent.self,
            provider: SmallSquareDailyNoteTimelineProvider()
        ) { entry in
            SmallSquareDailyNoteWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.small.display".localized())
        .description("widget.small.desc".localized())
        .supportedFamilies([.systemSmall])
        .widgetContainerBackgroundRemovable(false)
    }
}
