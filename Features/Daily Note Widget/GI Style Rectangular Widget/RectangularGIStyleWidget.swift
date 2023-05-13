//
//  RectangularGIStyleWidget.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import SwiftUI
import WidgetKit

struct RectangularGIStyleWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.RectangularGIStyleWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: GIStyleRectangularWidgetConfigurationIntent.self,
            provider: GIStyleRectangularTimelineProvider()
        ) { entry in
            GIStyleRectangularWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.gistyle.rect.display".localized())
        .description("widget.gistyle.rect.desc".localized())
        .supportedFamilies([.systemMedium])
    }
}
