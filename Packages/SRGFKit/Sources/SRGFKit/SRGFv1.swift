// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBMihoyoAPI
import SwiftUI
import UniformTypeIdentifiers

// MARK: - SRGFv1

// Ref: https://uigf.org/zh/standards/srgf.html

public struct SRGFv1: Codable, Hashable, Sendable {
    // MARK: Lifecycle

    public init(info: Info, list: [DataEntry]) {
        self.info = info
        self.list = list
    }

    // MARK: Public

    public var info: Info
    public var list: [DataEntry]
}

extension SRGFv1 {
    // MARK: - Info

    public struct Info: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(
            uid: String,
            srgfVersion: String,
            lang: GachaLanguageCode,
            regionTimeZone: Int,
            exportTimestamp: Int? = nil,
            exportApp: String? = nil,
            exportAppVersion: String? = nil
        ) {
            self.uid = uid
            self.srgfVersion = srgfVersion
            self.lang = lang
            self.regionTimeZone = regionTimeZone
            self.exportTimestamp = exportTimestamp
            self.exportApp = exportApp
            self.exportAppVersion = exportAppVersion
        }

        // MARK: Public

        public var uid, srgfVersion: String
        public var lang: GachaLanguageCode
        public var regionTimeZone: Int
        public var exportTimestamp: Int?
        public var exportApp, exportAppVersion: String?

        public var exportDate: Date? {
            guard let exportTimestamp = exportTimestamp else { return nil }
            return .init(timeIntervalSince1970: TimeInterval(exportTimestamp))
        }

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

            // MARK: Lifecycle

            public init?(managedRawValue: String) {
                switch managedRawValue {
                case "lightCones": self = .lightCone
                case "characters": self = .character
                default: return nil
                }
            }

            // MARK: Public

            /// 穹披助手的 CoreData Managed Object 对这个 Enum 有着不同的 RawValue 定义。
            public var asManagedObjectRawValue: String {
                switch self {
                case .lightCone: return "lightCones"
                case .character: return "characters"
                }
            }
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

// MARK: - Extensions.

extension SRGFv1 {
    public var defaultFileNameStem: String {
        let dateFormatter = DateFormatter.forSRGFFileName
        return "SRGF_\(info.uid)_\(dateFormatter.string(from: info.maybeDateExported ?? Date()))"
    }

    public var asDocument: Document {
        .init(model: self)
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
        let shortVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.exportAppVersion = shortVer ?? "1.14.514"
    }

    public var maybeDateExported: Date? {
        guard let exportTimestampStr = exportApp else { return nil }
        guard let exportTimestampValue = Double(exportTimestampStr) else { return nil }
        return .init(timeIntervalSince1970: exportTimestampValue)
    }
}

extension SRGFv1.DataEntry {
    public func toGachaEntry(
        uid: String,
        lang: GachaLanguageCode,
        timeZoneDelta: Int = (TimeZone.current.secondsFromGMT() / 3600)
    )
        -> GachaEntry {
        var name = name
        if let itemType = itemType, let managedType = GachaItem.ItemType(
            rawValue: itemType.asManagedObjectRawValue
        ) {
            name = GachaMetaManager.shared.getLocalizedName(
                id: itemID, type: managedType,
                langOverride: lang
            ) ?? name
        }

        return .init(
            count: Int32(count ?? "1") ?? 1, // Default is 1.
            gachaID: gachaID,
            gachaTypeRawValue: gachaType.rawValue,
            id: id,
            itemID: itemID,
            itemTypeRawValue: (itemType ?? .character).asManagedObjectRawValue,
            langRawValue: lang.rawValue,
            name: name ?? "#NAME:\(id)#",
            rankRawValue: rankType ?? "3",
            time: DateFormatter.forSRGFEntry(timeZoneDelta: timeZoneDelta).date(from: time) ?? Date(),
            uid: uid
        )
    }
}

extension GachaEntry {
    public func toSRGFEntry(
        langOverride: GachaLanguageCode? = nil,
        timeZoneDelta: Int = (TimeZone.current.secondsFromGMT() / 3600)
    )
        -> SRGFv1.DataEntry {
        var name = name
        if let managedType = GachaItem.ItemType(rawValue: itemTypeRawValue) {
            name = GachaMetaManager.shared
                .getLocalizedName(id: itemID, type: managedType, langOverride: langOverride) ?? name
        }
        return .init(
            gachaID: gachaID,
            itemID: itemID,
            time: time.asSRGFDate(timeZoneDelta: timeZoneDelta),
            id: id,
            gachaType: .init(rawValue: gachaTypeRawValue) ?? .departureWarp,
            name: name,
            rankType: rankRawValue,
            count: count.description, // Default is 1.
            itemType: .init(managedRawValue: itemTypeRawValue)
        )
    }
}

extension SRGFv1 {
    // MARK: - JsonFile

    public struct Document: FileDocument {
        // MARK: Lifecycle

        public init(configuration: ReadConfiguration) throws {
            self.model = try JSONDecoder()
                .decode(
                    SRGFv1.self,
                    from: configuration.file.regularFileContents!
                )
        }

        public init(model: SRGFv1) {
            self.model = model
        }

        // MARK: Public

        public static var readableContentTypes: [UTType] = [.json]

        public let model: SRGFv1

        public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .init(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(model)
            return FileWrapper(regularFileWithContents: data)
        }
    }
}
