//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension MiHoYoAPI {
    /// 返回CookieToken，需要验证SToken。
    static func cookieToken(cookie: String, queryItems: [URLQueryItem] = []) async throws -> GetCookieTokenResult {
        let request = try await generateRequest(
            region: .mainlandChina,
            host: "api-takumi.mihoyo.com",
            path: "/auth/api/getCookieAccountInfoBySToken",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: nil
        )
        let (data, _) = try await URLSession.shared.data(for: request)

        let result = try GetCookieTokenResult.decodeFromMiHoYoAPIJSONResult(data: data)

        return result
    }
}

// MARK: - GetCookieTokenResult

struct GetCookieTokenResult: Decodable, DecodableFromMiHoYoAPIJSONResult {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cookieToken = try container.decode(String.self, forKey: .cookieToken)
        self.uid = try container.decode(String.self, forKey: .uid)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case cookieToken = "cookie_token"
        case uid
    }

    let cookieToken: String
    let uid: String
}
