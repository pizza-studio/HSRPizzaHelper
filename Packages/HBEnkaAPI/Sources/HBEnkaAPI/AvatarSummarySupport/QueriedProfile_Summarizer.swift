// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated.DetailInfo.Avatar {
    public func summarize(theDB: EnkaHSR.EnkaDB) -> EnkaHSR.AvatarSummarized? {
        // Main Info
        let baseSkillSet = EnkaHSR.AvatarSummarized.AvatarMainInfo.BaseSkillSet(fetched: skillTreeList)
        guard let baseSkillSet = baseSkillSet else { return nil }

        let mainInfo = EnkaHSR.AvatarSummarized.AvatarMainInfo(
            theDB: theDB,
            charId: avatarId,
            avatarLevel: level,
            constellation: rank ?? 0,
            baseSkills: baseSkillSet
        )
        guard let mainInfo = mainInfo else { return nil }

        let equipInfo = EnkaHSR.AvatarSummarized.WeaponPanel(theDB: theDB, fetched: equipment)
        guard let equipInfo = equipInfo else { return nil }

        let artifactsInfo = relicList.compactMap {
            EnkaHSR.AvatarSummarized.ArtifactInfo(theDB: theDB, fetched: $0)
        }

        // Panel: Add values from catched Metadata
        let baseMeta = theDB.meta.avatar[avatarId.description]?[promotion.description]
        guard let baseMeta = baseMeta else { return nil }
        var panel = MutableAvatarPropertyPanel()
        panel.maxHP = baseMeta.hpBase + baseMeta.hpAdd
        panel.attack = baseMeta.attackBase + baseMeta.attackAdd
        panel.defence = baseMeta.defenceBase + baseMeta.defenceAdd
        panel.speed = baseMeta.speedBase
        panel.criticalChance = baseMeta.criticalChance
        panel.criticalDamage = baseMeta.criticalDamage
        // TODO: 得请专人来检查这里的数值计算方法。此处还缺很多数据、还有很多算法是错的。

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
        resultB.append(.init(theDB: theDB, type: .breakDamageAddedRatio, value: breakUp))
        resultB.append(.init(theDB: theDB, type: .energyRecovery, value: energyRecovery))
        resultB.append(.init(theDB: theDB, type: .statusProbability, value: statusProbability))
        resultB.append(.init(theDB: theDB, type: .statusResistance, value: statusResistance))
        resultB.append(.init(theDB: theDB, type: .healRatio, value: healRatio))
        resultB.append(.init(theDB: theDB, type: element.damageAddedRatioProperty, value: elementalDMGAddedRatio))
        return (resultA, resultB)
    }
}
