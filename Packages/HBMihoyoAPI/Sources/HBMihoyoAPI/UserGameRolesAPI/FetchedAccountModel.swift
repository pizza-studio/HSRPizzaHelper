//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - FetchedAccount

public struct FetchedAccount: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.region = try container.decode(String.self, forKey: .region)
        self.gameBiz = try container.decode(String.self, forKey: .gameBiz)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.level = try container.decode(Int.self, forKey: .level)
        self.isOfficial = try container.decode(Bool.self, forKey: .isOfficial)
        self.regionName = try container.decode(String.self, forKey: .regionName)
        self.gameUid = try container.decode(String.self, forKey: .gameUid)
        self.isChosen = try container.decode(Bool.self, forKey: .isChosen)
    }

    // MARK: Public

    public let region: String
    public let gameBiz: String
    public let nickname: String
    public let level: Int
    public let isOfficial: Bool
    public let regionName: String
    public let gameUid: String
    public let isChosen: Bool

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case region
        case gameBiz = "game_biz"
        case nickname
        case level
        case isOfficial = "is_official"
        case regionName = "region_name"
        case gameUid = "game_uid"
        case isChosen = "is_chosen"
    }
}

// MARK: Identifiable

extension FetchedAccount: Identifiable {
    public var id: String { gameUid }
}

// MARK: Hashable

extension FetchedAccount: Hashable {}

// MARK: - FetchedAccountDecodeHelper

struct FetchedAccountDecodeHelper: Decodable, DecodableFromMiHoYoAPIJSONResult {
    let list: [FetchedAccount]
}
