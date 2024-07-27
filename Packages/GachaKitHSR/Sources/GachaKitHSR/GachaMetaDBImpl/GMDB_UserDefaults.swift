// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation
import GachaMetaDB

#if !os(watchOS)
extension UserDefaults {
    public static let gmdbSuite = UserDefaults(suiteName: "group.Canglong.HSRPizzaHelper.GachaMetaDB") ?? .hsrSuite
}

extension Defaults.Keys {
    public static let lastGMDBDataCheckDate = Key<Date>(
        "lastCheckDateForGachaMetaDB",
        default: .init(timeIntervalSince1970: 0),
        suite: .gmdbSuite
    )
    public static let localGachaMetaDB = Key<GachaMetaDB>(
        "localGachaMetaDB",
        default: try! GachaMetaDB.getBundledDefault(for: .starRail)!,
        suite: .gmdbSuite
    )
    /// 用来标记当前 App 本地的抽卡记录是否有做过系统性的 ItemID 修复工作。
    public static let localGachaRecordItemIDsFixed = Key<Bool>(
        "localGachaRecordItemIDsFixed",
        default: false,
        suite: .gmdbSuite
    )
}

extension GachaItemMetadata: _DefaultsSerializable {}

#endif
