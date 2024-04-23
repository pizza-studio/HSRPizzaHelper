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
public enum Region: String, CaseIterable {
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
