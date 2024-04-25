// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated {
    // MARK: - QueriedProfile

    public struct QueriedProfile: Codable, Hashable {
        public let detailInfo: DetailInfo?
        public let uid: String?
        public let message: String?
    }

    // MARK: - DetailInfo

    public struct DetailInfo: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            uid: Int,
            nickname: String,
            level: Int,
            friendCount: Int,
            signature: String,
            recordInfo: RecordInfo?,
            headIcon: Int,
            worldLevel: Int,
            isDisplayAvatar: Bool,
            platform: PlatformType,
            avatarDetailList: [Avatar]
        ) {
            self.uid = uid
            self.nickname = nickname
            self.level = level
            self.friendCount = friendCount
            self.signature = signature
            self.recordInfo = recordInfo
            self.headIcon = headIcon
            self.worldLevel = worldLevel
            self.isDisplayAvatar = isDisplayAvatar
            self.platform = platform
            self.avatarDetailList = avatarDetailList
            self.assistAvatarList = []
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uid = try container.decode(Int.self, forKey: .uid)
            self.nickname = (try? container.decode(String.self, forKey: .nickname)) ?? "@Nanashibito"
            self.level = (try? container.decode(Int.self, forKey: .level)) ?? 0
            self.friendCount = (try? container.decode(Int.self, forKey: .friendCount)) ?? 0
            self.signature = (try? container.decode(String.self, forKey: .signature)) ?? ""
            self.recordInfo = try? container.decode(RecordInfo.self, forKey: .recordInfo)
            self.headIcon = (try? container.decode(Int.self, forKey: .headIcon)) ?? 1310
            self.worldLevel = (try? container.decode(Int.self, forKey: .worldLevel)) ?? 0
            self.isDisplayAvatar = (try? container.decode(Bool.self, forKey: .isDisplayAvatar)) ?? false
            // 在这个阶段就将 assistAvatarList 的内容并入到 avatarDetailList 内。
            let avatarListPrimary = (try? container.decode([Avatar].self, forKey: .assistAvatarList)) ?? []
            var avatarListSecondary = (try? container.decode([Avatar].self, forKey: .avatarDetailList)) ?? []
            let filteredCharIDs = avatarListPrimary.map(\.avatarId)
            avatarListSecondary.removeAll { filteredCharIDs.contains($0.avatarId) }
            self.assistAvatarList = []
            self.avatarDetailList = avatarListPrimary + avatarListSecondary
            do {
                self.platform = .init(rawValue: (try container.decode(Int?.self, forKey: .platform)) ?? 0) ?? .editor
            } catch {
                self.platform = .init(string: (try? container.decode(String?.self, forKey: .platform)) ?? "EDITOR")
            }
        }

        // MARK: Public

        public let uid: Int
        public let nickname: String
        public let level, friendCount: Int
        public let signature: String
        public let recordInfo: RecordInfo?
        public let headIcon, worldLevel: Int
        public let isDisplayAvatar: Bool
        public let platform: PlatformType
        public let avatarDetailList: [Avatar]
        public let assistAvatarList: [Avatar]
    }
}

extension EnkaHSR.QueryRelated.DetailInfo {
    // MARK: - Avatar

    public struct Avatar: Codable, Hashable {
        public let level, avatarId: Int
        public let equipment: Equipment
        public let relicList: [ArtifactItem]?
        public let promotion: Int?
        public let skillTreeList: [SkillTreeItem]
        public let rank: Int?

        // public let _assist: Bool? // 用不到的参数，表示「该角色是否允许其他玩家借用」。
        // public let pos: Int? // 用不到的参数，表示其在展柜内的原始陈列顺序。

        // Artifact list, guarded.
        public var artifactList: [ArtifactItem] {
            relicList ?? []
        }

        // Promotion, guarded
        public var promotionRank: Int {
            promotion ?? 0
        }
    }

    // MARK: - Equipment

    public struct Equipment: Codable, Hashable {
        // MARK: Public

        public let rank, level, tid: Int
        // public let flat: EquipmentFlat? // UNAVAILABLE_IN_MIHOMO_ORIGIN_RESULTS.
        public let promotion: Int?

        // Promotion, guarded
        public var promotionRank: Int {
            promotion ?? 0
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case rank
            case level
            case tid
            case promotion
            // case flat = "_flat" // UNAVAILABLE_IN_MIHOMO_ORIGIN_RESULTS.
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
        // public let flat: ArtifactItem.Flat? // UNAVAILABLE_IN_MIHOMO_ORIGIN_RESULTS.
        public let exp: Int?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case type
            case level
            case subAffixList
            case mainAffixId
            case tid
            // case flat = "_flat" // UNAVAILABLE_IN_MIHOMO_ORIGIN_RESULTS.
            case exp
        }
    }

    // MARK: - SkillTreeItem

    public struct SkillTreeItem: Codable, Hashable {
        public let pointId, level: Int
    }

    // MARK: - RecordInfo

    public struct RecordInfo: Codable, Hashable {
        public let maxRogueChallengeScore, achievementCount: Int?
        public let challengeInfo: ChallengeInfo?
        public let equipmentCount, avatarCount: Int?
    }

    // MARK: - ChallengeInfo

    public struct ChallengeInfo: Codable, Hashable {
        public let scheduleGroupId: Int?
    }

    // swiftlint:disable identifier_name
    public enum PlatformType: Int, Hashable, Codable, CaseIterable {
        case editor = 0
        case ios = 1
        case android = 2
        case pc = 3
        case web = 4
        case wap = 5
        case ps4 = 6
        case nintendo = 7
        case cloud_android = 8
        case cloud_pc = 9
        case cloud_ios = 10
        case ps5 = 11
        case mac = 12
        case cloud_mac = 13
        case cloud_web_android = 20
        case cloud_web_ios = 21
        case cloud_web_pc = 22
        case cloud_web_mac = 23
        case cloud_web_touch = 24
        case cloud_web_keyboard = 25

        // MARK: Lifecycle

        public init(string: String) {
            self = Self.allCases.first { $0.toString == string } ?? .editor
        }

        // MARK: Public

        public var toString: String {
            .init(describing: self).uppercased()
        }
    }
    // swiftlint:enable identifier_name
}
