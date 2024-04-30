//
//  GIStyleTimelineProvider.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/13.
//

import Foundation
import HBMihoyoAPI
import Intents
import SwiftUI
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

// MARK: - GIStyleTimelineProvider

protocol GIStyleTimelineProvider: IntentTimelineProvider, HasDefaultAccount
    where Entry == GIStyleEntry, Intent: GIStyleWidgetConfigurationErasable {
    var defaultConfiguration: GIStyleWidgetConfiguration { get }
}

extension GIStyleTimelineProvider {
    var defaultConfiguration: GIStyleWidgetConfiguration {
        .init(
            account: defaultAccount,
            background: Intent.defaultBackground,
            backgroundFolderName: LargeSquareWidgetConfigurationIntent.backgroundFolderName,
            textColor: .white,
            showAccountName: true,
            showExpedition: true
        )
    }
}

extension GIStyleTimelineProvider {
    func placeholder(in context: Context) -> GIStyleEntry {
        var expeditionWithUIImage: [(ExpeditionInformation.Expedition, [UIImage?])] = []
        expeditionWithUIImage = GeneralDailyNote.example().expeditionInformation.expeditions.map { expedition in
            var images: [UIImage?] = []
            expedition.avatarIconURLs.forEach { url in
                if let data = try? Data(contentsOf: url) {
                    images.append(UIImage(data: data))
                }
            }
            return (expedition, images)
        }
        return .init(
            date: Date(),
            dailyNoteResult: .success(GeneralDailyNote.example()),
            configuration: defaultConfiguration,
            expeditionWithUIImage: expeditionWithUIImage
        )
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (GIStyleEntry) -> Void) {
        var expeditionWithUIImage: [(ExpeditionInformation.Expedition, [UIImage?])] = []
        expeditionWithUIImage = GeneralDailyNote.example().expeditionInformation.expeditions.map { expedition in
            var images: [UIImage?] = []
            expedition.avatarIconURLs.forEach { url in
                if let data = try? Data(contentsOf: url) {
                    images.append(UIImage(data: data))
                }
            }
            return (expedition, images)
        }
        completion(
            .init(
                date: Date(),
                dailyNoteResult: .success(GeneralDailyNote.example()),
                configuration: defaultConfiguration,
                expeditionWithUIImage: expeditionWithUIImage
            )
        )
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<GIStyleEntry>) -> Void
    ) {
        Task {
            var entries: [Entry] = []

            let account = configuration
                .eraseToGIStyleWidgetConfiguration()
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
    )
        -> [Entry] {
        var expeditionWithUIImage: [(ExpeditionInformation.Expedition, [UIImage?])] = []
        if case let .success(dailyNote) = dailyNoteResult {
            var entries: [GIStyleEntry] = []
            switch dailyNoteResult {
            case let .success(dailyNote):
                expeditionWithUIImage = dailyNote.expeditionInformation.expeditions.map { expedition in
                    var images: [UIImage?] = []
                    expedition.avatarIconURLs.forEach { url in
                        if let data = try? Data(contentsOf: url) {
                            images.append(UIImage(data: data))
                        }
                    }
                    return (expedition, images)
                }
            case .failure:
                expeditionWithUIImage = []
            }
            entries.append(
                Entry(
                    date: Date(),
                    dailyNoteResult: dailyNoteResult,
                    configuration: configuration.eraseToGIStyleWidgetConfiguration(),
                    expeditionWithUIImage: expeditionWithUIImage
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
                        configuration: configuration.eraseToGIStyleWidgetConfiguration(),
                        expeditionWithUIImage: expeditionWithUIImage
                    )
                )
                loopNextTime = dailyNote.staminaInformation.nextStaminaTime
                dailyNote = dailyNote.replacingBenchmarkTime(nextTime)
                expeditionWithUIImage = expeditionWithUIImage.map { expedition, images in
                    (
                        expedition.replacingBenchmarkTime(nextTime), images
                    )
                }
            }
            return entries
        } else {
            return [
                Entry(
                    date: Date(),
                    dailyNoteResult: dailyNoteResult,
                    configuration: configuration.eraseToGIStyleWidgetConfiguration(),
                    expeditionWithUIImage: expeditionWithUIImage
                ),
            ]
        }
    }
}
