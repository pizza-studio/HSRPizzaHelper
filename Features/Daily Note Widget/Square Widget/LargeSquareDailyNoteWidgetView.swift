//
//  SquareDailyNoteWidgetView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import HBMihoyoAPI
import Intents
import SwiftUI

// MARK: - LargeSquareDailyNoteWidgetView

struct LargeSquareDailyNoteWidgetView: View {
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
                    LargeSquareDailyNoteSuccessView(entry: entry, dailyNote: dailyNote)
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

// MARK: - LargeSquareDailyNoteSuccessView

private struct LargeSquareDailyNoteSuccessView: View {
    let entry: DailyNoteEntry
    let dailyNote: DailyNote

    var body: some View {
        WidgetDailyNoteSuccessLargeView(entry: entry, dailyNote: dailyNote)
            .embed(in: .bottom)
    }
}
