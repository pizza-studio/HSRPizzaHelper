//
//  Servers.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//  返回识别服务器信息的工具类

import Foundation

// MARK: - Server

/// The server of an StarRail account.
public enum Server: String, CaseIterable {
    case china = "prod_gf_cn"
    case bilibili = "世界树" // TODO: still unknown.
    case unitedStates = "os_usa"
    case europe = "os_euro"
    case asia = "os_asia"
    case hongKongMacauTaiwan = "os_cht"
}

extension Server {
    /// The region of the server.
    public var region: Region {
        switch self {
        case .china, .bilibili:
            return .china
        case .asia, .europe, .unitedStates, .hongKongMacauTaiwan:
            return .global
        }
    }

    /// The timezone of the server.
    public var timeZone: TimeZone {
        switch self {
        case .asia, .bilibili, .china, .hongKongMacauTaiwan:
            return .init(secondsFromGMT: 8 * 60 * 60) ?? .current
        case .unitedStates:
            return .init(secondsFromGMT: -5 * 60 * 60) ?? .current
        case .europe:
            return .init(secondsFromGMT: 1 * 60 * 60) ?? .current
        }
    }
}

extension Server: Identifiable {
    public var id: String {
        self.rawValue
    }
}

extension Server: Codable {}
