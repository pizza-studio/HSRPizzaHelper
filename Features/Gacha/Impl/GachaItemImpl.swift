// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import Foundation
import HBMihoyoAPI

extension GachaItem {
    public func toGachaItemMO(context: NSManagedObjectContext) -> GachaItemMO {
        let gachaItem = self
        let persistedItem = GachaItemMO(context: context)
        persistedItem.id = gachaItem.id
        persistedItem.count = Int32(gachaItem.count)
        persistedItem.gachaID = gachaItem.gachaID
        persistedItem.gachaType = gachaItem.gachaType
        persistedItem.itemID = gachaItem.itemID
        persistedItem.itemType = gachaItem.itemType
        persistedItem.language = gachaItem.lang
        persistedItem.name = gachaItem.name
        persistedItem.rank = gachaItem.rank
        persistedItem.time = gachaItem.time
        persistedItem.timeRawValue = gachaItem.timeRawValue
        persistedItem.uid = gachaItem.uid
        return persistedItem
    }
}
