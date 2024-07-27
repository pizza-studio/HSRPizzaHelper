// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBMihoyoAPI
import SwiftUI
import UniformTypeIdentifiers

// MARK: - UIGFv4

// 穹披助手对 UIGF 仅从 v4 开始支援，因为之前版本的 UIGF 仅支援原神。
// Ref: https://uigf.org/zh/standards/uigf.html

public struct UIGFv4: Codable, Hashable, Sendable {
    // MARK: Lifecycle

    public init(
        info: Info,
        giProfiles: [ProfileGI]? = [],
        hsrProfiles: [ProfileHSR]? = [],
        zzzProfiles: [ProfileZZZ]? = []
    ) {
        self.info = info
        self.giProfiles = giProfiles
        self.hsrProfiles = hsrProfiles
        self.zzzProfiles = zzzProfiles
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey {
        case giProfiles = "hk4e"
        case hsrProfiles = "hkrpg"
        case zzzProfiles = "nap"
        case info
    }

    public var giProfiles: [ProfileGI]?
    public var hsrProfiles: [ProfileHSR]?
    public var info: Info
    public var zzzProfiles: [ProfileZZZ]?
}

extension UIGFv4 {
    fileprivate static func makeDecodingError(_ key: CodingKey) -> Error {
        let keyName = key.description
        var msg = "\(keyName) value is invalid or empty. "
        msg += "// \(keyName) 不得是空值或不可用值。 "
        msg += "// \(keyName) は必ず有効な値しか処理できません。"
        return DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: msg))
    }
}

// MARK: UIGFv4.Info

extension UIGFv4 {
    public struct Info: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(exportApp: String, exportAppVersion: String, exportTimestamp: String, version: String) {
            self.exportApp = exportApp
            self.exportAppVersion = exportAppVersion
            self.exportTimestamp = exportTimestamp
            self.version = version
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.exportApp = try container.decode(String.self, forKey: .exportApp)
            self.exportAppVersion = try container.decode(String.self, forKey: .exportAppVersion)
            self.version = try container.decode(String.self, forKey: .version)
            if let x = try? container.decode(String.self, forKey: .exportTimestamp) {
                self.exportTimestamp = x
            } else if let x = try? container.decode(Int.self, forKey: .exportTimestamp) {
                self.exportTimestamp = x.description
            } else if let x = try? container.decode(Double.self, forKey: .exportTimestamp) {
                self.exportTimestamp = x.description
            } else {
                self.exportTimestamp = "YJSNPI" // 摆烂值，反正这里不解析。
            }
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case exportApp = "export_app"
            case exportAppVersion = "export_app_version"
            case exportTimestamp = "export_timestamp"
            case version
        }

        /// 导出档案的 App 名称
        public let exportApp: String
        /// 导出档案的 App 版本
        public let exportAppVersion: String
        /// 导出档案的时间戳，秒级
        public let exportTimestamp: String
        /// 导出档案的 UIGF 版本号，格式为 'v{major}.{minor}'，如 v4.0
        public let version: String
    }
}

// MARK: UIGFv4.ProfileGI

extension UIGFv4 {
    public struct ProfileGI: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(lang: GachaLanguageCode, list: [GachaItemGI], timezone: Int?, uid: String) {
            self.lang = lang
            self.list = list
            self.timezone = timezone ?? GachaItem.getServerTimeZoneDelta(uid)
            self.uid = uid
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.list = try container.decode([GachaItemGI].self, forKey: .list)
            self.lang = try container.decodeIfPresent(GachaLanguageCode.self, forKey: .lang)
            self.timezone = try container.decode(Int.self, forKey: .timezone)

