// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.AvatarSummarized {
    public mutating func rateMyArtifacts() {
        artifactRatingResult = ArtifactRating.Appraiser(
            request: convert2ArtifactRatingModel()
        ).evaluate()
        if let result = artifactRatingResult {
            updateArtifacts { oldArray in
                oldArray.map { currentArtifact in
                    var ratedArtifact = currentArtifact
                    switch ratedArtifact.type {
                    case .head: ratedArtifact.ratedScore = result.stat1pt
                    case .hand: ratedArtifact.ratedScore = result.stat2pt
                    case .body: ratedArtifact.ratedScore = result.stat3pt
                    case .foot: ratedArtifact.ratedScore = result.stat4pt
                    case .object: ratedArtifact.ratedScore = result.stat5pt
                    case .neck: ratedArtifact.ratedScore = result.stat6pt
                    }
                    return ratedArtifact
                }
            }
        }
    }

    public func artifactsRated() -> Self {
        var this = self
        this.rateMyArtifacts()
        return this
    }

    public func convert2ArtifactRatingModel() -> ArtifactRating.RatingRequest {
        let extractedData = extractArtifactSetData()
        return ArtifactRating.RatingRequest(
            charID: mainInfo.uniqueCharId,
            characterElement: mainInfo.element,
            head: extractedData[.head] ?? .init(type: .head),
            hand: extractedData[.hand] ?? .init(type: .hand),
            body: extractedData[.body] ?? .init(type: .body),
            foot: extractedData[.foot] ?? .init(type: .foot),
            object: extractedData[.object] ?? .init(type: .object),
            neck: extractedData[.neck] ?? .init(type: .neck)
        )
    }

    private typealias ArtifactsDataDictionary =
        [EnkaHSR.DBModels.Artifact.ArtifactType: ArtifactRating.RatingRequest.Artifact]

    // swiftlint:disable cyclomatic_complexity
    private func extractArtifactSetData() -> ArtifactsDataDictionary {
        var arrResult = ArtifactsDataDictionary()
        artifacts.forEach { thisSummarizedArtifact in
            var result = ArtifactRating.RatingRequest.Artifact(
                type: thisSummarizedArtifact.type
            )
            let artifactType = thisSummarizedArtifact.type
            result.star = thisSummarizedArtifact.rarityStars
            result.setID = thisSummarizedArtifact.setID
            result.level = thisSummarizedArtifact.trainedLevel
            // 副词条
            thisSummarizedArtifact.subProps.forEach { thisPropPair in
                guard let typeAppraisable = thisPropPair.type.appraisableArtifactParam else { return }
                switch typeAppraisable {
                case .hpDelta: result.subPanel.hpDelta = thisPropPair.value
                case .atkDelta: result.subPanel.attackDelta = thisPropPair.value
                case .defDelta: result.subPanel.defenceDelta = thisPropPair.value
                case .hpAmp: result.subPanel.hpAddedRatio = thisPropPair.value
                case .atkAmp: result.subPanel.attackAddedRatio = thisPropPair.value
                case .defAmp: result.subPanel.defenceAddedRatio = thisPropPair.value
                case .spdDelta: result.subPanel.speedDelta = thisPropPair.value
                case .critChance: result.subPanel.criticalChanceBase = thisPropPair.value
                case .critDamage: result.subPanel.criticalDamageBase = thisPropPair.value
                case .statProb: result.subPanel.statusProbabilityBase = thisPropPair.value
                case .statResis: result.subPanel.statusResistanceBase = thisPropPair.value
                case .breakDmg: result.subPanel.breakDamageAddedRatioBase = thisPropPair.value
                case .healAmp: return // 主词条专属项目「治疗量加成」。
                case .energyRecovery: return // 主词条专属项目「元素充能效率」。
                case .dmgAmp: return // 主词条专属项目「元素伤害加成」。
                }
            }
            result.mainProp = thisSummarizedArtifact.mainProp.type.appraisableArtifactParam
            arrResult[artifactType] = result
        }
        return arrResult
    }
    // swiftlint:enable cyclomatic_complexity
}
