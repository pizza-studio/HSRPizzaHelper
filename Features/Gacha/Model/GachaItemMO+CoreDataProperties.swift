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
import SRGFKit
import UIKit

// MARK: - GachaItemMO + GachaItemProtocol

extension GachaItemMO: GachaItemProtocol {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<GachaItemMO> {
        NSFetchRequest<GachaItemMO>(entityName: "GachaItemMO")
    }

    @NSManaged public var count: Int32
    @NSManaged public var gachaID: String!
    @NSManaged public var gachaTypeRawValue: String!
    @NSManaged public var id: String!
    @NSManaged public var itemID: String
    @NSManaged public var itemTypeRawValue: String!
    @NSManaged public var langRawValue: String!
    @NSManaged public var name: String!
    @NSManaged public var rankRawValue: String!
    @NSManaged public var time: Date!
    @NSManaged public var timeRawValue: String?
    @NSManaged public var uid: String!

    var gachaType: GachaType {
        get {
            .init(rawValue: gachaTypeRawValue)!
        } set {
            gachaTypeRawValue = newValue.rawValue
        }
    }

    public var itemType: GachaItem.ItemType {
        get {
            .init(rawValue: itemTypeRawValue)!
        } set {
            itemTypeRawValue = newValue.rawValue
        }
    }

    public var rank: GachaItem.Rank {
        get {
            .init(rawValue: rankRawValue)!
        } set {
            rankRawValue = newValue.rawValue
        }
    }

    var language: MiHoYoAPILanguage {
        get {
            .init(rawValue: langRawValue)!
        } set {
            langRawValue = newValue.rawValue
        }
    }
}

// MARK: - GachaItemMO + Identifiable

extension GachaItemMO: Identifiable {}

extension GachaItemMO {
    var isLose5050: Bool {
        guard rank == .five else { return true }
        switch itemID {
        case "1003", "1004", "1101", "1104", "1107", "1209", "1211",
             "23000", "23002", "23003", "23004", "23005", "23012", "23013":
            return true
        default:
            return false
        }
    }
}
