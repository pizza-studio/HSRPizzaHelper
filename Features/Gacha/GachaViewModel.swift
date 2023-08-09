//
//  GachaViewModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import Combine
import Foundation
import HBMihoyoAPI

/// The view model displaying current fetch gacha status.
@MainActor
class GachaViewModel: ObservableObject {
    // MARK: Internal

    enum Status {
        case waitingForURL
        case pending(start: () -> ())
        case inProgress(cancel: () -> ())
        case got(page: Int, gachaType: GachaType, items: [GachaItem], cancel: () -> ())
        case failFetching(page: Int, gachaType: GachaType, error: LocalizedError, retry: () -> ())
        case finished(initialize: () -> ())
    }

    @Published var itemFetchedCount: [GachaType: Int] = Dictionary(
        uniqueKeysWithValues: GachaType.allCases
            .map { gachaType in
                (gachaType, 0)
            }
    )

    @Published var status: Status = .waitingForURL

    func load(urlString: String) throws {
        try client = .init(gachaURLString: urlString)
        status = .pending(start: { self.startFetching() })
    }

    // MARK: Private

    private var client: GachaClient?
    private var cancellable: AnyCancellable?

    private func insert(_ gachaItem: GachaItem) {
        let context = PersistenceController.shared.container.viewContext
        let persistedItem = GachaItemMO(context: context)
        persistedItem.id = gachaItem.id
        persistedItem.count = Int32(gachaItem.count)
        persistedItem.gachaID = gachaItem.gachaID
        persistedItem.gachaType = gachaItem.gachaType
        persistedItem.itemID = gachaItem.itemID
        persistedItem.itemType = gachaItem.itemType
        persistedItem.lang = gachaItem.lang
        persistedItem.name = gachaItem.name
        persistedItem.rank = gachaItem.rank
        persistedItem.time = gachaItem.time
        persistedItem.uid = gachaItem.uid
    }

    private func startFetching() {
        status = .inProgress(cancel: { self.cancel() })
        cancellable = client!.publisher.sink { [self] completion in
            switch completion {
            case .finished:
                status = .finished(initialize: {})
            case let .failure(error):
                switch error {
                case let .fetchDataError(page: page, size: _, gachaType: gachaType, error: error):
                    DispatchQueue.main.async { [self] in
                        print(error)
                        status = .failFetching(
                            page: page,
                            gachaType: gachaType,
                            // swiftlint:disable:next force_cast
                            error: error as! LocalizedError,
                            retry: {
                                self.initialize()
                            }
                        )
                    }
                }
            }
        } receiveValue: { [self] gachaType, result in
            DispatchQueue.main.async { [self] in
                status = .got(page: result.page, gachaType: gachaType, items: result.list, cancel: { self.cancel() })
            }
            result.list.forEach { item in
                insert(item)
            }
        }

        client?.start()
    }

    private func initialize() {
        client = nil
        status = .waitingForURL
        itemFetchedCount = Dictionary(
            uniqueKeysWithValues: GachaType.allCases
                .map { gachaType in
                    (gachaType, 0)
                }
        )
        cancellable = nil
    }

    private func cancel() {
        client?.cancel()
    }
}
