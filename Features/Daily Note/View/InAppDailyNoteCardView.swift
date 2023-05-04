//
//  InAppDailyNoteCardView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI
import SwiftUI

// MARK: - InAppDailyNoteCardView

struct InAppDailyNoteCardView: View {
    @StateObject var dailyNoteViewModel: DailyNoteViewModel = .init()

    let account: Account

    var body: some View {
        Group {
            switch dailyNoteViewModel.dailyNote {
            case .loading:
                ProgressView()
            case let .finished(result):
                switch result {
                case let .success(note):
                    NoteView(account: account, note: note)
                case let .failure(error):
                    ErrorView(account: account, error: error)
                }
            }
        }
        .onAppear {
            Task {
                await dailyNoteViewModel.getDailyNote(account: account)
            }
        }
    }
}

// MARK: - NoteView

private struct NoteView: View {
    let account: Account
    let note: DailyNote

    var body: some View {
        Section {
            VStack {
                HStack {
                    Text("Stamina").bold()
                    Spacer()
                    let iconFrame: CGFloat = 30
                    Image("Item_Trailblaze_Power")
                        .resizable()
                        .scaledToFit()
                        .frame(height: iconFrame)
                    Text("\(note.staminaInformation.currentStamina)/\(note.staminaInformation.maxStamina)")
                }
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(note.staminaInformation.fullTime, style: .time)
                        Text(note.staminaInformation.fullTime, style: .relative)
                    }
                }
            }
            VStack {
                HStack {
                    Text("Expedition").bold()
                    Spacer()
                    Text(
                        "\(note.expeditionInformation.onGoingExpeditionNumber)/\(note.expeditionInformation.totalExpeditionNumber)"
                    )
                }
                ForEach(note.expeditionInformation.expeditions, id: \.name) { expedition in
                    HStack {
                        VStack(alignment: .leading) {
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
                            Text("\(expedition.name)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(expedition.finishedTime, style: .time)
                            Text(dateComponentsFormatter.string(from: expedition.remainingTime) ?? "")
                        }
                    }
                }
            }
        } header: {
            if let name = account.name {
                Text(name)
            }
        }
    }
}

// MARK: - ErrorView

private struct ErrorView: View {
    let account: Account
    let error: Error

    var body: some View {
        VStack {
            Text(account.name ?? "")
            Text(error.localizedDescription)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

private let dateComponentsFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 1
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
