//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    public func note(server: Server, uid: String, cookie: String) async throws -> DailyNote {
        let queryItems: [URLQueryItem] = [
            .init(name: "server", value: server.rawValue),
            .init(name: "role_id", value: uid)
        ]
        let request = try generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/hkrpg/api/note?server=prod_gf_cn&role_id=102517327",
            queryItems: queryItems,
            cookie: cookie
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}
