// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import Defaults
import EnkaKitHSR
import Foundation
import GachaKitHSR
import HBMihoyoAPI
import SwiftUI

extension GachaItemMO {
    public func toUIGFEntry(
        langOverride: GachaLanguageCode? = nil,
        timeZoneDeltaOverride: Int? = nil
    )
        -> UIGFv4.DataEntry {
        toEntry().toUIGFEntry(
            langOverride: langOverride,
            timeZoneDeltaOverride: timeZoneDeltaOverride
        )
    }
}

extension UIGFv4.DataEntry {
    public func toManagedModel(
        uid: String,
        lang: GachaLanguageCode?,
        timeZoneDelta: Int
    )
        -> GachaItemMO {
        let rawResult = toGachaEntry(uid: uid, lang: lang, timeZoneDelta: timeZoneDelta)
        return rawResult.toManagedModel()
    }

    public func toManagedModel(
        uid: String,
        lang: GachaLanguageCode?,
        timeZoneDelta: Int,
        context: NSManagedObjectContext
    )
        -> GachaItemMO {
        let rawResult = toGachaEntry(uid: uid, lang: lang, timeZoneDelta: timeZoneDelta)
        return rawResult.toManagedModel(context: context)
    }
}
