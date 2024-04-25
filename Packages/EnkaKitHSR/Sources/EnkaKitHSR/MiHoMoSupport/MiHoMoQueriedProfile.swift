// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - MiHoMo

public enum MiHoMo {
    public struct QueriedProfile: Codable, Hashable {
        public let player: PlayerInfo
        public let characters: [CharacterInfo]
    }
}

// MARK: - Structs

extension MiHoMo.QueriedProfile {
    public struct LevelInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let level: Int
    }

    public struct AvatarInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let icon: String
    }

    public struct PathInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let icon: String
    }

    public struct ElementInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let color: String
        public let icon: String
    }

    public struct SkillInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let level: Int
        public let maxLevel: Int
        public let element: ElementInfo?
        public let type: String
        public let typeText: String
        public let effect: String
        public let effectText: String
        public let simpleDesc: String
        public let desc: String
        public let icon: String
    }

    public struct SkillTreeInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let level: Int
        public let anchor: String
        public let maxLevel: Int
        public let icon: String
        public let parent: String?
    }

    public struct AttributeInfo: Codable, Hashable {
        public let field: String
        public let name: String
        public let icon: String
        public let value: Float
        public let display: String
        public let percent: Bool
    }

    public struct PropertyInfo: Codable, Hashable {
        public let type: String
        public let field: String
        public let name: String
        public let icon: String
        public let value: Float
        public let display: String
        public let percent: Bool
    }

    public struct SubAffixInfo: Codable, Hashable {
        public let count: Int
        public let step: Int
        public let type: String
        public let field: String
        public let name: String
        public let icon: String
        public let value: Float
        public let display: String
        public let percent: Bool
    }

    public struct RelicInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let setId: String
        public let setName: String
        public let rarity: Int
        public let level: Int
        public let icon: String
        public let mainAffix: PropertyInfo?
        public let subAffix: [SubAffixInfo]
    }

    public struct RelicSetInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let icon: String
        public let num: Int
        public let desc: String
        public let properties: [PropertyInfo]
    }

    public struct LightConeInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let rarity: Int
        public let rank: Int
        public let level: Int
        public let promotion: Int
        public let icon: String
        public let preview: String
        public let portrait: String
        public let path: PathInfo?
        public let attributes: [AttributeInfo]
        public let properties: [PropertyInfo]
    }

    public struct SpaceInfo: Codable, Hashable {
        // public let memoryData: MemoryInfo // Deprecated.
        public let universeLevel: Int
        public let lightConeCount: Int
        public let avatarCount: Int
        public let achievementCount: Int
    }

    public struct PlayerInfo: Codable, Hashable {
        public let uid: String
        public let nickname: String
        public let level: Int
        public let worldLevel: Int
        public let friendCount: Int
        public let avatar: AvatarInfo?
        public let signature: String
        public let isDisplay: Bool
        public let spaceInfo: SpaceInfo?
    }

    public struct CharacterInfo: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let rarity: Int
        public let rank: Int
        public let level: Int
        public let promotion: Int
        public let icon: String
        public let preview: String
        public let portrait: String
        public let rankIcons: [String]
        public let path: PathInfo?
        public let element: ElementInfo?
        public let skills: [SkillInfo]
        public let skillTrees: [SkillTreeInfo]
        public let lightCone: LightConeInfo?
        public let relics: [RelicInfo]
        public let relicSets: [RelicSetInfo]
        public let attributes: [AttributeInfo]
        public let additions: [AttributeInfo]
        public let properties: [PropertyInfo]
    }
}
