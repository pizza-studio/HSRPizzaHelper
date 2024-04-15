// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// Relics = Artifacts.

extension EnkaHSR.DBModels {
    public typealias ArtifactsDict = [String: Artifact]

    public struct Artifact: Codable {
        public let Rarity: Int
        public let `Type`: String
        public let MainAffixGroup: Int
        public let SubAffixGroup: Int
        public let Icon: String
        public let SetID: Int
    }
}
