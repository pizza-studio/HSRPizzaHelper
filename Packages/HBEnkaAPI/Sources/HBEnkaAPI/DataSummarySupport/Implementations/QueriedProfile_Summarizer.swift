// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated.DetailInfo.Avatar {
    public func summarize(theDB: EnkaHSR.EnkaDB) -> EnkaHSR.AvatarSummarized? {
        // Main Info
        let baseSkillSet = EnkaHSR.AvatarSummarized.AvatarMainInfo.BaseSkillSet(
            theDB: theDB,
            constellation: rank ?? 0,
            fetched: skillTreeList
        )
        guard let baseSkillSet = baseSkillSet else { return nil }

        let mainInfo = EnkaHSR.AvatarSummarized.AvatarMainInfo(
            theDB: theDB,
            charId: avatarId,
            avatarLevel: level,
            constellation: rank ?? 0,
            baseSkills: baseSkillSet,
            levelName: EnkaHSR.EnkaDB.ExtraTerms.characterLevel[theDB.langTag] ?? "Lv.",
            constellationName: EnkaHSR.EnkaDB.ExtraTerms.constellation[theDB.langTag] ?? "Cons."
        )
        guard let mainInfo = mainInfo else { return nil }

        let equipInfo = EnkaHSR.AvatarSummarized.WeaponPanel(theDB: theDB, fetched: equipment)
        guard let equipInfo = equipInfo else { return nil }

        let artifactsInfo = relicList.compactMap {
            EnkaHSR.AvatarSummarized.ArtifactInfo(theDB: theDB, fetched: $0)
        }

        // Panel: Add basic values from catched character Metadata.
        let baseMetaCharacter = theDB.meta.avatar[avatarId.description]?[promotion.description]
        guard let baseMetaCharacter = baseMetaCharacter else { return nil }
        var panel = MutableAvatarPropertyPanel()
        panel.maxHP = baseMetaCharacter.hpBase
        panel.attack = baseMetaCharacter.attackBase
        panel.defence = baseMetaCharacter.defenceBase
        panel.maxHP += baseMetaCharacter.hpAdd * Double(level - 1)
        panel.attack += baseMetaCharacter.attackAdd * Double(level - 1)
        panel.defence += baseMetaCharacter.defenceAdd * Double(level - 1)
        panel.speed = baseMetaCharacter.speedBase
        panel.criticalChance = baseMetaCharacter.criticalChance
        panel.criticalDamage = baseMetaCharacter.criticalDamage

        // Panel: Base Props from the Weapon.

        let baseMetaWeapon = theDB.meta.equipment[equipment.tid.description]?[equipment.promotion.description]
        guard let baseMetaWeapon = baseMetaWeapon else { return nil }
        panel.maxHP += baseMetaWeapon.baseHP
        panel.attack += baseMetaWeapon.baseAttack
        panel.defence += baseMetaWeapon.baseDefence
        panel.maxHP += baseMetaWeapon.hpAdd * Double(equipInfo.trainedLevel - 1)
        panel.attack += baseMetaWeapon.attackAdd * Double(equipInfo.trainedLevel - 1)
        panel.defence += baseMetaWeapon.defenceAdd * Double(equipInfo.trainedLevel - 1)

        // Panel: Handle all additional props

        // Panel: - Additional Props from the Weapon.

        let weaponSpecialProps: [EnkaHSR.AvatarSummarized.PropertyPair] = equipInfo.specialProps

        // Panel: 来自天赋树的面板加成。
        // English: Base and Additional Props from the Skill Tree.

        let skillTreeProps: [EnkaHSR.AvatarSummarized.PropertyPair] = skillTreeList.compactMap { currentNode in
            if currentNode.level == 1 {
                return theDB.meta.tree.query(id: currentNode.pointId, stage: 1).map {
                    EnkaHSR.AvatarSummarized.PropertyPair(theDB: theDB, type: $0.key, value: $0.value)
                }
            }
            return nil
        }.reduce([], +)

        // Panel: - Additional Props from the Artifacts.

        let artifactProps: [EnkaHSR.AvatarSummarized.PropertyPair] = artifactsInfo.map(\.allProps).reduce([], +)

        // Panel: - Additional Props from the Artifact Set Effects.

        let artifactSetProps: [EnkaHSR.AvatarSummarized.PropertyPair] = {
            var resultPairs = [EnkaHSR.AvatarSummarized.PropertyPair]()
            var setIDCounters: [Int: Int] = [:]
            artifactsInfo.map(\.paramDataFetched.flat.setID).forEach { setIDCounters[$0, default: 0] += 1 }
            setIDCounters.forEach { setId, count in
                guard count >= 2 else { return }
                let x = theDB.meta.relic.setSkill.query(id: setId, stage: 2).map {
                    EnkaHSR.AvatarSummarized.PropertyPair(theDB: theDB, type: $0.key, value: $0.value)
                }
                resultPairs.append(contentsOf: x)
                guard count >= 4 else { return }
                let y = theDB.meta.relic.setSkill.query(id: setId, stage: 4).map {
                    EnkaHSR.AvatarSummarized.PropertyPair(theDB: theDB, type: $0.key, value: $0.value)
                }
                resultPairs.append(contentsOf: y)
            }
            return resultPairs
        }()

        // Panel: Triage and Handle.

        let allProps = skillTreeProps + weaponSpecialProps + artifactProps + artifactSetProps
        panel.triageAndHandle(theDB: theDB, allProps, element: mainInfo.element)

        // Panel: 将最终面板转成输出物件要用到的格式。

        let propPair = panel.converted(theDB: theDB, element: mainInfo.element)

        return .init(
            mainInfo: mainInfo,
            equippedWeapon: equipInfo,
            avatarPropertiesA: propPair.0,
            avatarPropertiesB: propPair.1,
            artifacts: artifactsInfo
        )
    }
}

