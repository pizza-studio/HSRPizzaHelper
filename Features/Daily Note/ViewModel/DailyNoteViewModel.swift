//
//  DailyNoteViewModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI
import SwiftUI

@MainActor
class DailyNoteViewModel: ObservableObject {
    @Published var dailyNote: FetchStatus<DailyNote> = .pending

    func getDailyNote(account: Account) async {
        if case let .finished(.success(note)) = dailyNote {
            let shouldUpdateAfterMinute: Double = 3
            let shouldUpdateAfterSecond = 60.0 * shouldUpdateAfterMinute
            if Date().timeIntervalSince(note.fetchTime) > shouldUpdateAfterSecond {
                await getDailyNoteUncheck(account: account)
            }
        } else if case .loading = dailyNote {
            return
        } else {
            await getDailyNoteUncheck(account: account)
        }
    }

    @MainActor
    func getDailyNoteUncheck(account: Account) async {
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
