//
//  RectangularDailyNoteWidget.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Foundation
import SwiftUI
import WidgetKit

struct RectangularDailyNoteWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.RectangularDailyNoteWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: RectangularWidgetConfigurationIntent.self,
            provider: RectangularDailyNoteTimelineProvider()
        ) { entry in
            RectangularDailyNoteWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.rect.display")
        .description("widget.rect.desc")
        .supportedFamilies([.systemMedium, .systemExtraLarge])
    }
}
