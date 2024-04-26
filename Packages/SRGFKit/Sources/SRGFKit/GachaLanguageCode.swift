// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - GachaLanguageCode

public enum GachaLanguageCode: String, CaseIterable, Sendable {
    case th = "th-th" // 泰语（泰国）
    case ko = "ko-kr" // 朝鲜语（韩国）
    case es = "es-es" // 西班牙语（西班牙）
    case ja = "ja-jp" // 日语（日本）
    case zhHans = "zh-cn" // 中文（中国大陆）
    case id = "id-id" // 印度尼西亚语（印度尼西亚）
    case pt = "pt-pt" // 葡萄牙语（葡萄牙）
    case de = "de-de" // 德语（德国）
    case fr = "fr-fr" // 法语（法国）
    case zhHant = "zh-tw" // 中文（台湾）
    case ru = "ru-ru" // 俄语（俄罗斯）
    case enUS = "en-us" // 英语（美国）
    case vi = "vi-vn" // 越南语（越南）

    // MARK: Lifecycle

    public init?(langTag: String) {
        switch langTag.prefix(2).lowercased() {
        case "ja", "jp": self = .ja
        case "ko", "kr": self = .ko
        case "es": self = .es
        case "th": self = .th
        case "id": self = .id
        case "pt": self = .pt
        case "de": self = .de
        case "fr": self = .fr
        case "ru": self = .ru
        case "en": self = .enUS
        case "vi": self = .vi
        case "zh":
            switch langTag.count {
            case 7...:
                let middleTag = langTag.map(\.description)[3 ... 6].joined().lowercased()
                switch middleTag {
                case "hans": self = .zhHans
                case "hant": self = .zhHant
                default: break
                }
            case 0 ... 5:
                let trailingTag = langTag.map(\.description)[3 ... 4].joined().lowercased()
                switch trailingTag {
                case "hk", "mo", "tw": self = .zhHant
                case "cn", "my", "sg": self = .zhHans
                default: break
                }
            default: break
            }
            self = .zhHans
        default: return nil
        }
    }
}

// MARK: Codable

extension GachaLanguageCode: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let languageCode = GachaLanguageCode(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid GachaLanguageCode raw value: \(rawValue)"
            )
        }
        self = languageCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: CustomStringConvertible

extension GachaLanguageCode {
    public var localizedKey: String {
        "gacha.languageCode.\(String(describing: self))"
    }

    public var localized: String {
        String(localized: "\(localizedKey)")
    }
}
