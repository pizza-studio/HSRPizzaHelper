// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias SkillRanksDict = [String: SkillRank]

    public struct SkillRank: Codable {
        // MARK: Public

        public let iconPath: String
        public let skillAddLevelList: [String: Int]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case iconPath = "IconPath"
            case skillAddLevelList = "SkillAddLevelList"
        }
    }
}
