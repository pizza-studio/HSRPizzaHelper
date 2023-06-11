//
//  WidgetDailyNoteSuccessLargeView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation
import HBMihoyoAPI
import SwiftUI

struct WidgetDailyNoteSuccessLargeView: View {
    let entry: DailyNoteEntry
    let dailyNote: DailyNote

    var body: some View {
        WidgetStaminaInformationCard(
            info: dailyNote.staminaInformation,
            useAccessibilityBackground: entry.configuration.useAccessibilityBackground,
            direction: entry.configuration.staminaPosition == .right ? .rightToLeft : .leftToRight
        )
        .embed(in: {
            switch entry.configuration.staminaPosition {
            case .left: return .left
            case .right: return .right
            case .center: return .middleCenter
            }
        }())
    }
}
