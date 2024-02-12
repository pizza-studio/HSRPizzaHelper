//
//  HSRDictionaryView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/30.
//

import AlertToast
import Combine
import SwiftUI

// MARK: - HSRDictionaryViewModel

private class HSRDictionaryViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.cancellable = debouncedSearchSubject
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main) // Adjust debounce time as needed
            .sink(receiveValue: { [weak self] query in
                guard let self else { return }
                // Perform search operation here with the debounced query
                guard query != "" else { return }
                self.nextPage = 1
                if case let .fetching(task) = queryStatus {
                    task.cancel()
                }
                self.currentResult = nil
                self.queryStatus = .fetching(Task(priority: .high) {
                    do {
                        let result = try await HSRDictionaryAPI.translation(query: query, page: 1, pageSize: 20)
                        DispatchQueue.main.async {
                            self.currentResult = result
                            self.queryStatus = .pending
                        }
                    } catch {
                        print(error)
                    }
                })
            })
    }

    // MARK: Internal

    @Published var queryStatus: QueryStatus = .pending
    var nextPage: Int = 1
    @Published var currentResult: CurrentResult?

    @Published var query: String = "" {
        didSet {
            debouncedSearchSubject.send(query)
        }
    }

    func fetchMore() {
        queryStatus = .fetching(Task(priority: .high) {
            do {
                let result = try await HSRDictionaryAPI.translation(
                    query: query,
                    page: nextPage,
                    pageSize: 20
                )
                DispatchQueue.main.async {
                    self.currentResult?.totalPage = result.totalPage
                    self.currentResult?.translations.append(contentsOf: result.translations)
                    self.queryStatus = .pending
                    self.nextPage += 1
                }
            } catch {
                print(error)
            }
        })
    }

    // MARK: Private

    private let debouncedSearchSubject = PassthroughSubject<String, Never>()
    private var cancellable: AnyCancellable?
}

private typealias CurrentResult = HSRDictionaryTranslationResult

// MARK: - QueryStatus

private enum QueryStatus {
    case pending
    case fetching(Task<(), Never>)
}

// MARK: - HSRDictionaryView

struct HSRDictionaryView: View {
    // MARK: Internal

    var body: some View {
        List {
            if let currentResult = viewModel.currentResult {
                if currentResult.translations.isEmpty {
                    Text("tool.dictionary.not_fount")
                } else {
                    ForEach(currentResult.translations) { translation in
                        NavigationLink {
                            DictionaryTranslationDetailView(translation: translation)
                        } label: {
                            HStack(alignment: .lastTextBaseline) {
                                Text(translation.target)
                                    .font(.headline)
                                    .lineLimit(1)
                                Spacer()
                                Text(translation.targetLanguage.rawValue)
                                    .font(.caption)
                            }
                        }
                    }
                    if viewModel.nextPage <= currentResult.totalPage,
                       case .pending = viewModel.queryStatus {
                        Button("tool.dictionary.fetch_more") {
                            viewModel.fetchMore()
                        }
                    }
                }
            }
            if case .fetching = viewModel.queryStatus {
                ProgressView().id(UUID())
            }
        }
        .inlineNavigationTitle("tool.dictionary.title")
        .searchable(
            text: $viewModel.query,
            prompt: "tool.dictionary.search.prompt"
        )
        .toolbar {
            Link(destination: URL(string: "https://hsrdict.pizzastudio.org/")!) {
                Image(systemSymbol: .safari)
            }
        }
    }

    // MARK: Private

    @StateObject private var viewModel: HSRDictionaryViewModel = .init()
}

// MARK: - DictionaryTranslationDetailView

private struct DictionaryTranslationDetailView: View {
    // MARK: Internal

    let translation: HSRDictionaryTranslationResult.Translation

    var body: some View {
        List {
            Section {
                Text(translation.target)
            } header: {
                Text("tool.dictionary.detail.target.header")
            } footer: {
                HStack {
                    Text(translation.targetLanguage.description)
                }
            }
            Section {
                ForEach(
                    translation.translationDictionary.map { ($0, $1) }.sorted(by: \.0.rawValue),
                    id: \.0
                ) { key, value in
                    Button {
                        UIPasteboard.general.string = value
                        isAlertShow.toggle()
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(key.description).font(.caption).foregroundColor(.gray)
                            Text(value).foregroundColor(.primary)
                        }
                    }
                }
            } header: {
                Text("tool.dictionary.detail.translations.header")
            } footer: {
                HStack { Spacer()
                    Text("\(translation.vocabularyId)")
                }
            }
        }
        .inlineNavigationTitle("tool.dictionary.detail.title")
        .alert("tool.dictionary.detail.copy_succeeded", isPresented: $isAlertShow) {
            Button("sys.ok") {
                isAlertShow.toggle()
            }
        }
    }

    // MARK: Private

    @State private var isAlertShow: Bool = false
}
