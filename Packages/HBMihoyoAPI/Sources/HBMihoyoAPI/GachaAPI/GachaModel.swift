//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/8/9.
//

import Foundation

// MARK: - GachaRequestAuthentication

struct GachaRequestAuthentication {
    let authenticationKey: String
    let authenticationKeyVersion: String
    let signType: String
    let server: Server
}

// MARK: - GachaError

public enum GachaError: Error {
    case fetchDataError(page: Int, size: Int, gachaType: GachaType, error: Error)
}

// MARK: - ParseGachaURLError

public enum ParseGachaURLError: Error {
    case invalidURL
    case noAuthenticationKey
    case noAuthenticationKeyVersion
    case noServer
    case invalidServer
    case noSignType
}

// MARK: - GachaType

public enum GachaType: String, Codable, Hashable, CaseIterable, Sendable, Comparable {
    case characterEventWarp = "11"
    case lightConeEventWarp = "12"
    case stellarWarp = "1" // 群星跃迁，常驻池
    case departureWarp = "2" // 始发跃迁，新手池

    // MARK: Public

    public static let nonLimitedWarps: [GachaType] = [.stellarWarp, .departureWarp]

    public var isLimitedWarp: Bool {
        !Self.nonLimitedWarps.contains(self)
    }

    public var isRegularWarp: Bool {
        Self.nonLimitedWarps.contains(self)
    }

    public static func < (lhs: GachaType, rhs: GachaType) -> Bool {
        Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }

    public func next() -> Self? {
        Self.allCases.first { self < $0 }
    }
}

// MARK: - GachaResult

public struct GachaResult: DecodableFromMiHoYoAPIJSONResult {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = Int(try container.decode(String.self, forKey: .page))!
        self.size = Int(try container.decode(String.self, forKey: .size))!
        self.region = try container.decode(Server.self, forKey: .region)
        self.regionTimeZone = try container.decode(Int.self, forKey: .regionTimeZone)
        self.list = try container.decode([GachaItem].self, forKey: .list)
    }

    // MARK: Public

    public let page: Int
    public let size: Int
    public let region: Server
    public let regionTimeZone: Int
    public let list: [GachaItem]

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case page
        case size
        case region
        case regionTimeZone = "region_time_zone"
        case list
    }
}

// MARK: - GachaItem

public struct GachaItem: Codable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.timeRawValue = try container.decode(String.self, forKey: .time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // 抽卡记录的网页固定显示伺服器时间。
        dateFormatter.timeZone = .init(secondsFromGMT: Self.getServerTimeZoneDelta(uid) * 3600)
        if let time = dateFormatter.date(from: timeRawValue) {
            self.time = time
        } else {
            throw DecodingError.typeMismatch(
                Date.self,
                .init(codingPath: [CodingKeys.time], debugDescription: "unable to decode time")
            )
        }
        self.gachaID = try container.decode(String.self, forKey: .gachaID)
        self.gachaType = try container.decode(GachaType.self, forKey: .gachaType)
        self.itemID = try container.decode(String.self, forKey: .itemID)
        if let count = Int(try container.decode(String.self, forKey: .count)) {
            self.count = count
        } else {
            throw DecodingError.typeMismatch(
                Int.self,
                .init(codingPath: [CodingKeys.count], debugDescription: "unable to decode count")
            )
        }
        self.name = try container.decode(String.self, forKey: .name)
        self.itemType = try container.decode(ItemType.self, forKey: .itemType)
        self.rank = try container.decode(GachaItem.Rank.self, forKey: .rank)
        self.id = try container.decode(String.self, forKey: .id)
        self.lang = try container.decode(MiHoYoAPILanguage.self, forKey: .lang)
    }

    // MARK: Public

    public enum Rank: String, Codable, Comparable {
        case three = "3"
        case four = "4"
        case five = "5"

        // MARK: Public

        public static func < (lhs: GachaItem.Rank, rhs: GachaItem.Rank) -> Bool {
            Int(lhs.rawValue)! < Int(rhs.rawValue)!
        }
    }

    public enum ItemType: String, Codable {
        case lightCones
        case characters

        // MARK: Lifecycle

        public init(itemID: String) {
            switch itemID.count {
            case 5...: self = .lightCones
            default: self = .characters
            }
        }

        public init?(rawString: String) {
            switch rawString {
            case "角色", "character", "characters", "Figur", "Figuren",
                 "Karakter", "Nhân Vật", "Personagem", "Personagens", "Personaje",
                 "Personajes", "Personnage", "Personnages", "Персонажи",
                 "ตัวละคร", "캐릭터", "キャラクター":
                self = .characters
            case "光円錐", "光锥", "光錐", "武器", "Arma", "Arme", "Cône de lumière",
                 "Cone de Luz", "cônes de lumière", "Cones de Luz", "Cono de luz",
                 "Conos de luz", "Lichtkegel", "Light Cone", "light_cone", "light_cones",
                 "lightcone", "lightcones", "Nón Ánh Sáng", "Senjata", "Vũ Khí", "Waffe",
                 "weapon", "weapons", "Оружие", "Световые конусы", "อาวุธ", "광추", "무기":
                self = .lightCones
            default: return nil
            }
        }

        public init(from decoder: Decoder) throws {
            let decoded = try decoder.singleValueContainer().decode(String.self)
            self = .init(rawString: decoded) ?? .lightCones
        }
    }

    public let uid: String
    public let time: Date
    public let timeRawValue: String
    public let gachaID: String
    public let gachaType: GachaType
    public let itemID: String
    public let count: Int
    public let name: String
    public let itemType: ItemType
    public let rank: Rank
    public let id: String
    public let lang: MiHoYoAPILanguage

    public static func getServerTimeZoneDelta(_ uid: String) -> Int {
        // 抽卡记录的网页固定显示伺服器时间。
        guard (9 ... 10).contains(uid.count) else { return 8 }
        var uid = uid
        if uid.count == 10 {
            uid.remove(at: uid.indices.first ?? .init(utf16Offset: 0, in: uid))
        }
        guard let firstDigit = uid.first else { return 8 }
        switch firstDigit {
        case "6": return -5
        case "7": return 1
        default: return 8
        }
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case uid
        case time
        case gachaID = "gacha_id"
        case gachaType = "gacha_type"
        case itemID = "item_id"
        case count
        case name
        case itemType = "item_type"
        case rank = "rank_type"
        case id
        case lang
    }
}
