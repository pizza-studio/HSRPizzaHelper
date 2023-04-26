//
//  BasicInfos.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//

import Foundation

public struct BasicInfos: Codable {
    public struct Stats: Codable {
        /// 解锁角色数
        public var avatarNumber: Int
        /// 精致宝箱数
        public var exquisiteChestNumber: Int
        /// 普通宝箱数
        public var commonChestNumber: Int
        /// 解锁传送点数量
        public var wayPointNumber: Int
        /// 岩神瞳
        public var geoculusNumber: Int
        /// 草神瞳
        public var dendroculusNumber: Int
        /// 解锁成就数
        public var achievementNumber: Int
        /// 解锁秘境数量
        public var domainNumber: Int
        /// 活跃天数
        public var activeDayNumber: Int
        /// 风神瞳
        public var anemoculusNumber: Int
        /// 华丽宝箱数
        public var luxuriousChestNumber: Int
        /// 雷神瞳
        public var electroculusNumber: Int
        /// 珍贵宝箱数
        public var preciousChestNumber: Int
        /// 深境螺旋
        public var spiralAbyss: String
        /// 奇馈宝箱数
        public var magicChestNumber: Int
    }

    public struct WorldExploration: Codable {
        public struct Offering: Codable {
            public var name: String
            public var level: Int
            public var icon: String
        }

        public var id: Int
        public var backgroundImage: String
        public var mapUrl: String
        public var parentId: Int
        public var type: String
        public var offerings: [Offering]
        public var level: Int
        public var explorationPercentage: Int
        public var icon: String
        public var innerIcon: String
        public var cover: String
        public var name: String
        public var strategyUrl: String
    }

    public struct Avatar: Codable, Identifiable {
        public var fetter: Int
        public var rarity: Int
        public var cardImage: String
        public var id: Int
        public var isChosen: Bool
        public var element: String
        public var image: String
        public var level: Int
        public var name: String
        public var activedConstellationNum: Int
    }

    public var stats: Stats
    public var worldExplorations: [WorldExploration]
    public var avatars: [Avatar]
}
