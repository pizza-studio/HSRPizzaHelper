//
//  InAppDailyNoteCardView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Combine
import Foundation
import HBMihoyoAPI
import SwiftUI

// MARK: - InAppDailyNoteCardView

struct InAppDailyNoteCardView: View {
    @StateObject private var dailyNoteViewModel: DailyNoteViewModel = .init()

    let account: Account

    let refreshSubject: PassthroughSubject<(), Never>

    var body: some View {
        Section {
            switch dailyNoteViewModel.dailyNote {
            case .loading, .pending:
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
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
        .onAppear {
            Task {
                await dailyNoteViewModel.getDailyNote(account: account)
            }
        }
        .onReceive(refreshSubject, perform: { _ in
            Task {
                await dailyNoteViewModel.getDailyNoteUncheck(account: account)
            }
        })
    }
}

// MARK: - NoteView

private struct NoteView: View {
    let account: Account
    let note: DailyNote
    @State
    var isDispatchDetailShow = false

    var body: some View {
        Section {
            VStack {
                HStack {
                    Text("sys.label.trailblaze").bold()
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    let iconFrame: CGFloat = 30
                    Image("Item_Trailblaze_Power")
                        .resizable()
                        .scaledToFit()
                        .frame(height: iconFrame)
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("\(note.staminaInformation.currentStamina)")
                            .font(.title)
                        + Text("/\(note.staminaInformation.maxStamina)")
                            .font(.caption)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(expedition.finishedTime, style: .time)
                        Text(dateComponentsFormatter.string(from: expedition.remainingTime) ?? "")
                    }
                    .font(.caption2)
                }
            }
            VStack {
                HStack {
                    Text("sys.label.dispatch").bold()
                    Spacer()
                    let onGoingExpeditionNumber = note.expeditionInformation.onGoingExpeditionNumber
                    let totalExpeditionNumber = note.expeditionInformation.totalExpeditionNumber
                    Text("\(onGoingExpeditionNumber)/\(totalExpeditionNumber)")
                }
                .onTapGesture {
                    withAnimation(.linear) {
                        isDispatchDetailShow.toggle()
                    }
                }
            }
            if isDispatchDetailShow {
                VStack {
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
                        .onTapGesture {
                            withAnimation(.linear) {
                                isDispatchDetailShow.toggle()
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
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
    // MARK: Internal

    let account: Account
    let error: Error

    var body: some View {
        HStack {
            Spacer()
            Image(systemSymbol: .exclamationmarkCircle)
                .foregroundColor(.red)
            Spacer()
        }
        .onTapGesture {
            isEditAccountSheetShown.toggle()
        }
        .sheet(isPresented: $isEditAccountSheetShown) {
            CreateAccountSheetView(account: account, isShown: $isEditAccountSheetShown)
        }
    }

    // MARK: Private

    @State private var isEditAccountSheetShown: Bool = false
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
