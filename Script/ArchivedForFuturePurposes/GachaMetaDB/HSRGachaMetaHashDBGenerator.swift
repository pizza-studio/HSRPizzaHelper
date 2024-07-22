// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - ProtagonistDetector

public enum ProtagonistDetector {
    case ofCaelus
    case ofStelle

    // MARK: Lifecycle

    public init?(rawValue: Int) {
        switch rawValue {
        case 8001, 8003, 8005, 8007, 8009, 8011, 8013, 8015: self = .ofCaelus
        case 8002, 8004, 8006, 8008, 8010, 8012, 8014, 8016: self = .ofStelle
        default: return nil
        }
    }

    public init?(against target: GachaItemMeta) {
        guard let map = target.l10nMap,
              map.description.contains(#"{NICKNAME}"#)
        else { return nil }
        self = (target.id % 2 == 0) ? .ofStelle : .ofCaelus
    }
}

// MARK: - GachaDictLang

public enum GachaDictLang: String, CaseIterable, Sendable, Identifiable {
    case langCHS
    case langCHT
    case langDE
    case langEN
    case langES
    case langFR
    case langID
    case langJP
    case langKR
    case langPT
    case langRU
    case langTH
    case langVI

    // MARK: Public

    public static let tableStelle = [
        "de-de": "Stella",
        "en-us": "Stelle",
        "es-es": "Estela",
        "fr-fr": "Stelle",
        "id-id": "Stelle",
        "ja-jp": "星",
        "ko-kr": "스텔레",
        "pt-pt": "Stelle",
        "ru-ru": "Стелла",
        "th-th": "Stelle",
        "vi-vn": "Stelle",
        "zh-cn": "星",
        "zh-tw": "星",
    ]

    public static let tableCaelus = [
        "de-de": "Caelus",
        "en-us": "Caelus",
        "es-es": "Caelus",
        "fr-fr": "Caelus",
        "id-id": "Caelus",
        "ja-jp": "穹",
        "ko-kr": "카일루스",
        "pt-pt": "Caelus",
        "ru-ru": "Келус",
        "th-th": "Caelus",
        "vi-vn": "Caelus",
        "zh-cn": "穹",
        "zh-tw": "穹",
    ]

    public var id: String { langID }

    public var langID: String {
        switch self {
        case .langCHS: "zh-cn"
        case .langCHT: "zh-tw"
        case .langDE: "de-de"
        case .langEN: "en-us"
        case .langES: "es-es"
        case .langFR: "fr-fr"
        case .langID: "id-id"
        case .langJP: "ja-jp"
        case .langKR: "ko-kr"
        case .langPT: "pt-pt"
        case .langRU: "ru-ru"
        case .langTH: "th-th"
        case .langVI: "vi-vn"
        }
    }

    public var filename: String {
        rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending(".json")
    }

    public var url: URL! {
        URL(string: """
        https://raw.githubusercontent.com/Dimbreath/StarRailData/master/TextMap/\(filename)
        """)
    }
}

// MARK: - QualityType

public enum QualityType: String, Codable {
    case v5sp = "QUALITY_ORANGE_SP"
    case v5 = "QUALITY_ORANGE"
    case v4 = "QUALITY_PURPLE"
    case v3 = "QUALITY_BLUE"
    case v2 = "QUALITY_GREEN"
    case v1 = "QUALITY_GRAY"

    // MARK: Internal

    var asrank: Int {
        switch self {
        case .v5, .v5sp: return 5
        case .v4: return 4
        case .v3: return 3
        case .v2: return 2
        case .v1: return 1
        }
    }
}

// MARK: - NameHashUnit

public struct NameHashUnit: Codable {
    public enum CodingKeys: String, CodingKey {
        case hash = "Hash"
    }

    public let hash: Int
}

// MARK: - GachaItemMeta

public class GachaItemMeta: Codable {
    // MARK: Lifecycle

    public init(id: Int, rank: Int, nameTextMapHash: Int) {
        self.id = id
        self.rank = rank
        self.nameTextMapHash = nameTextMapHash
    }

    // MARK: Public

    public let id: Int
    public let rank: Int
    public let nameTextMapHash: Int
    public var l10nMap: [String: String]?

    public var isCharacter: Bool {
        id <= 9999
    }
}

// MARK: - RawItemFetchModelProtocol

public protocol RawItemFetchModelProtocol {
    var id: Int { get }
    var nameTextMapHash: Int { get }
    var rarity: Int { get }
}

// MARK: - AvatarRawItem

public class AvatarRawItem: Codable, RawItemFetchModelProtocol {
    // MARK: Lifecycle

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.nameTextMapHash = (try container.decode(NameHashUnit.self, forKey: .nameTextMapHash)).hash
        let rawRarityText = try container.decode(String.self, forKey: .rarity)
        self.rarity = Int(rawRarityText.last?.description ?? "3") ?? 3
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey {
        case id = "AvatarID"
        case nameTextMapHash = "AvatarName"
        case rarity = "Rarity"
    }

