// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import Defaults
import EnkaKitHSR
import Foundation
import SRGFKit

extension GachaItemMO {
    public func toSRGFEntry() -> SRGFv1.DataEntry {
        .init(
            gachaID: gachaID,
            itemID: itemID,
            time: time.timeIntervalSince1970.description,
            id: id,
            gachaType: .init(rawValue: gachaTypeRawValue) ?? .departureWarp,
            name: name,
            rankType: rankRawValue,
            count: count.description, // Default is 1.
            itemType: .init(rawValue: itemTypeRawValue)
        )
    }
}

extension SRGFv1.DataEntry {
    public func toManagedModel(uid: String, lang: GachaLanguageCode) -> GachaItemMO {
        let rawResult = toGachaEntry(uid: uid, lang: lang)
        return rawResult.toManagedModel()
    }
}

extension NSManagedObjectContext {
    @discardableResult
    public func addFromSRGF(
        uid: String,
        lang: GachaLanguageCode,
        newSRGF: SRGFv1.DataEntry
    )
        -> GachaItemMO {
        let gachaItem = newSRGF.toGachaEntry(uid: uid, lang: lang)
        let persistedItem = GachaItemMO(context: self)
        persistedItem.id = gachaItem.id
        persistedItem.count = Int32(gachaItem.count)
        persistedItem.gachaID = gachaItem.gachaID
        persistedItem.gachaTypeRawValue = gachaItem.gachaTypeRawValue
        persistedItem.itemID = gachaItem.itemID
        persistedItem.itemTypeRawValue = gachaItem.itemTypeRawValue
        persistedItem.langRawValue = gachaItem.langRawValue
        persistedItem.name = gachaItem.name
        persistedItem.rankRawValue = gachaItem.rankRawValue
        persistedItem.time = gachaItem.time
        persistedItem.uid = gachaItem.uid
        return persistedItem
    }
}

extension PersistenceController {
    public func insert(_ entrySRGF: SRGFv1.DataEntry, lang: GachaLanguageCode, uid: String) {
        let context = container.viewContext
        let request = GachaItemMO.fetchRequest()
        request.predicate = NSPredicate(format: "(id = %@) AND (uid = %@)", entrySRGF.id, uid)
        guard let duplicateItems = try? context.fetch(request), duplicateItems.isEmpty else { return }
        context.addFromSRGF(uid: uid, lang: lang, newSRGF: entrySRGF)
    }
}
