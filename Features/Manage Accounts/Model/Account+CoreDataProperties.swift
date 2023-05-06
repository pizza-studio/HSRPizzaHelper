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

    /**
         The raw value for the server of the account. Possible values depend on the type of server.
     */
    /// The `rawValue` of the server.
    /// Usually access via `server` property instead of directly use this.
    @NSManaged fileprivate var serverRawValue: String!

    /// The UID of the account.
    @NSManaged public var uid: String!

    /// The UUID of the account.
    @NSManaged public var uuid: UUID!
}

// MARK: - Account + Identifiable

extension Account: Identifiable {
    public var id: UUID {
        uuid
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
