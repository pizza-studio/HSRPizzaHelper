// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import DefaultsKeys
import Foundation

// MARK: - ArtifactRating

// swiftlint:disable cyclomatic_complexity

public enum ArtifactRating {}

public typealias ArtifactSubStatScore = ArtifactRating.SubStatScoreLevel

// MARK: - ArtifactRating.SubStatScoreLevel

extension ArtifactRating {
    public enum SubStatScoreLevel: Double, Codable, Hashable {
        case highest = 31
        case higherPlus = 30
        case higher = 28
        case highPlus = 27
        case high = 25
        case medium = 23
        case low = 20
        case lower = 18
        case lowerLower = 14
        case lowest = 11
        case none = 9

        // MARK: Lifecycle

        /// Ref: https://github.com/Mar-7th/StarRailScore
        public init(march7thWeight: Double) {
            switch march7thWeight {
            case 1: self = .highest
            case 0.9 ..< 1: self = .higherPlus
            case 0.8 ..< 0.9: self = .higher
            case 0.7 ..< 0.8: self = .highPlus
            case 0.6 ..< 0.7: self = .high
            case 0.5 ..< 0.6: self = .medium
            case 0.4 ..< 0.5: self = .low
            case 0.3 ..< 0.4: self = .lower
            case 0.2 ..< 0.3: self = .lowerLower
            case 0.1 ..< 0.2: self = .lowest
            default: self = .none
            }
        }
    }
}

// MARK: - ArtifactRating.Appraiser

extension ArtifactRating {
    public struct Appraiser {
        // MARK: Lifecycle

        public init(request: ArtifactRating.RatingRequest) {
            self.request = request
        }

        // MARK: Public

        // 用于圣遗物评分统计的一个专属 Enum，仅包含会被圣遗物用到的词条。
        public enum Param: Hashable {
            case hpDelta
            case atkDelta
            case defDelta
            case hpAmp
            case atkAmp
            case defAmp
            case spdDelta
            case critChance
            case critDamage
            case statProb
            case statResis
            case breakDmg
            case healAmp
            case energyRecovery
            case dmgAmp(EnkaHSR.Element?)
        }

        public let request: ArtifactRating.RatingRequest
    }
}

extension ArtifactRating.Appraiser {
    public static func tellTier(score: Int) -> String {
        switch score {
        case 1300...: return "SSS+"
        case 1250 ..< 1300: return "SSS"
        case 1200 ..< 1250: return "SSS-"
        case 1150 ..< 1200: return "SS+"
        case 1100 ..< 1150: return "SS+"
        case 1050 ..< 1100: return "S+"
        case 1000 ..< 1050: return "S"
        case 950 ..< 1000: return "S-"
        case 900 ..< 950: return "A+"
        case 850 ..< 900: return "A"
        case 800 ..< 850: return "A-"
        case 750 ..< 800: return "B+"
        case 700 ..< 750: return "B"
        case 650 ..< 700: return "B-"
        case 600 ..< 650: return "C+"
        case 550 ..< 600: return "C"
        case 500 ..< 550: return "C-"
        case 450 ..< 500: return "D+"
        case 400 ..< 450: return "D"
        case 350 ..< 400: return "D-"
        case 300 ..< 350: return "E+"
        case 250 ..< 300: return "E"
        case 200 ..< 250: return "E-"
        default: return "F"
        }
    }

    public static func getDefaultRoll(
        for param: ArtifactRating.Appraiser.Param, star5: Bool
    )
        -> Double {
        var result: Double = 0
        switch param {
        case .dmgAmp: result = 7.0
        case .critChance: result = 3.3
        case .critDamage: result = 6.6
        case .energyRecovery: result = 5.5
        case .atkAmp: result = 5
        case .atkDelta: result = 17
        case .hpAmp: result = 5
        case .hpDelta: result = 26
        case .defAmp: result = 6.2
        case .defDelta: result = 20
        case .healAmp: result = 5.4
        case .spdDelta: result = 5 // HSR Special.
        case .statProb: result = 6 // HSR Special.
        case .statResis: result = 5 // HSR Special.
        case .breakDmg: result = 10 // HSR Special.
        }
        if !star5 { result *= 0.9 } // 简化对非五星圣遗物的处理。
        return result
    }
}

