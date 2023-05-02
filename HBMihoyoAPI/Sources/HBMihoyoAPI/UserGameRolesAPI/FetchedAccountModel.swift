//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

public struct FetchedAccount: Decodable {
    public let region: String
    public let gameBiz: String
    public let nickname: String
    public let level: Int
    public let isOfficial: Bool
    public let regionName: String
    public let gameUid: String
    public let isChosen: Bool
}

extension FetchedAccount: Identifiable {
    public var id: String { gameUid }
}

extension FetchedAccount: Hashable {}
