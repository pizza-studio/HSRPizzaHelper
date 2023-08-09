//
//  GetGachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import Foundation
import HBMihoyoAPI
import SwiftUI

// MARK: - GetGachaRecordView

struct GetGachaRecordView: View {
    @StateObject var viewModel: GachaViewModel = .init()

    var status: GachaViewModel.Status {
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
            case let .got(page: page, gachaType: gachaType, items: items, cancel: cancel):
                GotSomeItemView(page: page, gachaType: gachaType, items: items, cancel: cancel)
            case let .failFetching(page: page, gachaType: gachaType, error: error, retry: retry):
                FailFetchingView(page: page, gachaType: gachaType, error: error, retry: retry)
            case let .finished(initialize: initialize):
                FinishedView(initialize: initialize)
            }
        }
    }
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
    let items: [GachaItem]
    let cancel: () -> ()

    var body: some View {
        Section {
            Text("Page: \(page)")
            Text("Gacha Type: \(gachaType.rawValue)")
            Button("cancel") {
                cancel()
            }
        }
        ForEach(items, id: \.id) { item in
            Text(item.id)
            Text(item.name)
        }
    }
}

// MARK: - FailFetchingView

struct FailFetchingView: View {
    let page: Int
    let gachaType: GachaType
    let error: LocalizedError
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