extension ArtifactRating.RatingRequest.Artifact {
    func getSubScore(
        for request: ArtifactRating.RatingRequest
    )
        -> Double {
        let isStar5: Bool = star >= 5
        var ratingModel = ArtifactRating.CharacterStatScoreModel.getScoreModel(charID: request.charID.description)

        func getPt(_ base: Double, _ param: ArtifactRating.Appraiser.Param) -> Double {
            (base / ArtifactRating.Appraiser.getDefaultRoll(for: param, star5: isStar5)) * (ratingModel[param] ?? .none)
                .rawValue
        }

        // 副詞條處理。
        var stackedScore: [Double] = [
            getPt(subPanel.hpDelta, .hpDelta),
            getPt(subPanel.attackDelta, .atkDelta),
            getPt(subPanel.defenceDelta, .defDelta),
            getPt(subPanel.hpAddedRatio, .hpAmp),
            getPt(subPanel.attackAddedRatio, .atkAmp),
            getPt(subPanel.defenceAddedRatio, .defAmp),
            getPt(subPanel.speedDelta, .spdDelta),
            getPt(subPanel.criticalChanceBase, .critChance),
            getPt(subPanel.criticalDamageBase, .critDamage),
            getPt(subPanel.statusProbabilityBase, .statProb),
            getPt(subPanel.statusResistanceBase, .statResis),
            getPt(subPanel.breakDamageAddedRatioBase, .breakDmg),
        ]

        // 主詞條處理。
        var shouldAdjustForMainProp = false
        checkMainProps: do {
            guard let mainPropParam = mainProp else { break checkMainProps }
            guard ![.head, .hand].contains(type) else { break checkMainProps }
            ratingModel = ArtifactRating.CharacterStatScoreModel.getScoreModel(
                charID: request.charID.description,
                artifactType: type
            )
            let mainPropWeight = Double(level) * 0.25 + 1
            shouldAdjustForMainProp = true
            stackedScore.append(getPt(mainPropWeight, mainPropParam) / 5)
        }

        var result = stackedScore.reduce(0, +)
        if shouldAdjustForMainProp {
            // 因为引入了主词条加分机制，导致分数上涨得有些虚高了。这里给总分乘以 0.9。
            // 理论上，此处的调整不会影响到花翎，只会影响到钟杯帽。
            // 这也就是说，如果角色带了与自己属性或者特长不相配的属性伤害杯的话，反而会「扣分」。
            result *= 0.9
        }
        return result * 3
    }
}

extension ArtifactRating.Appraiser {
    public func evaluate() -> ArtifactRating.ScoreResult? {
        var result = ArtifactRating.ScoreResult(
            charID: request.charID.description
        )

        let totalScore: Int = request.allArtifacts.map { artifact in
            let score = Int(artifact.getSubScore(for: request))
            switch artifact.type {
            case .head: result.stat1pt = score
            case .hand: result.stat2pt = score
            case .body: result.stat3pt = score
            case .foot: result.stat4pt = score
            case .object: result.stat5pt = score
            case .neck: result.stat6pt = score
            }
            return score
        }.reduce(0, +)

        result.allpt = totalScore
        result.result = Self.tellTier(score: totalScore)

        return result
    }
}

// MARK: - ArtifactRating.ScoreResult

extension ArtifactRating {
    public struct ScoreResult: Codable, Equatable, Hashable {
        public var charID: String
        public var stat1pt: Int = 0
        public var stat2pt: Int = 0
        public var stat3pt: Int = 0
        public var stat4pt: Int = 0
        public var stat5pt: Int = 0
        public var stat6pt: Int = 0
        public var allpt: Int = 0
        public var result: String = "N/A"

        public var isValid: Bool {
            guard allpt == stat1pt + stat2pt + stat3pt + stat4pt + stat5pt
            else { return false }
            guard stat1pt >= 0 else { return false }
            guard stat2pt >= 0 else { return false }
            guard stat3pt >= 0 else { return false }
            guard stat4pt >= 0 else { return false }
            guard stat5pt >= 0 else { return false }
            guard stat6pt >= 0 else { return false }
            return true
        }

        public func convertToCollectionModel(
            uid: String
        )
            -> ArtifactRating.CollectionModel {
            ArtifactRating.CollectionModel(
                uid: uid,
                charID: charID,
                totalScore: allpt,
                stat1Score: stat1pt,
                stat2Score: stat2pt,
                stat3Score: stat3pt,
                stat4Score: stat4pt,
                stat5Score: stat5pt,
                stat6Score: stat6pt
            )
        }
    }
}

// MARK: - ArtifactRating.CollectionModel

extension ArtifactRating {
    public struct CollectionModel: Codable {
        public var uid: String
        public var charID: String
        public var totalScore: Int
        public var stat1Score: Int
        public var stat2Score: Int
        public var stat3Score: Int
        public var stat4Score: Int
        public var stat5Score: Int
        public var stat6Score: Int
    }
}

// swiftlint:enable cyclomatic_complexity
