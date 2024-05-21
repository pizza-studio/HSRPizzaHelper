//
//  InAppDailyNoteCardView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Combine
import EnkaSwiftUIViews
import Foundation
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

// MARK: - InAppDailyNoteCardView

struct InAppDailyNoteCardView: View {
    // MARK: Lifecycle

    init(
        account: Account
    ) {
        self._dailyNoteViewModel = StateObject(wrappedValue: DailyNoteViewModel(account: account))
        self.refreshSubject = globalDailyNoteCardRefreshSubject
    }

    // MARK: Internal

    var body: some View {
        Section {
            switch dailyNoteViewModel.dailyNote {
            case .loading, .pending:
                ProgressView()
            case let .finished(result):
                switch result {
                case let .success(note):
                    NoteView(account: account, note: note)
                case let .failure(error):
                    ErrorView(account: account, error: error)
                }
            }
        } header: {
            if let name = account.name {
                Text(name)
                    .secondaryColorVerseBackground()
            }
        }
        .onReceive(refreshSubject, perform: { _ in
            Task {
                await dailyNoteViewModel.getDailyNoteUncheck()
            }
        })
        .onAppBecomeActive {
            Task {
                await dailyNoteViewModel.getDailyNote()
            }
        }
    }

    // MARK: Private

    private let refreshSubject: PassthroughSubject<Void, Never>

    @StateObject private var dailyNoteViewModel: DailyNoteViewModel

    private var account: Account {
        dailyNoteViewModel.account
    }
}

// MARK: - NoteView

private struct NoteView: View {
    // MARK: Internal

    let account: Account
    let note: DailyNote

    var body: some View {
        // Trailblaze_Power
        VStack {
            HStack {
                Text("sys.label.trailblaze").bold()
                Spacer()
            }
            HStack(spacing: 10) {
                let iconFrame: CGFloat = 40
                Image("Item_Trailblaze_Power")
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(note.staminaInformation.currentStamina)")
                        .font(.title)
                    Text(verbatim: " / \(note.staminaInformation.maxStamina)")
                        .font(.caption)
                    Spacer()
                    if note.staminaInformation.fullTime > Date() {
                        (
                            Text(note.staminaInformation.fullTime, style: .relative)
                                + Text(verbatim: "\n")
                                + Text(dateFormatter.string(from: note.staminaInformation.fullTime))
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        // Daily Training & Simulated Universe (China mainland user only)
        if let dailyNote = note as? WidgetDailyNote {
            HStack {
                Text("app.dailynote.card.daily_training.label").bold()
                Spacer()
                let currentScore = dailyNote.dailyTrainingInformation.currentScore
                let maxScore = dailyNote.dailyTrainingInformation.maxScore
                Text(verbatim: "\(currentScore)/\(maxScore)")
            }
            HStack {
                Text("app.dailynote.card.simulated_universe.label").bold()
                Spacer()
                let currentScore = dailyNote.simulatedUniverseInformation.currentScore
                let maxScore = dailyNote.simulatedUniverseInformation.maxScore
                Text(verbatim: "\(currentScore)/\(maxScore)")
            }
        }
        // Dispatch
        VStack {
            HStack {
                Text("sys.label.dispatch").bold()
                Spacer()
                let onGoingExpeditionNumber = note.expeditionInformation.onGoingExpeditionNumber
                let totalExpeditionNumber = note.expeditionInformation.totalExpeditionNumber
                Text(verbatim: "\(onGoingExpeditionNumber)/\(totalExpeditionNumber)")
            }
            VStack(spacing: 15) {
                StaggeredGrid(
                    columns: horizontalSizeClass == .compact ? 2 : 4,
                    outerPadding: false,
                    scroll: false,
                    list: note.expeditionInformation.expeditions
                ) { currentExpedition in
                    currentExpedition
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
}

// MARK: - ExpeditionInformation.Expedition + View

extension ExpeditionInformation.Expedition: View {
    public var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 4) {
                // Avatar Icon
                HStack(alignment: .top, spacing: 2) {
                    let imageFrame: CGFloat = 32
                    ForEach(avatarIconURLs, id: \.self) { url in
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: imageFrame)
                        .background {
                            Color.gray.opacity(0.5).clipShape(Circle())
                        }
                    }
                }.fixedSize()
            }
            // Time
            if remainingTime > 0 {
                (
                    Text(finishedTime, style: .relative)
                        + Text("\n")
                        + Text(dateFormatter.string(from: finishedTime))
                )
                .multilineTextAlignment(.leading)
                .font(.caption2)
                .fontWidth(.condensed)
            } else {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            // Expedition Name
            // Text("\(name)")
            // .font(.footnote)
            // .foregroundColor(.secondary)
            // .minimumScaleFactor(0.5)
            // .fontWidth(.compressed)
            Spacer()
        }
    }
}

// MARK: - ErrorView

private struct ErrorView: View {
    // MARK: Internal

    let account: Account
    var error: Error

    var body: some View {
        Button {
            isEditAccountSheetShown.toggle()
        } label: {
            switch error {
            case MiHoYoAPIError.verificationNeeded:
                Label {
                    Text("app.dailynote.card.error.need_verification.button")
                } icon: {
                    Image(systemSymbol: .questionmarkCircle)
                        .foregroundColor(.yellow)
                }
            default:
                Label {
                    Text("app.dailynote.card.error.other_error.button")
                } icon: {
                    Image(systemSymbol: .exclamationmarkCircle)
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $isEditAccountSheetShown, content: {
            EditAccountSheetView(account: account, isShown: $isEditAccountSheetShown)
        })
    }

    // MARK: Private

    @State private var isEditAccountSheetShown: Bool = false
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter
}()

private let dateComponentsFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
