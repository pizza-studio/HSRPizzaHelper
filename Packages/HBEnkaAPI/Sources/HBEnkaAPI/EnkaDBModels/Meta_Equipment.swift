// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - Meta.EquipmentMeta

extension EnkaHSR.DBModels.Meta {
    public typealias RawEquipmentMetaDict = [String: [String: EquipmentMeta]]

    public struct EquipmentMeta: Codable {
        public let BaseHP: Double
        public let HPAdd: Double
        public let BaseAttack: Double
        public let AttackAdd: Double
        public let BaseDefence: Double
        public let DefenceAdd: Double
    }
}
