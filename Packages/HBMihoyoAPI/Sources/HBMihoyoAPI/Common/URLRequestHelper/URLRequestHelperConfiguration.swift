//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - URLRequestHelperConfiguration

/// Abstract class storing salt, version, etc for API.
@available(iOS 15.0, *)
enum URLRequestHelperConfiguration {
    // MARK: Internal

    static let userAgent: String = """
    Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) \
    AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.51.1
    """

    static func recordURLAPIHost(region: Region) -> String {
        switch region {
        case .china:
            return "api-takumi-record.mihoyo.com"
        case .global:
            return "bbs-api-os.mihoyo.com"
        }
    }

    static func accountAPIURLHost(region: Region) -> String {
        switch region {
        case .china:
            return "api-takumi.mihoyo.com"
        case .global:
            return "api-account-os.hoyolab.com"
        }
    }

    static func hostInHeaders(region: Region) -> String {
        switch region {
        case .china:
            return "https://api-takumi-record.mihoyo.com/"
        case .global:
            return "https://bbs-api-os.mihoyo.com/"
        }
    }

    static func salt(region: Region) -> String {
        switch region {
        case .china:
            return "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
        case .global:
            return "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
        }
    }

    static func xRpcAppVersion(region: Region) -> String {
        switch region {
        case .china:
            return "2.51.1"
        case .global:
            return "2.9.0"
        }
    }

    static func xRpcClientType(region: Region) -> String {
        switch region {
        case .china:
            return "5"
        case .global:
            return "2"
        }
    }

    static func referer(region: Region) -> String {
        switch region {
        case .china:
            return "https://webstatic.mihoyo.com"
        case .global:
            return "https://webstatic-sea.hoyolab.com"
        }
    }

    /// Get unfinished default headers containing host, api-version, etc.
    /// You need to add `DS` field using `URLRequestHelper.getDS` manually
    /// - Parameter region: the region of the account
    /// - Returns: http request headers
    static func defaultHeaders(region: Region) async throws -> [String: String] {
        await [
            "User-Agent": userAgent,
            "Referer": referer(region: region),
            "Origin": referer(region: region),
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "application/json, text/plain, */*",
            "Connection": "keep-alive",

            "x-rpc-app_version": xRpcAppVersion(region: region),
            "x-rpc-client_type": xRpcClientType(region: region),
            "x-rpc-device_fp": try await getDeviceFingerPrint(region: region),
            "x-rpc-page": "3.1.3_#/rpg",
            "x-rpc-device_id": (UIDevice.current.identifierForVendor ?? UUID()).uuidString,

            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Site": "same-site",
            "Sec-Fetch-Mode": "cors",
        ]
    }

    // MARK: Fileprivate

    fileprivate static func getDeviceFingerPrint(region: Region) async throws -> String {
        let userDefaults = UserDefaults(suiteName: "group.Canglong.HSRPizzaHelper")!
        if let fingerPrint = userDefaults.string(forKey: "device_finger_print"), fingerPrint != "" {
            return fingerPrint
        }
        func generateSeed() -> String {
            let characters = "0123456789abcdef"
            var result = ""
            for _ in 0 ..< 16 {
                let randomIndex = Int.random(in: 0 ..< characters.count)
                let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
                result.append(character)
            }
            return result
        }

        struct DeviceFingerPrintResult: DecodableFromMiHoYoAPIJSONResult {
            let msg: String
            // swiftlint:disable:next identifier_name
            let device_fp: String
            let code: Int
        }

        let url = URL(string: "https://public-data-api.mihoyo.com/device-fp/api/getFp")!
        let body: [String: String] = await [
            "seed_id": generateSeed(),
            "device_id": (UIDevice.current.identifierForVendor ?? UUID()).uuidString,
            "platform": "5",
            "seed_time": "\(Int(Date().timeIntervalSince1970) * 1000)",
            // swiftlint:disable line_length
            "ext_fields": """
            {"userAgent":"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.50.1","browserScreenSize":281520,"maxTouchPoints":5,"isTouchSupported":true,"browserLanguage":"zh-CN","browserPlat":"iPhone","browserTimeZone":"Asia/Shanghai","webGlRender":"Apple GPU","webGlVendor":"Apple Inc.","numOfPlugins":0,"listOfPlugins":"unknown","screenRatio":3,"deviceMemory":"unknown","hardwareConcurrency":"4","cpuClass":"unknown","ifNotTrack":"unknown","ifAdBlock":0,"hasLiedResolution":1,"hasLiedOs":0,"hasLiedBrowser":0}
            """,
            // swiftlint:enable line_length
            "app_name": "account_cn",
            "device_fp": "38d7ee834d1e9",
        ]
        var request = URLRequest(url: url)
        request.httpBody = try JSONEncoder().encode(body)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let fingerPrint = try DeviceFingerPrintResult.decodeFromMiHoYoAPIJSONResult(data: data).device_fp
        return fingerPrint
    }
}
