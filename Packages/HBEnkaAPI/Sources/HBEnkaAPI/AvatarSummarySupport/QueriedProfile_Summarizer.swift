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

        return .init(mainInfo: mainInfo, equippedWeapon: equipInfo, avatarProperties: [], artifacts: artifactsInfo)
    }
}
