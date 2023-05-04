//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - MultiToken

public struct MultiToken: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decode([Item].self, forKey: .list)

        if let stoken = get("stoken"), let ltoken = get("ltoken") {
            self.stoken = stoken
            self.ltoken = ltoken
        } else {
            let unknownErrorRetcode = -9999
            throw MiHoYoAPIError(
                retcode: unknownErrorRetcode,
                message: "Fail to get stoken & ltoken. Result is: \(items)"
            )
        }

        func get(_ tokenName: String) -> String? {
            items.first(where: { item in
                item.name == tokenName
            })?.token
        }
    }

    // MARK: Public

    public let stoken: String
    public let ltoken: String

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case list
    }

    struct Item: Decodable {
        public let name: String
        public let token: String
    }
}

// MARK: DecodableFromMiHoYoAPIJSONResult

extension MultiToken: DecodableFromMiHoYoAPIJSONResult {}
