// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated {
    // MARK: - QueriedProfile

    public struct QueriedProfile: Codable, Hashable {
        public let detailInfo: DetailInfo?
        public let uid: String
        public let message: String?
    }

    // MARK: - DetailInfo

    public struct DetailInfo: Codable, Hashable {
        public let platform, level, friendCount: Int?
        public let signature: String?
        public let recordInfo: RecordInfo?
        public let headIcon, worldLevel: Int?
        public let nickname: String?
        public let uid: Int
        public let isDisplayAvatar: Bool?
        public let avatarDetailList: [Avatar]?

        // public let assistAvatarList: [Avatar]

        // Signature, guarded. The default value is blank.
        public var signatureGuarded: String {
            signature ?? ""
        }

        // Nickname, guarded.
        public var nickNameGuarded: String {
            nickname ?? "@Nanashibito"
        }

        // Adventure Rank / Trailblazing Level, guarded.
        public var trailblazingLevel: Int {
            level ?? 114_514
        }

        // World Level, guarded.
        public var equilibriumLevel: Int {
            worldLevel ?? 114_514
        }

        // All Avatars, guarded.
        public var allAvatars: [Avatar] {
            avatarDetailList ?? []
        }
    }
}

extension EnkaHSR.QueryRelated.DetailInfo {
    // MARK: - Avatar

    public struct Avatar: Codable, Hashable {
        public let level, avatarId: Int
        public let equipment: Equipment
        public let relicList: [ArtifactItem]
        public let promotion: Int
        public let skillTreeList: [SkillTreeItem]
        public let rank: Int?
        // public let _assist: Bool? // 用不到的参数，表示「该角色是否允许其他玩家借用」。
        // public let pos: Int? // 用不到的参数，表示其在展柜内的原始陈列顺序。
    }

    // MARK: - Equipment

    public struct Equipment: Codable, Hashable {
        // MARK: Public

        public let rank, level, tid, promotion: Int
        public let flat: EquipmentFlat

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case rank
            case level
            case tid
            case promotion
            case flat = "_flat"
        }
    }

    // MARK: - EquipmentFlat

    public struct EquipmentFlat: Codable, Hashable {
        public let props: [Prop]
        public let name: Int
    }

    // MARK: - Prop

    public struct Prop: Codable, Hashable {
        public let type: String
        public let value: Double
    }

    // MARK: - ArtifactItem

    public struct ArtifactItem: Codable, Hashable {
        // MARK: Public

        // MARK: - SubAffixList

        public struct SubAffixItem: Codable, Hashable {
            public let affixId, cnt: Int
            public let step: Int?
        }

        // MARK: - ArtifactItem.Flat

        public struct Flat: Codable, Hashable {
            public let props: [Prop]
            public let setName, setID: Int
        }

        public let type: Int
        public let level: Int?
        public let subAffixList: [SubAffixItem]
        public let mainAffixId, tid: Int
        public let flat: ArtifactItem.Flat
        public let exp: Int?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case type
            case level
            case subAffixList
            case mainAffixId
            case tid
            case flat = "_flat"
            case exp
        }
    }

    // MARK: - SkillTreeItem

    public struct SkillTreeItem: Codable, Hashable {
        public let pointId, level: Int
    }

    // MARK: - RecordInfo

    public struct RecordInfo: Codable, Hashable {
        public let maxRogueChallengeScore, achievementCount: Int
        public let challengeInfo: ChallengeInfo
        public let equipmentCount, avatarCount: Int
    }

    // MARK: - ChallengeInfo

    public struct ChallengeInfo: Codable, Hashable {
        public let scheduleGroupId: Int
    }
}
