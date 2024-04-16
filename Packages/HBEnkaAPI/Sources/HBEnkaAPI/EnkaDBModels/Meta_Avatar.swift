// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

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
