//
//  AccountConfigurationModel.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  基于CoreData配置帐号所需核心信息

import CoreData
import Foundation
import HBMihoyoAPI
import Intents

class AccountConfigurationModel {
    // MARK: Lifecycle

    private init() {
        let containerURL = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: "group.HSRPizzaHelper"
            )!
        let storeURL = containerURL
            .appendingPathComponent("AccountConfiguration.splite")

        self
            .container =
            NSPersistentCloudKitContainer(name: "AccountConfiguration")
        let description = container.persistentStoreDescriptions.first!
        description.url = storeURL

//        description
//            .cloudKitContainerOptions =
//            .init(containerIdentifier: "iCloud.tech.hakubill.HSRPizzaHelper")
        description.setOption(
            true as NSNumber,
            forKey: "NSPersistentStoreRemoteChangeNotificationOptionKey"
        )

        container.loadPersistentStores { _, error in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext
            .mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        container.viewContext.refreshAllObjects()
    }

    // MARK: Internal

    // CoreData

    static let shared: AccountConfigurationModel = .init()

    let container: NSPersistentCloudKitContainer

    func fetchAccountConfigs() -> [AccountConfiguration] {
        // 从Core Data更新帐号信息
        container.viewContext.refreshAllObjects()
        let request =
            NSFetchRequest<AccountConfiguration>(entityName: "AccountConfiguration")

        do {
            let accountConfigs = try container.viewContext.fetch(request)
            return accountConfigs

        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return []
        }
    }

    func addAccount(name: String, uid: String, cookie: String, server: Server) {
        // 新增帐号至Core Data
        let newAccount = AccountConfiguration(context: container.viewContext)
        newAccount.name = name
        newAccount.uid = uid
        newAccount.cookie = cookie
        newAccount.server = server
        newAccount.uuid = UUID()
        saveAccountConfigs()
    }

    func deleteAccount(account: Account) {
        container.viewContext.delete(account.config)
        saveAccountConfigs()
    }

    func saveAccountConfigs() {
        do {
            try container.viewContext.save()
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
    }
}