            if let x = try? container.decode(String.self, forKey: .uid), !x.isEmpty {
                self.uid = x
            } else if let x = try? container.decode(Int.self, forKey: .uid) {
                self.uid = x.description
            } else {
                throw DecodingError.typeMismatch(
                    String.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Type for UID shall be either String or Integer."
                    )
                )
            }
        }

        // MARK: Public

        public struct GachaItemGI: Codable, Hashable, Sendable {
            // MARK: Lifecycle

            public init(
                count: String?,
                gachaType: GachaTypeGI,
                id: String,
                itemID: String,
                itemType: String?,
                name: String?,
                rankType: String?,
                time: String,
                uigfGachaType: UIGFGachaTypeGI
            ) {
                self.count = count
                self.gachaType = gachaType
                self.id = id
                self.itemID = itemID
                self.itemType = itemType
                self.name = name
                self.rankType = rankType
                self.time = time
                self.uigfGachaType = uigfGachaType
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var error: Error?

                self.count = try container.decodeIfPresent(String.self, forKey: .count)
                if Int(count ?? "1") == nil { error = UIGFv4.makeDecodingError(CodingKeys.count) }

                self.gachaType = try container.decode(GachaTypeGI.self, forKey: .gachaType)

                self.id = try container.decode(String.self, forKey: .id)
                if Int(id) == nil { error = UIGFv4.makeDecodingError(CodingKeys.id) }

                self.itemID = try container.decode(String.self, forKey: .itemID)
                if Int(itemID) == nil { error = UIGFv4.makeDecodingError(CodingKeys.itemID) }

                self.itemType = try container.decodeIfPresent(String.self, forKey: .itemType)
                if itemType?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.itemType) }

                self.name = try container.decodeIfPresent(String.self, forKey: .name)
                if name?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.name) }

                self.rankType = try container.decodeIfPresent(String.self, forKey: .rankType)
                if Int(rankType ?? "3") == nil { error = UIGFv4.makeDecodingError(CodingKeys.rankType) }

                self.time = try container.decode(String.self, forKey: .time)
                if DateFormatter.forUIGFEntry(timeZoneDelta: 0).date(from: time) == nil {
                    error = UIGFv4.makeDecodingError(CodingKeys.time)
                }

                self.uigfGachaType = try container.decode(UIGFGachaTypeGI.self, forKey: .uigfGachaType)

                if let error = error { throw error }
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case count
                case gachaType = "gacha_type"
                case id
                case itemID = "item_id"
                case itemType = "item_type"
                case name
                case rankType = "rank_type"
                case time
                case uigfGachaType = "uigf_gacha_type"
            }

            /// 卡池类型，API返回
            public enum GachaTypeGI: String, Codable, Hashable, Sendable {
                case beginnersWish = "100"
                case standardWish = "200"
                case characterEvent1 = "301"
                case weaponEvent = "302"
                case characterEvent2 = "400"
                case chronicledWish = "500"

                // MARK: Public

                public var uigfGachaType: UIGFGachaTypeGI {
                    switch self {
                    case .beginnersWish: return .beginnersWish
                    case .standardWish: return .standardWish
                    case .characterEvent1, .characterEvent2: return .characterEvent
                    case .weaponEvent: return .weaponEvent
                    case .chronicledWish: return .chronicledWish
                    }
                }
            }

            /// UIGF 卡池类型，用于区分卡池类型不同，但卡池保底计算相同的物品
            public enum UIGFGachaTypeGI: String, Codable, Hashable, Sendable {
                case beginnersWish = "100"
                case standardWish = "200"
                case characterEvent = "301"
                case weaponEvent = "302"
                case chronicledWish = "500"
            }

            /// 物品个数，一般为1，API返回
            public var count: String?
            /// 卡池类型，API返回
            public var gachaType: GachaTypeGI
            /// 记录内部 ID, API返回
            public var id: String
            /// 物品的内部 ID
            public var itemID: String
            /// 物品类型, API返回
            public var itemType: String?
            /// 物品名称, API返回
            public var name: String?
            /// 物品等级, API返回
            public var rankType: String?
            /// 获取物品的本地时间，与 timezone 一起计算出物品的准确获取时间，API返回
            public var time: String
            /// UIGF 卡池类型，用于区分卡池类型不同，但卡池保底计算相同的物品
            public var uigfGachaType: UIGFGachaTypeGI
        }

        /// 语言代码
        public var lang: GachaLanguageCode?
        public var list: [GachaItemGI]
        /// 时区偏移
        public var timezone: Int
        /// UID
        public var uid: String
    }
}

// MARK: UIGFv4.ProfileHSR

extension UIGFv4 {
    public struct ProfileHSR: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(lang: GachaLanguageCode, list: [GachaItemHSR], timezone: Int?, uid: String) {
            self.lang = lang
            self.list = list
            self.timezone = timezone ?? GachaItem.getServerTimeZoneDelta(uid)
            self.uid = uid
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.list = try container.decode([GachaItemHSR].self, forKey: .list)
            self.lang = try container.decodeIfPresent(GachaLanguageCode.self, forKey: .lang)
            self.timezone = try container.decode(Int.self, forKey: .timezone)

