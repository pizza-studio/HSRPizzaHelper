//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation
import UIKit

// MARK: - URLRequestHelperConfiguration

/// Abstract class storing salt, version, etc for API.
enum URLRequestHelperConfiguration {
    static let userAgent: String = """
    Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) \
    AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.37.1
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
            return "2.50.1"
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
    static func defaultHeaders(region: Region) -> [String: String] {
        [
            "x-rpc-app_version": xRpcAppVersion(region: region),
            "x-rpc-client_type": xRpcClientType(region: region),
            "User-Agent": userAgent,
            "Referer": referer(region: region),
            "Origin": referer(region: region),
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "application/json, text/plain, */*",
            "Connection": "keep-alive",
            "x-rpc-device_fp": getDeviceFingerPrint(),
        ]
    }
}

private func getDeviceFingerPrint() -> String {
    if let uuidString = UIDevice.current.identifierForVendor?.uuidString {
        return String(uuidString.md5.prefix(13))
    } else {
        return ""
    }
}
