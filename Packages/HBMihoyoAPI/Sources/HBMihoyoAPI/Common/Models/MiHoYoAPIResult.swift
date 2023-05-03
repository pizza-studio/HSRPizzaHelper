//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

protocol DecodableFromMiHoYoAPIJSONResult: Decodable {}

extension DecodableFromMiHoYoAPIJSONResult {
    static func decodeFromMiHoYoAPIJSONResult(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        let result = try decoder.decode(MiHoYoAPIJSONResult<Self>.self, from: data)
        if result.retcode == 0 {
            return result.data!
        } else {
            throw MiHoYoAPIError(retcode: result.retcode, message: result.message)
        }
    }
}

fileprivate struct MiHoYoAPIJSONResult<T: DecodableFromMiHoYoAPIJSONResult>: Decodable {
    let retcode: Int
    let message: String
    let data: T?

    enum CodingKeys: String, CodingKey {
        case retcode
        case message
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        retcode = try container.decode(Int.self, forKey: .retcode)
        message = try container.decode(String.self, forKey: .message)
        data = try container.decodeIfPresent(T.self, forKey: .data)
    }
}

extension Array: DecodableFromMiHoYoAPIJSONResult where Element: Decodable {}
