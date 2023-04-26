//
//  AccountModel.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  Account所需的所有信息

import Foundation
import HBMihoyoAPI

// MARK: - Account

struct Account: Equatable, Hashable {
    // MARK: Lifecycle

    init(config: AccountConfiguration) {
        self.config = config
    }

    // MARK: Internal

    var config: AccountConfiguration

    // 树脂等信息
    var result: FetchResult?
//    var background: WidgetBackground = .randomNamecardBackground
    var basicInfo: BasicInfos?
    var fetchComplete: Bool = false

    #if !os(watchOS)
//    var playerDetailResult: Result<
//        PlayerDetail,
//        PlayerDetail.PlayerDetailError
//    >?
//    var fetchPlayerDetailComplete: Bool = false

    // 深渊
    var spiralAbyssDetail: AccountSpiralAbyssDetail?
    // 账簿，旅行札记
    var ledgeDataResult: LedgerDataFetchResult?
    #endif

    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.config == rhs.config
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(config)
    }
}

extension AccountConfiguration {
    func fetchResult(_ completion: @escaping (FetchResult) -> ()) {
        guard (uid != nil) || (cookie != nil)
        else { completion(.failure(.noFetchInfo)); return }

        MihoyoAPI.fetchInfos(
            region: server.region,
            serverID: server.id,
            uid: uid!,
            cookie: cookie!
        ) { result in
            completion(result)
            #if !os(watchOS)
            switch result {
            case let .success(data):
                UserNotificationCenter.shared.createAllNotification(
                    for: self.name!,
                    with: data,
                    uid: self.uid!
                )
                #if canImport(ActivityKit)
//                if #available(iOS 16.1, *) {
//                    ResinRecoveryActivityController.shared
//                        .updateResinRecoveryTimerActivity(
//                            for: self,
//                            using: result
//                        )
//                }
                #endif
            case .failure:
                break
            }
            #endif
        }
    }

    func fetchSimplifiedResult(
        _ completion: @escaping (SimplifiedUserDataResult)
            -> ()
    ) {
        guard let cookie = cookie
        else { completion(.failure(.noFetchInfo)); return }
        guard cookie.contains("stoken")
        else { completion(.failure(.noStoken)); return }
        MihoyoAPI.fetchSimplifiedInfos(cookie: cookie) { result in
            completion(result)
            #if !os(watchOS)
            switch result {
            case let .success(data):
                UserNotificationCenter.shared.createAllNotification(
                    for: self.name!,
                    with: data,
                    uid: self.uid!
                )
            case .failure:
                break
            }
            #endif
        }
    }

    func fetchBasicInfo(_ completion: @escaping (BasicInfos) -> ()) {
        MihoyoAPI.fetchBasicInfos(
            region: server.region,
            serverID: server.id,
            uid: uid ?? "",
            cookie: cookie ?? ""
        ) { result in
            switch result {
            case let .success(data):
                completion(data)
            case .failure:
                print("fetching basic info error")
            }
        }
    }

    #if !os(watchOS)
//    func fetchPlayerDetail(
//        dateWhenNextRefreshable: Date?,
//        _ completion: @escaping (Result<
//            PlayerDetailFetchModel,
//            PlayerDetail.PlayerDetailError
//        >) -> ()
//    ) {
//        guard let uid = uid else { return }
//        API.OpenAPIs.fetchPlayerDetail(
//            uid,
//            dateWhenNextRefreshable: dateWhenNextRefreshable
//        ) { result in
//            completion(result)
//        }
//    }

//    func fetchAbyssInfo(
//        round: AbyssRound,
//        _ completion: @escaping (SpiralAbyssDetail) -> ()
//    ) {
//        // thisAbyssData
//        MihoyoAPI.fetchSpiralAbyssInfos(
//            region: server.region,
//            serverID: server.id,
//            uid: uid!,
//            cookie: cookie!,
//            scheduleType: round.rawValue
//        ) { result in
//            switch result {
//            case let .success(resultData):
//                completion(resultData)
//            case .failure:
//                print("Fail")
//            }
//        }
//    }

//    func fetchAbyssInfo(
//        _ completion: @escaping (AccountSpiralAbyssDetail)
//            -> ()
//    ) {
//        var this: SpiralAbyssDetail?
//        var last: SpiralAbyssDetail?
//        let group = DispatchGroup()
//        group.enter()
//        fetchAbyssInfo(round: .this) { data in
//            this = data
//            group.leave()
//        }
//        group.enter()
//        fetchAbyssInfo(round: .last) { data in
//            last = data
//            group.leave()
//        }
//        group.notify(queue: .main) {
//            guard let this = this, let last = last else { return }
//            completion(AccountSpiralAbyssDetail(this: this, last: last))
//        }
//    }

    func fetchLedgerData(
        _ completion: @escaping (LedgerDataFetchResult)
            -> ()
    ) {
        MihoyoAPI.fetchLedgerInfos(
            month: 0,
            uid: uid!,
            serverID: server.id,
            region: server.region,
            cookie: cookie!
        ) { result in
            completion(result)
        }
    }

    enum AbyssRound: String {
        case this = "1", last = "2"
    }
    #endif
}
