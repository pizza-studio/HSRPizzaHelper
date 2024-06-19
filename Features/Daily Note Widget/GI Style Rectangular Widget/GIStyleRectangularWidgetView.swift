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
    @Environment(\.colorScheme) var colorScheme
    let entry: GIStyleEntry

    var body: some View {
        Group {
            switch entry.dailyNoteResult {
            case let .success(dailyNote):
                WidgetGIStyleSuccessView(entry: entry, dailyNote: dailyNote)
            case let .failure(error):
                WidgetErrorView(error: error)
            }
        }
        .foregroundColor(entry.configuration.textColor)
        .widgetContainerBackground(withPaddingUnderIOS17: 20) {
            Group {
                if let image = entry.configuration.backgroundImage() {
                    image.resizable().scaledToFill()
                } else {
                    EmptyView()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .environment(\.colorScheme, actualColorScheme)
    }

    var actualColorScheme: ColorScheme {
        guard entry.configuration.textColor != .primary else { return colorScheme }
        return entry.configuration.textColor == .white ? .light : .dark
    }
}

// MARK: - WidgetGIStyleSuccessView

private struct WidgetGIStyleSuccessView: View {
    // MARK: Internal

    let entry: GIStyleEntry
    let dailyNote: DailyNote

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if entry.configuration.showAccountName, let name = entry.configuration.account?.name {
                    HStack(alignment: .lastTextBaseline, spacing: 2.0) {
                        Image(systemSymbol: .personFill)
                        Text(name)
                    }
                    .font(.caption)
                    .shadow(color: .black.opacity(0.3), radius: 0.3, x: 1.0, y: 1.0)
                }
                staminaViewUpper()
                Spacer()
                staminaViewLower()
            }
            Spacer(minLength: 15.0)
            expeditionView()
            Spacer()
        }
    }

    // MARK: Private

    private var staminaText: String {
        [
            dateFormatter.string(from: dailyNote.staminaInformation.fullTime),
            timeIntervalFormatter.string(from: dailyNote.staminaInformation.remainingTime),
        ].compactMap { $0 }.joined(separator: "\n")
    }

    @ViewBuilder
    private func staminaViewUpper() -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(verbatim: dailyNote.staminaInformation.currentStamina.description)
                .font(.system(size: 50, design: .rounded))
                .fontWeight(.medium)
                .minimumScaleFactor(0.8)
                .shadow(color: .black.opacity(0.3), radius: 0.3, x: 1, y: 1)
            Image("Item_Trailblaze_Power")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 25)
                .alignmentGuide(.firstTextBaseline) { context in
                    context[.bottom] - 0.05 * context.height
                }
                .shadow(color: .black.opacity(0.2), radius: 0.5, x: 2, y: 2)
        }
    }

    @ViewBuilder
    private func staminaViewLower() -> some View {
        HStack {
            if #available(iOSApplicationExtension 17.0, *) {
                Button(intent: GeneralWidgetRefreshIntent()) {
                    Image(systemSymbol: .arrowClockwiseCircle)
                        .font(.title3)
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
            } else {
                Image(systemSymbol: .hourglassCircle)
                    .font(.title3)
            }
            if !dailyNote.staminaInformation.isPrimaryStaminaFull {
                Text(staminaText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .font(.caption2)
            } else {
                Text("100%")
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 0.3, x: 1, y: 1)
    }

    @ViewBuilder
    private func percentageBar(_ percentage: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: 3,
                    style: .continuous
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(0.6)
                RoundedRectangle(
                    cornerRadius: 3,
                    style: .continuous
                )
                .frame(
                    width: geo.size.width * percentage,
                    height: geo.size.height
                )
                .foregroundStyle(.thickMaterial)
            }
            .aspectRatio(30 / 1, contentMode: .fit)
        }
        .frame(height: 7)
    }

    @ViewBuilder
    private func expeditionView() -> some View {
        if entry.configuration.showExpedition {
            Spacer()
            VStack(alignment: .leading, spacing: 6.0) {
                ForEach(entry.expeditionWithUIImage, id: \.0.name) { expedition, images in
                    let actualImages = images.compactMap { $0 }
                    HStack {
                        ForEach(actualImages, id: \.self) { uiImage in
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27.0, height: 27.0)
                                .shadow(color: .black.opacity(0.3), radius: 0.3, x: 1.0, y: 1.0)
                                .background(.thinMaterial, in: Circle())
                        }
                        .layoutPriority(1.0)
                        VStack(alignment: .leading, spacing: 3.0) {
                            percentageBar(expedition.percOfCompletion).frame(maxWidth: 100.0)
                            Text(timeIntervalFormatter.string(from: expedition.remainingTime)!)
                                .shadow(color: .black.opacity(0.3), radius: 0.3, x: 1.0, y: 1.0)
                        }
                        .font(.caption2)
                    }
                }
            }
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
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    return formatter
}()
