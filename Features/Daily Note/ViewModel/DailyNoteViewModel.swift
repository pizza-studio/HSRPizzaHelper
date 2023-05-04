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
        if case let .finished(.success(note)) = dailyNote {
            let shouldUpdateAfterMinute = 3.0
            let secondOfMinute = 60.0
            let shouldUpdateAfterSecond = secondOfMinute * shouldUpdateAfterMinute
            if Date().timeIntervalSince(note.fetchTime) > shouldUpdateAfterSecond {
                await getDailyNoteUncheck(account: account)
            }
        } else {
            await getDailyNoteUncheck(account: account)
        }
    }

    @MainActor
    func getDailyNoteUncheck(account: Account) async {
        do {
            dailyNote = try .finished(
                .success(
                    await MiHoYoAPI.note(
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
