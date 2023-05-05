//
//  Persistence.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

// swiftlint:disable force_unwrapping

import CoreData

struct AccountPersistenceController {
    // MARK: Lifecycle

    init(inMemory: Bool = false) {
        let containerURL = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: AppConfig.appGroupID
            )!
        let storeURL = containerURL
            .appendingPathComponent("HSRPizzaHelper.splite")

        self.container =
            NSPersistentCloudKitContainer(name: "HSRPizzaHelper")
        let description = container.persistentStoreDescriptions.first!
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            description.url = storeURL
        }

        description
            .cloudKitContainerOptions =
            .init(containerIdentifier: "iCloud.com.Canglong.HSRPizzaHelper")
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

    static let shared = AccountPersistenceController()

    let container: NSPersistentCloudKitContainer
}

// swiftlint:enable force_unwrapping
