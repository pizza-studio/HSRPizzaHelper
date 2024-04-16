// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias CharacterDict = [String: Character]

    public struct Character: Codable {
        // MARK: Public

        public struct AvatarFullName: Codable {
            // MARK: Public

            public let hash: Int64

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }
        }

        public struct AvatarName: Codable {
            // MARK: Public

            public let hash: Int64

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }
        }

        public let avatarName: AvatarName
        public let avatarFullName: AvatarFullName
        public let rarity: Int
        public let element: Element
        public let avatarBaseType: String
        public let avatarSideIconPath: String
        public let actionAvatarHeadIconPath: String
        public let avatarCutinFrontImgPath: String
        public let rankIDList: [Int]
        public let skillList: [Int]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case avatarName = "AvatarName"
            case avatarFullName = "AvatarFullName"
            case rarity = "Rarity"
            case element = "Element"
            case avatarBaseType = "AvatarBaseType"
            case avatarSideIconPath = "AvatarSideIconPath"
            case actionAvatarHeadIconPath = "ActionAvatarHeadIconPath"
            case avatarCutinFrontImgPath = "AvatarCutinFrontImgPath"
            case rankIDList = "RankIDList"
            case skillList = "SkillList"
        }
    }
}
