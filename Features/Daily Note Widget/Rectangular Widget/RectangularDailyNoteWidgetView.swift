//
//  RectangularDailyNoteWidgetView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/8.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - RectangularDailyNoteWidgetView

struct RectangularDailyNoteWidgetView: View {
    // MARK: Internal

    let entry: DailyNoteEntry

    var body: some View {
        VStack {
            // MARK: Top: Account

            if entry.configuration.showAccountName {
                WidgetAccountCard(
                    accountName: entry.configuration.account?.name,
                    useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                )
                .embed(in: .left)
            }

            Spacer()

            // MARK: Bottom: Result

            Group {
                switch entry.dailyNoteResult {
                case let .success(dailyNote):
                    WidgetDailyNoteSuccessLargeView(entry: entry, dailyNote: dailyNote)
                        .embed(in: .bottom)
                case let .failure(error):
                    WidgetErrorView(error: error)
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
