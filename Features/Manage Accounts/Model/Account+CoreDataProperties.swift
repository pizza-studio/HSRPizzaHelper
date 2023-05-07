//
//  Account+CoreDataProperties.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//
//

import CoreData
import Foundation

/**
 `Account` is a `NSManagedObject` subclass that represents an account.

 To make the object as a fetch request, use `fetchRequest` method.
 */
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

    /**
         The raw value for the server of the account. Possible values depend on the type of server.
     */
    @NSManaged public var serverRawValue: String!

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
