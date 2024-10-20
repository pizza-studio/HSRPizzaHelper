// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import DefaultsKeys

// MARK: - EnkaHSR.AvatarSummarized

extension EnkaHSR {
    /// The backend struct dedicated for rendering EachAvatarStatView.
    public struct AvatarSummarized: Codable, Hashable, Identifiable {
        // MARK: Public

        public let mainInfo: AvatarMainInfo
        public let equippedWeapon: WeaponPanel?
        public let avatarPropertiesA: [PropertyPair]
        public let avatarPropertiesB: [PropertyPair]
        public private(set) var artifacts: [ArtifactInfo]
        public var artifactRatingResult: ArtifactRating.ScoreResult?

        public var id: Int { mainInfo.uniqueCharId } // 回头可能需要另外考虑。

        // MARK: Internal

        internal mutating func updateArtifacts(targetArray: @escaping ([ArtifactInfo]) -> [ArtifactInfo]) {
            artifacts = targetArray(artifacts)
        }
    }
}

// MARK: - EnkaHSR.AvatarSummarized.AvatarMainInfo

extension EnkaHSR.AvatarSummarized {
    public struct CharacterID: Identifiable, Codable, Hashable {
        // MARK: Lifecycle

        public init?(id: String) {
            guard EnkaHSR.Sputnik.sharedDB.characters.keys.contains(id) else { return nil }
            self.id = id
        }

        // MARK: Public

        public let id: String

        public var i18nNameForUI: String {
            EnkaHSR.Sputnik.sharedDB.queryLocalizedNameForChar(id: id)
        }

        public var i18nNameFactoryVanilla: String {
            EnkaHSR.Sputnik.sharedDB.queryLocalizedNameForChar(id: id, officialNameOnly: true)
        }

        public var photoFileName: String {
            "\(id).heic"
        }

        public var photoFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.character.rawValue)/\(photoFileName)"
        }

        public var avatarFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.profileAvatar.rawValue)/\(photoFileName)"
        }

        public var avatarAssetName: String {
            "avatar_\(id)"
        }

        public var photoAssetName: String {
            "characters_\(id)"
        }
    }

    public struct AvatarMainInfo: Codable, Hashable {
        // MARK: Lifecycle

        public init?(
            theDB: EnkaHSR.EnkaDB,
            charID: Int,
            avatarLevel avatarLv: Int,
            constellation constellationLevel: Int,
            baseSkills baseSkillSet: BaseSkillSet,
            terms: EnkaHSR.EnkaDB.ExtraTerms
        ) {
            guard let theCommonInfo = theDB.characters[charID.description] else { return nil }
            guard let idExpressible = EnkaHSR.AvatarSummarized.CharacterID(id: charID.description) else { return nil }
            self.avatarLevel = avatarLv
            self.constellation = constellationLevel
            self.baseSkills = baseSkillSet
            self.uniqueCharId = charID
            self.element = theCommonInfo.element
            self.lifePath = theCommonInfo.avatarBaseType
            let nameTyped = EnkaHSR.CharacterName(pid: charID)
            self.localizedName = nameTyped.i18n(theDB: theDB, officialNameOnly: true)
            self.localizedRealName = nameTyped.i18n(theDB: theDB, officialNameOnly: false)
            self.terms = terms
            self.idExpressable = idExpressible
        }

        // MARK: Public

        public let terms: EnkaHSR.EnkaDB.ExtraTerms
        public let localizedName: String
        public let localizedRealName: String
        /// Unique Character ID number used by both Enka Network and MiHoYo.
        public let uniqueCharId: Int
        /// Unique Character ID Expressable Object.
        public let idExpressable: EnkaHSR.AvatarSummarized.CharacterID
        /// Character's Mastered Element.
        public let element: EnkaHSR.Element
        /// Character's LifePath.
        public let lifePath: EnkaHSR.LifePath
        /// Avatar Level trained by the player.
        public let avatarLevel: Int
        /// Avatar constellation level.
        public let constellation: Int
        /// Base Skills.
        public let baseSkills: BaseSkillSet

        public var name: String {
            Defaults[.useRealCharacterNames] ? localizedRealName : localizedName
        }
    }
}

