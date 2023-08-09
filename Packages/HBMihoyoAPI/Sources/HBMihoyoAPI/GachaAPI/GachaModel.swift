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

public enum GachaType: String, Codable, CaseIterable {
    case regularWarp = "1"
    case characterEventWarp = "11"
    case lightConeEventWarp = "12"

    // MARK: Public

    public func next() -> Self? {
        switch self {
        case .regularWarp:
            return .characterEventWarp
        case .characterEventWarp:
            return .lightConeEventWarp
        case .lightConeEventWarp:
            return nil
        }
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
        let timeString = try container.decode(String.self, forKey: .time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.time = dateFormatter.date(from: timeString)!
        self.gachaID = try container.decode(String.self, forKey: .gachaID)
        self.gachaType = try container.decode(GachaType.self, forKey: .gachaType)
        self.itemID = try container.decode(String.self, forKey: .itemID)
        self.count = Int(try container.decode(String.self, forKey: .count))!
        self.name = try container.decode(String.self, forKey: .name)
        self.itemType = try container.decode(GachaItem.ItemType.self, forKey: .itemType)
        self.rankType = try container.decode(GachaItem.Rank.self, forKey: .rankType)
        self.id = try container.decode(String.self, forKey: .id)
        self.lang = try container.decode(String.self, forKey: .lang)
    }

    // MARK: Public

    public enum Rank: String, Codable {
        case three = "3"
        case four = "4"
        case five = "5"
    }

    public enum ItemType: String, Codable {
        case lightCones = "光锥"
        case characters = "角色"
    }

    public let uid: String
    public let time: Date
    public let gachaID: String
    public let gachaType: GachaType
    public let itemID: String
    public let count: Int
    public let name: String
    public let itemType: ItemType
    public let rankType: Rank
    public let id: String
    public let lang: String

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
        case rankType = "rank_type"
        case id
        case lang
    }
}
