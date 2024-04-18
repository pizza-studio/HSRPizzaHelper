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

        // TODO: EnkaHSR requires manual calculation of avatar properties.
        let testPair1 = EnkaHSR.AvatarSummarized.PropertyPair(theDB: theDB, type: .maxHP, value: 114)
        let testPair2 = EnkaHSR.AvatarSummarized.PropertyPair(theDB: theDB, type: .defence, value: 514)
        let testPair3 = EnkaHSR.AvatarSummarized.PropertyPair(theDB: theDB, type: .criticalDamage, value: 1.919)
        let testPair4 = EnkaHSR.AvatarSummarized.PropertyPair(theDB: theDB, type: .criticalChance, value: 0.81)

        return .init(
            mainInfo: mainInfo,
            equippedWeapon: equipInfo,
            avatarProperties: [testPair1, testPair2, testPair3, testPair4],
            artifacts: artifactsInfo
        )
    }
}
