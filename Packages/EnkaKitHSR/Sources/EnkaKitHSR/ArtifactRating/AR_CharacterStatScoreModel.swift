// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - ArtifactRating.CharacterStatScoreModel

extension ArtifactRating {
    public typealias CharacterStatScoreModel = [ArtifactRating.Appraiser.Param: ArtifactSubStatScore]
}

extension ArtifactRating.CharacterStatScoreModel {
    /// 查詢得分模型專用的函式。
    /// - Parameters:
    ///   - charID: 角色 ID
    ///   - artifactType: 聖遺物種類。指定了的話就查詢主詞條，如果沒指定（也就是 nil）那就查詢副詞條。
    /// - Returns: [ArtifactRating.Appraiser.Param: ArtifactSubStatScore]
    static func getScoreModel(
        charID: String,
        artifactType: EnkaHSR.DBModels.Artifact.ArtifactType? = nil
    )
        -> Self {
        var result = Self()
        guard let queried = ArtifactRating.sharedStatScoreModelDB[charID] else { return result }
        if let artifactType = artifactType, let foundMainStack = queried.main[artifactType] {
            result = foundMainStack
        } else {
            result = queried.weight
        }
        return result
    }

    static func getMax(charID: String) -> Double {
        ArtifactRating.sharedStatScoreModelDB[charID]?.max ?? 10
    }
}

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
extension ArtifactRating {
    public struct StatScoreModelOptimized {
        // MARK: Public

        public typealias Dict = [String: StatScoreModelOptimized]

        // MARK: Internal

        var main: [
            EnkaHSR.DBModels.Artifact.ArtifactType:
                [ArtifactRating.Appraiser.Param: ArtifactRating.SubStatScoreLevel]
        ] = [:]
        var weight: [ArtifactRating.Appraiser.Param: ArtifactRating.SubStatScoreLevel] = [:]
        var max: Double = 10
    }

    public struct StatScoreModelDecodable: Codable, Hashable {
        // MARK: Public

        public typealias Dict = [String: Self]

        // MARK: Internal

        let main: [String: [String: Double]]
        let weight: [String: Double]
        let max: Double
    }

    public static let sharedStatScoreModelDB: StatScoreModelOptimized.Dict = try! .construct()!
}

// swiftlint:enable force_try
// swiftlint:enable force_unwrapping
