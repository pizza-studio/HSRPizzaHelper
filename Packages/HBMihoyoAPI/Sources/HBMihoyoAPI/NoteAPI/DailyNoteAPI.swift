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
    /// - Throws: An error of type `MiHoYoAPIError` if an error occurs while making the API request.
    ///
    /// - Returns: An instance of `DailyNote` that represents the user's daily note.
    public static func note(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> DailyNote {
        switch server.region {
        case .china:
            return try await widgetNote(cookie: cookie, deviceFingerPrint: deviceFingerPrint)
        case .global:
            return try await generalDailyNote(
                server: server,
                uid: uid,
                cookie: cookie,
                deviceFingerPrint: deviceFingerPrint
            )
        }
    }

    /// Fetches the daily note of the specified user.
    ///
    /// - Parameter server: The server where the user's account exists.
    /// - Parameter uid: The uid of the user whose daily note to fetch.
    /// - Parameter cookie: The cookie of the user. This is used for authentication purposes.
    ///
    /// - Throws: An error of type `MiHoYoAPI.Error` if an error occurs while making the API request.
    ///
    /// - Returns: An instance of `GeneralDailyNote` that represents the user's daily note.
    static func generalDailyNote(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> GeneralDailyNote {
//        #if DEBUG
//        return .example()
//        #else
        let queryItems: [URLQueryItem] = [
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
        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/hkrpg/api/note",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
//        #endif
    }

    /// Fetches the daily note of the specified user. Using widget api.
    /// - Parameters:
    ///   - cookie: The cookie of the user.
    ///   - deviceFingerPrint: The device finger print of the user.
    static func widgetNote(
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> WidgetDailyNote {
        var additionalHeaders = [
            "User-Agent": "WidgetExtension/434 CFNetwork/1492.0.1 Darwin/23.3.0",
        ]

        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            additionalHeaders.updateValue(deviceFingerPrint, forKey: "x-rpc-device_fp")
        }

        let request = try await Self.generateRecordAPIRequest(
            region: .china,
            path: "/game_record/app/hkrpg/aapi/widget",
            queryItems: [],
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
