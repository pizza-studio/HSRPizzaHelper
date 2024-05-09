// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated.DetailInfo.ArtifactItem {}

// swiftlint:disable cyclomatic_complexity
extension EnkaHSR.PropertyType {
    public init?(subAffixID: Int) {
        switch subAffixID {
        case 1: self = .hpDelta
        case 2: self = .attackDelta
        case 3: self = .defenceDelta
        case 4: self = .hpAddedRatio
        case 5: self = .attackAddedRatio
        case 6: self = .defenceAddedRatio
        case 7: self = .speedDelta
        case 8: self = .criticalChanceBase
        case 9: self = .criticalDamageBase
        case 10: self = .statusProbabilityBase
        case 11: self = .statusResistanceBase
        case 12: self = .breakDamageAddedRatioBase
        default: return nil
        }
    }

    public var appraisableArtifactParam: ArtifactRating.Appraiser.Param? {
        switch self {
        case .hpDelta: return .hpDelta
        case .attackDelta: return .atkDelta
        case .defenceDelta: return .defDelta
        case .hpAddedRatio: return .hpAmp
        case .attackAddedRatio: return .atkAmp
        case .defenceAddedRatio: return .defAmp
        case .speedDelta: return .spdDelta
        case .criticalChanceBase: return .critChance
        case .criticalDamageBase: return .critDamage
        case .statusProbabilityBase: return .statProb
        case .statusResistanceBase: return .statResis
        case .breakDamageAddedRatioBase: return .breakDmg
        case .healRatioBase: return .healAmp
        case .energyRecoveryBase: return .energyRecovery
        case .physicoAddedRatio: return .dmgAmp(.physico)
        case .pyroAddedRatio: return .dmgAmp(.pyro)
        case .cryoAddedRatio: return .dmgAmp(.cryo)
        case .electroAddedRatio: return .dmgAmp(.electro)
        case .anemoAddedRatio: return .dmgAmp(.anemo)
        case .posestoAddedRatio: return .dmgAmp(.posesto)
        case .fantasticoAddedRatio: return .dmgAmp(.fantastico)
        default: return nil
        }
    }
}

// swiftlint:enable cyclomatic_complexity
