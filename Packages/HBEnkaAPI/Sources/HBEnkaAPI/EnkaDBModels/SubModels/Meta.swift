// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public struct Meta: Codable {
        public let avatar: RawAvatarMetaDict
        public let equipment: RawEquipmentMetaDict
        public let equipmentSkill: RawEquipSkillMetaDict
        public let relic: RawRelicDB
        public let tree: RawTreeMetaDict
    }
}

// MARK: - EnkaHSR.DBModels.Meta.NestedPropValueMap

extension EnkaHSR.DBModels.Meta {
    public typealias NestedPropValueMap = [String: [String: [String: [String: Double]]]]
}

extension EnkaHSR.DBModels.Meta.NestedPropValueMap {
    public func query(id: some StringProtocol) -> [EnkaHSR.DBModels.PropertyType: Double] {
        let rawResult = self[id.description]?.first?.value.first?.value ?? [:]
        var results = [EnkaHSR.DBModels.PropertyType: Double]()
        for (key, value) in rawResult {
            guard let propKey = EnkaHSR.DBModels.PropertyType(rawValue: key) else { continue }
            results[propKey] = value
        }
        return results
    }

    public func query(id: Int) -> [EnkaHSR.DBModels.PropertyType: Double] {
        query(id: id.description)
    }
}

// MARK: - Meta.AvatarMeta

extension EnkaHSR.DBModels.Meta {
    public typealias RawAvatarMetaDict = [String: [String: AvatarMeta]]

    public struct AvatarMeta: Codable {
        // MARK: Public

        public let hpBase: Double
        public let hpAdd: Double
        public let attackBase: Double
        public let attackAdd: Double
        public let defenceBase: Double
        public let defenceAdd: Double
        public let speedBase: Double
        public let criticalChance: Double
        public let criticalDamage: Double
        public let baseAggro: Double

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case hpBase = "HPBase"
            case hpAdd = "HPAdd"
            case attackBase = "AttackBase"
            case attackAdd = "AttackAdd"
            case defenceBase = "DefenceBase"
            case defenceAdd = "DefenceAdd"
            case speedBase = "SpeedBase"
            case criticalChance = "CriticalChance"
            case criticalDamage = "CriticalDamage"
            case baseAggro = "BaseAggro"
        }
    }
}

// MARK: - Meta.EquipmentMeta

extension EnkaHSR.DBModels.Meta {
    public typealias RawEquipmentMetaDict = [String: [String: EquipmentMeta]]

    public struct EquipmentMeta: Codable {
        // MARK: Public

        public let baseHP: Double
        public let hpAdd: Double
        public let baseAttack: Double
        public let attackAdd: Double
        public let baseDefence: Double
        public let defenceAdd: Double

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case baseHP = "BaseHP"
            case hpAdd = "HPAdd"
            case baseAttack = "BaseAttack"
            case attackAdd = "AttackAdd"
            case baseDefence = "BaseDefence"
            case defenceAdd = "DefenceAdd"
        }
    }
}

// MARK: - Meta.RawEquipSkillMetaDict

extension EnkaHSR.DBModels.Meta {
    public typealias RawEquipSkillMetaDict = NestedPropValueMap
}

// MARK: - EnkaHSR.DBModels.Meta.RawRelicDB

// Relic = Artifact

extension EnkaHSR.DBModels.Meta {
    public struct RawRelicDB: Codable {
        public struct MainAffix: Codable {
            enum CodingKeys: String, CodingKey {
                case property = "Property"
                case baseValue = "BaseValue"
                case levelAdd = "LevelAdd"
            }

            let property: EnkaHSR.DBModels.PropertyType
            let baseValue: Double
            let levelAdd: Double
        }

        public struct SubAffix: Codable {
            enum CodingKeys: String, CodingKey {
                case property = "Property"
                case baseValue = "BaseValue"
                case stepValue = "StepValue"
            }

            let property: EnkaHSR.DBModels.PropertyType
            let baseValue: Double
            let stepValue: Double
        }

        public typealias MainAffixTable = [String: [String: MainAffix]]
        public typealias SubAffixTable = [String: [String: SubAffix]]
        public typealias RawSetSkillMetaDict = EnkaHSR.DBModels.Meta.NestedPropValueMap

        public let mainAffix: MainAffixTable
        public let subAffix: SubAffixTable
        public let setSkill: RawSetSkillMetaDict
    }
}

// MARK: - Meta.RawTreeMetaDict

extension EnkaHSR.DBModels.Meta {
    public typealias RawTreeMetaDict = NestedPropValueMap
}
