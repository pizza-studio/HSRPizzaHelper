// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import Defaults
import EnkaKitHSR
import Foundation
import GachaKit
import HBMihoyoAPI
import SwiftUI

extension GachaItemMO {
    public func toSRGFEntry(
        langOverride: GachaLanguageCode? = nil,
        timeZoneDelta: Int = (TimeZone.current.secondsFromGMT() / 3600)
    )
        -> SRGFv1.DataEntry {
        toEntry().toSRGFEntry(
            langOverride: langOverride,
            timeZoneDelta: timeZoneDelta
        )
    }
}

extension SRGFv1.DataEntry {
    public func toManagedModel(
        uid: String,
        lang: GachaLanguageCode,
        timeZoneDelta: Int = (TimeZone.current.secondsFromGMT() / 3600)
    )
        -> GachaItemMO {
        let rawResult = toGachaEntry(uid: uid, lang: lang, timeZoneDelta: timeZoneDelta)
        return rawResult.toManagedModel()
    }

    public func toManagedModel(
        uid: String,
        lang: GachaLanguageCode,
        timeZoneDelta: Int = (TimeZone.current.secondsFromGMT() / 3600),
        context: NSManagedObjectContext
    )
        -> GachaItemMO {
        let rawResult = toGachaEntry(uid: uid, lang: lang, timeZoneDelta: timeZoneDelta)
        return rawResult.toManagedModel(context: context)
    }
}