            if let x = try? container.decode(String.self, forKey: .uid), !x.isEmpty {
                self.uid = x
            } else if let x = try? container.decode(Int.self, forKey: .uid) {
                self.uid = x.description
            } else {
                throw DecodingError.typeMismatch(
                    String.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Type for UID shall be either String or Integer."
                    )
                )
            }
        }

        // MARK: Public

        public struct GachaItemHSR: Codable, Hashable, Sendable {
            // MARK: Lifecycle

            public init(
                count: String?,
                gachaID: String,
                gachaType: GachaTypeHSR,
                id: String,
                itemID: String,
                itemType: String?,
                name: String?,
                rankType: String?,
                time: String
            ) {
                self.count = count
                self.gachaID = gachaID
                self.gachaType = gachaType
                self.id = id
                self.itemID = itemID
                self.itemType = itemType
                self.name = name
                self.rankType = rankType
                self.time = time
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var error: Error?

                self.count = try container.decodeIfPresent(String.self, forKey: .count)
                if Int(count ?? "1") == nil { error = UIGFv4.makeDecodingError(CodingKeys.count) }

                self.gachaType = try container.decode(GachaTypeHSR.self, forKey: .gachaType)

                self.id = try container.decode(String.self, forKey: .id)
                if Int(id) == nil { error = UIGFv4.makeDecodingError(CodingKeys.id) }

                self.itemID = try container.decode(String.self, forKey: .itemID)
                if Int(itemID) == nil { error = UIGFv4.makeDecodingError(CodingKeys.itemID) }

                self.itemType = try container.decodeIfPresent(String.self, forKey: .itemType)
                if itemType?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.itemType) }

                self.gachaID = try container.decode(String.self, forKey: .gachaID)
                if Int(gachaID) == nil { error = UIGFv4.makeDecodingError(CodingKeys.gachaID) }

                self.name = try container.decodeIfPresent(String.self, forKey: .name)
                if name?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.name) }

                self.rankType = try container.decodeIfPresent(String.self, forKey: .rankType)
                if Int(rankType ?? "3") == nil { error = UIGFv4.makeDecodingError(CodingKeys.rankType) }

                self.time = try container.decode(String.self, forKey: .time)
                if DateFormatter.forUIGFEntry(timeZoneDelta: 0).date(from: time) == nil {
                    error = UIGFv4.makeDecodingError(CodingKeys.time)
                }

                if let error = error { throw error }
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case count
                case gachaID = "gacha_id"
                case gachaType = "gacha_type"
                case id
                case itemID = "item_id"
                case itemType = "item_type"
                case name
                case rankType = "rank_type"
                case time
            }

            /// 卡池类型
            public enum GachaTypeHSR: String, Codable, Hashable, Sendable {
                case stellarWarp = "1"
                case characterEventWarp = "11"
                case lightConeEventWarp = "12"
                case departureWarp = "2"
            }

            /// 物品个数，一般为1，API返回
            public var count: String?
            /// 卡池 Id
            public var gachaID: String
            /// 卡池类型
            public var gachaType: GachaTypeHSR
            /// 内部 Id
            public var id: String
            /// 物品的内部 ID
            public var itemID: String
            /// 物品类型, API返回
            public var itemType: String?
            /// 物品名称, API返回
            public var name: String?
            /// 物品等级, API返回
            public var rankType: String?
            /// 获取物品的本地时间，与 timezone 一起计算出物品的准确获取时间，API返回
            public var time: String
        }

        /// 语言代码
        public var lang: GachaLanguageCode?
        public var list: [GachaItemHSR]
        /// 时区偏移
        public var timezone: Int
        /// UID
        public var uid: String
    }
}

// MARK: UIGFv4.ProfileZZZ

extension UIGFv4 {
    public struct ProfileZZZ: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(lang: GachaLanguageCode, list: [GachaItemZZZ], timezone: Int?, uid: String) {
            self.lang = lang
            self.list = list
            self.timezone = timezone ?? GachaItem.getServerTimeZoneDelta(uid)
            self.uid = uid
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.list = try container.decode([GachaItemZZZ].self, forKey: .list)
            self.lang = try container.decodeIfPresent(GachaLanguageCode.self, forKey: .lang)
            self.timezone = try container.decode(Int.self, forKey: .timezone)

