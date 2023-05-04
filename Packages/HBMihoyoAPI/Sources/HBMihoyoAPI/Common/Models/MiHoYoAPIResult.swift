//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - DecodableFromMiHoYoAPIJSONResult

protocol DecodableFromMiHoYoAPIJSONResult: Decodable {}

extension DecodableFromMiHoYoAPIJSONResult {
    static func decodeFromMiHoYoAPIJSONResult(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        let result = try decoder.decode(MiHoYoAPIJSONResult<Self>.self, from: data)
        if result.retcode == 0 {
            // swiftlint:disable:next force_unwrapping
            return result.data!
        } else {
            throw MiHoYoAPIError(retcode: result.retcode, message: result.message)
        }
    }
}

// MARK: - MiHoYoAPIJSONResult

private struct MiHoYoAPIJSONResult<T: DecodableFromMiHoYoAPIJSONResult>: Decodable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.retcode = try container.decode(Int.self, forKey: .retcode)
        self.message = try container.decode(String.self, forKey: .message)
        self.data = try container.decodeIfPresent(T.self, forKey: .data)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case retcode
        case message
        case data
    }

    let retcode: Int
    let message: String
    let data: T?
}

// MARK: - Array + DecodableFromMiHoYoAPIJSONResult

extension Array: DecodableFromMiHoYoAPIJSONResult where Element: Decodable {}
