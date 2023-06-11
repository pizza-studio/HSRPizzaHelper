//
//  CreateVerificationAPI.swift
//
//
//  Created by 戴藏龙 on 2023/6/11.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    public static func createVerification(cookie: String, deviceFingerPrint: String?) async throws -> Verification {
        let queryItems: [URLQueryItem] = [
            .init(name: "is_high", value: "true"),
        ]
        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                return ["x-rpc-device_fp": deviceFingerPrint]
            } else {
                return nil
            }
        }()

        var urlComponents =
            URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/card/wapi/createVerification")!
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = try await URLRequestHelperConfiguration.defaultHeaders(
            region: .china,
            additionalHeaders: additionalHeaders
        )
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.setValue(
            URLRequestHelper.getDS(region: .china, query: url.query ?? "", body: nil),
            forHTTPHeaderField: "DS"
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}
