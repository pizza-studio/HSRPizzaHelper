//
//  DailyNoteViewModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI

class DailyNoteViewModel: ObservableObject {
    @Published var dailyNote: FetchStatus<DailyNote> = .loading

    func getDailyNote(account: Account) async {
        if case .finished(.success(let note)) = dailyNote {
            if Date().timeIntervalSince(note.fetchTime) > 60 * 3 {
                await getDailyNoteUncheck(account: account)
            }
        } else {
            await getDailyNoteUncheck(account: account)
        }
    }

    @MainActor
    func getDailyNoteUncheck(account: Account) async {
        do {
            dailyNote = .finished(
                .success(
                    try await MiHoYoAPI.note(
                        server: account.server,
                        uid: account.uid ?? "",
                        cookie: account.cookie ?? ""
                    )
                )
            )
        } catch {
            dailyNote = .finished(.failure(error))
        }
    }
}
