//
//  InAppDailyNoteCardView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Combine
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

    private let refreshSubject: PassthroughSubject<(), Never>

    @StateObject private var dailyNoteViewModel: DailyNoteViewModel

    private var account: Account {
        dailyNoteViewModel.account
    }
}

// MARK: - NoteView

private struct NoteView: View {
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
                    Text("\(note.staminaInformation.currentStamina)")
                        .font(.title)
                    Text(" / \(note.staminaInformation.maxStamina)")
                        .font(.caption)
                    Spacer()
                    if note.staminaInformation.fullTime > Date() {
                        (
                            Text(note.staminaInformation.fullTime, style: .relative)
                                + Text("\n")
                                + Text(dateFormatter.string(from: note.staminaInformation.fullTime))
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        // Dispatch
        VStack {
            HStack {
                Text("sys.label.dispatch").bold()
                Spacer()
                let onGoingExpeditionNumber = note.expeditionInformation.onGoingExpeditionNumber
                let totalExpeditionNumber = note.expeditionInformation.totalExpeditionNumber
                Text("\(onGoingExpeditionNumber)/\(totalExpeditionNumber)")
            }
            VStack(spacing: 15) {
                ForEach(note.expeditionInformation.expeditions, id: \.name) { expedition in
                    HStack(alignment: .bottom) {
                        // Avatar Icon
                        HStack {
                            let imageFrame: CGFloat = 40
                            ForEach(expedition.avatarIconURLs, id: \.self) { url in
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: imageFrame)
                            }
                        }
                        // Expedition Name
                        Text("\(expedition.name)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                        // Time
                        if expedition.remainingTime > 0 {
                            (
                                Text(expedition.finishedTime, style: .relative)
                                    + Text("\n")
                                    + Text(dateFormatter.string(from: expedition.finishedTime))
                            )
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                        } else {
                            Image(systemSymbol: .checkmarkCircle)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
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
