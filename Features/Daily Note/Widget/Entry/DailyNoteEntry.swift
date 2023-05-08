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
        configuration: DailyNoteWidgetConfiguration
    ) {
        self.date = date
        self.dailyNoteResult = dailyNoteResult
        self.configuration = configuration
    }

    // MARK: Internal

    let date: Date

    let configuration: DailyNoteWidgetConfiguration

    let dailyNoteResult: Result<DailyNote, Error>
}

// MARK: - GetDailyNoteTimelineError

enum GetDailyNoteTimelineError: Error {
    case foundNoAccount
    case fetchDailyNoteError(MiHoYoAPIError)
}
