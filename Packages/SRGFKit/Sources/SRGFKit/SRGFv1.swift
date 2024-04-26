// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - SRGFv1

// Ref: https://uigf.org/zh/standards/srgf.html

public struct SRGFv1: Codable, Hashable, Sendable {
    public let info: Info
    public let list: [Entry]
}

extension SRGFv1 {
    // MARK: - Info

    public struct Info: Codable, Hashable, Sendable {
        // MARK: Public

        public let uid, lang, srgfVersion: String
        public let regionTimeZone: Int
        public let exportTimestamp: Int?
        public let exportApp, exportAppVersion: String?

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

        public let gachaID, gachaType, itemID, time, id: String
        public let name, itemType, rankType, count: String?

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
