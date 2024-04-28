// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import Defaults
import EnkaKitHSR
import Foundation
import HBMihoyoAPI
import SRGFKit
import SwiftUI

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

    public var asSRGFEntry: SRGFv1.DataEntry {
        toSRGFEntry()
    }
}

extension SRGFv1.DataEntry {
    public func toManagedModel(uid: String, lang: GachaLanguageCode) -> GachaItemMO {
        let rawResult = toGachaEntry(uid: uid, lang: lang)
        return rawResult.toManagedModel()
    }

    public func toManagedModel(uid: String, lang: GachaLanguageCode, context: NSManagedObjectContext) -> GachaItemMO {
        let rawResult = toGachaEntry(uid: uid, lang: lang)
        return rawResult.toManagedModel(context: context)
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
    public func insertEntry(_ entrySRGF: SRGFv1.DataEntry, lang: GachaLanguageCode, uid: String) throws {
        try insertEntries([entrySRGF], lang: lang, uid: uid)
    }

    public func insertEntries(
        _ entrySRGFs: [SRGFv1.DataEntry],
        lang: GachaLanguageCode,
        uid: String,
        counter: Binding<Int>? = nil
    ) throws {
        let context = container.viewContext
        let request = GachaItemMO.fetchRequest()
        try entrySRGFs.forEach { entrySRGF in
            request.predicate = NSPredicate(format: "(id = %@) AND (uid = %@)", entrySRGF.id, uid)
            guard try context.fetch(request).isEmpty else { return }
            context.addFromSRGF(uid: uid, lang: lang, newSRGF: entrySRGF)
            counter?.wrappedValue += 1
        }
        try context.save()
    }

    public func importSRGF(_ srgf: SRGFv1, counter: Binding<Int>? = nil) async throws {
        let lang = srgf.info.lang
        let uid = srgf.info.uid
        try insertEntries(srgf.list, lang: lang, uid: uid, counter: counter)
    }

    public func exportSRGF(_ uid: String) async throws -> SRGFv1? {
        guard let lang = GachaLanguageCode(langTag: Locale.langCodeForEnkaAPI) else { return nil }
        let info = SRGFv1.Info(uid: uid, lang: lang)
        let context = container.viewContext
        let request = GachaItemMO.fetchRequest()
        request.predicate = NSPredicate(format: "(uid = %@)", uid)
        let result = SRGFv1(info: info, list: try context.fetch(request).map(\.asSRGFEntry))
        return result
    }
}

extension GachaItem.ItemType {
  public var asSRGFType: SRGFv1.DataEntry.ItemType {
    switch self {
    case .lightCones: return .lightCone
    case .characters: return .character
    }
  }
}

extension SRGFv1.DataEntry.ItemType {
  public var asManagedType: GachaItem.ItemType {
    switch self {
    case .lightCone: return .lightCones
    case .character: return .characters
    }
  }
}
