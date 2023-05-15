//
//  DailyNoteEntry.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import HBMihoyoAPI
import WidgetKit

// MARK: - DailyNoteEntry

struct DailyNoteEntry: TimelineEntry {
    // MARK: Lifecycle

    init(
        date: Date,
        dailyNoteResult: Result<DailyNote, Error>,
        configuration: DailyNoteBackgroundWidgetConfiguration
    ) {
        self.date = date
        self.dailyNoteResult = dailyNoteResult
        self.configuration = configuration
    }

    // MARK: Internal

    let date: Date

    let configuration: DailyNoteBackgroundWidgetConfiguration

    let dailyNoteResult: Result<DailyNote, Error>
}

// MARK: - GetDailyNoteTimelineError

enum GetDailyNoteTimelineError: Error {
    case foundNoAccount
    case fetchDailyNoteError(MiHoYoAPIError)
}

// MARK: LocalizedError

extension GetDailyNoteTimelineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .foundNoAccount:
            return "widget.dailynote.timeline.error.noaccount".localized()
        case let .fetchDailyNoteError(error):
            return error.localizedDescription
        }
    }
}
