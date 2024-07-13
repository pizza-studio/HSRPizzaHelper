// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation

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

    public static var sharedStatScoreModelDB: StatScoreModelOptimized.Dict = .construct()
}

extension ArtifactRating {
    public static func resetFactoryScoreModel() {
        Defaults.reset([.srsModelData])
        sharedStatScoreModelDB = .construct()
    }

    public static func onlineUpdateScoreModel() async -> Bool {
        let initialServer = Defaults[.defaultDBQueryHost]
        do {
            let data = try await EnkaHSR.Sputnik.fetchArtifactModelData(from: initialServer)
            sharedStatScoreModelDB = data.optimized
        } catch {
            return false
        }
        return true
    }

    public static func isScoreModelExpired(against profile: EnkaHSR.QueryRelated.DetailInfo) -> Bool {
        let targetIDs: Set<String> = .init(profile.avatarDetailList.map(\.avatarId.description))
        guard targetIDs.isSubset(of: Set<String>(sharedStatScoreModelDB.keys)) else { return true }
        let effectiveModels = sharedStatScoreModelDB.compactMap { theKey, theModel in
            targetIDs.contains(theKey) ? theModel : nil
        }
        return effectiveModels.areAllContentsValid
    }
}

extension [ArtifactRating.StatScoreModelOptimized] {
    public var areAllContentsValid: Bool {
        let effectiveCount: Int = map { theModel in
            theModel.weight.map(\.value.rawValue).reduce(0, +) > 0 ? 1 : 0
        }.reduce(0, +)
        return effectiveCount == count
    }
}
