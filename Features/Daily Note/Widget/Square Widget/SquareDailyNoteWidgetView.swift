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
    let entry: DailyNoteEntry

    var body: some View {
        Group {
            switch entry.dailyNoteResult {
            case let .success(dailyNote):
                SquareDailyNoteSuccessView(entry: entry, dailyNote: dailyNote)
            case let .failure(error):
                Text(error.localizedDescription)
            }
        }
        .background {
            VStack {
                HStack {
                    WidgetAccountCard(
                        accountName: entry.configuration.account?.name,
                        useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                    )
                    Spacer()
                }
                Spacer()
            }
            .padding(10)
        }
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
}

// MARK: - SquareDailyNoteSuccessView

private struct SquareDailyNoteSuccessView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: DailyNoteEntry
    let dailyNote: DailyNote

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            VStack {
                Spacer()
                WidgetStaminaInformationCard(
                    info: dailyNote.staminaInformation,
                    useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                )
                .padding(10)
            }
        case .systemLarge:
            GeometryReader { geo in
                VStack {
                    Spacer()
                    HStack {
                        WidgetStaminaInformationCard(
                            info: dailyNote.staminaInformation,
                            useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                        )
                        .padding([.bottom, .leading], 10)
                        .padding(.trailing, 5)
                        .frame(maxWidth: geo.size.width * 1 / 2)
                        Spacer()
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}
