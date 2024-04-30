//
//  GachaViewModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import Combine
import Foundation
import HBMihoyoAPI
import SwiftUI

/// The view model displaying current fetch gacha status.
@MainActor
class GetGachaViewModel: ObservableObject {
    // MARK: Internal

    struct GachaTypeDateCount: Hashable, Identifiable {
        let date: Date
        var count: Int
        let gachaType: GachaType

        var id: Int {
            hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(date)
            hasher.combine(gachaType)
        }
    }

    enum Status {
        case waitingForURL
        case pending(start: () -> Void, initialize: () -> Void)
        case inProgress(cancel: () -> Void)
        case got(page: Int, gachaType: GachaType, newItemCount: Int, cancel: () -> Void)
        case failFetching(page: Int, gachaType: GachaType, error: Error, retry: () -> Void)
        case finished(typeFetchedCount: [GachaType: Int], initialize: () -> Void)
    }

    @Published var savedTypeFetchedCount: [GachaType: Int] = Dictionary(
        uniqueKeysWithValues: GachaType.allCases
            .map { gachaType in
                (gachaType, 0)
            }
    )

    @Published var status: Status = .waitingForURL

    @Published var cachedItems: [GachaItem] = []

    @Published var gachaTypeDateCounts: [GetGachaViewModel.GachaTypeDateCount] = []

    func load(urlString: String) throws {
        try client = .init(gachaURLString: urlString)
        setPending()
    }

    func updateCachedItems(_ item: GachaItem) {
        if cachedItems.count > 20 {
            _ = cachedItems.removeFirst()
        }
        cachedItems.append(item)
    }

    func updateGachaDateCounts(_ item: GachaItem) {
        if gachaTypeDateCounts
            .filter({ ($0.date == item.time) && ($0.gachaType == item.gachaType) }).isEmpty {
            let count = GachaTypeDateCount(
                date: item.time,
                count: gachaTypeDateCounts.filter { data in
                    (data.date < item.time) && (data.gachaType == item.gachaType)
                }.map(\.count).sum(),
                gachaType: item.gachaType
            )
            gachaTypeDateCounts.append(count)
        }
        gachaTypeDateCounts.indices { element in
            (element.date >= item.time) && (element.gachaType == item.gachaType)
        }?.forEach { index in
            self.gachaTypeDateCounts[index].count += 1
        }
    }

    // MARK: Private

    private var client: GachaClient?
    private var cancellables: [AnyCancellable] = []

    private func setFinished() {
        DispatchQueue.main.async {
            withAnimation {
                self.status = .finished(typeFetchedCount: self.savedTypeFetchedCount, initialize: { self.initialize() })
            }
        }
    }

    private func setFailFetching(page: Int, gachaType: GachaType, error: Error) {
        DispatchQueue.main.async {
            withAnimation {
                self.status = .failFetching(
                    page: page,
                    gachaType: gachaType,
                    error: error,
                    retry: {
                        self.initialize()
                    }
                )
            }
        }
    }

    private func setGot(page: Int, gachaType: GachaType) {
        DispatchQueue.main.async { [self] in
            withAnimation {
                self.status = .got(
                    page: page,
                    gachaType: gachaType,
                    newItemCount: savedTypeFetchedCount.values.sum(),
                    cancel: {
                        self.cancel()
                    }
                )
            }
        }
    }

    private func setWaitingForURL() {
        DispatchQueue.main.async {
            withAnimation {
                self.status = .waitingForURL
            }
        }
    }

    private func setPending() {
        DispatchQueue.main.async {
            withAnimation {
                self.status = .pending(start: { self.startFetching() }, initialize: { self.initialize() })
            }
        }
    }

    private func setInProgress() {
        DispatchQueue.main.async {
            withAnimation {
                self.status = .inProgress(cancel: { self.cancel() })
            }
        }
    }

    private func insert(_ gachaItem: GachaItem) {
        let context = PersistenceController.shared.container.viewContext

        let request = GachaItemMO.fetchRequest()
        request.predicate = NSPredicate(format: "(id = %@) AND (uid = %@)", gachaItem.id, gachaItem.uid)
        if let duplicateItems = try? context.fetch(request),
           duplicateItems.isEmpty {
            let persistedItem = GachaItemMO(context: context)
            persistedItem.id = gachaItem.id
            persistedItem.count = Int32(gachaItem.count)
            persistedItem.gachaID = gachaItem.gachaID
            persistedItem.gachaType = gachaItem.gachaType
            persistedItem.itemID = gachaItem.itemID
            persistedItem.itemType = gachaItem.itemType
            persistedItem.language = gachaItem.lang
            persistedItem.name = gachaItem.name
            persistedItem.rank = gachaItem.rank
            persistedItem.time = gachaItem.time
            persistedItem.timeRawValue = gachaItem.timeRawValue
            persistedItem.uid = gachaItem.uid
            withAnimation {
                savedTypeFetchedCount[gachaItem.gachaType]! += 1
            }
        }
    }

    private func startFetching() {
        setInProgress()
        cancellables.append(client!.publisher.sink { [self] completion in
            switch completion {
            case .finished:
                setFinished()
            case let .failure(error):
                switch error {
                case let .fetchDataError(page: page, size: _, gachaType: gachaType, error: error):
                    setFailFetching(page: page, gachaType: gachaType, error: error)
                }
            }
        } receiveValue: { [self] gachaType, result in
            setGot(page: result.page, gachaType: gachaType)
            cancellables.append(
                Publishers.Zip(
                    result.list.publisher,
                    Timer.publish(
                        every: 0.5 / 20.0,
                        on: .main,
                        in: .default
                    )
                    .autoconnect()
                )
                .map(\.0)
                .sink(receiveCompletion: { _ in
                    let context = PersistenceController.shared.container.viewContext
                    try? context.save()
                }, receiveValue: { [self] item in
                    withAnimation {
                        self.updateCachedItems(item)
                        self.updateGachaDateCounts(item)
                    }
                    insert(item)
                })
            )

        })
        client?.start()
    }

    private func initialize() {
        client = nil
        setWaitingForURL()
        savedTypeFetchedCount = Dictionary(
            uniqueKeysWithValues: GachaType.allCases
                .map { gachaType in
                    (gachaType, 0)
                }
        )
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        cancellables = []
        cachedItems = []
        gachaTypeDateCounts = []
    }

    private func retry() {
        setPending()
        savedTypeFetchedCount = Dictionary(
            uniqueKeysWithValues: GachaType.allCases
                .map { gachaType in
                    (gachaType, 0)
                }
        )
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        cancellables = []
        cachedItems = []
        gachaTypeDateCounts = []
    }

    private func cancel() {
        client?.cancel()
    }
}
