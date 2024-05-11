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
                .body: [
                    .defAmp: .highest,
                    .hpAmp: .medium,
                    .statProb: .highest,
                ],
                .foot: [.defAmp: .highest, .spdDelta: .higher, .hpAmp: .medium],
                .object: [.hpAmp: .medium, .defAmp: .highest],
                .neck: [
                    .defAmp: .highest,
                    .energyRecovery: .highest,
                    .hpAmp: .medium,
                ],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .hpAmp: .medium,
                .hpDelta: .lowerLower,
                .defDelta: .medium,
                .statProb: .medium,
                .defAmp: .highest,
                .spdDelta: .highest,
                .statResis: .medium,
            ],
            max: 9.3
        ),
        "1002": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
                .neck: [.atkAmp: .highest, .energyRecovery: .medium],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .object: [.atkAmp: .higher, .dmgAmp(.anemo): .highest],
            ],
            weight: [
                .atkDelta: .lower,
                .critChance: .highest,
                .spdDelta: .highest,
                .atkAmp: .higher,
                .critDamage: .highest,
            ],
            max: 10.18
        ),
        "1003": .init(
            main: [
                .body: [
                    .critChance: .highest,
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                ],
                .neck: [
                    .breakDmg: .highest,
                    .energyRecovery: .highest,
                    .atkAmp: .higher,
                ],
                .object: [.dmgAmp(.pyro): .highest, .atkAmp: .higher],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
            ],
            weight: [
                .spdDelta: .higher,
                .atkDelta: .lower,
                .critChance: .highest,
                .atkAmp: .higher,
                .critDamage: .highest,
                .breakDmg: .medium,
            ],
            max: 10.16
        ),
        "1004": .init(
            main: [
                .object: [.atkAmp: .higher, .dmgAmp(.fantastico): .highest],
                .foot: [.atkAmp: .highest, .spdDelta: .highest],
                .body: [
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .statProb: .highest,
                    .atkAmp: .higher,
                ],
                .neck: [
                    .atkAmp: .higher,
                    .energyRecovery: .highest,
                    .breakDmg: .highest,
                ],
            ],
            weight: [
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critDamage: .highest,
                .spdDelta: .highest,
                .critChance: .highest,
                .statProb: .highest,
            ],
            max: 10.76
        ),
        "1005": .init(
            main: [
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .neck: [
                    .energyRecovery: .medium,
                    .atkAmp: .higher,
                    .breakDmg: .highest,
                ],
                .body: [
                    .critDamage: .higher,
                    .atkAmp: .highest,
                    .statProb: .highest,
                    .critChance: .higher,
                ],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .higher],
            ],
            weight: [
                .atkDelta: .lower,
                .critDamage: .highest,
                .atkAmp: .higher,
                .critChance: .highest,
                .statProb: .highest,
                .spdDelta: .highest,
            ],
            max: 10.76
        ),
        "1006": .init(
            main: [
                .object: [.dmgAmp(.posesto): .highest, .atkAmp: .higher],
                .neck: [.energyRecovery: .highest, .atkAmp: .medium],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .body: [
                    .statProb: .highest,
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
            ],
            weight: [
                .statProb: .highest,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .spdDelta: .highest,
                .critDamage: .highest,
                .critChance: .highest,
            ],
            max: 10.72
        ),
        "1008": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .higher],
                .neck: [
                    .energyRecovery: .medium,
                    .atkAmp: .highest,
                    .breakDmg: .highest,
                ],
            ],
            weight: [
                .atkDelta: .lower,
                .spdDelta: .higher,
                .critChance: .highest,
                .atkAmp: .higher,
                .critDamage: .highest,
            ],
            max: 10.08
        ),
        "1009": .init(
            main: [
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .neck: [
                    .energyRecovery: .highest,
                    .breakDmg: .highest,
                    .atkAmp: .higher,
                ],
                .object: [.dmgAmp(.pyro): .highest, .atkAmp: .higher],
            ],
            weight: [
                .spdDelta: .highest,
                .atkAmp: .higher,
                .atkDelta: .lower,
                .breakDmg: .higher,
            ],
            max: 9.16
        ),
        "1013": .init(
            main: [
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.cryo): .highest],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
            ],
            weight: [
                .spdDelta: .higher,
                .critChance: .highest,
                .atkAmp: .higher,
                .critDamage: .highest,
                .atkDelta: .lower,
            ],
            max: 10.08
        ),
        "1101": .init(
            main: [
                .body: [
                    .hpAmp: .medium,
                    .atkAmp: .medium,
                    .critDamage: .highest,
                ],
                .foot: [
                    .spdDelta: .highest,
                    .atkAmp: .medium,
                    .defAmp: .higher,
                    .hpAmp: .higher,
                ],
                .neck: [.atkAmp: .medium, .energyRecovery: .highest],
                .object: [
                    .hpAmp: .highest,
                    .dmgAmp(.anemo): .medium,
                    .defAmp: .highest,
                    .atkAmp: .medium,
                ],
            ],
            weight: [
                .defDelta: .lower,
                .defAmp: .higher,
                .critDamage: .highest,
                .spdDelta: .highest,
                .hpDelta: .lower,
                .atkAmp: .medium,
                .hpAmp: .higher,
                .atkDelta: .lowerLower,
                .statResis: .medium,
            ],
            max: 10.06
        ),
        "1102": .init(
            main: [
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .object: [.dmgAmp(.posesto): .highest, .atkAmp: .higher],
                .neck: [.atkAmp: .highest, .energyRecovery: .medium],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .atkAmp: .higher,
                .atkDelta: .lower,
                .critChance: .highest,
                .spdDelta: .highest,
                .critDamage: .highest,
            ],
            max: 10.18
        ),
        "1103": .init(
            main: [
                .neck: [
                    .breakDmg: .highest,
                    .energyRecovery: .medium,
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
                .atkDelta: .lower,
                .critChance: .highest,
                .atkAmp: .higher,
                .spdDelta: .higher,
            ],
            max: 10.08
        ),
        "1104": .init(
            main: [
                .body: [.defAmp: .highest, .hpAmp: .medium, .statProb: .medium],
                .neck: [
                    .defAmp: .highest,
                    .hpAmp: .medium,
                    .energyRecovery: .highest,
                ],
                .foot: [.spdDelta: .higher, .defAmp: .highest, .hpAmp: .medium],
                .object: [.hpAmp: .medium, .defAmp: .highest],
            ],
            weight: [
                .spdDelta: .highest,
                .statResis: .medium,
                .hpDelta: .lowerLower,
                .hpAmp: .medium,
                .defAmp: .highest,
                .defDelta: .medium,
                .statProb: .medium,
            ],
            max: 9.3
        ),
        "1105": .init(
            main: [
                .foot: [.hpAmp: .highest, .spdDelta: .highest],
                .object: [.defAmp: .medium, .hpAmp: .highest],
                .neck: [.hpAmp: .highest, .energyRecovery: .medium],
                .body: [.healAmp: .highest, .hpAmp: .higher],
            ],
            weight: [
                .hpDelta: .medium,
                .spdDelta: .higher,
                .hpAmp: .highest,
                .defDelta: .lowerLower,
                .defAmp: .medium,
                .statResis: .medium,
            ],
            max: 8.46
        ),
        "1106": .init(
            main: [
                .object: [.atkAmp: .higher, .dmgAmp(.cryo): .highest],
                .neck: [.atkAmp: .highest, .energyRecovery: .medium],
                .body: [
                    .atkAmp: .higher,
                    .statProb: .highest,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                ],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
            ],
            weight: [
                .critChance: .highest,
                .critDamage: .highest,
                .statProb: .highest,
                .atkDelta: .lower,
                .spdDelta: .highest,
                .atkAmp: .higher,
            ],
            max: 10.72
        ),
        "1107": .init(
            main: [
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .higher],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
                .neck: [
                    .energyRecovery: .medium,
                    .atkAmp: .highest,
                    .breakDmg: .highest,
                ],
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                ],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .atkAmp: .higher,
                .critChance: .highest,
                .critDamage: .highest,
                .atkDelta: .lower,
                .spdDelta: .higher,
            ],
            max: 10.08
        ),
        "1108": .init(
            main: [
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .body: [
                    .critDamage: .higher,
                    .statProb: .highest,
                    .atkAmp: .highest,
                    .critChance: .higher,
                ],
                .object: [.dmgAmp(.anemo): .highest, .atkAmp: .higher],
                .neck: [.atkAmp: .higher, .energyRecovery: .highest],
            ],
            weight: [
                .statProb: .highest,
                .critChance: .highest,
                .spdDelta: .highest,
                .critDamage: .highest,
                .atkAmp: .higher,
                .atkDelta: .lower,
            ],
            max: 10.76
        ),
        "1109": .init(
            main: [
                .neck: [
                    .atkAmp: .highest,
                    .energyRecovery: .medium,
                    .breakDmg: .medium,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.pyro): .highest],
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .critChance: .highest,
                .spdDelta: .higher,
                .atkAmp: .higher,
                .atkDelta: .lower,
                .critDamage: .highest,
            ],
            max: 9.98
        ),
        "1110": .init(
            main: [
                .neck: [.hpAmp: .highest, .energyRecovery: .highest],
                .object: [.hpAmp: .highest],
                .foot: [.hpAmp: .higher, .spdDelta: .highest],
                .body: [.hpAmp: .higher, .healAmp: .highest],
            ],
            weight: [
                .defDelta: .lowerLower,
                .spdDelta: .highest,
                .statResis: .highPlus,
                .defAmp: .medium,
                .hpDelta: .medium,
                .hpAmp: .highest,
            ],
            max: 9.64
        ),
        "1111": .init(
            main: [
                .object: [.atkAmp: .higher, .dmgAmp(.physico): .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .body: [
                    .critChance: .higher,
                    .critDamage: .higher,
                    .atkAmp: .highest,
                    .statProb: .highest,
                ],
                .neck: [
                    .atkAmp: .highest,
                    .energyRecovery: .highest,
                    .breakDmg: .highest,
                ],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critChance: .highest,
                .spdDelta: .highest,
                .critDamage: .highest,
                .statProb: .highest,
            ],
            max: 10.76
        ),
        "1112": .init(
            main: [
                .neck: [.energyRecovery: .highest, .atkAmp: .highest],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
                .object: [.dmgAmp(.pyro): .highest, .atkAmp: .higher],
                .body: [
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .hpDelta: .lowest,
                .hpAmp: .lower,
                .spdDelta: .highest,
                .critChance: .highest,
                .atkDelta: .lower,
                .critDamage: .highest,
                .atkAmp: .higher,
            ],
            max: 10.32
        ),
        "1201": .init(
            main: [
                .object: [.dmgAmp(.posesto): .highest, .atkAmp: .higher],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
                .body: [
                    .critChance: .highest,
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                ],
            ],
            weight: [
                .spdDelta: .higher,
                .critChance: .highest,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critDamage: .highest,
            ],
            max: 10.08
        ),
        "1202": .init(
            main: [
                .object: [.atkAmp: .higher, .dmgAmp(.electro): .highest],
                .body: [
                    .critDamage: .medium,
                    .critChance: .medium,
                    .hpAmp: .medium,
                    .atkAmp: .highest,
                ],
                .neck: [.energyRecovery: .highest, .atkAmp: .highest],
                .foot: [.atkAmp: .highest, .spdDelta: .highest],
            ],
            weight: [
                .hpAmp: .medium,
                .hpDelta: .lowerLower,
                .atkDelta: .medium,
                .atkAmp: .highest,
                .spdDelta: .highest,
            ],
            max: 9.28
        ),
        "1203": .init(
            main: [
                .body: [.healAmp: .highest, .hpAmp: .higher],
                .object: [.defAmp: .medium, .hpAmp: .highest],
                .foot: [.spdDelta: .highest, .hpAmp: .highest],
                .neck: [.hpAmp: .highest, .energyRecovery: .medium],
            ],
            weight: [
                .hpAmp: .highest,
                .statResis: .medium,
                .defDelta: .lowerLower,
                .defAmp: .medium,
                .hpDelta: .medium,
                .spdDelta: .higher,
            ],
            max: 8.46
        ),
        "1204": .init(
            main: [
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .higher],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .critChance: .highest,
                .atkAmp: .higher,
                .atkDelta: .lower,
                .critDamage: .highest,
                .spdDelta: .highest,
            ],
            max: 10.32
        ),
        "1205": .init(
            main: [
                .body: [
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .hpAmp: .higher,
                    .atkAmp: .higher,
                ],
                .foot: [.hpAmp: .higher, .atkAmp: .higher, .spdDelta: .highest],
                .neck: [
                    .hpAmp: .highest,
                    .atkAmp: .higher,
                    .energyRecovery: .medium,
                ],
                .object: [
                    .atkAmp: .higher,
                    .hpAmp: .higher,
                    .dmgAmp(.anemo): .highest,
                ],
            ],
            weight: [
                .hpAmp: .higher,
                .spdDelta: .higher,
                .atkDelta: .lower,
                .critChance: .highest,
                .atkAmp: .higher,
                .hpDelta: .lower,
                .critDamage: .highest,
            ],
            max: 10.28
        ),
        "1206": .init(
            main: [
                .neck: [
                    .energyRecovery: .medium,
                    .atkAmp: .higher,
                    .breakDmg: .highest,
                ],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .object: [.atkAmp: .higher, .dmgAmp(.physico): .highest],
                .body: [
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                    .critChance: .highest,
                ],
            ],
            weight: [
                .critDamage: .highest,
                .critChance: .highest,
                .atkDelta: .lower,
                .spdDelta: .highest,
                .breakDmg: .medium,
                .atkAmp: .higher,
            ],
            max: 10.36
        ),
        "1207": .init(
            main: [
                .body: [
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .atkAmp: .highest,
                    .statProb: .higher,
                ],
                .object: [.dmgAmp(.fantastico): .highest, .atkAmp: .higher],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
                .neck: [.atkAmp: .higher, .energyRecovery: .highest],
            ],
            weight: [
                .spdDelta: .highest,
                .atkDelta: .lower,
                .atkAmp: .higher,
            ],
            max: 8.2
        ),
        "1208": .init(
            main: [
                .foot: [.hpAmp: .higher, .spdDelta: .highest],
                .body: [
                    .hpAmp: .highest,
                    .defAmp: .higher,
                    .critDamage: .higher,
                ],
                .neck: [
                    .defAmp: .high,
                    .hpAmp: .higher,
                    .energyRecovery: .highest,
                ],
                .object: [
                    .dmgAmp(.posesto): .highest,
                    .hpAmp: .highest,
                    .defAmp: .higher,
                ],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .hpDelta: .medium,
                .critDamage: .high,
                .critChance: .high,
                .defAmp: .high,
                .statResis: .highPlus,
                .defDelta: .lower,
                .hpAmp: .highest,
                .spdDelta: .highest,
            ],
            max: 9.72
        ),
        "1209": .init(
            main: [
                .object: [.dmgAmp(.cryo): .highest, .atkAmp: .higher],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .highest,
                    .critChance: .higherPlus,
                ],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .spdDelta: .highest,
                .atkDelta: .lower,
                .critChance: .highest,
                .critDamage: .highest,
                .atkAmp: .higher,
            ],
            max: 10.28
        ),
        "1210": .init(
            main: [
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
                .neck: [.energyRecovery: .highest, .atkAmp: .higher],
                .body: [
                    .critChance: .high,
                    .atkAmp: .highest,
                    .critDamage: .high,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.pyro): .highest],
            ],
            weight: [
                .hpAmp: .lower,
                .spdDelta: .highest,
                .atkAmp: .highest,
                .atkDelta: .low,
                .critChance: .higher,
                .critDamage: .higher,
                .hpDelta: .lowest,
            ],
            max: 10.08
        ),
        "1211": .init(
            main: [
                .neck: [.hpAmp: .highest, .energyRecovery: .higher],
                .foot: [.spdDelta: .highest, .hpAmp: .highest],
                .object: [.hpAmp: .highest, .defAmp: .medium],
                .body: [.hpAmp: .higher, .healAmp: .highest],
            ],
            weight: [
                .hpAmp: .highest,
                .defDelta: .lowerLower,
                .hpDelta: .medium,
                .statResis: .medium,
                .spdDelta: .highest,
                .defAmp: .medium,
            ],
            max: 9.3
        ),
        "1212": .init(
            main: [
                .body: [
                    .critDamage: .highest,
                    .atkAmp: .higher,
                    .critChance: .higher,
                ],
                .neck: [.atkAmp: .highest, .energyRecovery: .highest],
                .object: [.atkAmp: .higher, .dmgAmp(.cryo): .highest],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
            ],
            weight: [
                .statResis: .lowerLower,
                .critChance: .higher,
                .critDamage: .highest,
                .defAmp: .lower,
                .defDelta: .lowest,
                .spdDelta: .highest,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .hpAmp: .lower,
                .hpDelta: .lowest,
            ],
            max: 10.04
        ),
        "1213": .init(
            main: [
                .body: [
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                    .atkAmp: .higher,
                ],
                .foot: [.atkAmp: .higher, .spdDelta: .highest],
                .neck: [
                    .energyRecovery: .highest,
                    .breakDmg: .highest,
                    .atkAmp: .higher,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.fantastico): .highest],
            ],
            weight: [
                .spdDelta: .higher,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critChance: .highest,
                .critDamage: .highest,
            ],
            max: 10.08
        ),
        "1214": .init(
            main: [
                .body: [
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                    .atkAmp: .higher,
                ],
                .object: [.dmgAmp(.posesto): .highest, .atkAmp: .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .neck: [
                    .energyRecovery: .medium,
                    .breakDmg: .highest,
                    .atkAmp: .higher,
                ],
            ],
            weight: [
                .critDamage: .highest,
                .spdDelta: .highest,
                .atkDelta: .lower,
                .critChance: .highest,
                .breakDmg: .highest,
                .atkAmp: .higher,
            ],
            max: 10.68
        ),
        "1215": .init(
            main: [
                .foot: [.hpAmp: .higher, .spdDelta: .highest, .atkAmp: .higher],
                .neck: [
                    .energyRecovery: .highest,
                    .hpAmp: .higher,
                    .atkAmp: .higher,
                ],
                .body: [.atkAmp: .highest, .hpAmp: .highest],
                .object: [.hpAmp: .highest, .atkAmp: .higher],
            ],
            weight: [
                .statResis: .medium,
                .defDelta: .lower,
                .spdDelta: .highest,
                .hpAmp: .higher,
                .defAmp: .higher,
                .hpDelta: .lower,
            ],
            max: 9.18
        ),
        "1217": .init(
            main: [
                .body: [.hpAmp: .higher, .healAmp: .highest],
                .object: [.hpAmp: .highest, .defAmp: .medium],
                .neck: [.energyRecovery: .highest, .hpAmp: .higher],
                .foot: [.hpAmp: .higher, .spdDelta: .highest],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .hpAmp: .highest,
                .defAmp: .medium,
                .statResis: .medium,
                .spdDelta: .highest,
                .hpDelta: .medium,
                .defDelta: .lowerLower,
            ],
            max: 9.4
        ),
        "1301": .init(
            main: [
                .object: [.hpAmp: .highest],
                .foot: [.hpAmp: .higher, .spdDelta: .highest],
                .body: [.hpAmp: .higher, .healAmp: .highest],
                .neck: [
                    .breakDmg: .highest,
                    .energyRecovery: .highest,
                    .hpAmp: .higher,
                ],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .defAmp: .medium,
                .defDelta: .lowerLower,
                .hpDelta: .medium,
                .spdDelta: .highest,
                .statResis: .medium,
                .hpAmp: .highest,
                .breakDmg: .highest,
            ],
            max: 9.9
        ),
        "1302": .init(
            main: [
                .foot: [.spdDelta: .highest, .atkAmp: .higher],
                .object: [.atkAmp: .higher, .dmgAmp(.physico): .highest],
                .body: [
                    .critChance: .highest,
                    .critDamage: .highest,
                    .atkAmp: .higher,
                ],
                .neck: [.energyRecovery: .higher, .atkAmp: .highest],
            ],
            weight: [
                .spdDelta: .highest,
                .critDamage: .highest,
                .atkDelta: .lower,
                .atkAmp: .higher,
                .critChance: .highest,
            ],
            max: 10.18
        ),
        "1303": .init(
            main: [
                .neck: [
                    .breakDmg: .highest,
                    .energyRecovery: .highest,
                    .hpAmp: .higher,
                    .defAmp: .higher,
                ],
                .body: [.hpAmp: .highest, .defAmp: .highest],
                .object: [.hpAmp: .highest, .defAmp: .highest],
                .foot: [.hpAmp: .higher, .spdDelta: .highest, .defAmp: .higher],
            ],
            weight: [
                .defDelta: .lower,
                .hpDelta: .lower,
                .spdDelta: .highest,
                .statResis: .medium,
                .defAmp: .higher,
                .hpAmp: .higher,
                .breakDmg: .highest,
            ],
            max: 10.0
        ),
        "1304": .init(
            main: [
                .body: [
                    .critDamage: .highest,
                    .defAmp: .highest,
                    .critChance: .higher,
                ],
                .object: [.dmgAmp(.fantastico): .highest, .defAmp: .highest],
                .neck: [.energyRecovery: .highest, .defAmp: .highest],
                .foot: [.spdDelta: .highest, .defAmp: .highest],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .statResis: .medium,
                .defAmp: .highest,
                .critDamage: .highest,
                .critChance: .highest,
                .spdDelta: .higher,
                .defDelta: .medium,
            ],
            max: 10.26
        ),
        "1305": .init(
            main: [
                .neck: [.energyRecovery: .highest, .atkAmp: .highest],
                .object: [.dmgAmp(.fantastico): .highest, .atkAmp: .higher],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .highest,
                    .critChance: .highest,
                ],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
            ],
            weight: [
                .critChance: .highest,
                .atkDelta: .lower,
                .spdDelta: .higher,
                .atkAmp: .higher,
                .critDamage: .highest,
            ],
            max: 10.08
        ),
        "1306": .init(
            main: [
                .object: [.hpAmp: .highest, .defAmp: .medium],
                .foot: [.spdDelta: .highest, .hpAmp: .higher],
                .body: [
                    .defAmp: .medium,
                    .hpAmp: .higher,
                    .critDamage: .highest,
                ],
                .neck: [
                    .defAmp: .medium,
                    .energyRecovery: .highest,
                    .hpAmp: .higher,
                ],
            ],
            weight: [
                .hpAmp: .higher,
                .defAmp: .medium,
                .hpDelta: .lower,
                .spdDelta: .highest,
                .statResis: .higher,
                .defDelta: .lowerLower,
                .critDamage: .highest,
            ],
            max: 10.06
        ),
        "1307": .init(
            main: [
                .object: [.dmgAmp(.anemo): .highest, .atkAmp: .higher],
                .body: [.atkAmp: .higher, .statProb: .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
                .neck: [.atkAmp: .highest, .energyRecovery: .highest],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .critDamage: .low,
                .spdDelta: .highest,
                .atkDelta: .low,
                .atkAmp: .highest,
                .critChance: .low,
                .statProb: .highest,
            ],
            max: 9.84
        ),
        "1308": .init(
            main: [
                .foot: [.atkAmp: .highest],
                .object: [.dmgAmp(.electro): .highest, .atkAmp: .highest],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .highest,
                    .critChance: .highest,
                ],
                .neck: [.atkAmp: .highest],
            ],
            weight: [
                .statProb: .medium,
                .atkAmp: .higher,
                .critDamage: .highest,
                .spdDelta: .higher,
                .critChance: .highest,
                .atkDelta: .lower,
            ],
            max: 10.04
        ),
        "1309": .init(
            main: [
                .body: [.atkAmp: .highest],
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .highest],
                .foot: [.atkAmp: .highest],
                .neck: [.atkAmp: .higher, .energyRecovery: .highest],
            ],
            weight: [
                .defDelta: .lower,
                .atkAmp: .highest,
                .statResis: .medium,
                .hpAmp: .higher,
                .spdDelta: .highest,
                .hpDelta: .lower,
                .defAmp: .higher,
                .atkDelta: .medium,
            ],
            max: 10.02
        ),
        "1312": .init(
            main: [
                .neck: [.atkAmp: .highest, .energyRecovery: .highest],
                .foot: [.spdDelta: .highest, .atkAmp: .highest],
                .object: [.dmgAmp(.cryo): .highest, .atkAmp: .higher],
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .highest,
                ],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .atkDelta: .lower,
                .spdDelta: .higher,
                .statProb: .medium,
                .critChance: .highest,
                .atkAmp: .higher,
                .critDamage: .highest,
            ],
            max: 10.16
        ),
        "1315": .init(
            main: [
                .body: [.critChance: .highest],
                .foot: [.spdDelta: .highest],
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .higher],
                .neck: [.breakDmg: .highest],
            ],
            weight: [:],
            max: 0.0
        ),
        "8001": .init(
            main: [
                .neck: [
                    .atkAmp: .highest,
                    .breakDmg: .highest,
                    .energyRecovery: .medium,
                ],
                .object: [.atkAmp: .higher, .dmgAmp(.physico): .highest],
                .foot: [.atkAmp: .highest, .spdDelta: .higher],
                .body: [
                    .atkAmp: .higher,
                    .critDamage: .higherPlus,
                    .critChance: .highest,
                ],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .spdDelta: .higher,
                .atkAmp: .higher,
                .atkDelta: .lower,
                .critChance: .highest,
                .critDamage: .highest,
            ],
            max: 10.08
        ),
        "8002": .init(
            main: [
                .object: [.dmgAmp(.physico): .highest, .atkAmp: .higher],
                .body: [
                    .atkAmp: .higher,
                    .critChance: .highest,
                    .critDamage: .higherPlus,
                ],
                .foot: [.spdDelta: .higher, .atkAmp: .highest],
                .neck: [
                    .atkAmp: .highest,
                    .energyRecovery: .medium,
                    .breakDmg: .highest,
                ],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .critDamage: .highest,
                .critChance: .highest,
                .spdDelta: .higher,
                .atkDelta: .lower,
                .atkAmp: .higher,
            ],
            max: 10.08
        ),
        "8003": .init(
            main: [
                .neck: [.defAmp: .highest, .hpAmp: .medium],
                .body: [
                    .statProb: .highest,
                    .hpAmp: .medium,
                    .defAmp: .highest,
                ],
                .object: [.defAmp: .highest, .hpAmp: .medium],
                .foot: [.spdDelta: .higher, .hpAmp: .medium, .defAmp: .highest],
                .head: [.hpDelta: .highest],
            ],
            weight: [
                .defAmp: .highest,
                .statProb: .highest,
                .statResis: .medium,
                .spdDelta: .highest,
                .defDelta: .medium,
                .hpAmp: .medium,
                .hpDelta: .lowerLower,
            ],
            max: 9.8
        ),
        "8004": .init(
            main: [
                .body: [
                    .defAmp: .highest,
                    .hpAmp: .medium,
                    .statProb: .highest,
                ],
                .neck: [.defAmp: .highest, .hpAmp: .medium],
                .object: [.hpAmp: .medium, .defAmp: .highest],
                .foot: [.spdDelta: .higher, .defAmp: .highest, .hpAmp: .medium],
            ],
            weight: [
                .defDelta: .medium,
                .defAmp: .highest,
                .spdDelta: .highest,
                .statProb: .highest,
                .hpDelta: .lowerLower,
                .statResis: .medium,
                .hpAmp: .medium,
            ],
            max: 9.8
        ),
        "8005": .init(
            main: [
                .foot: [.defAmp: .higher, .hpAmp: .higher, .spdDelta: .highest],
                .body: [.hpAmp: .highest, .defAmp: .highest],
                .object: [.hpAmp: .highest, .defAmp: .highest],
                .neck: [.breakDmg: .highest, .hpAmp: .higher, .defAmp: .higher],
            ],
            weight: [
                .defAmp: .medium,
                .hpDelta: .lowerLower,
                .breakDmg: .highest,
                .hpAmp: .medium,
                .spdDelta: .highest,
                .defDelta: .lowerLower,
            ],
            max: 9.16
        ),
        "8006": .init(
            main: [
                .neck: [.breakDmg: .highest, .hpAmp: .higher, .defAmp: .higher],
                .foot: [.hpAmp: .higher, .spdDelta: .highest, .defAmp: .higher],
                .body: [.hpAmp: .highest, .defAmp: .highest],
                .object: [.defAmp: .highest, .hpAmp: .highest],
                .hand: [.atkDelta: .highest],
            ],
            weight: [
                .defDelta: .lowerLower,
                .spdDelta: .highest,
                .hpDelta: .lowerLower,
                .defAmp: .medium,
                .breakDmg: .highest,
                .hpAmp: .medium,
            ],
            max: 9.16
        ),
    ]
}
