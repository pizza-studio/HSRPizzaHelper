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
        Group {
            switch entry.dailyNoteResult {
            case let .success(dailyNote):
                RectangularDailyNoteSuccessView(entry: entry, dailyNote: dailyNote)
            case let .failure(error):
                Text(error.localizedDescription)
            }
        }
        .padding(.vertical, mainViewPadding)
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
            .padding(mainViewPadding)
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

    // MARK: Private

    private let mainViewPadding: CGFloat = 10
}

// MARK: - RectangularDailyNoteSuccessView

private struct RectangularDailyNoteSuccessView: View {
    let entry: DailyNoteEntry
    let dailyNote: DailyNote

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                    WidgetStaminaInformationCard(
                        info: dailyNote.staminaInformation,
                        useAccessibilityBackground: entry.configuration.useAccessibilityBackground
                    )
                    .padding(.trailing, 5)
                    .frame(maxWidth: geo.size.width * 1 / 2)
                    Spacer()
                }
            }
        }
    }
}
