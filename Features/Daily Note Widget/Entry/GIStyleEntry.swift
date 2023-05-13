//
//  GIStyleEntry.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import HBMihoyoAPI
import SwiftUI
import WidgetKit

// MARK: - GIStyleEntry

struct GIStyleEntry: TimelineEntry {
    // MARK: Lifecycle

    init(
        date: Date,
        dailyNoteResult: Result<DailyNote, Error>,
        configuration: GIStyleWidgetConfiguration,
        expeditionWithUIImage: [(ExpeditionInformation.Expedition, [UIImage?])]
    ) {
        self.date = date
        self.dailyNoteResult = dailyNoteResult
        self.configuration = configuration
        self.expeditionWithUIImage = expeditionWithUIImage
    }

    // MARK: Internal

    let date: Date

    let configuration: GIStyleWidgetConfiguration

    let dailyNoteResult: Result<DailyNote, Error>

    let expeditionWithUIImage: [(ExpeditionInformation.Expedition, [UIImage?])]
}
