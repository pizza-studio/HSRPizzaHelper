// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias CharacterDict = [String: Character]

    public struct Character: Codable {
        public struct AvatarFullName: Codable {
            public let Hash: Int64
        }

        public struct AvatarName: Codable {
            public let Hash: Int64
        }

        public let AvatarName: AvatarName
        public let AvatarFullName: AvatarFullName
        public let Rarity: Int
        public let Element: Element
        public let AvatarBaseType: String
        public let AvatarSideIconPath: String
        public let ActionAvatarHeadIconPath: String
        public let AvatarCutinFrontImgPath: String
        public let RankIDList: [Int]
        public let SkillList: [Int]
    }
}
