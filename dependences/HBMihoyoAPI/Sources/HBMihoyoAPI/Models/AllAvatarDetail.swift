//
//  AllAvatarDetail.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//

import Foundation

public struct AllAvatarDetailModel: Codable {
    public struct Avatar: Codable, Equatable {
        public struct Costume: Codable {
            public var id: Int
            public var name: String
            public var icon: String
        }

        public struct Reliquary: Codable {
            public struct Set: Codable {
                public struct Affix: Codable {
                    public var activationNumber: Int
                    public var effect: String
                }

                public var id: Int
                public var name: String
                public var affixes: [Affix]
            }

            public var pos: Int
            public var rarity: Int
            public var set: Set
            public var id: Int
            public var posName: String
            public var level: Int
            public var name: String
            public var icon: String
        }

        public struct Weapon: Codable {
            public var rarity: Int
            public var icon: String
            public var id: Int
            public var typeName: String
            public var level: Int
            public var affixLevel: Int
            public var type: Int
            public var promoteLevel: Int
            public var desc: String
        }

        public struct Constellation: Codable {
            public var effect: String
            public var id: Int
            public var icon: String
            public var name: String
            public var pos: Int
            public var isActived: Bool
        }

        public var id: Int
        public var element: String
        public var costumes: [Costume]
        public var reliquaries: [Reliquary]
        public var level: Int
        public var image: String
        public var icon: String
        public var weapon: Weapon
        public var fetter: Int
        public var constellations: [Constellation]
        public var activedConstellationNum: Int
        public var name: String
        public var rarity: Int

        public var isProtagonist: Bool {
            switch id {
            case 10000005, 10000007: return true
            default: return false
            }
        }

        public static func == (
            lhs: AllAvatarDetailModel.Avatar,
            rhs: AllAvatarDetailModel.Avatar
        )
            -> Bool {
            lhs.id == rhs.id
        }
    }

    public var avatars: [Avatar]
}
