//
//  LockscreenTimelineProvider.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/14.
//

import Foundation
import HBMihoyoAPI
import Intents
import WidgetKit

// MARK: - DailyNoteTimelineProvider

private var refreshWhenSucceedAfterHour: Double {
    AppConfig.widgetRefreshFrequencyInHour
}

private var refreshWhenSucceedAfterSecond = refreshWhenSucceedAfterHour * 60 * 60

private var refreshWhenErrorMinute: Int {
    AppConfig.widgetRefreshWhenErrorMinute
}

private var refreshWhenErrorAfterSecond = TimeInterval(refreshWhenErrorMinute * 60)

// MARK: - LockscreenTimelineProvider

struct LockscreenTimelineProvider: IntentTimelineProvider, HasDefaultAccount {
    // MARK: Internal

    typealias Entry = LockscreenEntry
    typealias Intent = LockscreenWidgetConfigurationIntent

    var defaultConfiguration: LockscreenWidgetConfigurationIntent {
        let defaultIntent = LockscreenWidgetConfigurationIntent()
        defaultIntent.account = defaultAccount
        return defaultIntent
    }

    func placeholder(in context: Context) -> LockscreenEntry {
        .init(
            date: Date(),
            configuration: defaultConfiguration,
            dailyNoteResult: .success(GeneralDailyNote.example())
        )
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (LockscreenEntry) -> ()) {
        completion(
            .init(
                date: Date(),
                configuration: defaultConfiguration,
                dailyNoteResult: .success(GeneralDailyNote.example())
            )
        )
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<LockscreenEntry>) -> ()
    ) {
        Task {
            var entries: [Entry] = []

            let account: Account? = {
                if let account = configuration.account?.toAccount() {
                    return account
                } else if let account = IntentAccountProvider.getFirstAccount() {
                    return account
                } else {
                    return nil
                }
            }()

            let dailyNoteResult: Result<DailyNote, Error>
            if let account {
                dailyNoteResult = await getDailyNote(account: account)
            } else {
                dailyNoteResult = .failure(GetDailyNoteTimelineError.foundNoAccount)
            }
            entries.append(
                contentsOf: getEntries(dailyNoteResult: dailyNoteResult, configuration: configuration)
            )

            let refreshTimeInterval: TimeInterval
            switch dailyNoteResult {
            case .success:
                refreshTimeInterval = refreshWhenSucceedAfterSecond
            case .failure:
                refreshTimeInterval = refreshWhenErrorAfterSecond
            }
            let timeline = Timeline(
                entries: entries,
                policy: .after(Date(timeIntervalSinceNow: refreshTimeInterval))
            )
            completion(timeline)
        }
    }

    // MARK: Private

    private func getDailyNote(account: Account) async -> Result<DailyNote, Error> {
        do {
            let dailyNote = try await MiHoYoAPI.note(
                server: account.server,
                uid: account.uid ?? "",
                cookie: account.cookie ?? "",
                deviceFingerPrint: account.deviceFingerPrint
            )
            HSRNotificationCenter.scheduleNotification(for: account, dailyNote: dailyNote)
            return .success(dailyNote)
        } catch {
            return .failure(error)
        }
    }

    private func getEntries(
        dailyNoteResult: Result<DailyNote, Error>,
        configuration: Intent
    ) -> [Entry] {
        if case let .success(dailyNote) = dailyNoteResult {
            var entries: [LockscreenEntry] = []
            entries.append(
                Entry(
                    date: Date(),
                    configuration: configuration,
                    dailyNoteResult: dailyNoteResult
                )
            )

            let refreshTime = Date(timeIntervalSinceNow: refreshWhenSucceedAfterSecond)

            var dailyNote = dailyNote
            var loopNextTime = dailyNote.staminaInformation.nextStaminaTime
            while let nextTime = loopNextTime, nextTime < refreshTime {
                entries.append(
                    Entry(
                        date: nextTime,
                        configuration: configuration,
                        dailyNoteResult: .success(
                            dailyNote
                        )
                    )
                )
                loopNextTime = dailyNote.staminaInformation.nextStaminaTime
                dailyNote = dailyNote.replacingBenchmarkTime(nextTime)
            }
            return entries
        } else {
            return [
                Entry(
                    date: Date(),
                    configuration: configuration,
                    dailyNoteResult: dailyNoteResult
                ),
            ]
        }
    }
}
