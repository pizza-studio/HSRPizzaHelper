// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - EnkaHSR.DBModels.Meta.RawRelicDB

// Relic = Artifact

extension EnkaHSR.DBModels.Meta {
    public struct RawRelicDB: Codable {
        public let mainAffix: MainAffixTable
        public let subAffix: SubAffixTable
        public let setSkill: RawSetSkillMetaDict
    }
}

// MARK: - Structs @ EnkaHSR.Meta.RawRelicDB

extension EnkaHSR.DBModels.Meta.RawRelicDB {
    public struct MainAffix: Codable {
        enum CodingKeys: String, CodingKey {
            case property = "Property"
            case baseValue = "BaseValue"
            case levelAdd = "LevelAdd"
        }

        let property: EnkaHSR.DBModels.PropType
        let baseValue: Double
        let levelAdd: Double
    }

    public struct SubAffix: Codable {
        enum CodingKeys: String, CodingKey {
            case property = "Property"
            case baseValue = "BaseValue"
            case stepValue = "StepValue"
        }

        let property: EnkaHSR.DBModels.PropType
        let baseValue: Double
        let stepValue: Double
    }

    public typealias MainAffixTable = [String: [String: MainAffix]]
    public typealias SubAffixTable = [String: [String: SubAffix]]
    public typealias RawSetSkillMetaDict = EnkaHSR.DBModels.Meta.NestedPropValueMap
}