// MARK: - EnkaHSR.AvatarSummarized.AvatarMainInfo.BaseSkillSet

extension EnkaHSR.AvatarSummarized.AvatarMainInfo {
    /// Base Skill Set of a Character, excluding Technique since it doesn't have a level.
    public struct BaseSkillSet: Codable, Hashable {
        // MARK: Lifecycle

        public init?(
            theDB: EnkaHSR.EnkaDB,
            constellation: Int,
            fetched: [EnkaHSR.QueryRelated.DetailInfo.SkillTreeItem]
        ) {
            guard fetched.count >= 4, let firstTreeItem = fetched.first else { return nil }
            var charID = Int((Double(firstTreeItem.pointId) / 1000.0).rounded(.down))
            if case .ofStelle = Protagonist(rawValue: charID) { charID -= 1 }
            let charIDStr = charID.description
            var levelAdditionList = [String: Int]()
            if constellation > 1 {
                for i in 1 ... constellation {
                    let keyword = "\(charIDStr)0\(i)"
                    theDB.skillRanks[keyword]?.skillAddLevelList.forEach { thisPointId, levelDelta in
                        var writeKeyArr = thisPointId.map(\.description)
                        writeKeyArr.insert("0", at: 4)
                        levelAdditionList[writeKeyArr.joined(), default: 0] += levelDelta
                    }
                }
            }

            self.basicAttack = .init(
                charIDStr: charIDStr, baseLevel: fetched[0].level,
                levelAddition: levelAdditionList[fetched[0].pointId.description],
                type: .basicAttack
            )
            self.elementalSkill = .init(
                charIDStr: charIDStr, baseLevel: fetched[1].level,
                levelAddition: levelAdditionList[fetched[1].pointId.description],
                type: .elementalSkill
            )
            self.elementalBurst = .init(
                charIDStr: charIDStr, baseLevel: fetched[2].level,
                levelAddition: levelAdditionList[fetched[2].pointId.description],
                type: .elementalBurst
            )
            self.talent = .init(
                charIDStr: charIDStr, baseLevel: fetched[3].level,
                levelAddition: levelAdditionList[fetched[3].pointId.description],
                type: .talent
            )
        }

        // MARK: Public

        public struct BaseSkill: Codable, Hashable {
            public enum SkillType: String, Codable, Hashable {
                case basicAttack = "Normal"
                case elementalSkill = "BP"
                case elementalBurst = "Ultra"
                case talent = "Passive"
            }

            public let charIDStr: String
            /// Base skill level with amplification by constellations.
            public let baseLevel: Int
            public let levelAddition: Int?
            public let type: SkillType

            public var iconFileName: String {
                "\(charIDStr)_\(type.rawValue).heic"
            }

            public var iconFilePath: String {
                "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.skills.rawValue)/\(iconFileName)"
            }

            public var iconAssetName: String {
                "skill_\(charIDStr)_\(type.rawValue)"
            }
        }

        /// Basic Attack.
        public let basicAttack: BaseSkill
        /// Skill.
        public let elementalSkill: BaseSkill
        /// Ultimate.
        public let elementalBurst: BaseSkill
        /// Talent.
        public let talent: BaseSkill

        public var toArray: [BaseSkill] {
            [basicAttack, elementalSkill, elementalBurst, talent]
        }
    }
}

// MARK: - EnkaHSR.AvatarSummarized.PropertyPair

extension EnkaHSR.AvatarSummarized {
    public struct PropertyPair: Codable, Hashable, Identifiable {
        // MARK: Lifecycle

