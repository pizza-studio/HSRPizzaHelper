//
//  StaminaLockscreenWidgetRectangularView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/14.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - StaminaLockscreenWidgetRectangularView

struct StaminaLockscreenWidgetRectangularView: View {
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

private struct SuccessView: View {
    let entry: LockscreenEntry
    let dailyNote: DailyNote

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Image("Item_Trailblaze_Power_Gray")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 35)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.13 * context.height
                    }
                Text("\(dailyNote.staminaInformation.currentStamina)")
                    .font(.system(.title, design: .rounded))
            }
            Text(dateFormatter.string(from: dailyNote.staminaInformation.fullTime))
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, -4)
        }
    }
}

private let timeIntervalFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .hour]
    formatter.unitsStyle = .brief
    formatter.maximumUnitCount = 2
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    return formatter
}()
