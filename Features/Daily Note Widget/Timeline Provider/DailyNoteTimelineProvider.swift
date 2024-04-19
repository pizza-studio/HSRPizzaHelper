//
//  DailyNoteTimelineProvider.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/7.
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

// MARK: - DailyNoteTimelineProvider

protocol DailyNoteTimelineProvider: IntentTimelineProvider, HasDefaultAccount
    where Entry == DailyNoteEntry, Intent: DailyNoteWidgetConfigurationErasable {
    var defaultConfiguration: DailyNoteBackgroundWidgetConfiguration { get }
}

extension DailyNoteTimelineProvider {
    var defaultConfiguration: DailyNoteBackgroundWidgetConfiguration {
        .init(
            account: defaultAccount,
            background: Intent.defaultBackground,
            backgroundFolderName: LargeSquareWidgetConfigurationIntent.backgroundFolderName,
            useAccessibilityBackground: true,
            textColor: .primary,
            staminaPosition: .left,
            showAccountName: true
        )
    }
}

extension DailyNoteTimelineProvider {
    func placeholder(in context: Context) -> DailyNoteEntry {
        .init(
            date: Date(),
            dailyNoteResult: .success(GeneralDailyNote.example()),
            configuration: defaultConfiguration
        )
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (DailyNoteEntry) -> Void) {
        completion(
            .init(
                date: Date(),
                dailyNoteResult: .success(GeneralDailyNote.example()),
                configuration: defaultConfiguration
            )
        )
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<DailyNoteEntry>) -> Void
    ) {
        Task {
            var entries: [Entry] = []

            let account = configuration
                .eraseToDailyNoteWidgetConfiguration()
                .account

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
            var entries: [DailyNoteEntry] = []
            entries.append(
                Entry(
                    date: Date(),
                    dailyNoteResult: dailyNoteResult,
                    configuration: configuration.eraseToDailyNoteWidgetConfiguration()
                )
            )

            let refreshTime = Date(timeIntervalSinceNow: refreshWhenSucceedAfterSecond)

            var dailyNote = dailyNote
            var loopNextTime = dailyNote.staminaInformation.nextStaminaTime
            while let nextTime = loopNextTime, nextTime < refreshTime {
                entries.append(
                    Entry(
                        date: nextTime,
                        dailyNoteResult: .success(
                            dailyNote
                        ),
                        configuration: configuration.eraseToDailyNoteWidgetConfiguration()
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
                    dailyNoteResult: dailyNoteResult,
                    configuration: configuration.eraseToDailyNoteWidgetConfiguration()
                ),
            ]
        }
    }
}
