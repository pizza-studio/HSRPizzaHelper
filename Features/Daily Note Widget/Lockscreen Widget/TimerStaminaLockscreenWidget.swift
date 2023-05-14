//
//  TimerStaminaLockscreenWidget.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/14.
//

import Foundation
import HBMihoyoAPI
import SwiftUI
import WidgetKit

// MARK: - TimerStaminaLockscreenWidget

@available(iOSApplicationExtension 16.0, *)
struct TimerStaminaLockscreenWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.TimerStaminaLockscreenWidget"

    @Environment(\.widgetFamily) var widgetFamily

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: LockscreenWidgetConfigurationIntent.self,
            provider: LockscreenTimelineProvider()
        ) { entry in
            TimerStaminaLockscreenWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.gistyle.square.display".localized())
        .description("widget.gistyle.square.desc".localized())
        .supportedFamilies([
            .accessoryCircular,
        ])
    }
}

// MARK: - TimerStaminaLockscreenWidgetView

@available(iOSApplicationExtension 16.0, *)
private struct TimerStaminaLockscreenWidgetView: View {
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
    }
}

// MARK: - SuccessView

@available(iOSApplicationExtension 16.0, *)
private struct SuccessView: View {
    let entry: LockscreenEntry
    let dailyNote: DailyNote

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 3) {
                Image("Item_Trailblaze_Power_Gray")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 13)
                VStack(spacing: 1) {
                    if dailyNote.staminaInformation.remainingTime != 0 {
                        Text(
                            dailyNote.staminaInformation.fullTime,
                            style: .timer
                        )
                        .multilineTextAlignment(.center)
                        .font(.system(.body, design: .monospaced))
                        .minimumScaleFactor(0.5)
                        .widgetAccentable()
                        .frame(width: 50)
                        Text("\(dailyNote.staminaInformation.currentStamina)")
                            .font(.system(
                                .body,
                                design: .rounded,
                                weight: .medium
                            ))
                            .padding(.bottom, -2)
                    } else {
                        Text("\(dailyNote.staminaInformation.currentStamina)")
                            .font(.system(
                                size: 20,
                                weight: .medium,
                                design: .rounded
                            ))
                    }
                }
            }
            .padding(.vertical, 2)
            #if os(watchOS)
                .padding(.vertical, 2)
            #endif
        }
    }
}
