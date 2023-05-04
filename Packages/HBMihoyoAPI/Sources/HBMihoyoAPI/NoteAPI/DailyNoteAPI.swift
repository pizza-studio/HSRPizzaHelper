//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    public static func note(server: Server, uid: String, cookie: String) async throws -> DailyNote {
        // TODO: Remove this when release
        #if DEBUG
        let exampleURL = Bundle.module.url(forResource: "daily_note_example", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        return try .decodeFromMiHoYoAPIJSONResult(data: exampleData)
        #endif
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

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}
