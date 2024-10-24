// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    public typealias SkillTreesDict = [String: SkillTree]

    public typealias SkillTree = [String: [SkillInTree]]

    public enum SkillInTree: Codable, Hashable {
        case baseSkill(String)
        case extendedSkills([String])

        // MARK: Lifecycle

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([String].self) {
                self = .extendedSkills(x)
                return
            }
            if let x = try? container.decode(String.self) {
                self = .baseSkill(x)
                return
            }
            throw DecodingError.typeMismatch(
                SkillInTree.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SkillInTree")
            )
        }

        // MARK: Public

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .baseSkill(x):
                try container.encode(x)
            case let .extendedSkills(x):
                try container.encode(x)
            }
        }
    }
}
