//
//  DailyNoteViewModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI
import SwiftUI

/// A view model for fetching a daily note for a specific account.
class DailyNoteViewModel: ObservableObject {
    // MARK: Lifecycle

    /// Initializes a new instance of the view model.
    ///
    /// - Parameter account: The account for which the daily note will be fetched.
    init(account: Account) {
        self.account = account
        Task {
            await getDailyNoteUncheck()
        }
    }

    // MARK: Internal

    /// The current daily note.
    @Published private(set) var dailyNote: FetchStatus<DailyNote> = .pending

    /// The account for which the daily note is being fetched.
    let account: Account

    /// Fetches the daily note and updates the published `dailyNote` property accordingly.
    func getDailyNote() async {
        if case let .finished(.success(note)) = dailyNote {
            // check if note is older than 15 minutes
            let shouldUpdateAfterMinute: Double = 15
            let shouldUpdateAfterSecond = 60.0 * shouldUpdateAfterMinute

            if Date().timeIntervalSince(note.fetchTime) > shouldUpdateAfterSecond {
                await getDailyNoteUncheck()
            }
        } else if case .loading = dailyNote {
            return // another operation is already in progress
        } else {
            await getDailyNoteUncheck()
        }
    }

    /// Asynchronously fetches the daily note using the MiHoYoAPI with the account information it was initialized with.
    @MainActor
    func getDailyNoteUncheck() async {
        dailyNote = .loading
        do {
            let data = try await MiHoYoAPI.note(
                server: account.server,
                uid: account.uid ?? "",
                cookie: account.cookie ?? "",
                deviceFingerPrint: account.deviceFingerPrint
            )
            #if !os(watchOS)
            HSRNotificationCenter.scheduleNotification(for: account, dailyNote: data)
            #endif
            withAnimation {
                dailyNote = .finished(.success(data))
            }
        } catch {
            withAnimation {
                dailyNote = .finished(.failure(error))
            }
        }
    }
}
