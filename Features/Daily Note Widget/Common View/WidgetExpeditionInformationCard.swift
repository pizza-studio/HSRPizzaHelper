//
//  WidgetExpeditionInformationCard.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation
import HBMihoyoAPI
import SwiftUI
import WidgetKit

struct WidgetExpeditionInformationCard: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let info: ExpeditionInformation

    let useAccessibilityBackground: Bool

    var body: some View {
        // TODO: `WidgetExpeditionInformationCard`
        EmptyView()
    }

    private var iconFrame: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 20
        case .systemExtraLarge, .systemLarge, .systemMedium:
            return 27
        default:
            return 27
        }
    }

    private var staminaFont: Font {
        switch widgetFamily {
        case .systemSmall:
            return .title2
        case .systemExtraLarge, .systemLarge, .systemMedium:
            return .title
        default:
            return .title
        }
    }
}
