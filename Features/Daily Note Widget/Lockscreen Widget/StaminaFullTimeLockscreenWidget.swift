//
//  StaminaFullTimeLockscreenWidget.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/14.
//

import Foundation
import HBMihoyoAPI
import SwiftUI
import WidgetKit

// MARK: - StaminaFullTimeLockscreenWidget

@available(iOSApplicationExtension 16.0, *)
struct StaminaFullTimeLockscreenWidget: Widget {
    let kind: String = "com.Canglong.HSRPizzaHelper.HSRPizzaHelperWidget.StaminaFullTimeLockscreenWidget"

    @Environment(\.widgetFamily) var widgetFamily

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: LockscreenWidgetConfigurationIntent.self,
            provider: LockscreenTimelineProvider()
        ) { entry in
            StaminaFullTimeLockscreenWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.lockscreen.fulltime.display".localized())
        .description("widget.lockscreen.fulltime.desc".localized())
        .supportedFamilies([
            .accessoryCircular,
        ])
        .widgetContainerBackgroundRemovable(false)
        .contentMarginsDisabled()
    }
}

// MARK: - StaminaFullTimeLockscreenWidgetView

@available(iOSApplicationExtension 16.0, *)
private struct StaminaFullTimeLockscreenWidgetView: View {
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

@available(iOSApplicationExtension 16.0, *)
private struct SuccessView: View {
    let entry: LockscreenEntry
    let dailyNote: DailyNote

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -0.5) {
                Image("Item_Trailblaze_Power_Gray")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 9)
                VStack(spacing: -2) {
                    if dailyNote.staminaInformation.remainingTime != 0 {
                        Text("\(dailyNote.staminaInformation.currentStamina)")
                            .font(.system(
                                size: 20,
                                weight: .medium,
                                design: .rounded
                            ))
                            .widgetAccentable()
                        Text(dateFormatter.string(from: dailyNote.staminaInformation.fullTime))
                            .font(.system(
                                .caption,
                                design: .monospaced
                            ))
                            .minimumScaleFactor(0.5)
                    } else {
                        Text("\(dailyNote.staminaInformation.currentStamina)")
                            .font(.system(
                                size: 20,
                                weight: .medium,
                                design: .rounded
                            ))
                            .widgetAccentable()
                    }
                }
            }
            .padding(.vertical, 2)
            #if os(watchOS)
                .padding(.vertical, 2)
                .padding(.bottom, 1)
            #endif
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()
