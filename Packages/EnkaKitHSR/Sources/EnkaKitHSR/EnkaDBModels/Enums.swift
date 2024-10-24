// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

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

    public enum PropertyType: String, Codable, Hashable, CaseIterable, RawRepresentable {
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
        case energyRecovery = "SPRatio"
        case energyRecoveryBase = "SPRatioBase"
        case healRatio = "HealRatio"
        case healRatioBase = "HealRatioBase"
        case healTakenRatio = "HealTakenRatio"
        case hpAddedRatio = "HPAddedRatio"
        case hpDelta = "HPDelta"
        case maxHP = "MaxHP"
        case energyLimit = "MaxSP"
        case speed = "Speed"
        case speedAddedRatio = "SpeedAddedRatio"
        case speedDelta = "SpeedDelta"
        case statusProbability = "StatusProbability"
        case statusProbabilityBase = "StatusProbabilityBase"
        case statusResistance = "StatusResistance"
        case statusResistanceBase = "StatusResistanceBase"
    }
}

// MARK: - Implementations (Static)

extension EnkaHSR.DBModels.Element {
    public var iconFileName: String {
        "\(rawValue).heic"
    }

    public var iconFilePath: String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.element.rawValue)/\(iconFileName)"
    }

    public var iconAssetName: String {
        "element_\(iconFileName.replacingOccurrences(of: ".heic", with: ""))"
    }

    public var damageAddedRatioProperty: EnkaHSR.PropertyType {
        switch self {
        case .physico: return .physicoAddedRatio
        case .anemo: return .anemoAddedRatio
        case .electro: return .electroAddedRatio
        case .fantastico: return .fantasticoAddedRatio
        case .posesto: return .posestoAddedRatio
        case .pyro: return .pyroAddedRatio
        case .cryo: return .cryoAddedRatio
        }
    }

    public static let elementConversionDict: [String: String] = [
        "Physical": "Physico",
        "Wind": "Anemo",
        "Lightning": "Electro",
        "Imaginary": "Fantastico",
        "Quantum": "Posesto",
        "Fire": "Pyro",
        "Ice": "Cryo",
    ]
}

extension EnkaHSR.DBModels.LifePath {
    public var iconFileName: String {
        String(describing: self).capitalized + ".heic"
    }

    public var iconFilePath: String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.lifePath.rawValue)/\(iconFileName)"
    }

    public var iconAssetName: String {
        "path_\(String(describing: self).capitalized)"
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
            || rawValue.contains("Rate")
            || rawValue.contains("Resistance")
            || rawValue.contains("BreakUp")
            || rawValue.contains("Damage")
    }

    public var iconFileName: String? {
        hasPropIcon ? proposedIconFileName : nil
    }

    public var iconAssetName: String? {
        hasPropIcon ? "property_\(proposedIconFileNameStem)" : nil
    }

    internal var proposedIconFileName: String {
        "\(proposedIconFileNameStem).heic"
    }

    internal var proposedIconFileNameStem: String {
        var nameStem = rawValue
        switch self {
        case .baseHP, .hpAddedRatio, .hpDelta: nameStem = "MaxHP"
        case .baseDefence, .defenceAddedRatio, .defenceDelta: nameStem = "Defence"
        case .attackAddedRatio, .attackDelta, .baseAttack: nameStem = "Attack"
        case .breakDamageAddedRatio, .breakDamageAddedRatioBase: nameStem = "BreakUp"
        case .criticalChanceBase: nameStem = "CriticalChance"
        case .healRatioBase: nameStem = "HealRatio"
        case .statusProbabilityBase: nameStem = "StatusProbability"
        case .speedAddedRatio, .speedDelta: nameStem = "Speed"
        case .energyRecovery: nameStem = "EnergyRecovery"
        case .energyRecoveryBase: nameStem = "EnergyRecovery"
        case .criticalDamageBase: nameStem = "CriticalDamage"
        case .statusResistanceBase: nameStem = "StatusResistance"
        case .energyLimit: nameStem = "EnergyLimit"
        case .allDamageTypeAddedRatio: nameStem = "AllDamageTypeAddedRatio"
        default: break
        }
        return "Icon\(nameStem)"
    }

    /// This variable is only for unit tests.
    internal var proposedIconAssetName: String {
        "property_\(proposedIconFileNameStem)"
    }

    /// This variable is only for unit tests.
    internal var proposedIconFilePath: String {
        let rawPathComponent = EnkaHSR.AssetPathComponents.property.rawValue
        return "\(EnkaHSR.assetPathRoot)/\(rawPathComponent)/\(proposedIconFileName)"
    }

    public var iconFilePath: String? {
        hasPropIcon ? proposedIconFilePath : nil
    }

    public var hasPropIcon: Bool {
        switch self {
        case .allDamageTypeAddedRatio: return true
        case .baseAttack, .baseDefence, .baseHP: return true
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
        case .healRatioBase: return true
        case .defenceDelta: return true
        case .hpAddedRatio: return true
        case .defenceAddedRatio: return true
        case .attackDelta: return true
        case .attackAddedRatio: return true
        case .criticalChanceBase: return true
        case .breakDamageAddedRatio: return true
        case .breakDamageAddedRatioBase: return true
        case .statusProbabilityBase: return true
        case .speedDelta: return true
        case .energyRecoveryBase: return true
        case .criticalDamageBase: return true
        case .statusResistanceBase: return true

        default:
            // Just in case that there will be new elements available.
            let condition1 = rawValue.suffix(10) == "AddedRatio" || rawValue.suffix(15) == "ResistanceDelta"
            let condition2 = rawValue.prefix(9) != "AllDamage"
            return condition1 && condition2
        }
    }

    public var element: EnkaHSR.Element? {
        switch self {
        case .anemoAddedRatio, .anemoResistance, .anemoResistanceDelta:
            return .anemo
        case .physicoAddedRatio, .physicoResistance, .physicoResistanceDelta:
            return .physico
        case .electroAddedRatio, .electroResistance, .electroResistanceDelta:
            return .electro
        case .fantasticoAddedRatio, .fantasticoResistance, .fantasticoResistanceDelta:
            return .fantastico
        case .posestoAddedRatio, .posestoResistance, .posestoResistanceDelta:
            return .posesto
        case .pyroAddedRatio, .pyroResistance, .pyroResistanceDelta:
            return .pyro
        case .cryoAddedRatio, .cryoResistance, .cryoResistanceDelta:
            return .cryo
        default: return nil
        }
    }

    public static func getAvatarProperties(
        element: EnkaHSR.Element
    )
        -> [EnkaHSR.PropertyType] {
        var results: [EnkaHSR.PropertyType] = [
            .maxHP,
            .attack,
            .defence,
            .speed,
            .criticalChance,
            .criticalDamage,
            .breakUp,
            .energyRecovery,
            .statusProbability,
            .statusResistance,
            .healRatio,
        ]
        switch element {
        case .physico: results.append(.physicoAddedRatio)
        case .anemo: results.append(.anemoAddedRatio)
        case .electro: results.append(.electroAddedRatio)
        case .fantastico: results.append(.fantasticoAddedRatio)
        case .posesto: results.append(.posestoAddedRatio)
        case .pyro: results.append(.pyroAddedRatio)
        case .cryo: results.append(.cryoAddedRatio)
        }

        return results
    }
}
