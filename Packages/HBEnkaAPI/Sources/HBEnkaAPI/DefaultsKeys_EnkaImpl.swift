// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import DefaultsKeys
import Foundation

#if !os(watchOS)
extension UserDefaults {
    public static let enkaSuite = UserDefaults(suiteName: "group.Canglong.HSRPizzaHelper.storageForEnka") ?? .hsrSuite
}

extension Defaults.Keys {
    public static let lastEnkaDBDataCheckDate = Key<Date>(
        "lastEnkaDBDataCheckDate",
        default: .init(timeIntervalSince1970: 0),
        suite: .enkaSuite
    )
    public static let enkaDBData = Key<EnkaHSR.EnkaDB>(
        "enkaDBData",
        default: EnkaHSR.EnkaDB()!,
        suite: .enkaSuite
    )
}
#endif

// MARK: - EnkaHSR.EnkaDB + _DefaultsSerializable

extension EnkaHSR.EnkaDB: _DefaultsSerializable {}
