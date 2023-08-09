//
//  GachaItemMO+CoreDataProperties.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//
//

import CoreData
import Foundation
import HBMihoyoAPI

extension GachaItemMO {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<GachaItemMO> {
        NSFetchRequest<GachaItemMO>(entityName: "GachaItemMO")
    }

    @NSManaged public var count: Int32
    @NSManaged public var gachaID: String!
    @NSManaged public var gachaTypeRawValue: String!
    @NSManaged public var id: String!
    @NSManaged public var itemID: String!
    @NSManaged public var itemTypeRawValue: String!
    @NSManaged public var lang: String!
    @NSManaged public var name: String!
    @NSManaged public var rankRawValue: String!
    @NSManaged public var time: Date!
    @NSManaged public var uid: String!

    var gachaType: GachaType {
        get {
            .init(rawValue: gachaTypeRawValue)!
        } set {
            gachaTypeRawValue = newValue.rawValue
        }
    }

    var itemType: GachaItem.ItemType {
        get {
            .init(rawValue: itemTypeRawValue)!
        } set {
            itemTypeRawValue = newValue.rawValue
        }
    }

    var rank: GachaItem.Rank {
        get {
            .init(rawValue: rankRawValue)!
        } set {
            rankRawValue = newValue.rawValue
        }
    }
}

// MARK: - GachaItemMO + Identifiable

extension GachaItemMO: Identifiable {}
