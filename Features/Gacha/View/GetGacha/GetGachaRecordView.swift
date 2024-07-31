//
//  GetGachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import Charts
import Defaults
import DefaultsKeys
import EnkaSwiftUIViews
import Foundation
import HBMihoyoAPI
import SwiftUI

// MARK: - GetGachaRecordView

struct GetGachaRecordView: View {
    // MARK: Internal

    var status: GetGachaViewModel.Status {
        viewModel.status
    }

    var body: some View {
        List {
            switch viewModel.status {
            case .waitingForURL:
                WaitingForURLView { urlString in
                    try viewModel.load(urlString: urlString)
                }
            case let .pending(start: start, initialize: initialize):
                WaitingForStartView(start: start, initialize: initialize)
            case let .inProgress(cancel: cancel):
                InProgressView(cancel: cancel)
            case let .got(page: page, gachaType: gachaType, newItemCount: newItemCount, cancel: cancel):
                GotSomeItemView(page: page, gachaType: gachaType, newItemCount: newItemCount, cancel: cancel)
            case let .failFetching(page: page, gachaType: gachaType, error: error, retry: retry):
                FailFetchingView(page: page, gachaType: gachaType, error: error, retry: retry)
            case let .finished(typeFetchedCount: typeFetchedCount, initialize: initialize):
                FinishedView(typeFetchedCount: typeFetchedCount, initialize: initialize)
            }

            switch viewModel.status {
            case .failFetching, .finished, .got:
                Section {
                    GetGachaChart(data: $viewModel.gachaTypeDateCounts)
                }
            default:
                EmptyView()
            }

            if !viewModel.cachedItems.isEmpty {
                Section {
                    ForEach(viewModel.cachedItems.reversed(), id: \.id) { item in
                        GachaItemBar(item: item)
                    }
                } header: {
                    Text("app.gacha.get.running")
                }
            }
        }
        .inlineNavigationTitle("gacha.get_record.title")
    }

    // MARK: Private

    @StateObject private var viewModel: GetGachaViewModel = .init()
}

// MARK: - WaitingForURLView

private struct WaitingForURLView: View {
    // MARK: Internal

    let completion: (String) throws -> Void

    var body: some View {
        Section {
            Button {
                if let urlString = UIPasteboard.general.string {
                    do {
                        try completion(urlString)
                    } catch let error as ParseGachaURLError {
                        self.error = error
                        self.isErrorAlertShow.toggle()
                    } catch {
                        fatalError()
                    }
                } else {
                    isPasteBoardNoDataAlertShow.toggle()
                }
            } label: {
                Label("gacha.get_record.waiting_url.read_clipboard", systemSymbol: .docOnClipboard)
            }
            .alert(isPresented: $isErrorAlertShow, error: error) {
                Button("sys.ok") {
                    isErrorAlertShow.toggle()
                }
            }
        }
        Section {
            Section {
                Link(
                    "gacha.get_record.waiting_url.help.method1",
                    destination: URL(
                        string: "https://paimon.moe/wish/import"
                    )!
                )
            }
        } header: {
            Text("gacha.get_record.waiting_url.help.header")
        }
    }

    // MARK: Private

    @State private var error: ParseGachaURLError?
    @State private var isErrorAlertShow: Bool = false

    @State private var isPasteBoardNoDataAlertShow: Bool = false
}

// MARK: - WaitingForStartView

private struct WaitingForStartView: View {
    let start: () -> Void
    let initialize: () -> Void

    var body: some View {
        Button {
            start()
        } label: {
            Label("gacha.get_record.ready_start.start", systemSymbol: .playCircle)
        }
        Button {
            initialize()
        } label: {
            Label("gacha.get_record.ready_start.initialize", systemSymbol: .arrowClockwiseCircle)
        }
    }
}

// MARK: - InProgressView

private struct InProgressView: View {
    let cancel: () -> Void

    var body: some View {
        Section {
            Label {
                Text("gacha.get_record.in_progress.obtaining")
            } icon: {
                ProgressView().id(UUID())
            }
            Button {
                cancel()
            } label: {
                Label("gacha.get_record.in_progress.cancel", systemSymbol: .stopCircle)
            }
        }
    }
}

// MARK: - GotSomeItemView

private struct GotSomeItemView: View {
    let page: Int
    let gachaType: GachaType
    let newItemCount: Int
    let cancel: () -> Void

    var body: some View {
        Section {
            Label {
                Text("gacha.get_record.got_some.obtaining")
            } icon: {
                ProgressView().id(UUID())
            }
            Button {
                cancel()
            } label: {
                Label("sys.cancel", systemSymbol: .stopCircle)
            }
        } footer: {
            HStack {
                Text(String(format: "gacha.get_record.got_some.pool".localized(), gachaType.description))
                Spacer()
                Text(String(format: "gacha.get_record.got_some.page".localized(), page))
                Spacer()
                Text(String(format: "gacha.get_record.got_some.got_new_records".localized(), newItemCount))
            }
        }
    }
}

// MARK: - GachaItemBar

private struct GachaItemBar: View {
    let item: GachaItem

    @Default(.useRealCharacterNames) var useRealCharacterNames: Bool

    var body: some View {
        HStack {
            GachaItemIcon(item: item)
            HStack {
                item.localizedNameView(officialNameOnly: !useRealCharacterNames)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(item.rank.rawValue)
                        .font(.caption2)
                    Text(dateFormatter.string(from: item.time))
                        .foregroundColor(.secondary)
                        .font(.caption2)
                }
            }
        }
    }
}

// MARK: - FailFetchingView

struct FailFetchingView: View {
    let page: Int
    let gachaType: GachaType
    let error: Error
    let retry: () -> Void

    var body: some View {
        Label {
            Text(error.localizedDescription)
        } icon: {
            Image(systemSymbol: .exclamationmarkCircle)
                .foregroundColor(.red)
        }
        Button {
            retry()
        } label: {
            Label("gacha.get_record.fail_fetch.retry", systemSymbol: .arrowClockwiseCircle)
        }
    }
}

// MARK: - FinishedView

struct FinishedView: View {
    // MARK: Internal

    let typeFetchedCount: [GachaType: Int]
    let initialize: () -> Void

    var body: some View {
        Section {
            Label {
                Text("gacha.get_record.finished.succeeded")
            } icon: {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            Button {
                initialize()
            } label: {
                Label("gacha.get_record.finished.initialize", systemSymbol: .arrowClockwiseCircle)
            }
        } footer: {
            VStack(alignment: .leading) {
                Text("gacha.get_record.finished.new_record_count") + Text(newRecordCount)
            }
        }
    }

    // MARK: Private

    private var newRecordCount: String {
        typeFetchedCount.sorted(by: \.key).map { gachaType, count in
            "\(gachaType.description) - \(count); "
        }.reduce("", +)
    }
}

private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

// MARK: - GetGachaChart

private struct GetGachaChart: View {
    // MARK: Internal

    @Binding var data: [GetGachaViewModel.GachaTypeDateCount]

    var body: some View {
        Chart(data) {
            LineMark(
                x: .value("gacha.get_record.chart.date", $0.date),
                y: .value("gacha.get_record.chart.count", $0.count)
            )
            .foregroundStyle(by: .value("gacha.get_record.chart.gacha_type", $0.gachaType.description))
        }
        .chartForegroundStyleScale([
            GachaType.characterEventWarp.description: .blue,
            GachaType.lightConeEventWarp.description: .yellow,
            GachaType.stellarWarp.description: .green,
            GachaType.departureWarp.description: .cyan,
        ])
        .padding(.top)
    }

    // MARK: Private

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
