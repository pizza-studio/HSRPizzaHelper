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
            self.lang = try container.decode(GachaLanguageCode.self, forKey: .lang)
            self.timezone = try container.decode(Int.self, forKey: .timezone)

            if let x = try? container.decode(String.self, forKey: .uid) {
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
            self.lang = try container.decode(GachaLanguageCode.self, forKey: .lang)
            self.timezone = try container.decode(Int.self, forKey: .timezone)

            if let x = try? container.decode(String.self, forKey: .uid) {
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
                gachaID: String?,
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
            public var gachaID: String?
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
            self.lang = try container.decode(GachaLanguageCode.self, forKey: .lang)
            self.timezone = try container.decode(Int.self, forKey: .timezone)

            if let x = try? container.decode(String.self, forKey: .uid) {
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

