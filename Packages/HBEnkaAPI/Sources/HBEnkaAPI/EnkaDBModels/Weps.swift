// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias WeaponsDict = [String: Weapon]

    public struct Weapon: Codable {
        public struct EquipmentName: Codable {
            public let Hash: Int
        }

        public let Rarity: Int
        public let AvatarBaseType: String
        public let EquipmentName: EquipmentName
        public let ImagePath: String
    }
}
