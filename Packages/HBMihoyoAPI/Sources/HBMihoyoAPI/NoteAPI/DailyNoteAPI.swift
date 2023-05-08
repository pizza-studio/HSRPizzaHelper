//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    /// Fetches the daily note of the specified user.
    ///
    /// - Parameter server: The server where the user's account exists.
    /// - Parameter uid: The uid of the user whose daily note to fetch.
    /// - Parameter cookie: The cookie of the user. This is used for authentication purposes.
    ///
    /// - Throws: An error of type `MiHoYoAPI.Error` if an error occurs while making the API request.
    ///
    /// - Returns: An instance of `DailyNote` that represents the user's daily note.
    public static func note(server: Server, uid: String, cookie: String) async throws -> DailyNote {
        #if DEBUG
        return .example()
        #else
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
        #endif
    }
}
