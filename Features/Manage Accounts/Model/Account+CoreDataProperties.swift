//
//  Account+CoreDataProperties.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//
//

import CoreData
import Foundation

extension Account {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Account> {
        NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var cookie: String!
    @NSManaged public var name: String!
    @NSManaged public var priority: NSNumber!
    @NSManaged public var serverRawValue: String!
    @NSManaged public var uid: String!
    @NSManaged public var uuid: UUID!
}

// MARK: - Account + Identifiable

extension Account: Identifiable {
    public var id: UUID {
        uuid
    }
}
