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
    case bilibili = "prod_qd_cn"
    case unitedStates = "prod_official_usa"
    case europe = "prod_official_eur"
    case asia = "prod_official_asia"
    case hongKongMacauTaiwan = "prod_official_cht"

    // MARK: Lifecycle

    public init?(uid: String?) {
        guard var theUID = uid else { return nil }
        while theUID.count > 9 {
            theUID = theUID.dropFirst().description
        }
        guard let initial = theUID.first, let initialInt = Int(initial.description) else { return nil }
        switch initialInt {
        case 1 ... 4: self = .china
        case 5: self = .bilibili
        case 6: self = .unitedStates
        case 7: self = .europe
        case 8: self = .asia
        case 9: self = .hongKongMacauTaiwan
        default: return nil
        }
    }
}

extension Server {
    /// The region of the server.
    public var region: Region {
        switch self {
        case .bilibili, .china:
            return .mainlandChina
        case .asia, .europe, .hongKongMacauTaiwan, .unitedStates: return .global
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

// MARK: Identifiable

extension Server: Identifiable {
    public var id: String {
        rawValue
    }
}

// MARK: Codable

extension Server: Codable {}

// MARK: CustomStringConvertible

extension Server: CustomStringConvertible {
    public var description: String {
        switch self {
        case .china:
            return "星穹列车"
        case .bilibili:
            return "无名客"
        case .unitedStates:
            return "America"
        case .europe:
            return "Europe"
        case .asia:
            return "Asia"
        case .hongKongMacauTaiwan:
            return "TW/HK/MO"
        }
    }
}
