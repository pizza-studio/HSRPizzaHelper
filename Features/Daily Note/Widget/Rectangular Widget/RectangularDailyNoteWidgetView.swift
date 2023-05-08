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
        .background {
            VStack {
                HStack {
                    WidgetAccountCard(accountName: entry.configuration.account?.name)
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
    }
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
                    WidgetStaminaInformationCard(info: dailyNote.staminaInformation)
                        .padding([.bottom, .leading], 10)
                        .padding(.trailing, 5)
                        .frame(maxWidth: geo.size.width * 1 / 2)
                    Spacer()
                }
            }
        }
    }
}
