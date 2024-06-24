//
//  Account+CoreDataProperties.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//
//

import CoreData
import Foundation
import HBMihoyoAPI

/// An `NSManagedObject` representing an account.
extension Account {
    /**
        Returns a fetch request object for retrieving accounts.

        - Returns: A `NSFetchRequest` object from `Account`.
     */
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Account> {
        NSFetchRequest<Account>(entityName: "Account")
    }

    /// The cookie of the account.
    @NSManaged public var cookie: String!

    /// The name of the account.
    @NSManaged public var name: String!

    /// The priority of the account.
    @NSManaged public var priority: NSNumber!

    /// The `rawValue` of the server.
    /// Usually access via `server` property instead of directly use this.
    @NSManaged public var serverRawValue: String!

    /// The UID of the account.
    @NSManaged public var uid: String!

    /// The UUID of the account.
    @NSManaged public var uuid: UUID!

    @NSManaged public var allowNotification: NSNumber!

    /// The UID of the account.
    @NSManaged public var deviceFingerPrintInner: String?

    public var hasValidCookie: Bool {
        !(cookie ?? "").isEmpty
    }

    var deviceFingerPrint: String {
        get {
            deviceFingerPrintInner ?? ""
        } set {
            deviceFingerPrintInner = newValue
        }
    }
}

// MARK: - Account + Identifiable

extension Account: Identifiable {
    public var id: UUID {
        uuid ?? UUID()
    }
}

extension Account {
    /// Get the account's current server
    var server: Server {
        get {
            .init(rawValue: serverRawValue ?? "") ?? .china
        } set {
            serverRawValue = newValue.rawValue
        }
    }
}
