//
//  GetGachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import Charts
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
            case let .pending(start: start):
                WaitingForStartView(start: start)
            case let .inProgress(cancel: cancel):
                InProgressView(cancel: cancel)
            case let .got(page: page, gachaType: gachaType, cancel: cancel):
                GotSomeItemView(page: page, gachaType: gachaType, cancel: cancel)
            case let .failFetching(page: page, gachaType: gachaType, error: error, retry: retry):
                FailFetchingView(page: page, gachaType: gachaType, error: error, retry: retry)
            case let .finished(initialize: initialize):
                FinishedView(initialize: initialize)
            }

            switch viewModel.status {
            case .failFetching, .finished, .got, .inProgress:
                if #available(iOS 16.0, *) {
                    Section {
                        GetGachaChart(data: $viewModel.gachaTypeDateCounts)
                    }
                } else {
                    Section {
                        ForEach(viewModel.typeFetchedCount.sorted(by: \.key), id: \.key) { key, value in
                            HStack {
                                Text(key.rawValue)
                                Spacer()
                                Text("\(value)")
                            }
                        }
                    } header: {
                        Text("New items saved")
                    }
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
                    Text("Successfully obtained...")
                }
            }
        }
    }

    // MARK: Private

    @StateObject private var viewModel: GetGachaViewModel = .init()
}

// MARK: - WaitingForURLView

private struct WaitingForURLView: View {
    // MARK: Internal

    let completion: (String) throws -> ()

    var body: some View {
        Button("Read from clipboard") {
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
        }
        .alert(isPresented: $isErrorAlertShow, error: error) {
            Button("OK") {
                isErrorAlertShow.toggle()
            }
        }
    }

    // MARK: Private

    @State private var error: ParseGachaURLError?
    @State private var isErrorAlertShow: Bool = false

    @State private var isPasteBoardNoDataAlertShow: Bool = false
}

// MARK: - WaitingForStartView

private struct WaitingForStartView: View {
    let start: () -> ()

    var body: some View {
        Button("Start") {
            start()
        }
    }
}

// MARK: - InProgressView

private struct InProgressView: View {
    let cancel: () -> ()

    var body: some View {
        Button("cancel") {
            cancel()
        }
    }
}

// MARK: - GotSomeItemView

private struct GotSomeItemView: View {
    let page: Int
    let gachaType: GachaType
    let cancel: () -> ()

    var body: some View {
        Section {
            Text("Page: \(page)")
            Text("Gacha Type: \(gachaType.rawValue)")
            Button("cancel") {
                cancel()
            }
        }
    }
}

// MARK: - GachaItemBar

private struct GachaItemBar: View {
    let item: GachaItem

    var body: some View {
        HStack {
            ItemIcon(item: item)
            HStack {
                Text(item.localizedName)
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
    let retry: () -> ()

    var body: some View {
        Button("retry") {
            retry()
        }
        Text(error.localizedDescription)
    }
}

// MARK: - FinishedView

struct FinishedView: View {
    let initialize: () -> ()

    var body: some View {
        Button("Initialize") {
            initialize()
        }
    }
}

// MARK: - ParseGachaURLError + LocalizedError

extension ParseGachaURLError: LocalizedError {}

// MARK: - GachaError + LocalizedError

extension GachaError: LocalizedError {}

// MARK: - ItemIcon

private struct ItemIcon: View {
    let item: GachaItem

    var body: some View {
        Group {
            if let uiImage = item.icon {
                Image(uiImage: uiImage).resizable().scaledToFit()
            } else {
                Image(systemSymbol: .questionmarkCircle).resizable().scaledToFit()
            }
        }
        .background {
            Image(item.rank.backgroundKey)
                .scaledToFit()
                .scaleEffect(1.5)
                .offset(y: 3)
        }
        .clipShape(Circle())
        .contentShape(Circle())
        .frame(width: 35, height: 35)
    }
}

private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

// MARK: - GetGachaChart

@available(iOS 16.0, *)
private struct GetGachaChart: View {
    // MARK: Internal

    @Binding var data: [GetGachaViewModel.GachaTypeDateCount]

    var body: some View {
        Chart(data) {
            LineMark(
                x: .value("日期", $0.date),
                y: .value("抽数", $0.count)
            )
            .foregroundStyle(by: .value("祈愿类型", $0.gachaType.rawValue))
        }
        .chartForegroundStyleScale([
            GachaType.regularWarp.rawValue: .green,
            GachaType.characterEventWarp.rawValue: .blue,
            GachaType.lightConeEventWarp.rawValue: .yellow,
        ])
    }

    // MARK: Private

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
