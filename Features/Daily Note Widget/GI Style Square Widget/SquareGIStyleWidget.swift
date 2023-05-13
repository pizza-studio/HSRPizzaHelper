//
//  SquareGIStyleWidget.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import SwiftUI
import WidgetKit

struct SquareGIStyleWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.SquareGIStyleWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: GIStyleSquareWidgetConfigurationIntent.self,
            provider: GIStyleSquareTimelineProvider()
        ) { entry in
            GIStyleSquareWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.gistyle.square.display".localized())
        .description("widget.gistyle.square.desc".localized())
        .supportedFamilies([.systemLarge])
    }
}
