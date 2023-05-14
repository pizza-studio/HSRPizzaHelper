//
//  LockscreenEntry.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/14.
//

import Foundation
import HBMihoyoAPI
import SwiftUI
import WidgetKit

// MARK: - GIStyleEntry

struct LockscreenEntry: TimelineEntry {
    let date: Date

    let configuration: LockscreenWidgetConfigurationIntent

    let dailyNoteResult: Result<DailyNote, Error>
}
