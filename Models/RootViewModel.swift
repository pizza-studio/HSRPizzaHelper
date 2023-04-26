//
//  RootViewModel.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  View中用于加载信息的工具类

import CoreData
import Foundation
import HBMihoyoAPI
//import HBPizzaHelperAPI
import StoreKit
import SwiftUI
import WatchConnectivity

// MARK: - ViewModel

@MainActor
class ViewModel: NSObject, ObservableObject {
    // MARK: Lifecycle

//    var session: WCSession

    init(session: WCSession = .default) {
//        self.session = session
        super.init()
//        self.session.delegate = self
//        session.activate()
        fetchAccount()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchAccount),
            name: .NSPersistentStoreRemoteChange,
            object: accountConfigurationModel
                .container
                .persistentStoreCoordinator
        )
    }

    // MARK: Internal

    static let shared = ViewModel()

    @Published
    var accounts: [Account] = []

    @Published
    var showDetailOfAccount: Account?
    @Published
    var showCharacterDetailOfAccount: Account?
    @Published
    var showingCharacterName: String?

    #if !os(watchOS)
//    var charLoc: [String: String]?
//    var charMap: [String: ENCharacterMap.Character]?
    #endif

    let accountConfigurationModel: AccountConfigurationModel = .shared

    @objc
    func fetchAccount() {
        // 从Core Data更新帐号信息
        // 检查是否有更改，如果有更改则更新
        DispatchQueue.main.async {
            let accountConfigs = self.accountConfigurationModel
                .fetchAccountConfigs()

            if UserDefaults(suiteName: "group.GenshinPizzaHelper")?
                .string(forKey: "defaultServer") == nil {
                if !accountConfigs.isEmpty {
                    UserDefaults(suiteName: "group.GenshinPizzaHelper")?.set(
                        accountConfigs.first!.server.rawValue,
                        forKey: "defaultServer"
                    )
                } else {
                    UserDefaults(suiteName: "group.GenshinPizzaHelper")?
                        .register(
                            defaults: ["defaultServer": Server.asia.rawValue]
                        )
                }
            }

            if !self.accounts.isEqualTo(accountConfigs) {
                self.accounts = accountConfigs.map { Account(config: $0) }
                self.refreshData()
                print("account fetched")
                #if !os(watchOS)
                self.refreshLedgerData()
                #endif
            }
        }
    }

    func forceFetchAccount() {
        // 强制从云端Core Data更新帐号信息
        accounts = accountConfigurationModel.fetchAccountConfigs()
            .map { Account(config: $0) }
        refreshData()
        print("force account fetched")
    }

    func addAccount(name: String, uid: String, cookie: String, server: Server) {
        // 添加的第一个帐号作为材料刷新的时区
        if accounts
            .isEmpty {
            UserDefaults(suiteName: "group.GenshinPizzaHelper")?
                .set(server.rawValue, forKey: "defaultServer")
        }
        // 新增帐号至Core Data
        accountConfigurationModel.addAccount(
            name: name,
            uid: uid,
            cookie: cookie,
            server: server
        )
        fetchAccount()
    }

    func deleteAccount(account: Account) {
        accounts.removeAll {
            account == $0
        }
        accountConfigurationModel.deleteAccount(account: account)
        fetchAccount()
    }

    func saveAccount() {
        accountConfigurationModel.saveAccountConfigs()
        fetchAccount()
    }

    func refreshData() {
        accounts.indices.forEach { index in
            accounts[index].fetchComplete = false
            accounts[index].config.fetchResult { result in
                self.accounts[index].result = result
//                self.accounts[index].background = .randomNamecardBackground
                self.accounts[index].fetchComplete = true
            }
        }
        refreshAbyssAndBasicInfo()
    }

    func refreshAbyssAndBasicInfo() {
        accounts.indices.forEach { index in
            #if !os(watchOS)
            let group = DispatchGroup()
            group.enter()
            accounts[index].config.fetchBasicInfo { basicInfo in
                self.accounts[index].basicInfo = basicInfo
                group.leave()
            }
            group.enter()
//            self.accounts[index].config.fetchAbyssInfo { data in
//                self.accounts[index].spiralAbyssDetail = data
//                group.leave()
//            }
//            group.notify(queue: .main) {
//                self.accounts[index].uploadAbyssData()
//            }
            #endif
        }
    }

    #if !os(watchOS)
    func refreshLedgerData() {
        accounts.indices.forEach { index in
            self.accounts[index].config.fetchLedgerData { result in
                self.accounts[index].ledgeDataResult = result
            }
        }
    }
    #endif
}

// MARK: WCSessionDelegate

extension ViewModel: WCSessionDelegate {
    #if !os(watchOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {}
    #endif

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        DispatchQueue.main.async {
            let accounts = message["accounts"] as? [Account]
            print(accounts == nil ? "data nil" : "data received")
            self.accounts = accounts ?? []
        }
    }
}

extension Array where Element == Account {
    func isEqualTo(_ newAccountConfigs: [AccountConfiguration]) -> Bool {
        if isEmpty, newAccountConfigs.isEmpty { return true }
        if count != newAccountConfigs.count { return false }

        var isSame = true

        forEach { account in
            guard let uuid = account.config.uuid else { isSame = false; return }
            guard let compareAccount = (
                newAccountConfigs
                    .first { $0.uuid == uuid }
            ) else { isSame = false; return }
            if !(
                compareAccount.uid == account.config.uid && compareAccount
                    .cookie == account.config.cookie && compareAccount
                    .server == account.config.server
            ) { isSame = false }
        }

        newAccountConfigs.forEach { config in
            guard let uuid = config.uuid else { isSame = false; return }
            guard let compareAccount = (
                self.first { $0.config.uuid == uuid }?
                    .config
            ) else { isSame = false; return }
            if !(
                compareAccount.uid == config.uid && compareAccount
                    .cookie == config.cookie && compareAccount.server == config
                    .server
            ) { isSame = false }
        }

        return isSame
    }
}
