// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    /// Elements used in HSR, using Ancient Greek namings (same as Genshin).
    /// - remark: Typealiased as `EnkaHSR.Element`.`
    public enum Element: String, Codable, CaseIterable {
        case physico = "Physical"
        case anemo = "Wind"
        case electro = "Thunder"
        case fantastico = "Imaginary"
        case posesto = "Quantum"
        case pyro = "Fire"
        case cryo = "Ice"
    }

    public enum LifePath: String, Codable, CaseIterable {
        case none = "None"
        case destruction = "Warrior"
        case hunt = "Rogue"
        case erudition = "Mage"
        case harmony = "Shaman"
        case nihility = "Warlock"
        case preservation = "Knight"
        case abundance = "Priest"
    }

    public enum PropertyType: String, Codable, CaseIterable {
        case anemoAddedRatio = "WindAddedRatio"
        case anemoResistance = "WindResistance"
        case anemoResistanceDelta = "WindResistanceDelta"
        case physicoAddedRatio = "PhysicalAddedRatio"
        case physicoResistance = "PhysicalResistance"
        case physicoResistanceDelta = "PhysicalResistanceDelta"
        case electroAddedRatio = "ThunderAddedRatio"
        case electroResistance = "ThunderResistance"
        case electroResistanceDelta = "ThunderResistanceDelta"
        case fantasticoAddedRatio = "ImaginaryAddedRatio"
        case fantasticoResistance = "ImaginaryResistance"
        case fantasticoResistanceDelta = "ImaginaryResistanceDelta"
        case posestoAddedRatio = "QuantumAddedRatio"
        case posestoResistance = "QuantumResistance"
        case posestoResistanceDelta = "QuantumResistanceDelta"
        case pyroAddedRatio = "FireAddedRatio"
        case pyroResistance = "FireResistance"
        case pyroResistanceDelta = "FireResistanceDelta"
        case cryoAddedRatio = "IceAddedRatio"
        case cryoResistance = "IceResistance"
        case cryoResistanceDelta = "IceResistanceDelta"
        case allDamageTypeAddedRatio = "AllDamageTypeAddedRatio"
        case attack = "Attack"
        case attackAddedRatio = "AttackAddedRatio"
        case attackDelta = "AttackDelta"
        case baseAttack = "BaseAttack"
        case baseDefence = "BaseDefence"
        case baseHP = "BaseHP"
        case baseSpeed = "BaseSpeed"
        case breakUp = "BreakUp"
        case breakDamageAddedRatio = "BreakDamageAddedRatio"
        case breakDamageAddedRatioBase = "BreakDamageAddedRatioBase"
        case criticalChance = "CriticalChance"
        case criticalChanceBase = "CriticalChanceBase"
        case criticalDamage = "CriticalDamage"
        case criticalDamageBase = "CriticalDamageBase"
        case defence = "Defence"
        case defenceAddedRatio = "DefenceAddedRatio"
        case defenceDelta = "DefenceDelta"
        case energyLimit = "EnergyLimit"
        case energyRecovery = "EnergyRecovery"
        case healRatio = "HealRatio"
        case healRatioBase = "HealRatioBase"
        case healTakenRatio = "HealTakenRatio"
        case hPAddedRatio = "HPAddedRatio"
        case hPDelta = "HPDelta"
        case maxHP = "MaxHP"
        case maxSP = "MaxSP"
        case speed = "Speed"
        case speedAddedRatio = "SpeedAddedRatio"
        case speedDelta = "SpeedDelta"
        case spRatio = "SPRatio"
        case spRatioBase = "SPRatioBase"
        case statusProbability = "StatusProbability"
        case statusProbabilityBase = "StatusProbabilityBase"
        case statusResistance = "StatusResistance"
        case statusResistanceBase = "StatusResistanceBase"
    }
}

// MARK: - Implementations (Static)

extension EnkaHSR.DBModels.Element {
    public var iconFileName: String {
        var result = "\(rawValue).png"
        switch self {
        case .electro: result = "Lightning.png"
        default: break
        }
        return result
    }

    public var iconFileSubPath: String? {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.element)/\(iconFileName)"
    }
}

extension EnkaHSR.DBModels.LifePath {
    public var iconFileName: String {
        String(describing: self).capitalized + ".png"
    }
}

extension EnkaHSR.PropertyType {
    public var iconFileName: String? {
        hasPropIcon ? "Icon\(rawValue).png" : nil
    }

    public var hasPropIcon: Bool {
        switch self {
        case .allDamageTypeAddedRatio: return false // An exceptional case.
        case .attack: return true
        case .breakUp: return true
        case .criticalChance: return true
        case .criticalDamage: return true
        case .defence: return true
        case .energyLimit: return true
        case .energyRecovery: return true
        case .healRatio: return true
        case .maxHP: return true
        case .speed: return true
        case .statusProbability: return true
        case .statusResistance: return true
        case .pyroAddedRatio: return true
        case .pyroResistanceDelta: return true
        case .cryoAddedRatio: return true
        case .cryoResistanceDelta: return true
        case .fantasticoAddedRatio: return true
        case .fantasticoResistanceDelta: return true
        case .physicoAddedRatio: return true
        case .physicoResistanceDelta: return true
        case .posestoAddedRatio: return true
        case .posestoResistanceDelta: return true
        case .electroAddedRatio: return true
        case .electroResistanceDelta: return true
        case .anemoAddedRatio: return true
        case .anemoResistanceDelta: return true
        default:
            // Just in case that there will be new elements available.
            let condition1 = rawValue.suffix(10) == "AddedRatio" || rawValue.suffix(15) == "ResistanceDelta"
            let condition2 = rawValue.prefix(9) != "AllDamage"
            return condition1 && condition2
        }
    }
}