            if let x = try? container.decode(String.self, forKey: .uid), !x.isEmpty {
                self.uid = x
            } else if let x = try? container.decode(Int.self, forKey: .uid) {
                self.uid = x.description
            } else {
                throw DecodingError.typeMismatch(
                    String.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Type for UID shall be either String or Integer."
                    )
                )
            }
        }

        // MARK: Public

        public struct GachaItemZZZ: Codable, Hashable, Sendable {
            // MARK: Lifecycle

            public init(
                count: String?,
                gachaID: String?,
                gachaType: GachaTypeZZZ,
                id: String,
                itemID: String,
                itemType: String?,
                name: String?,
                rankType: String?,
                time: String
            ) {
                self.count = count
                self.gachaID = gachaID
                self.gachaType = gachaType
                self.id = id
                self.itemID = itemID
                self.itemType = itemType
                self.name = name
                self.rankType = rankType
                self.time = time
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var error: Error?

                self.count = try container.decodeIfPresent(String.self, forKey: .count)
                if Int(count ?? "1") == nil { error = UIGFv4.makeDecodingError(CodingKeys.count) }

                self.gachaType = try container.decode(GachaTypeZZZ.self, forKey: .gachaType)

                self.id = try container.decode(String.self, forKey: .id)
                if Int(id) == nil { error = UIGFv4.makeDecodingError(CodingKeys.id) }

                self.itemID = try container.decode(String.self, forKey: .itemID)
                if Int(itemID) == nil { error = UIGFv4.makeDecodingError(CodingKeys.itemID) }

                self.itemType = try container.decodeIfPresent(String.self, forKey: .itemType)
                if itemType?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.itemType) }

                self.gachaID = try container.decodeIfPresent(String.self, forKey: .gachaID)
                if Int(gachaID ?? "") == nil { error = UIGFv4.makeDecodingError(CodingKeys.gachaID) }

                self.name = try container.decodeIfPresent(String.self, forKey: .name)
                if name?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.name) }

                self.rankType = try container.decodeIfPresent(String.self, forKey: .rankType)
                if Int(rankType ?? "3") == nil { error = UIGFv4.makeDecodingError(CodingKeys.rankType) }

                self.time = try container.decode(String.self, forKey: .time)
                if DateFormatter.forUIGFEntry(timeZoneDelta: 0).date(from: time) == nil {
                    error = UIGFv4.makeDecodingError(CodingKeys.time)
                }

                if let error = error { throw error }
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case count
                case gachaID = "gacha_id"
                case gachaType = "gacha_type"
                case id
                case itemID = "item_id"
                case itemType = "item_type"
                case name
                case rankType = "rank_type"
                case time
            }

            /// 卡池类型
            public enum GachaTypeZZZ: String, Codable, Hashable, Sendable, CaseIterable {
                case standardBanner = "1"
                case limitedBanner = "2"
                case wEngineBanner = "3"
                case bangbooBanner = "5"

                // MARK: Lifecycle

                public init?(altRawValue: String) {
                    let matched = Self.allCases.first { $0.alternativeRawValue == altRawValue }
                    guard let matched else { return nil }
                    self = matched
                }

                public init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    guard let x = try? container.decode(String.self),
                          let newSelf = GachaTypeZZZ(rawValue: x) ?? GachaTypeZZZ(altRawValue: x)
                    else {
                        throw DecodingError.typeMismatch(
                            GachaTypeZZZ.self,
                            DecodingError.Context(
                                codingPath: decoder.codingPath,
                                debugDescription: "Wrong type for GachaTypeZZZ."
                            )
                        )
                    }
                    self = newSelf
                }

                // MARK: Public

                public var alternativeRawValue: String {
                    rawValue + "001"
                }
            }

            /// 物品个数，一般为1，API返回
            public var count: String?
            /// 卡池 Id
            public var gachaID: String?
            /// 卡池类型
            public var gachaType: GachaTypeZZZ
            /// 记录内部 ID, API返回
            public var id: String
            /// 物品的内部 ID
            public var itemID: String
            /// 物品类型, API返回
            public var itemType: String?
            /// 物品名称, API返回
            public var name: String?
            /// 物品等级, API返回
            public var rankType: String?
            /// 获取物品的本地时间，与 timezone 一起计算出物品的准确获取时间，API返回
            public var time: String
        }

        /// 语言代码
        public var lang: GachaLanguageCode?
        public var list: [GachaItemZZZ]
        /// 时区偏移
        public var timezone: Int
        /// UID
        public var uid: String
    }
}

