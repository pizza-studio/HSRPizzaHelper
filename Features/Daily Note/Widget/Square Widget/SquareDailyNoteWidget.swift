//
//  DailyNoteSquareWidget.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import SwiftUI
import WidgetKit

struct SquareDailyNoteWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.SquareDailyNoteWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SquareWidgetConfigurationIntent.self,
            provider: SquareDailyNoteTimelineProvider()
        ) { entry in
            SquareDailyNoteWidgetView(entry: entry)
        }
        .configurationDisplayName("SquareDailyNoteWidget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}
