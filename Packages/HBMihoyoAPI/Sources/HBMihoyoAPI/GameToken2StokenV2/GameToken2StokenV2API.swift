//
//  File.swift
//
//
//  Created by 戴藏龙 on 2024/5/12.
//

import Foundation

extension MiHoYoAPI {
    public static func gameToken2StokenV2(accountId: String, gameToken: String) async throws -> GameToken2StokenV2Data {
        var request =
            URLRequest(url: URL(string: "https://api-takumi.mihoyo.com/account/ma-cn-session/app/getTokenByGameToken")!)
        request.httpMethod = "POST"

        struct Body: Encodable {
            let accountId: Int
            let gameToken: String

            enum CodingKeys: String, CodingKey {
                case accountId = "account_id"
                case gameToken = "game_token"
            }
        }

        request.httpBody = try JSONEncoder().encode(Body(accountId: Int(accountId)!, gameToken: gameToken))
        request.setValue("bll8iq97cem8", forHTTPHeaderField: "x-rpc-app_id")

        let (result, _) = try await URLSession.shared.data(for: request)
        return try .decodeFromMiHoYoAPIJSONResult(data: result)
    }

    public static func stoken2LTokenV1(mid: String, stoken: String) async throws -> Stoken2LTokenV1Data {
        var request =
            URLRequest(url: URL(string: "https://passport-api.mihoyo.com/account/auth/api/getLTokenBySToken")!)
        request.httpMethod = "GET"

        request.setValue("mid=\(mid); stoken=\(stoken); ", forHTTPHeaderField: "cookie")

        let (result, _) = try await URLSession.shared.data(for: request)
        return try .decodeFromMiHoYoAPIJSONResult(data: result)
    }
}
