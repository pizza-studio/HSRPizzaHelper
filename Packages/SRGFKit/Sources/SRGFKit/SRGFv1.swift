// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - SRGFv1

// Ref: https://uigf.org/zh/standards/srgf.html

public struct SRGFv1: Codable, Hashable, Sendable {
    public var info: Info
    public var list: [Entry]
}

extension SRGFv1 {
    // MARK: - Info

    public struct Info: Codable, Hashable, Sendable {
        // MARK: Public

        public var uid, lang, srgfVersion: String
        public var regionTimeZone: Int
        public var exportTimestamp: Int?
        public var exportApp, exportAppVersion: String?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case uid, lang
            case regionTimeZone = "region_time_zone"
            case exportTimestamp = "export_timestamp"
            case exportApp = "export_app"
            case exportAppVersion = "export_app_version"
            case srgfVersion = "srgf_version"
        }
    }

    // MARK: - List

    public struct Entry: Codable, Hashable, Sendable, Identifiable {
        // MARK: Public

        public var gachaID, gachaType, itemID, time, id: String
        public var name, itemType, rankType, count: String?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case gachaID = "gacha_id"
            case gachaType = "gacha_type"
            case itemID = "item_id"
            case count, time, name
            case itemType = "item_type"
            case rankType = "rank_type"
            case id
        }
    }
}

extension SRGFv1.Info {
    public init(uid: String, lang: GachaLanguageCode) {
        self.uid = uid
        self.lang = lang.rawValue
        self.srgfVersion = "v1.0"
        self.regionTimeZone = TimeZone.current.secondsFromGMT() / 3600
        self.exportTimestamp = Int(Date.now.timeIntervalSince1970)
        self.exportApp = "PizzaHelper4HSR"
        self.exportAppVersion = (
            Bundle.main
                .infoDictionary!["CFBundleShortVersionString"] as! String
        )
    }
}
