// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// Relics = Artifacts.

extension EnkaHSR.DBModels {
    public typealias ArtifactsDict = [String: Artifact]

    public struct Artifact: Codable, Hashable {
        // MARK: Public

        public let rarity: Int
        public let type: String
        public let mainAffixGroup: Int
        public let subAffixGroup: Int
        public let icon: String
        public let setID: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case rarity = "Rarity"
            case type = "Type"
            case mainAffixGroup = "MainAffixGroup"
            case subAffixGroup = "SubAffixGroup"
            case icon = "Icon"
            case setID = "SetID"
        }
    }
}
