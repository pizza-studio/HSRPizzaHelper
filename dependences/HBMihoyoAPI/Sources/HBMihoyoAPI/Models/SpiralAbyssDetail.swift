//
//  SpiralAbyssDetail.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//

import Foundation

// MARK: - SpiralAbyssDetail

public struct SpiralAbyssDetail: Codable {
    public struct CharacterRankModel: Codable {
        /// 角色ID
        public var avatarId: Int
        /// 排名对应的值
        public var value: Int
        /// 角色头像
        public var avatarIcon: String
        /// 角色星级（4/5）
        public var rarity: Int
    }

    public struct Floor: Codable {
        public struct Level: Codable {
            public struct Battle: Codable {
                public struct Avatar: Codable {
                    /// 角色ID
                    public var id: Int
                    /// 角色头像
                    public var icon: String
                    /// 角色等级
                    public var level: Int
                    /// 角色星级
                    public var rarity: Int
                }

                /// 半间序数，1为上半，2为下半
                public var index: Int
                /// 出战角色
                public var avatars: [Avatar]
                /// 完成时间戳since1970
                public var timestamp: String
            }

            /// 本间星数
            public var star: Int
            /// 本间满星数（3）
            public var maxStar: Int
            /// 上半间与下半间
            public var battles: [Battle]
            /// 本间序数，第几件
            public var index: Int
        }

        /// 是否解锁
        public var isUnlock: Bool
        /// ？
        public var settleTime: String
        /// 本层星数
        public var star: Int
        /// 各间数据
        public var levels: [Level]
        /// 满星数（=9）
        public var maxStar: Int
        /// 废弃
        public var icon: String
        /// 第几层，楼层序数（9,10,11,12）
        public var index: Int

        /// 是否满星
        public var gainAllStar: Bool {
            star == maxStar
        }
    }

    /// 元素爆发排名（只有第一个）
    public var energySkillRank: [CharacterRankModel]
    /// 本期深渊开始时间
    public var startTime: String
    /// 总胜利次数
    public var totalWinTimes: Int
    /// 到达最高层间数（最深抵达），eg "12-3"
    public var maxFloor: String
    /// 各楼层数据
    public var floors: [Floor]
    /// 总挑战次数
    public var totalBattleTimes: Int
    /// 最高承受伤害排名（只有最高）
    public var takeDamageRank: [CharacterRankModel]
    /// 是否解锁深渊
    public var isUnlock: Bool
    /// 最多击败敌人数量排名（只有最高
    public var defeatRank: [CharacterRankModel]
    /// 本期深渊结束时间
    public var endTime: String
    /// 元素战记伤害排名（只有最高）
    public var normalSkillRank: [CharacterRankModel]
    /// 元素战记伤害排名（只有最高）
    public var damageRank: [CharacterRankModel]
    /// 深渊期数ID，每期+1
    public var scheduleId: Int
    /// 出站次数
    public var revealRank: [CharacterRankModel]
    public var totalStar: Int
}

// MARK: - AccountSpiralAbyssDetail

public struct AccountSpiralAbyssDetail {
    // MARK: Lifecycle

    public init(this: SpiralAbyssDetail, last: SpiralAbyssDetail) {
        self.this = this
        self.last = last
    }

    // MARK: Public

    public enum WhichSeason {
        case this
        case last
    }

    public let this: SpiralAbyssDetail
    public let last: SpiralAbyssDetail

    public func get(_ whichSeason: WhichSeason) -> SpiralAbyssDetail {
        switch whichSeason {
        case .this:
            return this
        case .last:
            return last
        }
    }
}
