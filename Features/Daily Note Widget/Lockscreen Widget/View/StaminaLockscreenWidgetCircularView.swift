//
//  StaminaLockscreenWidgetCircularView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/14.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - StaminaLockscreenWidgetCircularView

@available(iOSApplicationExtension 16.0, *)
struct StaminaLockscreenWidgetCircularView: View {
    let entry: LockscreenEntry

    var body: some View {
        Group {
            switch entry.dailyNoteResult {
            case let .success(dailyNote):
                SuccessView(entry: entry, dailyNote: dailyNote)
            case .failure:
                Image(systemSymbol: .ellipsis)
            }
        }
    }
}

// MARK: - SuccessView

@available(iOSApplicationExtension 16.0, *)
private struct SuccessView: View {
    let entry: LockscreenEntry
    let dailyNote: DailyNote

    var body: some View {
        Gauge(
            value: Double(dailyNote.staminaInformation.currentStamina) /
                Double(dailyNote.staminaInformation.maxStamina)
        ) {
            Image("Item_Trailblaze_Power_Gray")
                .resizable()
                .scaledToFit()
        } currentValueLabel: {
            Text("\(dailyNote.staminaInformation.currentStamina)")
                .font(.system(.title3, design: .rounded))
                .minimumScaleFactor(0.4)
        }
        .gaugeStyle(ProgressGaugeStyle())
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

// MARK: - ProgressGaugeStyle

private struct ProgressGaugeStyle: GaugeStyle {
    var circleColor: Color = .white

//    var valueTextColor: Color = .white
//    var labelColor: Color = .white

    #if os(watchOS)
    let strokeLineWidth: CGFloat = 4.7
    #else
    let strokeLineWidth: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            TotalArc()
                .stroke(
                    circleColor,
                    style: StrokeStyle(
                        lineWidth: strokeLineWidth,
                        lineCap: .round
                    )
                )
                .widgetAccentable()
                .opacity(0.5)
            Arc(percentage: configuration.value)
                .stroke(
                    circleColor,
                    style: StrokeStyle(
                        lineWidth: strokeLineWidth,
                        lineCap: .round
                    )
                )
                .widgetAccentable()
                .shadow(radius: 1)
            configuration.currentValueLabel
                .padding(strokeLineWidth * 1.4)
            VStack {
                Spacer()
                configuration.label
                #if os(watchOS)
                    .frame(width: 10, height: 10)
                    .padding(.bottom, -1.5)
                #else
                    .frame(width: 12, height: 12)
                    .padding(.bottom, -1.5)
                #endif
            }
            .widgetAccentable()
        }
        .padding(strokeLineWidth * 1 / 2)
    }
}

// MARK: - TotalArc

struct TotalArc: Shape {
//    #if os(watchOS)
//    let startAngle: Angle = .degrees(45)
//    let endAngle: Angle = .degrees(135)
//    #else
    let startAngle: Angle = .degrees(50)
    let endAngle: Angle = .degrees(130)

//    #endif

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return path
    }
}

// MARK: - Arc

struct Arc: Shape {
    let percentage: Double

    func path(in rect: CGRect) -> Path {
//        #if os(watchOS)
//        let startAngle: Angle = .degrees(45 - (1 - percentage) * 270)
//        let endAngle: Angle = .degrees(135)
//        #else
        let startAngle: Angle = .degrees(50 - (1 - percentage) * 280)
        let endAngle: Angle = .degrees(130)
//        #endif

        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return path
    }
}
