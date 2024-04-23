// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// Relics = Artifacts.

extension EnkaHSR.DBModels {
    public typealias ArtifactsDict = [String: Artifact]

    public struct Artifact: Codable, Hashable {
        // MARK: Public

        public enum ArtifactType: String, Codable, Hashable, CaseIterable, Identifiable {
            case head = "HEAD"
            case hand = "HAND"
            case body = "BODY"
            case foot = "FOOT"
            case object = "OBJECT"
            case neck = "NECK"

            // MARK: Public

            public var id: String { rawValue }

            public var assetSuffix: Int {
                switch self {
                case .head: return 0
                case .hand: return 1
                case .body: return 2
                case .foot: return 3
                case .object: return 0
                case .neck: return 1
                }
            }
        }

        public let rarity: Int
        public let type: ArtifactType
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
