// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - SRGFv1

// Ref: https://uigf.org/zh/standards/srgf.html

public struct SRGFv1: Codable, Hashable, Sendable {
    public var info: Info
    public var list: [DataEntry]
}

extension SRGFv1 {
    // MARK: - Info

    public struct Info: Codable, Hashable, Sendable {
        // MARK: Public

        public var uid, srgfVersion: String
        public var lang: GachaLanguageCode
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

    public struct DataEntry: Codable, Hashable, Sendable, Identifiable {
        // MARK: Lifecycle

        public init(
            gachaID: String,
            itemID: String,
            time: String,
            id: String,
            gachaType: GachaType,
            name: String? = nil,
            rankType: String? = nil,
            count: String? = nil,
            itemType: ItemType? = nil
        ) {
            self.gachaID = gachaID
            self.itemID = itemID
            self.time = time
            self.id = id
            self.gachaType = gachaType
            self.name = name
            self.rankType = rankType
            self.count = count
            self.itemType = itemType
        }

        // MARK: Public

        public enum ItemType: String, Codable, Hashable, CaseIterable, Sendable {
            case lightCone = "Light Cone"
            case character = "Character"
        }

        public enum GachaType: String, Codable, Hashable, CaseIterable, Sendable {
            case characterEventWarp = "11"
            case lightConeEventWarp = "12"
            case stellarWarp = "1" // 群星跃迁，常驻池
            case departureWarp = "2" // 始发跃迁，新手池
        }

        public var gachaID, itemID, time, id: String
        public var gachaType: GachaType
        public var name, rankType, count: String?
        public var itemType: ItemType?

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
        self.lang = lang
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

extension SRGFv1.DataEntry {
    public func toGachaEntry(uid: String, lang: GachaLanguageCode) -> GachaEntry {
        .init(
            count: Int32(count ?? "1") ?? 1, // Default is 1.
            gachaID: gachaID,
            gachaTypeRawValue: gachaType.rawValue,
            id: id,
            itemID: itemID,
            itemTypeRawValue: (itemType ?? .character).rawValue,
            langRawValue: lang.rawValue,
            name: name ?? "#NAME:\(id)#",
            rankRawValue: rankType ?? "3",
            time: Date(timeIntervalSince1970: Double(time) ?? Date().timeIntervalSince1970),
            uid: uid
        )
    }
}

extension GachaEntry {
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