        public init(
            theDB: EnkaHSR.EnkaDB,
            type: EnkaHSR.PropertyType,
            value: Double
        ) {
            self.type = type
            self.value = value
            var title = (theDB.locTable[type.rawValue] ?? type.rawValue)
            Self.sanitizeTitle(&title)
            self.localizedTitle = title
            self.isArtifact = false
            self.count = 0
            self.step = nil
        }

        public init(
            theDB: EnkaHSR.EnkaDB,
            type: EnkaHSR.PropertyType,
            value: Double,
            count: Int,
            step: Int?
        ) {
            self.type = type
            self.value = value
            var title = (theDB.locTable[type.rawValue] ?? type.rawValue)
            Self.sanitizeTitle(&title)
            self.localizedTitle = title
            self.isArtifact = true
            self.count = count
            self.step = step
        }

        // MARK: Public

        public let type: EnkaHSR.PropertyType
        public let value: Double
        public let localizedTitle: String
        public let isArtifact: Bool
        public let count: Int
        public let step: Int?

        public var id: EnkaHSR.PropertyType { type }

        public var valueString: String {
            var copiedValue = value
            let prefix = isArtifact ? "+" : ""
            if type.isPercentage {
                copiedValue *= 100
                return prefix + copiedValue.roundToPlaces(places: 1).description + "%"
            }
            return prefix + Int(copiedValue).description
        }

        public var iconFileName: String? {
            type.iconFileName
        }

        public var iconAssetName: String? {
            type.iconAssetName
        }

        public var iconFilePath: String? {
            type.iconFilePath
        }

        // MARK: Private

        private static func sanitizeTitle(_ title: inout String) {
            title = title.replacingOccurrences(of: "Regeneration", with: "Recharge")
            title = title.replacingOccurrences(of: "Rate", with: "%")
            title = title.replacingOccurrences(of: "Bonus", with: "+")
            title = title.replacingOccurrences(of: "Boost", with: "+")
            title = title.replacingOccurrences(of: "ダメージ", with: "傷害量")
            title = title.replacingOccurrences(of: "能量恢复", with: "元素充能")
            title = title.replacingOccurrences(of: "能量恢復", with: "元素充能")
            title = title.replacingOccurrences(of: "属性", with: "元素")
            title = title.replacingOccurrences(of: "屬性", with: "元素")
            title = title.replacingOccurrences(of: "量子元素", with: "量子")
            title = title.replacingOccurrences(of: "物理元素", with: "物理")
            title = title.replacingOccurrences(of: "虛數元素", with: "虛數")
            title = title.replacingOccurrences(of: "虚数元素", with: "虚数")
            title = title.replacingOccurrences(of: "提高", with: "加成")
            title = title.replacingOccurrences(of: "与", with: "")
        }
    }
}

// MARK: - EnkaHSR.AvatarSummarized.WeaponPanel

extension EnkaHSR.AvatarSummarized {
    public struct WeaponPanel: Codable, Hashable {
        // MARK: Lifecycle

        public init?(
            theDB: EnkaHSR.EnkaDB,
            fetched: EnkaHSR.QueryRelated.DetailInfo.Equipment
        ) {
            guard let theCommonInfo = theDB.weapons[fetched.tid.description] else { return nil }
            self.enkaId = fetched.tid
            self.commonInfo = theCommonInfo
            self.paramDataFetched = fetched
            let nameHash = theCommonInfo.equipmentName.hash.description
            self.localizedName = theDB.locTable[nameHash] ?? "EnkaId: \(fetched.tid)"
            self.trainedLevel = fetched.level
            self.refinement = fetched.rank
            self.basicProps = fetched.getFlat(theDB: theDB).props.compactMap { currentRecord in
                if let theType = EnkaHSR.PropertyType(rawValue: currentRecord.type) {
                    return PropertyPair(theDB: theDB, type: theType, value: currentRecord.value)
                }
                return nil
            }
            self.specialProps = theDB.meta.equipmentSkill.query(
                id: enkaId, stage: fetched.rank
            ).map { key, value in
                PropertyPair(theDB: theDB, type: key, value: value)
            }
        }

        // MARK: Public

