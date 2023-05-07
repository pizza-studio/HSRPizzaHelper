//
//  WidgetStaminaInformationCard.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/8.
//

import HBMihoyoAPI
import SwiftUI

struct WidgetStaminaInformationCard: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let info: StaminaInformation

    var body: some View {
        HStack(spacing: 5) {
            Image("Item_Trailblaze_Power")
                .resizable()
                .scaledToFit()
                .frame(height: iconFrame)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text("\(info.currentStamina)")
                    .font(staminaFont)
                (
                    Text(info.fullTime, style: .time)
                        + Text("\n")
                        + Text(info.fullTime, style: .relative)
                )
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.8)
                .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
    }

    var iconFrame: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 20
        case .systemExtraLarge, .systemLarge, .systemMedium:
            return 27
        default:
            return 27
        }
    }

    var staminaFont: Font {
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
