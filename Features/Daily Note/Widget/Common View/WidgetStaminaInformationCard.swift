//
//  WidgetStaminaInformationCard.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/8.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - WidgetStaminaInformationCard

struct WidgetStaminaInformationCard: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let info: StaminaInformation

    let useAccessibilityBackground: Bool

    var body: some View {
        HStack(spacing: 5) {
            Image("Item_Trailblaze_Power")
                .resizable()
                .scaledToFit()
                .frame(height: iconFrame)
                .shadow(radius: 10)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text("\(info.currentStamina)")
                    .font(staminaFont)
                    .shadow(radius: 10)
                (
                    Text(dateFormatter.string(from: info.fullTime))
                        + Text("\n")
                        + Text(timeIntervalFormatter.string(from: info.remainingTime)!)
                )
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
                .font(.caption2)
            }
        }

        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .accessibilityBackground(enable: useAccessibilityBackground)
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

// MARK: - AccessibilityBackground

private struct AccessibilityBackground: ViewModifier {
    let enable: Bool

    func body(content: Content) -> some View {
        if enable {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                )
        } else {
            content
        }
    }
}

extension View {
    fileprivate func accessibilityBackground(enable: Bool) -> some View {
        modifier(AccessibilityBackground(enable: enable))
    }
}

private let timeIntervalFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .hour]
    formatter.unitsStyle = .abbreviated
    formatter.maximumUnitCount = 2
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()
