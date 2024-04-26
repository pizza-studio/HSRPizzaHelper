// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

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
        var rawResult = toGachaEntry(uid: uid, lang: lang)
        return rawResult.toManagedModel()
    }
}
