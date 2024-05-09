// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - ArtifactRating.RatingRequest

extension ArtifactRating {
    public struct RatingRequest {
        public var charID: Int
        public var characterElement: EnkaHSR.Element
        public var head: Artifact
        public var hand: Artifact
        public var body: Artifact
        public var foot: Artifact
        public var object: Artifact
        public var neck: Artifact

        public var allArtifacts: [Artifact] {
            [head, hand, body, foot, object, neck]
        }

        public var allValidArtifacts: [Artifact] {
            allArtifacts.filter(\.isValid)
        }
    }
}

// MARK: - ArtifactRating.RatingRequest.Artifact

extension ArtifactRating.RatingRequest {
    // MARK: Public

    public struct Artifact {
        public var mainProp: ArtifactRating.Appraiser.Param?
        public var type: EnkaHSR.DBModels.Artifact.ArtifactType
        public var star: Int = 5
        public var level: Int = 20
        public var setID: Int = -114_514
        public var subPanel: SubPropData = .init()

        public var isNull: Bool {
            setID == -114_514
        }

        public var isValid: Bool {
            !isNull
        }
    }
}

// MARK: - ArtifactRating.RatingRequest.SubPropData

extension ArtifactRating.RatingRequest {
    public struct SubPropData: Hashable, Codable, Sendable {
        var hpDelta: Double = 0
        var attackDelta: Double = 0
        var defenceDelta: Double = 0
        var hpAddedRatio: Double = 0
        var attackAddedRatio: Double = 0
        var defenceAddedRatio: Double = 0
        var speedDelta: Double = 0
        var criticalChanceBase: Double = 0
        var criticalDamageBase: Double = 0
        var statusProbabilityBase: Double = 0
        var statusResistanceBase: Double = 0
        var breakDamageAddedRatioBase: Double = 0
    }
}
