//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    public static func getUserGameRolesByCookie(region: Region, cookie: String) async throws -> [FetchedAccount] {
        let queryItems: [URLQueryItem] = [
            .init(name: "game_biz", value: region.rawValue),
        ]

        let request = try await Self.generateAccountAPIRequest(
            region: region,
            path: "/binding/api/getUserGameRolesByCookie",
            queryItems: queryItems,
            cookie: cookie
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        let list = try FetchedAccountDecodeHelper.decodeFromMiHoYoAPIJSONResult(data: data)
        return list.list
    }
}
