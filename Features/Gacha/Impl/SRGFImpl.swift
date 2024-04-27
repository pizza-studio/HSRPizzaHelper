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

    public func importSRGF(_ srgf: SRGFv1) async {
        // TODO: 这个函式可以实作状态反馈与结果实时统计功能，
        // 结果实时统计可以使用新增 Binding 参数的方法来完成。
        let lang = srgf.info.lang
        let uid = srgf.info.uid
        srgf.list.forEach { dataEntry in
            insert(dataEntry, lang: lang, uid: uid)
        }
    }

    public func exportSRGF(_ uid: String) async -> SRGFv1? {
        // TODO: 这个函式可以实作状态反馈与结果实时统计功能，
        // 结果实时统计可以使用新增 Binding 参数的方法来完成。
        guard let lang = GachaLanguageCode(langTag: Locale.langCodeForEnkaAPI) else { return nil }
        var info = SRGFv1.Info(uid: uid, lang: lang)
        // TODO: 从 PersistenceController 调取所有符合给定 UID 的抽卡记录（GachaItemMO）。
        // 然后将这些记录直接用「.toSRGFEntry()」这个 API 翻译成 SRGFv1.DataEntry 类型。
        // 再将翻译结果塞到下面这行的 list 参数阵列里面。
        var result = SRGFv1(info: info, list: [])
        return result
    }
}
