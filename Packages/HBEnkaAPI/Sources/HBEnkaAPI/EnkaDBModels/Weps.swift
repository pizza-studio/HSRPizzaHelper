// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias WeaponsDict = [String: Weapon]

    public struct Weapon: Codable {
        // MARK: Public

        public struct EquipmentName: Codable {
            // MARK: Public

            public let hash: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }
        }

        public let rarity: Int
        public let avatarBaseType: String
        public let equipmentName: EquipmentName
        public let imagePath: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case rarity = "Rarity"
            case avatarBaseType = "AvatarBaseType"
            case equipmentName = "EquipmentName"
            case imagePath = "ImagePath"
        }
    }
}
