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
}

// swiftlint:disable file_length
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

    /// Ref (HSR v2.1 and earlier): https://github.com/Mar-7th/StarRailScore
    /// Ref (2.2 and newer): Bilibili HSR Wiki.
    public static let sharedStatScoreModelDB: StatScoreModelOptimized.Dict = [
        "1001": .init(
            main: [
                .foot: [.hpAmp: .medium, .spdDelta: .higher, .defAmp: .highest],
                .body: [
                    .statProb: .highest,
                    .hpAmp: .medium,
                    .defAmp: .highest,
                ],
                .object: [.hpAmp: .medium, .defAmp: .highest],
                .neck: [
                    .defAmp: .highest,
                    .hpAmp: .medium,
                    .energyRecovery: .highest,
                ],
            ],
            weight: [
                .hpAmp: .medium,
                .defDelta: .medium,
                .spdDelta: .highest,
                .statResis: .medium,
                .defAmp: .highest,
                .statProb: .medium,
                .hpDelta: .lowerLower,
            ],
            max: 10.0
        ),
        "1002": .init(
            main: [
                .neck: [.atkAmp: .highest, .energyRecovery: .medium],
                .object: [.atkAmp: .higher, .dmgAmp(.anemo): .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .body: [
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .critDamage: .highest,
                .critChance: .highest,
                .spdDelta: .highest,
                .atkAmp: .higher,
                .atkDelta: .lower,
            ],
            max: 10.0
        ),
        "1003": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .neck: [
                    .breakDmg: .highest,
                    .energyRecovery: .highest,
                    .atkAmp: .higher,
                ],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
                .object: [.dmgAmp(.pyro): .highest, .atkAmp: .higher],
            ],
            weight: [
                .atkAmp: .higher,
                .spdDelta: .higher,
                .critChance: .highest,
                .breakDmg: .medium,
                .atkDelta: .lower,
                .critDamage: .highest,
            ],
            max: 10.0
        ),
        "1004": .init(
            main: [
                .neck: [
                    .energyRecovery: .highest,
                    .breakDmg: .highest,
                    .atkAmp: .higher,
                ],
                .object: [.dmgAmp(.fantastico): .highest, .atkAmp: .higher],
                .foot: [.atkAmp: .highest, .spdDelta: .highest],
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .statProb: .highest,
                    .critDamage: .higherPlus,
                ],
            ],
            weight: [
                .spdDelta: .highest,
                .atkAmp: .higher,
                .critChance: .highest,
                .critDamage: .highest,
                .atkDelta: .lower,
                .statProb: .highest,
            ],
            max: 10.0
        ),
        "1005": .init(
            main: [
                .body: [
                    .critDamage: .higher,
                    .critChance: .higher,
                    .atkAmp: .highest,
                    .statProb: .highest,
                ],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .higher],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .neck: [
                    .energyRecovery: .medium,
                    .breakDmg: .highest,
                    .atkAmp: .higher,
                ],
            ],
            weight: [
                .atkDelta: .lower,
                .spdDelta: .highest,
                .statProb: .highest,
                .critChance: .highest,
                .critDamage: .highest,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "1006": .init(
            main: [
                .neck: [.atkAmp: .medium, .energyRecovery: .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .object: [.atkAmp: .higher, .dmgAmp(.posesto): .highest],
                .body: [
                    .statProb: .highest,
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .spdDelta: .highest,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critDamage: .highest,
                .critChance: .highest,
                .statProb: .highest,
            ],
            max: 10.0
        ),
        "1008": .init(
            main: [
                .neck: [
                    .energyRecovery: .medium,
                    .breakDmg: .highest,
                    .atkAmp: .highest,
                ],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                ],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .higher],
            ],
            weight: [
                .atkAmp: .higher,
                .critDamage: .highest,
                .spdDelta: .higher,
                .critChance: .highest,
                .atkDelta: .lower,
            ],
            max: 10.0
        ),
        "1009": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .object: [.dmgAmp(.pyro): .highest, .atkAmp: .higher],
                .foot: [.atkAmp: .highest, .spdDelta: .highest],
                .neck: [
                    .energyRecovery: .highest,
                    .atkAmp: .higher,
                    .breakDmg: .highest,
                ],
            ],
            weight: [
                .breakDmg: .higher,
                .atkDelta: .lower,
                .spdDelta: .highest,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "1013": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
                .object: [.atkAmp: .higher, .dmgAmp(.cryo): .highest],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
            ],
            weight: [
                .spdDelta: .higher,
                .atkAmp: .higher,
                .critChance: .highest,
                .critDamage: .highest,
                .atkDelta: .lower,
            ],
            max: 10.0
        ),
        "1101": .init(
            main: [
                .foot: [
                    .atkAmp: .medium,
                    .hpAmp: .higher,
                    .spdDelta: .highest,
                    .defAmp: .higher,
                ],
                .object: [
                    .defAmp: .highest,
                    .dmgAmp(.anemo): .medium,
                    .hpAmp: .highest,
                    .atkAmp: .medium,
                ],
                .neck: [.energyRecovery: .highest, .atkAmp: .medium],
                .body: [
                    .critDamage: .highest,
                    .atkAmp: .medium,
                    .hpAmp: .medium,
                ],
            ],
            weight: [
                .hpDelta: .lower,
                .spdDelta: .highest,
                .atkAmp: .medium,
                .defAmp: .higher,
                .defDelta: .lower,
                .atkDelta: .lowerLower,
                .statResis: .medium,
                .hpAmp: .higher,
                .critDamage: .highest,
            ],
            max: 10.0
        ),
        "1102": .init(
            main: [
                .neck: [.atkAmp: .highest, .energyRecovery: .medium],
                .object: [.dmgAmp(.posesto): .highest, .atkAmp: .higher],
                .body: [
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                ],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
            ],
            weight: [
                .critChance: .highest,
                .critDamage: .highest,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .spdDelta: .highest,
            ],
            max: 10.0
        ),
        "1103": .init(
            main: [
                .neck: [
                    .energyRecovery: .medium,
                    .breakDmg: .highest,
                    .atkAmp: .highest,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.electro): .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                ],
            ],
            weight: [
                .critDamage: .highest,
                .atkAmp: .higher,
                .atkDelta: .lower,
                .critChance: .highest,
                .spdDelta: .higher,
            ],
            max: 10.0
        ),
        "1104": .init(
            main: [
                .body: [.hpAmp: .medium, .defAmp: .highest, .statProb: .medium],
                .foot: [.spdDelta: .higher, .defAmp: .highest, .hpAmp: .medium],
                .object: [.defAmp: .highest, .hpAmp: .medium],
                .neck: [
                    .energyRecovery: .highest,
                    .defAmp: .highest,
                    .hpAmp: .medium,
                ],
            ],
            weight: [
                .hpAmp: .medium,
                .statResis: .medium,
                .defAmp: .highest,
                .defDelta: .medium,
                .statProb: .medium,
                .hpDelta: .lowerLower,
                .spdDelta: .highest,
            ],
            max: 10.0
        ),
        "1105": .init(
            main: [
                .foot: [.hpAmp: .highest, .spdDelta: .highest],
                .neck: [.hpAmp: .highest, .energyRecovery: .medium],
                .object: [.hpAmp: .highest, .defAmp: .medium],
                .body: [.healAmp: .highest, .hpAmp: .higher],
            ],
            weight: [
                .spdDelta: .higher,
                .defDelta: .lowerLower,
                .statResis: .medium,
                .hpAmp: .highest,
                .hpDelta: .medium,
                .defAmp: .medium,
            ],
            max: 10.0
        ),
        "1106": .init(
            main: [
                .body: [
                    .statProb: .highest,
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                ],
                .neck: [.energyRecovery: .medium, .atkAmp: .highest],
                .object: [.atkAmp: .higher, .dmgAmp(.cryo): .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
            ],
            weight: [
                .critChance: .highest,
                .atkDelta: .lower,
                .critDamage: .highest,
                .spdDelta: .highest,
                .statProb: .highest,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "1107": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.physico): .highest],
                .neck: [
                    .atkAmp: .highest,
                    .energyRecovery: .medium,
                    .breakDmg: .highest,
                ],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
            ],
            weight: [
                .atkAmp: .higher,
                .critChance: .highest,
                .spdDelta: .higher,
                .critDamage: .highest,
                .atkDelta: .lower,
            ],
            max: 10.0
        ),
        "1108": .init(
            main: [
                .neck: [.atkAmp: .higher, .energyRecovery: .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .body: [
                    .critDamage: .higher,
                    .critChance: .higher,
                    .statProb: .highest,
                    .atkAmp: .highest,
                ],
                .object: [.dmgAmp(.anemo): .highest, .atkAmp: .higher],
            ],
            weight: [
                .critDamage: .highest,
                .spdDelta: .highest,
                .atkDelta: .lower,
                .critChance: .highest,
                .atkAmp: .higher,
                .statProb: .highest,
            ],
            max: 10.0
        ),
        "1109": .init(
            main: [
                .neck: [
                    .breakDmg: .medium,
                    .energyRecovery: .medium,
                    .atkAmp: .highest,
                ],
                .object: [.dmgAmp(.pyro): .highest, .atkAmp: .higher],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .body: [
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critDamage: .highest,
                .critChance: .highest,
                .spdDelta: .higher,
            ],
            max: 10.0
        ),
        "1110": .init(
            main: [
                .neck: [.hpAmp: .highest, .energyRecovery: .highest],
                .foot: [.hpAmp: .higher, .spdDelta: .highest],
                .object: [.hpAmp: .highest],
                .body: [.healAmp: .highest, .hpAmp: .higher],
            ],
            weight: [
                .defDelta: .lowerLower,
                .hpAmp: .highest,
                .statResis: .highPlus,
                .hpDelta: .medium,
                .spdDelta: .highest,
                .defAmp: .medium,
            ],
            max: 10.0
        ),
        "1111": .init(
            main: [
                .body: [
                    .statProb: .highest,
                    .critChance: .higher,
                    .critDamage: .higher,
                    .atkAmp: .highest,
                ],
                .neck: [
                    .energyRecovery: .highest,
                    .atkAmp: .highest,
                    .breakDmg: .highest,
                ],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .object: [.atkAmp: .higher, .dmgAmp(.physico): .highest],
            ],
            weight: [
                .atkAmp: .higher,
                .atkDelta: .lower,
                .spdDelta: .highest,
                .critChance: .highest,
                .critDamage: .highest,
                .statProb: .highest,
            ],
            max: 10.0
        ),
        "1112": .init(
            main: [
                .neck: [.energyRecovery: .highest, .atkAmp: .highest],
                .object: [.dmgAmp(.pyro): .highest, .atkAmp: .higher],
                .body: [
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                ],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
            ],
            weight: [
                .atkAmp: .higher,
                .spdDelta: .highest,
                .critChance: .highest,
                .atkDelta: .lower,
                .hpDelta: .lowest,
                .critDamage: .highest,
                .hpAmp: .lower,
            ],
            max: 10.0
        ),
        "1201": .init(
            main: [
                .object: [.atkAmp: .higher, .dmgAmp(.posesto): .highest],
                .neck: [.atkAmp: .higher, .energyRecovery: .highest],
                .body: [
                    .critChance: .highest,
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                ],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
            ],
            weight: [
                .atkDelta: .lower,
                .critDamage: .highest,
                .spdDelta: .higher,
                .critChance: .highest,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "1202": .init(
            main: [
                .body: [
                    .hpAmp: .medium,
                    .critDamage: .medium,
                    .critChance: .medium,
                    .atkAmp: .highest,
                ],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .higher],
                .neck: [.energyRecovery: .highest, .atkAmp: .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
            ],
            weight: [
                .atkDelta: .medium,
                .hpDelta: .lowerLower,
                .spdDelta: .highest,
                .atkAmp: .highest,
                .hpAmp: .medium,
            ],
            max: 10.0
        ),
        "1203": .init(
            main: [
                .foot: [.spdDelta: .highest, .hpAmp: .highest],
                .object: [.hpAmp: .highest, .defAmp: .medium],
                .body: [.hpAmp: .higher, .healAmp: .highest],
                .neck: [.hpAmp: .highest, .energyRecovery: .medium],
            ],
            weight: [
                .hpDelta: .medium,
                .spdDelta: .higher,
                .defAmp: .medium,
                .defDelta: .lowerLower,
                .hpAmp: .highest,
                .statResis: .medium,
            ],
            max: 10.0
        ),
        "1204": .init(
            main: [
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.electro): .highest],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
                .neck: [.atkAmp: .higher, .energyRecovery: .highest],
            ],
            weight: [
                .spdDelta: .highest,
                .atkAmp: .higher,
                .critChance: .highest,
                .atkDelta: .lower,
                .critDamage: .highest,
            ],
            max: 10.0
        ),
        "1205": .init(
            main: [
                .neck: [
                    .atkAmp: .higher,
                    .hpAmp: .highest,
                    .energyRecovery: .medium,
                ],
                .body: [
                    .critChance: .highest,
                    .hpAmp: .higher,
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                ],
                .object: [
                    .dmgAmp(.anemo): .highest,
                    .hpAmp: .higher,
                    .atkAmp: .higher,
                ],
                .foot: [.spdDelta: .highest, .atkAmp: .higher, .hpAmp: .higher],
            ],
            weight: [
                .spdDelta: .higher,
                .atkAmp: .higher,
                .critChance: .highest,
                .critDamage: .highest,
                .hpDelta: .lower,
                .atkDelta: .lower,
                .hpAmp: .higher,
            ],
            max: 10.0
        ),
        "1206": .init(
            main: [
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .higher],
                .neck: [
                    .energyRecovery: .medium,
                    .breakDmg: .highest,
                    .atkAmp: .higher,
                ],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .breakDmg: .medium,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critChance: .highest,
                .critDamage: .highest,
                .spdDelta: .highest,
            ],
            max: 10.0
        ),
        "1207": .init(
            main: [
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
                .body: [
                    .statProb: .higher,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .atkAmp: .highest,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.fantastico): .highest],
            ],
            weight: [
                .atkAmp: .higher,
                .spdDelta: .highest,
                .atkDelta: .lower,
            ],
            max: 10.0
        ),
        "1208": .init(
            main: [
                .object: [
                    .hpAmp: .highest,
                    .defAmp: .higher,
                    .dmgAmp(.posesto): .highest,
                ],
                .foot: [.hpAmp: .higher, .spdDelta: .highest],
                .body: [
                    .critDamage: .higher,
                    .hpAmp: .highest,
                    .defAmp: .higher,
                ],
                .neck: [
                    .hpAmp: .higher,
                    .energyRecovery: .highest,
                    .defAmp: .high,
                ],
            ],
            weight: [
                .defDelta: .lower,
                .critDamage: .high,
                .hpDelta: .medium,
                .statResis: .highPlus,
                .defAmp: .high,
                .spdDelta: .highest,
                .critChance: .high,
                .hpAmp: .highest,
            ],
            max: 10.0
        ),
        "1209": .init(
            main: [
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .body: [
                    .critDamage: .highest,
                    .atkAmp: .higher,
                    .critChance: .higherPlus,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.cryo): .highest],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
            ],
            weight: [
                .atkDelta: .lower,
                .critChance: .highest,
                .critDamage: .highest,
                .spdDelta: .highest,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "1210": .init(
            main: [
                .object: [.atkAmp: .higher, .dmgAmp(.pyro): .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
                .body: [
                    .atkAmp: .highest,
                    .critChance: .high,
                    .critDamage: .high,
                ],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
            ],
            weight: [
                .hpDelta: .lowest,
                .hpAmp: .lower,
                .critChance: .higher,
                .spdDelta: .highest,
                .atkAmp: .highest,
                .atkDelta: .low,
                .critDamage: .higher,
            ],
            max: 10.0
        ),
        "1211": .init(
            main: [
                .neck: [.hpAmp: .highest, .energyRecovery: .higher],
                .body: [.healAmp: .highest, .hpAmp: .higher],
                .foot: [.spdDelta: .highest, .hpAmp: .highest],
                .object: [.defAmp: .medium, .hpAmp: .highest],
            ],
            weight: [
                .hpAmp: .highest,
                .hpDelta: .medium,
                .spdDelta: .highest,
                .defAmp: .medium,
                .defDelta: .lowerLower,
                .statResis: .medium,
            ],
            max: 10.0
        ),
        "1212": .init(
            main: [
                .neck: [.atkAmp: .highest, .energyRecovery: .highest],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .highest,
                    .critChance: .higher,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.cryo): .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
            ],
            weight: [
                .critDamage: .highest,
                .defDelta: .lowest,
                .spdDelta: .highest,
                .hpDelta: .lowest,
                .atkAmp: .higher,
                .hpAmp: .lower,
                .critChance: .higher,
                .atkDelta: .lower,
                .defAmp: .lower,
                .statResis: .lowerLower,
            ],
            max: 10.0
        ),
        "1213": .init(
            main: [
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .neck: [
                    .energyRecovery: .highest,
                    .atkAmp: .higher,
                    .breakDmg: .highest,
                ],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                ],
                .object: [.dmgAmp(.fantastico): .highest, .atkAmp: .higher],
            ],
            weight: [
                .critChance: .highest,
                .atkDelta: .lower,
                .spdDelta: .higher,
                .critDamage: .highest,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "1214": .init(
            main: [
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .neck: [
                    .atkAmp: .higher,
                    .breakDmg: .highest,
                    .energyRecovery: .medium,
                ],
                .object: [.dmgAmp(.posesto): .highest, .atkAmp: .highest],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .atkDelta: .lower,
                .spdDelta: .highest,
                .atkAmp: .higher,
                .critDamage: .highest,
                .breakDmg: .highest,
                .critChance: .highest,
            ],
            max: 10.0
        ),
        "1215": .init(
            main: [
                .body: [.hpAmp: .highest, .atkAmp: .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest, .hpAmp: .higher],
                .object: [.atkAmp: .higher, .hpAmp: .highest],
                .neck: [
                    .hpAmp: .higher,
                    .energyRecovery: .highest,
                    .atkAmp: .higher,
                ],
            ],
            weight: [
                .spdDelta: .highest,
                .hpDelta: .lower,
                .defAmp: .higher,
                .statResis: .medium,
                .hpAmp: .higher,
                .defDelta: .lower,
            ],
            max: 10.0
        ),
        "1217": .init(
            main: [
                .object: [.defAmp: .medium, .hpAmp: .highest],
                .neck: [.hpAmp: .higher, .energyRecovery: .highest],
                .body: [.healAmp: .highest, .hpAmp: .higher],
                .foot: [.hpAmp: .higher, .spdDelta: .highest],
            ],
            weight: [
                .statResis: .medium,
                .spdDelta: .highest,
                .hpAmp: .highest,
                .defAmp: .medium,
                .defDelta: .lowerLower,
                .hpDelta: .medium,
            ],
            max: 10.0
        ),
        "1301": .init(
            main: [
                .neck: [
                    .hpAmp: .higher,
                    .energyRecovery: .highest,
                    .breakDmg: .highest,
                ],
                .foot: [.spdDelta: .highest, .hpAmp: .higher],
                .object: [.hpAmp: .highest],
                .body: [.hpAmp: .higher, .healAmp: .highest],
            ],
            weight: [
                .breakDmg: .highest,
                .hpAmp: .highest,
                .defAmp: .medium,
                .defDelta: .lowerLower,
                .statResis: .medium,
                .hpDelta: .medium,
                .spdDelta: .highest,
            ],
            max: 10.0
        ),
        "1302": .init(
            main: [
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .higher],
                .body: [
                    .critDamage: .highest,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .neck: [.energyRecovery: .higher, .atkAmp: .highest],
            ],
            weight: [
                .atkDelta: .lower,
                .spdDelta: .highest,
                .critDamage: .highest,
                .critChance: .highest,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "1303": .init(
            main: [
                .object: [.defAmp: .highest, .hpAmp: .highest],
                .neck: [
                    .hpAmp: .higher,
                    .breakDmg: .highest,
                    .energyRecovery: .highest,
                    .defAmp: .higher,
                ],
                .body: [.defAmp: .highest, .hpAmp: .highest],
                .foot: [.spdDelta: .highest, .hpAmp: .higher, .defAmp: .higher],
            ],
            weight: [
                .defDelta: .lower,
                .defAmp: .higher,
                .hpAmp: .higher,
                .breakDmg: .highest,
                .hpDelta: .lower,
                .spdDelta: .highest,
                .statResis: .medium,
            ],
            max: 10.0
        ),
        "1304": .init(
            main: [
                .object: [.dmgAmp(.fantastico): .highest, .defAmp: .highest],
                .body: [
                    .critDamage: .highest,
                    .defAmp: .highest,
                    .critChance: .higher,
                ],
                .neck: [.defAmp: .highest, .energyRecovery: .highest],
                .foot: [.defAmp: .highest, .spdDelta: .highest],
            ],
            weight: [
                .critDamage: .highest,
                .defAmp: .highest,
                .statResis: .medium,
                .critChance: .highest,
                .spdDelta: .higher,
                .defDelta: .medium,
            ],
            max: 10.0
        ),
        "1305": .init(
            main: [
                .neck: [.atkAmp: .highest, .energyRecovery: .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .highest,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.fantastico): .highest],
            ],
            weight: [
                .spdDelta: .higher,
                .critDamage: .highest,
                .critChance: .highest,
                .atkAmp: .higher,
                .atkDelta: .lower,
            ],
            max: 10.0
        ),
        "1306": .init(
            main: [
                .foot: [.spdDelta: .highest, .hpAmp: .higher],
                .object: [.hpAmp: .highest, .defAmp: .medium],
                .body: [
                    .critDamage: .highest,
                    .hpAmp: .higher,
                    .defAmp: .medium,
                ],
                .neck: [
                    .hpAmp: .higher,
                    .defAmp: .medium,
                    .energyRecovery: .highest,
                ],
            ],
            weight: [
                .hpAmp: .higher,
                .defAmp: .medium,
                .hpDelta: .lower,
                .spdDelta: .highest,
                .critDamage: .highest,
                .defDelta: .lowerLower,
                .statResis: .higher,
            ],
            max: 10.0
        ),
        "1307": .init(
            main: [
                .neck: [.atkAmp: .highest, .energyRecovery: .highest],
                .body: [.atkAmp: .higher, .statProb: .highest],
                .object: [.atkAmp: .higher, .dmgAmp(.anemo): .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
            ],
            weight: [
                .atkDelta: .low,
                .critChance: .low,
                .spdDelta: .highest,
                .atkAmp: .highest,
                .critDamage: .low,
                .statProb: .highest,
            ],
            max: 10.0
        ),
        "1308": .init(
            main: [
                .foot: [.atkAmp: .highest],
                .body: [
                    .critDamage: .highest,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .highest],
                .neck: [.atkAmp: .highest],
            ],
            weight: [
                .critChance: .highest,
                .statProb: .medium,
                .spdDelta: .higher,
                .atkAmp: .higher,
                .atkDelta: .lower,
                .critDamage: .highest,
            ],
            max: 10.0
        ),
        "1309": .init(
            main: [
                .foot: [
                    .atkAmp: .highest,
                ],
                .neck: [
                    .atkAmp: .higher,
                    .energyRecovery: .highest,
                ],
                .object: [
                    .atkAmp: .highest,
                    .dmgAmp(.physico): .highest,
                ],
                .body: [
                    .atkAmp: .highest,
                ],
            ],
            weight: [
                .spdDelta: .highest,
                .statResis: .medium,
                .defDelta: .lower,
                .hpDelta: .lower,
                .defAmp: .higher,
                .hpAmp: .higher,
                .atkAmp: .highest,
                .atkDelta: .medium,
            ],
            max: 10.0
        ),
        "1312": .init(
            main: [
                .body: [
                    .critDamage: .highest,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
                .object: [.dmgAmp(.cryo): .highest, .atkAmp: .higher],
                .neck: [.energyRecovery: .highest, .atkAmp: .highest],
            ],
            weight: [
                .atkDelta: .lower,
                .critDamage: .highest,
                .atkAmp: .higher,
                .statProb: .medium,
                .critChance: .highest,
                .spdDelta: .higher,
            ],
            max: 10.0
        ),
        "8001": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .neck: [
                    .breakDmg: .highest,
                    .energyRecovery: .medium,
                    .atkAmp: .highest,
                ],
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .higher],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
            ],
            weight: [
                .atkDelta: .lower,
                .critDamage: .highest,
                .critChance: .highest,
                .spdDelta: .higher,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "8002": .init(
            main: [
                .body: [
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                ],
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .higher],
                .neck: [
                    .breakDmg: .highest,
                    .energyRecovery: .medium,
                    .atkAmp: .highest,
                ],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
            ],
            weight: [
                .atkDelta: .lower,
                .critChance: .highest,
                .critDamage: .highest,
                .spdDelta: .higher,
                .atkAmp: .higher,
            ],
            max: 10.0
        ),
        "8003": .init(
            main: [
                .foot: [.spdDelta: .higher, .hpAmp: .medium, .defAmp: .highest],
                .body: [
                    .statProb: .highest,
                    .defAmp: .highest,
                    .hpAmp: .medium,
                ],
                .neck: [.hpAmp: .medium, .defAmp: .highest],
                .object: [.hpAmp: .medium, .defAmp: .highest],
            ],
            weight: [
                .statResis: .medium,
                .hpAmp: .medium,
                .spdDelta: .highest,
                .defDelta: .medium,
                .statProb: .highest,
                .defAmp: .highest,
                .hpDelta: .lowerLower,
            ],
            max: 10.0
        ),
        "8004": .init(
            main: [
                .foot: [.defAmp: .highest, .hpAmp: .medium, .spdDelta: .higher],
                .body: [
                    .defAmp: .highest,
                    .hpAmp: .medium,
                    .statProb: .highest,
                ],
                .object: [.defAmp: .highest, .hpAmp: .medium],
                .neck: [.hpAmp: .medium, .defAmp: .highest],
            ],
            weight: [
                .spdDelta: .highest,
                .defDelta: .medium,
                .statResis: .medium,
                .defAmp: .highest,
                .hpDelta: .lowerLower,
                .statProb: .highest,
                .hpAmp: .medium,
            ],
            max: 10.0
        ),
        "8005": .init(
            main: [
                .object: [
                    .defAmp: .highest,
                    .hpAmp: .highest,
                ],
                .body: [
                    .hpAmp: .highest,
                    .defAmp: .highest,
                ],
                .neck: [
                    .hpAmp: .higher,
                    .defAmp: .higher,
                    .breakDmg: .highest,
                ],
                .foot: [
                    .spdDelta: .highest,
                    .defAmp: .higher,
                    .hpAmp: .higher,
                ],
            ],
            weight: [
                .defAmp: .medium,
                .breakDmg: .highest,
                .hpDelta: .lowerLower,
                .hpAmp: .medium,
                .spdDelta: .highest,
                .defDelta: .lowerLower,
            ],
            max: 10.0
        ),
        "8006": .init(
            main: [
                .object: [
                    .defAmp: .highest,
                    .hpAmp: .highest,
                ],
                .neck: [
                    .breakDmg: .highest,
                    .defAmp: .higher,
                    .hpAmp: .higher,
                ],
                .body: [
                    .hpAmp: .highest,
                    .defAmp: .highest,
                ],
                .foot: [
                    .defAmp: .higher,
                    .spdDelta: .highest,
                    .hpAmp: .higher,
                ],
            ],
            weight: [
                .defDelta: .lowerLower,
                .hpDelta: .lowerLower,
                .spdDelta: .highest,
                .breakDmg: .highest,
                .defAmp: .medium,
                .hpAmp: .medium,
            ],
            max: 10.0
        ),
    ]
}
