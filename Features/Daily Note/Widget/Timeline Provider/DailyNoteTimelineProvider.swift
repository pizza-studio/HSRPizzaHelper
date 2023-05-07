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

protocol DailyNoteTimelineProvider: IntentTimelineProvider & HasDefaultAccount & HasDefaultBackground
    where Entry == DailyNoteEntry, Intent: DailyNoteWidgetConfigurationErasable {
    var defaultConfiguration: DailyNoteWidgetConfiguration { get }
}

extension DailyNoteTimelineProvider {
    var defaultConfiguration: DailyNoteWidgetConfiguration {
        .init(
            account: defaultAccount,
            background: .useSpecificBackgrounds([defaultBackground])
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
            if let account = intentAccount {
                let dailyNoteResult = await getDailyNote(account: account)
                entries.append(
                    getEntry(dailyNoteResult: dailyNoteResult)
                )
            } else {
                entries.append(
                    getEntry(
                        dailyNoteResult: .failure(GetDailyNoteTimelineError.foundNoAccount)
                    )
                )
            }

            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)

            func getEntry(dailyNoteResult: Result<DailyNote, Error>) -> Entry {
                Entry(
                    date: Date(),
                    dailyNoteResult: dailyNoteResult,
                    configuration: configuration.eraseToDailyNoteWidgetConfiguration()
                )
            }
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
}

// MARK: - HasDefaultAccount

protocol HasDefaultAccount {
    var defaultAccount: IntentAccount { get }
}

extension HasDefaultAccount {
    var defaultAccount: IntentAccount {
        let intentAccount = IntentAccount(
            identifier: UUID().uuidString,
            display: "Lava"
        )
        intentAccount.cookie = ""
        intentAccount.server = .china
        intentAccount.uid = "118774161"
        return intentAccount
    }
}

// MARK: - HasDefaultBackground

protocol HasDefaultBackground {
    var defaultBackground: WidgetBackground { get }
}
