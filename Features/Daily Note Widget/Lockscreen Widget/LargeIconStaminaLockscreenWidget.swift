//
//  LargeIconStaminaLockscreenWidget.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/14.
//

import Foundation
import HBMihoyoAPI
import SwiftUI
import WidgetKit

// MARK: - LargeIconStaminaLockscreenWidget

@available(iOSApplicationExtension 16.0, *)
struct LargeIconStaminaLockscreenWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.LargeIconStaminaLockscreenWidget"

    @Environment(\.widgetFamily) var widgetFamily

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: LockscreenWidgetConfigurationIntent.self,
            provider: LockscreenTimelineProvider()
        ) { entry in
            LargeIconStaminaLockscreenWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.lockscreen.largeicon.display".localized())
        .description("widget.lockscreen.largeicon.desc".localized())
        .widgetContainerBackgroundRemovable(false)
        .contentMarginsDisabled()
        .supportedFamilies([
            .accessoryCircular,
        ])
        .widgetContainerBackgroundRemovable(false)
    }
}

// MARK: - LargeIconStaminaLockscreenWidgetView

struct LargeIconStaminaLockscreenWidgetView: View {
    let entry: LockscreenEntry

    var body: some View {
        Group {
            switch entry.dailyNoteResult {
            case let .success(dailyNote):
                SuccessView(entry: entry, dailyNote: dailyNote)
            case .failure:
                Image(systemSymbol: .ellipsis)
            }
        }
        .widgetEmptyContainerBackground()
    }
}

// MARK: - SuccessView

private struct SuccessView: View {
    let entry: LockscreenEntry
    let dailyNote: DailyNote

    var body: some View {
        VStack(spacing: 0) {
            Image("Item_Trailblaze_Power_Gray")
                .resizable()
                .scaledToFit()
            Text("\(dailyNote.staminaInformation.currentStamina)")
                .font(.system(.body, design: .rounded).weight(.medium))
        }
    }
}
