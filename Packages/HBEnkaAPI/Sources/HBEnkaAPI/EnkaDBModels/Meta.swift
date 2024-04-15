// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias MetaDict = [String: Meta]

    public struct Meta: Codable {
        public let avatar: RawAvatarMetaDict
        public let equipment: RawEquipmentMetaDict
        public let equipmentSkill: RawEquipSkillMetaDict
        public let relic: RawRelicDB
        public let tree: RawTreeMetaDict
    }
}

// MARK: - Dictionary Aliases

extension EnkaHSR.DBModels.Meta {
    public typealias NestedPropValueMap = [String: [String: [String: [String: Double]]]]
}

extension EnkaHSR.DBModels.Meta.NestedPropValueMap {
    public func query(id: any StringProtocol) -> [EnkaHSR.DBModels.PropType: Double] {
        let rawResult = self[id.description]?.first?.value.first?.value ?? [:]
        var results = [EnkaHSR.DBModels.PropType: Double]()
        for (key, value) in rawResult {
            guard let propKey = EnkaHSR.DBModels.PropType(rawValue: key) else { continue }
            results[propKey] = value
        }
        return results
    }

    public func query(id: Int) -> [EnkaHSR.DBModels.PropType: Double] {
        query(id: id.description)
    }
}
