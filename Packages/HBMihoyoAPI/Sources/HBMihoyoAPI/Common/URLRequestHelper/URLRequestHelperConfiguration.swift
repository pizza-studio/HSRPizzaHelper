//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - URLRequestHelperConfiguration

/// Abstract class storing salt, version, etc for API.
enum URLRequestHelperConfiguration {
    static let userAgent: String = """
    Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) \
    AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.71.1
    """

    static func recordURLAPIHost(region: Region) -> String {
        switch region {
        case .mainlandChina:
            return "api-takumi-record.mihoyo.com"
        case .global:
            return "bbs-api-os.hoyolab.com"
        }
    }

    static func accountAPIURLHost(region: Region) -> String {
        switch region {
        case .mainlandChina:
            return "api-takumi.mihoyo.com"
        case .global:
            return "api-account-os.hoyolab.com"
        }
    }

    static func hostInHeaders(region: Region) -> String {
        switch region {
        case .mainlandChina:
            return "https://api-takumi-record.mihoyo.com/"
        case .global:
            return "https://bbs-api-os.mihoyo.com/"
        }
    }

    static func salt(region: Region) -> String {
        switch region {
        case .mainlandChina:
            return "rtvTthKxEyreVXQCnhluFgLXPOFKPHlA"
        case .global:
            return "599uqkwc0dlqu3h6epzjzfhgyyrd44ae"
        }
    }

    static func xRpcAppVersion(region: Region) -> String {
        switch region {
        case .mainlandChina:
            return "2.71.1"
        case .global:
            return "2.54.0"
        }
    }

    static func xRpcClientType(region: Region) -> String {
        switch region {
        case .mainlandChina:
            return "5"
        case .global:
            return "2"
        }
    }

    static func referer(region: Region) -> String {
        switch region {
        case .mainlandChina:
            return "https://webstatic.mihoyo.com"
        case .global:
            return "https://webstatic-sea.hoyolab.com"
        }
    }

    /// Get unfinished default headers containing host, api-version, etc.
    /// You need to add `DS` field using `URLRequestHelper.getDS` manually
    /// - Parameter region: the region of the account
    /// - Returns: http request headers
    static func defaultHeaders(region: Region, additionalHeaders: [String: String]?) async throws -> [String: String] {
        #if os(iOS)
        let deviceId = await (UIDevice.current.identifierForVendor ?? UUID()).uuidString
        #else
        let deviceId = UUID().uuidString
        #endif
        var headers = [
            "User-Agent": userAgent,
            "Referer": referer(region: region),
            "Origin": referer(region: region),
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "application/json, text/plain, */*",
            "Connection": "keep-alive",

            "x-rpc-app_version": xRpcAppVersion(region: region),
            "x-rpc-client_type": xRpcClientType(region: region),
            "x-rpc-page": "3.1.3_#/rpg",
            "x-rpc-device_id": deviceId,
            "x-rpc-language": Locale.miHoYoAPILanguage.rawValue,

            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Site": "same-site",
            "Sec-Fetch-Mode": "cors",
        ]
        if let additionalHeaders {
            headers.merge(additionalHeaders, uniquingKeysWith: { $1 })
        }
        return headers
    }
}