        /// Unique Weapon ID.
        public let enkaId: Int
        /// Common information fetched from EnkaDB.
        public let commonInfo: EnkaHSR.DBModels.Weapon
        /// Data from Enka query result profile.
        public let paramDataFetched: EnkaHSR.QueryRelated.DetailInfo.Equipment
        public let localizedName: String
        public let trainedLevel: Int
        public let refinement: Int
        public let basicProps: [PropertyPair]
        public let specialProps: [PropertyPair]

        public var rarityStars: Int { commonInfo.rarity }

        public var allProps: [PropertyPair] {
            basicProps + specialProps
        }

        public var iconFileName: String {
            "\(enkaId).heic"
        }

        public var iconFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.weapon.rawValue)/\(iconFileName)"
        }

        public var iconAssetName: String {
            "light_cone_\(enkaId)"
        }
    }
}

// MARK: - EnkaHSR.AvatarSummarized.ArtifactInfo

extension EnkaHSR.AvatarSummarized {
    public struct ArtifactInfo: Codable, Hashable, Identifiable {
        // MARK: Lifecycle

        public init?(theDB: EnkaHSR.EnkaDB, fetched: EnkaHSR.QueryRelated.DetailInfo.ArtifactItem) {
            guard let theCommonInfo = theDB.artifacts[fetched.tid.description] else { return nil }
            self.enkaId = fetched.tid
            self.commonInfo = theCommonInfo
            self.paramDataFetched = fetched
            guard let flat = fetched.getFlat(theDB: theDB) else { return nil }
            let props: [PropertyPair] = flat.props.compactMap { currentRecord in
                if let theType = EnkaHSR.PropertyType(rawValue: currentRecord.type) {
                    return PropertyPair(
                        theDB: theDB,
                        type: theType,
                        value: currentRecord.value,
                        count: currentRecord.count,
                        step: currentRecord.step
                    )
                }
                return nil
            }
            guard let theMainProp = props.first else { return nil }
            self.mainProp = theMainProp
            self.subProps = Array(props.dropFirst())
            self.setID = flat.setID
            // 回頭恐需要單獨給聖遺物套裝名稱設定 Datamine。
            self.setNameLocalized = "Set.\(setID)"
        }

        // MARK: Public

        /// Unique Artifact ID, defining its Rarity, Set Suite, and Body Part.
        public let enkaId: Int
        /// Artifact Set ID.
        public let setID: Int
        public let setNameLocalized: String
        /// Common information fetched from EnkaDB.
        public let commonInfo: EnkaHSR.DBModels.Artifact
        /// Data from Enka query result profile.
        public let paramDataFetched: EnkaHSR.QueryRelated.DetailInfo.ArtifactItem
        public let mainProp: PropertyPair
        public let subProps: [PropertyPair]

        public var ratedScore: Int?

        public var trainedLevel: Int { paramDataFetched.level ?? 0 }
        public var rarityStars: Int { commonInfo.rarity }
        public var id: Int { enkaId }
        public var allProps: [PropertyPair] {
            var result = subProps
            result.insert(mainProp, at: 0)
            return result
        }

        public var type: EnkaHSR.DBModels.Artifact.ArtifactType {
            .init(typeID: paramDataFetched.type) ?? commonInfo.type
        }

        public var iconFileName: String {
            "\(commonInfo.setID)_\(type.assetSuffix).heic"
        }

        public var iconFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.artifact.rawValue)/\(iconFileName)"
        }

        public var iconAssetName: String {
            "relic_\(commonInfo.setID)_\(type.assetSuffix)"
        }
    }
}

// MARK: - Swift Extension to round doubles.

extension Double {
    /// Rounds the double to decimal places value
    fileprivate func roundToPlaces(places: Int = 1) -> Double {
        guard places > 0 else { return self }
        var precision = 1.0
        for _ in 0 ..< places {
            precision *= 10
        }
        return Double((precision * self).rounded() / precision)
    }
}
