//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - Region

/// The region of server.
/// `.china` uses miyoushe api and `.global` uses HoYoLAB api.
public enum Region: String, CaseIterable, Sendable {
    // CNMainland servers
    case mainlandChina = "hkrpg_cn"
    // Other servers
    case global = "hkrpg_global"
}

// MARK: Identifiable

extension Region: Identifiable {
    public var id: String {
        rawValue
    }
}

extension Region {
    public var servers: [Server] {
        switch self {
        case .mainlandChina: return [.china, .bilibili]
        case .global: return [.unitedStates, .europe, .asia, .hongKongMacauTaiwan]
        }
    }

    public var showcaseAPIProviderName: String {
        switch self {
        case .mainlandChina: return "MiHoMo Origin"
        case .global: return "Enka Networks"
        }
    }
}
