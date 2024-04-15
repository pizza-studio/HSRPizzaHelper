// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias SkillsDict = [String: Skill]

    public struct Skill: Codable {
        public let IconPath: String
        public let PointType: Int
    }
}
