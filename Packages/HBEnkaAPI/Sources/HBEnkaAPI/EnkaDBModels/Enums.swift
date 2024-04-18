// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    /// Elements used in HSR, using Ancient Greek namings (same as Genshin).
    /// - remark: Typealiased as `EnkaHSR.Element`.`
    public enum Element: String, Codable, Hashable, CaseIterable {
        case physico = "Physical"
        case anemo = "Wind"
        case electro = "Thunder"
        case fantastico = "Imaginary"
        case posesto = "Quantum"
        case pyro = "Fire"
        case cryo = "Ice"
    }

    public enum LifePath: String, Codable, Hashable, CaseIterable {
        case none = "None"
        case destruction = "Warrior"
        case hunt = "Rogue"
        case erudition = "Mage"
        case harmony = "Shaman"
        case nihility = "Warlock"
        case preservation = "Knight"
        case abundance = "Priest"
    }

    public enum PropertyType: String, Codable, Hashable, CaseIterable {
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
        case hpAddedRatio = "HPAddedRatio"
        case hpDelta = "HPDelta"
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

    public var iconFilePath: String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.element.rawValue)/\(iconFileName)"
    }
}

extension EnkaHSR.DBModels.LifePath {
    public var iconFileName: String {
        String(describing: self).capitalized + ".png"
    }

    public var iconFilePath: String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.lifePath.rawValue)/\(iconFileName)"
    }
}

extension EnkaHSR.PropertyType {
    public var titleSuffix: String {
        var result = ""
        if isDelta { result = "+" }
        if isPercentage { result = "%" }
        return result
    }

    public var isDelta: Bool { rawValue.suffix(5) == "Delta" }

    public var isPercentage: Bool {
        rawValue.contains("Chance")
            || rawValue.contains("Probability")
            || rawValue.contains("Ratio")
            || rawValue.contains("Crit")
            || rawValue.contains("StatusResistance")
    }

    public var iconFileName: String? {
        var nameStem = rawValue
        switch self {
        case .attackAddedRatio, .defenceAddedRatio, .speedAddedRatio:
            nameStem = nameStem.replacingOccurrences(of: "AddedRatio", with: "")
        case .hpAddedRatio: nameStem = "MaxHP"
        case .breakDamageAddedRatio: nameStem = "BreakUp"
        case .hpDelta: nameStem = "MaxHP"
        case .defenceDelta: nameStem = "Defence"
        case .attackDelta: nameStem = "Attack"
        case .criticalChanceBase: nameStem = "CriticalChance"
        case .statusProbabilityBase: nameStem = "StatusProbability"
        case .speedDelta: nameStem = "Speed"
        case .spRatioBase: nameStem = "StatusProbability"
        case .criticalDamageBase: nameStem = "CriticalDamage"
        default: break
        }
        return hasPropIcon ? "Icon\(nameStem).png" : nil
    }

    public var iconFilePath: String? {
        guard let iconFileName = iconFileName else { return nil }
        return "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.property.rawValue)/\(iconFileName)"
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

        // Other cases requiring reusing existing icons.
        case .hpDelta: return true
        case .defenceDelta: return true
        case .hpAddedRatio: return true
        case .defenceAddedRatio: return true
        case .attackDelta: return true
        case .attackAddedRatio: return true
        case .criticalChanceBase: return true
        case .breakDamageAddedRatio: return true
        case .statusProbabilityBase: return true
        case .speedDelta: return true
        case .spRatioBase: return true
        case .criticalDamageBase: return true

        default:
            // Just in case that there will be new elements available.
            let condition1 = rawValue.suffix(10) == "AddedRatio" || rawValue.suffix(15) == "ResistanceDelta"
            let condition2 = rawValue.prefix(9) != "AllDamage"
            return condition1 && condition2
        }
    }
}
