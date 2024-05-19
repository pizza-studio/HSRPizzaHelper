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
    // MARK: - Enka Suite

    public static let lastEnkaDBDataCheckDate = Key<Date>(
        "lastEnkaDBDataCheckDate",
        default: .init(timeIntervalSince1970: 0),
        suite: .enkaSuite
    )
    public static let enkaDBData = Key<EnkaHSR.EnkaDB>(
        "enkaDBData",
        default: EnkaHSR.EnkaDB(locTag: Locale.langCodeForEnkaAPI)!,
        suite: .enkaSuite
    )
    public static let lastEnkaQueryDate = Key<[String: Date]>(
        "lastEnkaDBDataCheckDate",
        default: [:],
        suite: .enkaSuite
    )
    public static let queriedEnkaProfiles = Key<[String: EnkaHSR.QueryRelated.DetailInfo]>(
        "lastEnkaDBDataCheckDate",
        default: [:],
        suite: .enkaSuite
    )
    public static let defaultDBQueryHost = Key<EnkaHSR.HostType>(
        "defaultDBQueryHost",
        default: EnkaHSR.HostType.enkaGlobal,
        suite: .enkaSuite
    )

    // MARK: - HSR Suite

    /// Whether animating on calling character showcase panel tabView.
    public static let animateOnCallingCharacterShowcase = Key<Bool>(
        "animateOnCallingCharacterShowcase",
        default: true,
        suite: .hsrSuite
    )

    /// Whether displaying character photos in Genshin style.
    public static let useGenshinStyleCharacterPhotos = Key<Bool>(
        "useGenshinStyleCharacterPhotos",
        default: true,
        suite: .hsrSuite
    )

    /// Whether displaying artifact compatibility rating results in EachAvatarStatView.
    public static let enableArtifactRatingInShowcase = Key<Bool>(
        "enableArtifactRatingInShowcase",
        default: true,
        suite: .hsrSuite
    )
}
#endif

// MARK: - EnkaHSR.EnkaDB + _DefaultsSerializable

extension EnkaHSR.EnkaDB: _DefaultsSerializable {}

// MARK: - EnkaHSR.QueryRelated.DetailInfo + _DefaultsSerializable

extension EnkaHSR.QueryRelated.DetailInfo: _DefaultsSerializable {}

// MARK: - EnkaHSR.HostType + _DefaultsSerializable

extension EnkaHSR.HostType: _DefaultsSerializable {
    public static func toggleEnkaDBQueryHost() {
        switch Defaults[.defaultDBQueryHost] {
        case .enkaGlobal: Defaults[.defaultDBQueryHost] = .mainlandChina
        case .mainlandChina: Defaults[.defaultDBQueryHost] = .enkaGlobal
        }
    }
}
