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
    @StateObject
    var dailyNoteViewModel: DailyNoteViewModel = .init()

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
            Text(account.name!)
            HStack {
                Text("current_stamina")
                Spacer()
                Text("\(note.staminaInformation.currentStamina)")
            }
            HStack {
                Text("max_stamina")
                Spacer()
                Text("\(note.staminaInformation.maxStamina)")
            }
            HStack {
                Text("stamina_recover_time")
                Spacer()
                Text("\(note.staminaInformation.staminaRecoverTime)")
            }
            HStack {
                Text("acceptedExpeditionNumber")
                Spacer()
                Text("\(note.expeditionInformation.acceptedExpeditionNumber)")
            }
            HStack {
                Text("totalExpeditionNumber")
                Spacer()
                Text("\(note.expeditionInformation.totalExpeditionNumber)")
            }
            ForEach(note.expeditionInformation.expeditions, id: \.name) { expedition in
                VStack {
                    HStack {
                        Text("\(expedition.name)")
                        Spacer()
                        HStack {
                            ForEach(expedition.avatarIconURLs, id: \.self) { url in
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFit()
                                        .frame(height: 25)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    HStack {
                        Text("\(expedition.status.rawValue)")
                        Spacer()
                        Text("\(expedition.remainingTime)")
                    }
                }
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