// MARK: - MutableAvatarPropertyPanel

private struct MutableAvatarPropertyPanel {
    // MARK: Public

    public var maxHP: Double = 0
    public var attack: Double = 0
    public var defence: Double = 0
    public var speed: Double = 0
    public var criticalChance: Double = 0
    public var criticalDamage: Double = 0
    public var breakUp: Double = 0
    public var energyRecovery: Double = 1
    public var statusProbability: Double = 0
    public var statusResistance: Double = 0
    public var healRatio: Double = 0
    public var elementalDMGAddedRatio: Double = 0

    public func converted(
        theDB: EnkaHSR.EnkaDB,
        element: EnkaHSR
            .Element
    ) -> ([EnkaHSR.AvatarSummarized.PropertyPair], [EnkaHSR.AvatarSummarized.PropertyPair]) {
        var resultA = [EnkaHSR.AvatarSummarized.PropertyPair]()
        var resultB = [EnkaHSR.AvatarSummarized.PropertyPair]()
        resultA.append(.init(theDB: theDB, type: .maxHP, value: maxHP))
        resultA.append(.init(theDB: theDB, type: .attack, value: attack))
        resultA.append(.init(theDB: theDB, type: .defence, value: defence))
        resultA.append(.init(theDB: theDB, type: .speed, value: speed))
        resultA.append(.init(theDB: theDB, type: .criticalChance, value: criticalChance))
        resultA.append(.init(theDB: theDB, type: .criticalDamage, value: criticalDamage))
        resultB.append(.init(theDB: theDB, type: element.damageAddedRatioProperty, value: elementalDMGAddedRatio))
        resultB.append(.init(theDB: theDB, type: .breakDamageAddedRatio, value: breakUp))
        resultB.append(.init(theDB: theDB, type: .healRatio, value: healRatio))
        resultB.append(.init(theDB: theDB, type: .energyRecovery, value: energyRecovery))
        resultB.append(.init(theDB: theDB, type: .statusProbability, value: statusProbability))
        resultB.append(.init(theDB: theDB, type: .statusResistance, value: statusResistance))
        return (resultA, resultB)
    }

