// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

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
        let Property: EnkaHSR.DBModels.PropType
        let BaseValue: Double
        let LevelAdd: Double
    }

    public struct SubAffix: Codable {
        let Property: EnkaHSR.DBModels.PropType
        let BaseValue: Double
        let StepValue: Double
    }

    public typealias MainAffixTable = [String: [String: MainAffix]]
    public typealias SubAffixTable = [String: [String: SubAffix]]
    public typealias RawSetSkillMetaDict = EnkaHSR.DBModels.Meta.NestedPropValueMap
}
