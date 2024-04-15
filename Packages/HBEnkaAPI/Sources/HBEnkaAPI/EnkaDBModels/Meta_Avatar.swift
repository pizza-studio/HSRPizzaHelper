// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - Meta.AvatarMeta

extension EnkaHSR.DBModels.Meta {
    public typealias RawAvatarMetaDict = [String: [String: AvatarMeta]]

    public struct AvatarMeta: Codable {
        public let HPBase: Double
        public let HPAdd: Double
        public let AttackBase: Double
        public let AttackAdd: Double
        public let DefenceBase: Double
        public let DefenceAdd: Double
        public let SpeedBase: Double
        public let CriticalChance: Double
        public let CriticalDamage: Double
        public let BaseAggro: Double
    }
}
