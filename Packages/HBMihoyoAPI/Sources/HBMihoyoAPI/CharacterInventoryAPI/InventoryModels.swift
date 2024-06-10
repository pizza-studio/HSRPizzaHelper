// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - MiHoYoAPI.CharacterInventory

extension MiHoYoAPI {
    public struct CharacterInventory: Codable, Hashable, Sendable, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public struct HYAvatar: Codable, Hashable, Sendable, Identifiable {
            public let id: Int // 七大基础参数之一
            public let level: Int // 七大基础参数之一
            public let name: String // 七大基础参数之一
            public let element: String // 七大基础参数之一
            public let icon: String // 七大基础参数之一
            public let rarity: Int // 七大基础参数之一
            public let rank: Int // 七大基础参数之一；命之座
            public let image: String? // 无法在 basic 模式下提供
            public let equip: HYEquip? // 无法在 basic 模式下提供
            public let relics: [HYArtifactOuter]? // 无法在 basic 模式下提供
            public let ornaments: [HYArtifactInner]? // 无法在 basic 模式下提供
            public let ranks: [HYSkillRank]? // 技能樹；无法在 basic 模式下提供

            public var allArtifacts: [any MiHoYoAPIArtifactProtocol] {
                var result = [any MiHoYoAPIArtifactProtocol]()
                result.append(contentsOf: relics ?? [])
                result.append(contentsOf: ornaments ?? [])
                return result
            }
        }

        public let avatarList: [HYAvatar]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case avatarList = "avatar_list"
        }
    }
}

// MARK: - MiHoYoAPIArtifactProtocol

public protocol MiHoYoAPIArtifactProtocol: Codable, Hashable, Sendable, Identifiable {
    var id: Int { get }
    var level: Int { get }
    var pos: Int { get }
    var name: String { get }
    var desc: String { get }
    var icon: String { get }
    var rarity: Int { get }
}

extension MiHoYoAPI.CharacterInventory.HYAvatar {
    public struct HYEquip: Codable, Hashable, Sendable, Identifiable {
        public let id: Int
        public let level: Int
        public let rank: Int
        public let name: String
        public let desc: String
        public let icon: String
        public let rarity: Int
    }

    public struct HYArtifactOuter: MiHoYoAPIArtifactProtocol {
        public let id: Int
        public let level: Int
        public let pos: Int
        public let name: String
        public let desc: String
        public let icon: String
        public let rarity: Int
    }

    public struct HYArtifactInner: MiHoYoAPIArtifactProtocol {
        public let id: Int
        public let level: Int
        public let pos: Int
        public let name: String
        public let desc: String
        public let icon: String
        public let rarity: Int
    }

    public struct HYSkillRank: Codable, Hashable, Sendable, Identifiable {
        // MARK: Public

        public let id: Int
        public let pos: Int
        public let name: String
        public let icon: String
        public let desc: String
        public let isUnlocked: Bool

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case isUnlocked = "is_unlocked"
            case id, pos, name, icon, desc
        }
    }
}