// MARK: - Extensions

extension UIGFv4 {
    public typealias DataEntry = ProfileHSR.GachaItemHSR // 注意这个地方是否与所属 App 一致。

    public enum SupportedHoYoGames: String {
        case genshinImpact = "GI"
        case starRail = "HSR"
        case zenlessZoneZero = "ZZZ"
    }

    public init() {
        self.info = .init()
        self.giProfiles = []
        self.hsrProfiles = []
        self.zzzProfiles = []
    }

    public var defaultFileNameStem: String {
        let dateFormatter = DateFormatter.forUIGFFileName
        return "\(Self.initials)\(dateFormatter.string(from: info.maybeDateExported ?? Date()))"
    }

    private static let initials = "UIGFv4_"

    public func getFileNameStem(
        uid: String? = nil,
        for game: SupportedHoYoGames? = .starRail
    )
        -> String {
        var stack = Self.initials
        if let game { stack += "\(game.rawValue)_" }
        if let uid { stack += "\(uid)_" }
        return defaultFileNameStem.replacingOccurrences(of: Self.initials, with: stack)
    }

    public var asDocument: Document {
        .init(model: self)
    }
}

extension UIGFv4.Info {
    // MARK: Lifecycle

    public init() {
        self.exportApp = "PizzaHelper4HSR"
        let shortVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.exportAppVersion = shortVer ?? "1.14.514"
        self.exportTimestamp = Int(Date.now.timeIntervalSince1970).description
        self.version = "v4.0"
    }

    public var maybeDateExported: Date? {
        guard let exportTimestamp = Double(exportTimestamp) else { return nil }
        return .init(timeIntervalSince1970: Double(exportTimestamp))
    }
}

extension UIGFv4.DataEntry {
    public func toGachaEntry(
        uid: String,
        lang: GachaLanguageCode?,
        timeZoneDelta: Int
    )
        -> GachaEntry {
        let lang = lang ?? .enUS // UIGFv4 不強制要求 lang，但這會導致一些問題。
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
    public func toUIGFEntry(
        langOverride: GachaLanguageCode? = nil,
        timeZoneDeltaOverride: Int? = nil
    )
        -> UIGFv4.DataEntry {
        // 导出的时候按照 server 时区那样来导出，
        // 这样可以直接沿用爬取伺服器数据时拿到的 time raw string，
        // 借此做到对导出的 JSON 内容的最大程度的传真。
        let timeZoneDelta: Int = timeZoneDeltaOverride ?? GachaItem.getServerTimeZoneDelta(uid)
        let langOverride = langOverride ?? Locale.gachaLangauge
        let newItemType = GachaItem.ItemType(itemID: itemID)
        let name = GachaMetaManager.shared.getLocalizedName(
            id: itemID, langOverride: langOverride
        ) ?? name
        // 每次导出 UIGF 资料时，都根据当前语言来重新生成 `item_type` 资料值。
        let itemTypeTranslated = newItemType.translatedRaw(for: langOverride)
        return .init(
            count: count.description, // Default is 1.
            gachaID: gachaID,
            gachaType: .init(rawValue: gachaTypeRawValue) ?? .departureWarp,
            id: id,
            itemID: itemID,
            itemType: itemTypeTranslated,
            name: name,
            rankType: rankRawValue,
            time: timeRawValue ?? time.asUIGFDate(timeZoneDelta: timeZoneDelta)
        )
    }
}

// MARK: - UIGFv4.Document

extension UIGFv4 {
    public struct Document: FileDocument {
        // MARK: Lifecycle

        public init(configuration: ReadConfiguration) throws {
            self.model = try JSONDecoder()
                .decode(
                    UIGFv4.self,
                    from: configuration.file.regularFileContents!
                )
        }

        public init(model: UIGFv4) {
            self.model = model
        }

        // MARK: Public

        public static var readableContentTypes: [UTType] = [.json]

        public let model: UIGFv4

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
