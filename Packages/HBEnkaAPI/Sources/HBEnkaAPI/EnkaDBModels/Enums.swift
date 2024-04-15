// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.DBModels {
    /// Elements used in HSR, using Ancient Greek namings (same as Genshin).
    public enum Element: String, Codable {
        case Physico = "Physical"
        case Anemo = "Wind"
        case Electro = "Thunder"
        case Fantastico = "Imaginary"
        case Posesto = "Quantum"
        case Pyro = "Fire"
        case Cryo = "Ice"
    }

    public enum PropType: String, Codable {
        case AnemoAddedRatio = "WindAddedRatio"
        case AnemoResistance = "WindResistance"
        case AnemoResistanceDelta = "WindResistanceDelta"
        case PhysicoAddedRatio = "PhysicalAddedRatio"
        case PhysicoResistance = "PhysicalResistance"
        case PhysicoResistanceDelta = "PhysicalResistanceDelta"
        case ElectroAddedRatio = "ThunderAddedRatio"
        case ElectroResistance = "ThunderResistance"
        case ElectroResistanceDelta = "ThunderResistanceDelta"
        case FantasticoAddedRatio = "ImaginaryAddedRatio"
        case FantasticoResistance = "ImaginaryResistance"
        case FantasticoResistanceDelta = "ImaginaryResistanceDelta"
        case PosestoAddedRatio = "QuantumAddedRatio"
        case PosestoResistance = "QuantumResistance"
        case PosestoResistanceDelta = "QuantumResistanceDelta"
        case PyroAddedRatio = "FireAddedRatio"
        case PyroResistance = "FireResistance"
        case PyroResistanceDelta = "FireResistanceDelta"
        case CryoAddedRatio = "IceAddedRatio"
        case CryoResistance = "IceResistance"
        case CryoResistanceDelta = "IceResistanceDelta"
        case AllDamageTypeAddedRatio
        case Attack
        case AttackAddedRatio
        case AttackDelta
        case BaseAttack
        case BaseDefence
        case BaseHP
        case BaseSpeed
        case BreakDamageAddedRatio
        case BreakDamageAddedRatioBase
        case CriticalChance
        case CriticalChanceBase
        case CriticalDamage
        case CriticalDamageBase
        case Defence
        case DefenceAddedRatio
        case DefenceDelta
        case HealRatio
        case HealRatioBase
        case HealTakenRatio
        case HPAddedRatio
        case HPDelta
        case MaxHP
        case MaxSP
        case Speed
        case SpeedAddedRatio
        case SpeedDelta
        case SPRatio
        case SPRatioBase
        case StatusProbability
        case StatusProbabilityBase
        case StatusResistance
        case StatusResistanceBase
    }
}
