//
//  GIStyleRectangularWidgetView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/13.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - GIStyleRectangularWidgetView

struct GIStyleRectangularWidgetView: View {
    let entry: GIStyleEntry

    var body: some View {
        Group {
            switch entry.dailyNoteResult {
            case let .success(dailyNote):
                WidgetGIStyleSuccessView(entry: entry, dailyNote: dailyNote)
            case let .failure(error):
                Text(error.localizedDescription)
            }
        }
        .foregroundColor(entry.configuration.textColor)
        .padding(20)
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

// MARK: - WidgetGIStyleSuccessView

private struct WidgetGIStyleSuccessView: View {
    let entry: GIStyleEntry
    let dailyNote: DailyNote

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if entry.configuration.showAccountName, let name = entry.configuration.account?.name {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemSymbol: .personFill)
                        Text(name)
                    }
                    .font(.caption)
                }
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(dailyNote.staminaInformation.currentStamina)")
                        .font(.system(size: 50, design: .rounded))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.8)
                        .shadow(radius: 1)
                    Image("Item_Trailblaze_Power")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 25)
                        .alignmentGuide(.firstTextBaseline) { context in
                            context[.bottom] - 0.05 * context.height
                        }
                        .shadow(radius: 0.8)
                }
                HStack {
                    Image(systemSymbol: .hourglassCircle)
                        .font(.title3)
                    if dailyNote.staminaInformation.remainingTime >= 0 {
                        Group {
                            if dailyNote.staminaInformation.currentStamina != dailyNote.staminaInformation.maxStamina {
                                (
                                    Text(dateFormatter.string(from: dailyNote.staminaInformation.fullTime))
                                        + Text("\n")
                                        +
                                        Text(
                                            timeIntervalFormatter
                                                .string(from: dailyNote.staminaInformation.remainingTime)!
                                        )
                                )
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .font(.caption2)
                            } else {
                                Text("FULL")
                            }
                        }
                    }
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                ForEach(entry.expeditionWithUIImage, id: \.0.name) { expedition, images in
                    HStack {
                        ForEach(images, id: \.self) { uiImage in
                            if let uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25)
                                    .shadow(color: .white, radius: 1)
                                    .background(.thinMaterial, in: Circle())
                            }
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text(expedition.name)
                            Text(timeIntervalFormatter.string(from: expedition.remainingTime)!)
                        }
                        .font(.caption2)
                    }
                }
            }
            Spacer()
        }
    }
}

private let timeIntervalFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .hour]
    formatter.unitsStyle = .brief
    formatter.maximumUnitCount = 2
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()
