// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

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
