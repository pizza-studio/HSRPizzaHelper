//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    /// Get `MultiToken` by using a login ticket
    ///
    /// - Parameters:
    ///     - loginTicket: Login ticket string to use when making the API request
    ///     - loginUid: Login user ID string
    /// - Returns: A `MultiToken` struct
    public static func getMultiTokenByLoginTicket(
        loginTicket: String,
        loginUid: String
    ) async throws
        -> MultiToken {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "login_ticket", value: loginTicket),
            URLQueryItem(name: "token_types", value: "3"),
            URLQueryItem(name: "uid", value: loginUid),
        ]

        let request = try await Self.generateAccountAPIRequest(
            region: .mainlandChina,
            path: "/auth/api/getMultiTokenByLoginTicket",
            queryItems: queryItems,
            cookie: nil
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
