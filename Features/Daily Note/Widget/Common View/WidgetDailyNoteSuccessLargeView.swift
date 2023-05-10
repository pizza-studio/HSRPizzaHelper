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
        switch entry.configuration.expeditionDisplayMode {
        case .display:
            WidgetStaminaInformationCard(
                info: dailyNote.staminaInformation,
                useAccessibilityBackground: entry.configuration.useAccessibilityBackground,
                direction: .leftToRight
            )
            .padding(.trailing, 5)
            Spacer()
            WidgetExpeditionInformationCard(
                info: dailyNote.expeditionInformation,
                useAccessibilityBackground: entry.configuration.useAccessibilityBackground
            )
            .padding(.leading, 5)
        case let .hide(staminaPosition: position):
            WidgetStaminaInformationCard(
                info: dailyNote.staminaInformation,
                useAccessibilityBackground: entry.configuration.useAccessibilityBackground,
                direction: position == .right ? .rightToLeft : .leftToRight
            )
            .embed(in: {
                switch position {
                case .left: return .left
                case .right: return .right
                case .center: return .center
                }
            }())
        }
    }
}
