//
//  SquareDailyNoteWidgetView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import HBMihoyoAPI
import Intents
import SwiftUI

// MARK: - SquareDailyNoteWidgetView

struct SquareDailyNoteWidgetView: View {
    // MARK: Internal

    let entry: DailyNoteEntry

    var body: some View {
        VStack {
            // MARK: Top - Account Name

            HStack {
                WidgetAccountCard(
                    accountName: entry.configuration.account?.name,
                    useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                )
                Spacer()
            }
            Spacer()

            // MARK: Bottom - Result

            Group {
                switch entry.dailyNoteResult {
                case let .success(dailyNote):
                    SquareDailyNoteSuccessView(entry: entry, dailyNote: dailyNote)
                case let .failure(error):
                    Text(error.localizedDescription)
                }
            }
        }
        .padding(mainViewPadding)
        .background {
            Group {
                if let image = entry.configuration.backgroundImage() {
                    image.resizable().scaledToFill()
                } else {
                    EmptyView()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .foregroundColor(entry.configuration.textColor)
    }

    // MARK: Private

    private let mainViewPadding: CGFloat = 10
}

// MARK: - SquareDailyNoteSuccessView

private struct SquareDailyNoteSuccessView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: DailyNoteEntry
    let dailyNote: DailyNote

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            WidgetStaminaInformationCard(
                info: dailyNote.staminaInformation,
                useAccessibilityBackground: entry.configuration.useAccessibilityBackground
            )
        case .systemLarge:
            VStack {
                Spacer()
                HStack {
                    WidgetStaminaInformationCard(
                        info: dailyNote.staminaInformation,
                        useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                    )
                    .padding(.trailing, 5)
                    Spacer()
                }
            }
        default:
            EmptyView()
        }
    }
}