    /// Triage the property pairs into two categories, and then handle them.
    /// - Parameters:
    ///   - newProps: An array of property pairs to addup to self.
    ///   - element: The element of the character, affecting which element's damange added ratio will be respected.
    public mutating func triageAndHandle(
        theDB: EnkaHSR.EnkaDB,
        _ newProps: [EnkaHSR.AvatarSummarized.PropertyPair],
        element: EnkaHSR.Element
    ) {
        var propAmplifiers = [EnkaHSR.AvatarSummarized.PropertyPair]()
        var propAdditions = [EnkaHSR.AvatarSummarized.PropertyPair]()
        newProps.forEach { $0.triage(amp: &propAmplifiers, add: &propAdditions, element: element) }

        var propAmpDictionary: [EnkaHSR.PropertyType: Double] = [:]
        propAmplifiers.forEach {
            propAmpDictionary[$0.type, default: 0] += $0.value
        }

        propAmpDictionary.forEach { key, value in
            handle(.init(theDB: theDB, type: key, value: value), element: element)
        }

        propAdditions.forEach { handle($0, element: element) }
    }

    // MARK: Private

    // swiftlint:disable cyclomatic_complexity
    private mutating func handle(
        _ prop: EnkaHSR.AvatarSummarized.PropertyPair,
        element: EnkaHSR.Element
    ) {
        switch prop.type {
        // 星穹铁道没有附魔，所以只要是与角色属性不匹配的元素伤害加成都是狗屁。
        case element.damageAddedRatioProperty: elementalDMGAddedRatio += prop.value
        case .attack, .attackDelta, .baseAttack: attack += prop.value
        case .attackAddedRatio: attack *= (1 + prop.value)
        case .baseHP, .hpDelta, .maxHP: maxHP += prop.value
        case .hpAddedRatio: maxHP *= (1 + prop.value)
        case .baseSpeed, .speed, .speedDelta: speed += prop.value
        case .speedAddedRatio: speed *= (1 + prop.value)
        case .criticalChance, .criticalChanceBase: criticalChance += prop.value
        case .criticalDamage, .criticalDamageBase: criticalDamage += prop.value
        case .baseDefence, .defence, .defenceDelta: defence += prop.value
        case .defenceAddedRatio: defence *= (1 + prop.value)
        case .energyRecovery, .energyRecoveryBase: energyRecovery += prop.value
        case .healRatio, .healRatioBase: healRatio += prop.value
        case .statusProbability, .statusProbabilityBase: statusProbability += prop.value
        case .statusResistance, .statusResistanceBase: statusResistance += prop.value
        case .breakDamageAddedRatio, .breakDamageAddedRatioBase, .breakUp:
            breakUp += prop.value
        default: return
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

extension EnkaHSR.AvatarSummarized.PropertyPair {
    func triage(
        amp arrAmp: inout [EnkaHSR.AvatarSummarized.PropertyPair],
        add arrAdd: inout [EnkaHSR.AvatarSummarized.PropertyPair],
        element: EnkaHSR.Element
    ) {
        switch type {
        case .attackAddedRatio, .defenceAddedRatio, .hpAddedRatio, .speedAddedRatio: arrAmp.append(self)
        case .attack, .attackDelta,
             .baseAttack, .baseDefence, .baseHP, .baseSpeed,
             .breakDamageAddedRatio, .breakDamageAddedRatioBase,
             .breakUp, .criticalChance, .criticalChanceBase,
             .criticalDamage, .criticalDamageBase, .defence,
             .defenceDelta, element.damageAddedRatioProperty,
             .energyRecovery, .energyRecoveryBase,
             .healRatio, .healRatioBase,
             .hpDelta, .maxHP, .speed,
             .speedDelta, .statusProbability,
             .statusProbabilityBase, .statusResistance,
             .statusResistanceBase:
            arrAdd.append(self)
        default: break
        }
    }
}