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

        var additionalHeaders: [String: String] = [:]
        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            additionalHeaders["x-rpc-device_fp"] = deviceFingerPrint
        }
        additionalHeaders["x-rpc-challenge_path"] =
            "https://api-takumi-record.mihoyo.com/game_record/app/hkrpg/api/note"
        additionalHeaders["x-rpc-challenge_game"] = "6"

        var urlComponents =
            URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/card/wapi/createVerification")!
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = try await URLRequestHelperConfiguration.defaultHeaders(
            region: .mainlandChina,
            additionalHeaders: additionalHeaders
        )
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.setValue(
            URLRequestHelper.getDS(region: .mainlandChina, query: url.query ?? "", body: nil),
            forHTTPHeaderField: "DS"
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }

    public static func verifyVerification(
        challenge: String,
        validate: String,
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> VerifyVerification {
        var additionalHeaders: [String: String] = [:]
        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            additionalHeaders["x-rpc-device_fp"] = deviceFingerPrint
        }
        additionalHeaders["x-rpc-challenge_path"] =
            "https://api-takumi-record.mihoyo.com/game_record/app/hkrpg/api/note"
        additionalHeaders["x-rpc-challenge_game"] = "6"

        struct VerifyVerificationBody: Encodable {
            let geetestChallenge: String
            let geetestValidate: String
            let geetestSeccode: String
            init(challenge: String, validate: String) {
                self.geetestChallenge = challenge
                self.geetestValidate = validate
                self.geetestSeccode = "\(validate)|jordan"
            }
        }
        let body = VerifyVerificationBody(challenge: challenge, validate: validate)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let bodyData = try encoder.encode(body)

        let urlComponents =
            URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/card/wapi/verifyVerification")!
        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = try await URLRequestHelperConfiguration.defaultHeaders(
            region: .mainlandChina,
            additionalHeaders: additionalHeaders
        )
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.setValue(
            URLRequestHelper.getDS(region: .mainlandChina, query: url.query ?? "", body: bodyData),
            forHTTPHeaderField: "DS"
        )
        request.httpBody = bodyData

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}
