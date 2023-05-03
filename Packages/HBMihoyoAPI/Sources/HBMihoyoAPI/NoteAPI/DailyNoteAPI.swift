//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

@available(iOS 15.0, *)
public extension MiHoYoAPI {
    static func note(server: Server, uid: String, cookie: String) async throws -> DailyNote {
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]
        let request = try Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/hkrpg/api/note",
            queryItems: queryItems,
            cookie: cookie
        )

        print(request)
        print(request.allHTTPHeaderFields!)

        let (data, _) = try await URLSession.shared.data(for: request)

        print(String(data: data, encoding: .utf8)!)
        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}
