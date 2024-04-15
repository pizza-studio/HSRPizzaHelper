// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated {
    // MARK: - QueriedProfile

    public struct QueriedProfile: Codable {
        public let detailInfo: DetailInfo
        public let uid: String
    }

    // MARK: - DetailInfo

    public struct DetailInfo: Codable {
        public let platform, level, friendCount: Int
        public let signature: String
        public let recordInfo: RecordInfo
        public let headIcon, worldLevel: Int
        public let nickname: String
        public let uid: Int
        public let isDisplayAvatar: Bool
        public let avatarDetailList, assistAvatarList: [Avatar]
    }
}

extension EnkaHSR.QueryRelated.DetailInfo {
    // MARK: - Avatar

    public struct Avatar: Codable {
        public let level, avatarId: Int
        public let equipment: Equipment
        public let relicList: [RelicList]
        public let promotion: Int
        public let skillTreeList: [SkillTreeList]
        public let rank: Int?
        public let _assist: Bool?
        public let pos: Int?
    }

    // MARK: - Equipment

    public struct Equipment: Codable {
        public let rank, level, tid, promotion: Int
        public let _flat: EquipmentFlat
    }

    // MARK: - EquipmentFlat

    public struct EquipmentFlat: Codable {
        public let props: [Prop]
        public let name: Int
    }

    // MARK: - Prop

    public struct Prop: Codable {
        public let type: String
        public let value: Double
    }

    // MARK: - RelicList

    public struct RelicList: Codable {
        public let type: Int
        public let level: Int?
        public let subAffixList: [SubAffixList]
        public let mainAffixId, tid: Int
        public let _flat: RelicListFlat
        public let exp: Int?
    }

    // MARK: - RelicListFlat

    public struct RelicListFlat: Codable {
        public let props: [Prop]
        public let setName, setID: Int
    }

    // MARK: - SubAffixList

    public struct SubAffixList: Codable {
        public let affixId, cnt: Int
        public let step: Int?
    }

    // MARK: - SkillTreeList

    public struct SkillTreeList: Codable {
        public let pointId, level: Int
    }

    // MARK: - RecordInfo

    public struct RecordInfo: Codable {
        public let maxRogueChallengeScore, achievementCount: Int
        public let challengeInfo: ChallengeInfo
        public let equipmentCount, avatarCount: Int
    }

    // MARK: - ChallengeInfo

    public struct ChallengeInfo: Codable {
        public let scheduleGroupId: Int
    }
}
