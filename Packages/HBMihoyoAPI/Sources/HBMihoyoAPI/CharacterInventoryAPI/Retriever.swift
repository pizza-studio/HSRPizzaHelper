// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

extension MiHoYoAPI {
    /// Fetches the character inventory list of the specified user.
    ///
    /// - Parameter server: The server where the user's account exists.
    /// - Parameter uid: The uid of the user whose character inventory to fetch.
    /// - Parameter cookie: The cookie of the user. This is used for authentication purposes.
    ///
    /// - Throws: An error of type `MiHoYoAPIError` if an error occurs while making the API request.
    ///
    /// - Returns: An instance of `CharacterInventory` that represents the user's character inventory.
    public static func characterInventory(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> CharacterInventory {
        switch server.region {
        case .global, .mainlandChina:
            return try await generalCharacterInventory(
                server: server,
                uid: uid,
                cookie: cookie,
                deviceFingerPrint: deviceFingerPrint
            )
        }
    }

    /// Fetches the character inventory list of the specified user.
    ///
    /// - Parameter server: The server where the user's account exists.
    /// - Parameter uid: The uid of the user whose character inventory to fetch.
    /// - Parameter cookie: The cookie of the user. This is used for authentication purposes.
    ///
    /// - Throws: An error of type `MiHoYoAPI.Error` if an error occurs while making the API request.
    ///
    /// - Returns: An instance of `GeneralCharacterInventory` that represents the user's character inventory.
    private static func generalCharacterInventory(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> CharacterInventory {
        var queryItems: [URLQueryItem] = [
            .init(name: "need_wiki", value: "false"),
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                return ["x-rpc-device_fp": deviceFingerPrint]
            } else {
                return nil
            }
        }()

        var newCookie = cookie
        if server.region == .mainlandChina {
            queryItems.insert(.init(name: "id", value: "1001"), at: 0)
            let newCookieWrapped = newCookie.replacingOccurrences(of: "; ", with: "\n")
                .replacingOccurrences(of: ";", with: "\n")
            var vars = [String: String]()
            newCookieWrapped.enumerateLines { currentLine, _ in
                let cells = currentLine.split(separator: "=")
                guard cells.count == 2 else { return }
                vars[cells[0].description] = cells[1].description
            }

            let cookieToken = try await cookieToken(cookie: cookie, queryItems: queryItems)
            vars["account_id"] = cookieToken.uid
            vars["cookie_token"] = cookieToken.cookieToken

            newCookie = "account_id=\(cookieToken.uid); cookie_token=\(cookieToken.cookieToken); " + cookie
            newCookie.removeAll()
            newCookie.append("account_id=\(vars["account_id"] ?? ""); ")
            newCookie.append("cookie_token=\(vars["cookie_token"] ?? ""); ")
            newCookie.append("ltoken=\(vars["ltoken"] ?? ""); ")
            newCookie.append("ltuid=\(vars["ltuid"] ?? ""); ")
        }

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/hkrpg/api/avatar/info",
            queryItems: queryItems,
            cookie: newCookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
