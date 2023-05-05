//
//  DailyNoteViewModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI
import SwiftUI

class DailyNoteViewModel: ObservableObject {
    // MARK: Lifecycle

    init(account: Account) {
        self.account = account
    }

    // MARK: Internal

    @Published private(set) var dailyNote: FetchStatus<DailyNote> = .pending

    let account: Account

    func getDailyNote() async {
        if case let .finished(.success(note)) = dailyNote {
            let shouldUpdateAfterMinute: Double = 15
            let shouldUpdateAfterSecond = 60.0 * shouldUpdateAfterMinute
            if Date().timeIntervalSince(note.fetchTime) > shouldUpdateAfterSecond {
                await getDailyNoteUncheck()
            }
        } else if case .loading = dailyNote {
            return
        } else {
            await getDailyNoteUncheck()
        }
    }

    @MainActor
    func getDailyNoteUncheck() async {
        dailyNote = .loading
        do {
            let data = try await MiHoYoAPI.note(
                server: account.server,
                uid: account.uid ?? "",
                cookie: account.cookie ?? ""
            )
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
