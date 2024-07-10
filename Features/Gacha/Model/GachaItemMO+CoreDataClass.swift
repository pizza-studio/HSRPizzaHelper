// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import Foundation
import GachaKit

// MARK: - GachaItemMO

@objc(GachaItemMO)
public class GachaItemMO: NSManagedObject {}

extension GachaEntry {
    public func toManagedModel() -> GachaItemMO {
        let result = GachaItemMO()
        result.count = count
        result.gachaID = gachaID
        result.gachaTypeRawValue = gachaTypeRawValue
        result.id = id
        result.itemID = itemID
        result.itemTypeRawValue = itemTypeRawValue
        result.langRawValue = langRawValue
        result.name = name
        result.rankRawValue = rankRawValue
        result.time = time
        result.timeRawValue = timeRawValue
        result.uid = uid
        return result
    }

    public func toManagedModel(context: NSManagedObjectContext) -> GachaItemMO {
        let result = GachaItemMO(context: context)
        result.count = count
        result.gachaID = gachaID
        result.gachaTypeRawValue = gachaTypeRawValue
        result.id = id
        result.itemID = itemID
        result.itemTypeRawValue = itemTypeRawValue
        result.langRawValue = langRawValue
        result.name = name
        result.rankRawValue = rankRawValue
        result.time = time
        result.timeRawValue = timeRawValue
        result.uid = uid
        return result
    }
}

extension GachaItemMO {
    public func toEntry() -> GachaEntry {
        .init(
            count: count,
            gachaID: gachaID,
            gachaTypeRawValue: gachaTypeRawValue,
            id: id,
            itemID: itemID,
            itemTypeRawValue: itemTypeRawValue,
            langRawValue: langRawValue,
            name: name,
            rankRawValue: rankRawValue,
            time: time,
            timeRawValue: timeRawValue,
            uid: uid
        )
    }
}
