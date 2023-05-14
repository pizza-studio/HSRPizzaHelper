//
//  CommonStaminaLockscreenWidget.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/14.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - CommonStaminaLockscreenWidget

@available(iOSApplicationExtension 16.0, *)
struct CommonStaminaLockscreenWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.CommonStaminaLockscreenWidget"

    @Environment(\.widgetFamily) var widgetFamily

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: LockscreenWidgetConfigurationIntent.self,
            provider: LockscreenTimelineProvider()
        ) { entry in
            CommonStaminaLockscreenWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.gistyle.square.display".localized())
        .description("widget.gistyle.square.desc".localized())
        #if !os(watchOS)
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
            ])
        #else
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCorner,
            ])
        #endif
    }
}

// MARK: - CommonStaminaLockscreenWidgetView

@available(iOSApplicationExtension 16.0, *)
private struct CommonStaminaLockscreenWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: LockscreenEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            StaminaLockscreenWidgetCircularView(entry: entry)
        case .accessoryInline:
            StaminaLockscreenWidgetInlineView(entry: entry)
        case .accessoryRectangular:
            StaminaLockscreenWidgetRectangularView(entry: entry)
        #if os(watchOS)
        case .accessoryCorner:
            // TODO: watch corner widget
            EmptyView()
        #endif
        default:
            EmptyView()
        }
    }
}
