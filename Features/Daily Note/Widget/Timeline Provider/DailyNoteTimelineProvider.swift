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

private let refreshWhenSucceedAfterHour: Int = 5
private var refreshWhenSucceedAfterSecond = TimeInterval(refreshWhenSucceedAfterHour * 60 * 60)

private let refreshWhenErrorMinute: Int = 5
private var refreshWhenErrorAfterSecond = TimeInterval(refreshWhenErrorMinute * 60)

// MARK: - DailyNoteTimelineProvider

protocol DailyNoteTimelineProvider: IntentTimelineProvider, HasDefaultAccount
    where Entry == DailyNoteEntry, Intent: DailyNoteWidgetConfigurationErasable {
    var defaultConfiguration: DailyNoteWidgetConfiguration { get }
}

extension DailyNoteTimelineProvider {
    var defaultConfiguration: DailyNoteWidgetConfiguration {
        .init(
            account: defaultAccount,
            background: Intent.defaultBackground,
            backgroundFolderName: SquareWidgetConfigurationIntent.backgroundFolderName
        )
    }
}

extension DailyNoteTimelineProvider {
    func placeholder(in context: Context) -> DailyNoteEntry {
        .init(
            date: Date(),
            dailyNoteResult: .success(.example()),
            configuration: defaultConfiguration
        )
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (DailyNoteEntry) -> ()) {
        completion(
            .init(
                date: Date(),
                dailyNoteResult: .success(.example()),
                configuration: defaultConfiguration
            )
        )
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<DailyNoteEntry>) -> ()
    ) {
        Task {
            var entries: [Entry] = []

            let intentAccount = configuration
                .eraseToDailyNoteWidgetConfiguration()
                .account

            let dailyNoteResult: Result<DailyNote, Error>
            if let account = intentAccount {
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

    private func getDailyNote(account: IntentAccount) async -> Result<DailyNote, Error> {
        do {
            let dailyNote = try await MiHoYoAPI.note(
                server: account.server,
                uid: account.uid ?? "",
                cookie: account.cookie ?? ""
            )
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
            var nextTime = dailyNote.staminaInformation.nextStaminaTime
            while nextTime < refreshTime {
                entries.append(
                    Entry(
                        date: nextTime,
                        dailyNoteResult: .success(
                            dailyNote
                        ),
                        configuration: configuration.eraseToDailyNoteWidgetConfiguration()
                    )
                )
                nextTime = dailyNote.staminaInformation.nextStaminaTime
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
