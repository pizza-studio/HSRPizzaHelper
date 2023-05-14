//
//  StaminaLockscreenWidgetInlineView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/14.
//

import SwiftUI

// MARK: - StaminaLockscreenWidgetInlineView

struct StaminaLockscreenWidgetInlineView: View {
    let entry: LockscreenEntry

    var body: some View {
        Image(systemSymbol: .staroflifeCircle)
        switch entry.dailyNoteResult {
        case let .success(dailyNote):
            Text("\(dailyNote.staminaInformation.currentStamina)")
                + Text(", ")
                + Text(timeIntervalFormatter.string(from: dailyNote.staminaInformation.remainingTime)!)
        case .failure:
            Text("…")
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
