//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

/// The region of server.
/// `.china` uses miyoushe api and `.global` uses HoYoLAB api.
public enum Region: String {
    // CNMainland servers
    case china = "hkrpg_cn"
    // Other servers
    case global = "hkrpg_global"
}

extension Region: Identifiable {
    public var id: String {
        self.rawValue
    }
}
