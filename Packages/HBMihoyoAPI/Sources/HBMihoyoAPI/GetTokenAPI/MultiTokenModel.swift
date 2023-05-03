//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

public struct MultiToken: Decodable {
    public let stoken: String
    public let ltoken: String

    enum CodingKeys: String, CodingKey {
        case list = "list"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decode([Item].self, forKey: .list)

        if let stoken = get("stoken"), let ltoken = get("ltoken") {
            self.stoken = stoken
            self.ltoken = ltoken
        } else {
            throw MiHoYoAPIError(retcode: -9999, message: "Fail to get stoken & ltoken. Result is: \(items)")
        }

        func get(_ tokenName: String) -> String? {
            items.first(where: { item in
                item.name == tokenName
            })?.token
        }
    }

    struct Item: Decodable {
        public let name: String
        public let token: String
    }
}

extension MultiToken: DecodableFromMiHoYoAPIJSONResult {}
