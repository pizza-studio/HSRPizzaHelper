//
//  SquareDailyNoteWidgetView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Intents
import SwiftUI

struct SquareDailyNoteWidgetView: View {
    let entry: DailyNoteEntry

    var body: some View {
        ZStack {
            Group {
                if let image = entry.configuration.background.image() {
                    image.resizable().scaledToFit()
                } else {
                    EmptyView()
                }
            }
            Group {
                switch entry.dailyNoteResult {
                case let .success(dailyNote):
                    Text("\(dailyNote.staminaInformation.currentStamina)")
                case let .failure(error):
                    Text(error.localizedDescription)
                }
            }
        }
    }
}
