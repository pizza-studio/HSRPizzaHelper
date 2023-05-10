//
//  SmallSquareDailyNoteWidgetView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/10.
//

import HBMihoyoAPI
import Intents
import SwiftUI

// MARK: - SmallSquareDailyNoteWidgetView

struct SmallSquareDailyNoteWidgetView: View {
    // MARK: Internal

    let entry: DailyNoteEntry

    var body: some View {
        VStack {
            // MARK: Top - Account Name

            if entry.configuration.showAccountName {
                WidgetAccountCard(
                    accountName: entry.configuration.account?.name,
                    useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                )
                .embed(in: .left)
            }

            Spacer()

            // MARK: Bottom - Result

            Group {
                switch entry.dailyNoteResult {
                case let .success(dailyNote):
                    SmallSquareDailyNoteSuccessView(entry: entry, dailyNote: dailyNote)
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

// MARK: - SmallSquareDailyNoteSuccessView

private struct SmallSquareDailyNoteSuccessView: View {
    let entry: DailyNoteEntry
    let dailyNote: DailyNote

    var body: some View {
        WidgetStaminaInformationCard(
            info: dailyNote.staminaInformation,
            useAccessibilityBackground: entry.configuration.useAccessibilityBackground,
            direction: .leftToRight
        )
    }
}
