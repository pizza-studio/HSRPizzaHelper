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
        case pending(start: () -> ())
        case inProgress(cancel: () -> ())
        case got(page: Int, gachaType: GachaType, cancel: () -> ())
        case failFetching(page: Int, gachaType: GachaType, error: Error, retry: () -> ())
        case finished(initialize: () -> ())
    }

    @Published var typeFetchedCount: [GachaType: Int] = Dictionary(
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
        DispatchQueue.main.async { [self] in
            status = .pending(start: { self.startFetching() })
        }
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
            persistedItem.uid = gachaItem.uid
            withAnimation {
                typeFetchedCount[gachaItem.gachaType]! += 1
            }
        }
    }

    private func startFetching() {
        status = .inProgress(cancel: { self.cancel() })
        cancellables.append(client!.publisher.sink { [self] completion in
            switch completion {
            case .finished:
                DispatchQueue.main.async {
                    self.status = .finished(initialize: { DispatchQueue.main.async { self.initialize() } })
                }
            case let .failure(error):
                switch error {
                case let .fetchDataError(page: page, size: _, gachaType: gachaType, error: error):
                    DispatchQueue.main.async {
                        self.status = .failFetching(
                            page: page,
                            gachaType: gachaType,
                            error: error,
                            retry: {
                                DispatchQueue.main.async {
                                    self.initialize()
                                }
                            }
                        )
                    }
                }
            }
        } receiveValue: { [self] gachaType, result in
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
            DispatchQueue.main.async {
                self.status = .got(page: result.page, gachaType: gachaType, cancel: {
                    DispatchQueue.main.async {
                        self.cancel()
                    }
                })
            }
        })
        client?.start()
    }

    private func initialize() {
        client = nil
        status = .waitingForURL
        typeFetchedCount = Dictionary(
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
