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
    fileprivate static func makeDecodingError(_ key: CodingKey) -> Error {
        let keyName = key.description
        var msg = "\(keyName) value is invalid or empty. "
        msg += "// \(keyName) 不得是空值或不可用值。 "
        msg += "// \(keyName) は必ず有効な値しか処理できません。"
        return DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: msg))
    }
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
            itemType: String? = nil
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

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var error: Error?

            self.count = try container.decodeIfPresent(String.self, forKey: .count)
            if Int(count ?? "1") == nil { error = SRGFv1.makeDecodingError(CodingKeys.count) }

            self.gachaType = try container.decode(GachaType.self, forKey: .gachaType)

            self.id = try container.decode(String.self, forKey: .id)
            if Int(id) == nil { error = SRGFv1.makeDecodingError(CodingKeys.id) }

            self.itemID = try container.decode(String.self, forKey: .itemID)
            if Int(itemID) == nil { error = SRGFv1.makeDecodingError(CodingKeys.itemID) }

            self.itemType = try container.decodeIfPresent(String.self, forKey: .itemType)
            if itemType?.isEmpty ?? false { error = SRGFv1.makeDecodingError(CodingKeys.itemType) }

            self.gachaID = try container.decode(String.self, forKey: .gachaID)
            if Int(gachaID) == nil { error = SRGFv1.makeDecodingError(CodingKeys.gachaID) }

            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            if name?.isEmpty ?? false { error = SRGFv1.makeDecodingError(CodingKeys.name) }

            self.rankType = try container.decodeIfPresent(String.self, forKey: .rankType)
            if Int(rankType ?? "3") == nil { error = SRGFv1.makeDecodingError(CodingKeys.rankType) }

            self.time = try container.decode(String.self, forKey: .time)
            if DateFormatter.forUIGFEntry(timeZoneDelta: 0).date(from: time) == nil {
                error = SRGFv1.makeDecodingError(CodingKeys.time)
            }

            if let error = error { throw error }
        }

        // MARK: Public

        public typealias GachaType = UIGFv4.ProfileHSR.GachaItemHSR.GachaTypeHSR

        public var gachaID, itemID, time, id: String
        public var gachaType: GachaType
        public var name, rankType, count: String?
        public var itemType: String?

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
        let dateFormatter = DateFormatter.forUIGFFileName
        return "SRGF_\(info.uid)_\(dateFormatter.string(from: info.maybeDateExported ?? Date()))"
    }

    public var asDocument: GachaDocument {
        .init(model: self)
    }
}

extension SRGFv1.Info {
    public init(uid: String, lang: GachaLanguageCode) {
        self.uid = uid
        self.lang = lang
        self.srgfVersion = "v1.0"
        self.regionTimeZone = GachaItem.getServerTimeZoneDelta(uid)
        self.exportTimestamp = Int(Date.now.timeIntervalSince1970)
        self.exportApp = "PizzaHelper4HSR"
        let shortVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.exportAppVersion = shortVer ?? "1.14.514"
    }

    public var maybeDateExported: Date? {
        guard let exportTimestamp = exportTimestamp else { return nil }
        return .init(timeIntervalSince1970: Double(exportTimestamp))
    }
}

extension SRGFv1.DataEntry {
    public func toGachaEntry(
        uid: String,
        lang: GachaLanguageCode,
        timeZoneDelta: Int
    )
        -> GachaEntry {
        let newItemType = GachaItem.ItemType(itemID: itemID)
        let name = GachaMetaManager.shared.getLocalizedName(
            id: itemID, langOverride: lang
        ) ?? name
        let timeTyped: Date? = DateFormatter.forUIGFEntry(timeZoneDelta: timeZoneDelta).date(from: time)
        let fallbackRankType = GachaMetaManager.shared.getRankType(id: itemID)
        return .init(
            count: Int32(count ?? "1") ?? 1, // Default is 1.
            gachaID: gachaID,
            gachaTypeRawValue: gachaType.rawValue,
            id: id,
            itemID: itemID,
            itemTypeRawValue: newItemType.rawValue, // 披萨助手有内部专用的 Item Type Raw Value。
            langRawValue: lang.rawValue,
            name: name ?? "#NAME:\(id)#",
            rankRawValue: rankType ?? fallbackRankType?.rawValue ?? "3",
            time: timeTyped ?? Date(),
            timeRawValue: time,
            uid: uid
        )
    }
}

extension GachaEntry {
    public func toSRGFEntry(
        langOverride: GachaLanguageCode? = nil,
        timeZoneDeltaOverride: Int? = nil
    )
        -> SRGFv1.DataEntry {
        // 导出的时候按照 server 时区那样来导出，
        // 这样可以直接沿用爬取伺服器数据时拿到的 time raw string，
        // 借此做到对导出的 JSON 内容的最大程度的传真。
        let timeZoneDelta: Int = timeZoneDeltaOverride ?? GachaItem.getServerTimeZoneDelta(uid)
        let langOverride = langOverride ?? Locale.gachaLangauge
        let newItemType = GachaItem.ItemType(itemID: itemID)
        let name = GachaMetaManager.shared.getLocalizedName(
            id: itemID, langOverride: langOverride
        ) ?? name
        // 每次导出 SRGF 资料时，都根据当前语言来重新生成 `item_type` 资料值。
        let itemTypeTranslated = newItemType.translatedRaw(for: langOverride)
        return .init(
            gachaID: gachaID,
            itemID: itemID,
            time: timeRawValue ?? time.asUIGFDate(timeZoneDelta: timeZoneDelta),
            id: id,
            gachaType: .init(rawValue: gachaTypeRawValue) ?? .departureWarp,
            name: name,
            rankType: rankRawValue,
            count: count.description, // Default is 1.
            itemType: itemTypeTranslated
        )
    }
}

// MARK: - SRGFv1.Document

extension SRGFv1 {
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
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
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