    public let id: Int
    public let nameTextMapHash: Int
    public let rarity: Int
}

// MARK: - WeaponRawItem

public class WeaponRawItem: Codable, RawItemFetchModelProtocol {
    // MARK: Lifecycle

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.nameTextMapHash = (try container.decode(NameHashUnit.self, forKey: .nameTextMapHash)).hash
        let rawRarityText = try container.decode(String.self, forKey: .rarity)
        self.rarity = Int(rawRarityText.last?.description ?? "3") ?? 3
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey {
        case id = "EquipmentID"
        case nameTextMapHash = "EquipmentName"
        case rarity = "Rarity"
    }

    public let id: Int
    public let nameTextMapHash: Int
    public let rarity: Int
}

extension RawItemFetchModelProtocol {
    public func toGachaItemMeta() -> GachaItemMeta {
        .init(id: id, rank: rarity, nameTextMapHash: nameTextMapHash)
    }
}

let urlHeader = """
https://raw.githubusercontent.com/Dimbreath/StarRailData/master/ExcelOutput/
"""

let urlAvatarJSON = URL(string: urlHeader + "AvatarConfig.json")!
let urlWeaponJSON = URL(string: urlHeader + "EquipmentConfig.json")!

func fetchAvatars() async throws -> [GachaItemMeta] {
    let (data, _) = try await URLSession.shared.data(from: urlAvatarJSON)
    let response = try JSONDecoder().decode([String: AvatarRawItem].self, from: data)
    return response.map { $0.value.toGachaItemMeta() }
}

func fetchWeapons() async throws -> [GachaItemMeta] {
    let (data, _) = try await URLSession.shared.data(from: urlWeaponJSON)
    let response = try JSONDecoder().decode([String: WeaponRawItem].self, from: data)
    return response.map { $0.value.toGachaItemMeta() }
}

let items = try await withThrowingTaskGroup(of: [GachaItemMeta].self, returning: [GachaItemMeta].self) { taskGroup in
    taskGroup.addTask { try await fetchAvatars() }
    taskGroup.addTask { try await fetchWeapons() }
    var images = [GachaItemMeta]()
    for try await result in taskGroup {
        images.append(contentsOf: result)
    }
    return images
}

let neededHashIDs = Set<String>(items.map(\.nameTextMapHash.description))

// MARK: - Get translations from AnimeGameData

let dictAll = try await withThrowingTaskGroup(
    of: (subDict: [String: String], lang: GachaDictLang).self,
    returning: [String: [String: String]].self
) { taskGroup in
    GachaDictLang.allCases.forEach { locale in
        taskGroup.addTask {
            let (data, _) = try await URLSession.shared.data(from: locale.url)
            var dict = try JSONDecoder().decode([String: String].self, from: data)
            let keysToRemove = Set<String>(dict.keys).subtracting(neededHashIDs)
            keysToRemove.forEach { dict.removeValue(forKey: $0) }
            if locale == .langJP {
                dict.keys.forEach { theKey in
                    guard dict[theKey]?.contains("{RUBY") ?? false else { return }
                    if let rawStrToHandle = dict[theKey], rawStrToHandle.contains("{") {
                        dict[theKey] = rawStrToHandle.replacingOccurrences(
                            of: #"\{RUBY.*?\}"#,
                            with: "",
                            options: .regularExpression
                        )
                    }
                }
            }
            return (subDict: dict, lang: locale)
        }
    }
    var results = [String: [String: String]]()
    for try await result in taskGroup {
        results[result.lang.langID] = result.subDict
    }
    return results
}

// MARK: - Apply translations

items.forEach { currentItem in
    GachaDictLang.allCases.forEach { localeID in
        let hashKey = currentItem.nameTextMapHash.description
        guard let dict = dictAll[localeID.langID]?[hashKey] else { return }
        if currentItem.l10nMap == nil { currentItem.l10nMap = [:] }
        currentItem.l10nMap?[localeID.langID] = dict
    }
}

// MARK: - Prepare Dictionary.

var dict: [String: GachaItemMeta] = [:]

items.forEach { item in
    guard let desc = item.l10nMap?.description,
          !desc.contains("测试")
    else { return }
    let key = item.id.description
    protagonistName: switch ProtagonistDetector(against: item) {
    case .ofCaelus: item.l10nMap = GachaDictLang.tableCaelus
    case .ofStelle: item.l10nMap = GachaDictLang.tableStelle
    default: break protagonistName
    }
    dict[key] = item
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

let encoded = String(data: try encoder.encode(dict), encoding: .utf8)

print(encoded ?? "Error happened.")
NSLog("All Tasks Done.")
