// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR {
    /// The backend struct dedicated for rendering EachAvatarStatView.
    public struct AvatarSummarized: Codable, Hashable {
        public let mainInfo: AvatarMainInfo
        public let equippedWeapon: WeaponPanel
        public let avatarPropertiesA: [PropertyPair]
        public let avatarPropertiesB: [PropertyPair]
        public let artifacts: [ArtifactInfo]
    }
}

// MARK: - AvatarMainInfo & BaseSkillSet

extension EnkaHSR.AvatarSummarized {
    public struct AvatarMainInfo: Codable, Hashable {
        // MARK: Lifecycle

        public init?(
            theDB: EnkaHSR.EnkaDB,
            charId: Int,
            avatarLevel avatarLv: Int,
            constellation constellationLevel: Int,
            baseSkills baseSkillSet: BaseSkillSet
        ) {
            guard let theCommonInfo = theDB.characters[charId.description] else { return nil }
            self.avatarLevel = avatarLv
            self.constellation = constellationLevel
            self.baseSkills = baseSkillSet
            self.uniqueCharId = charId
            self.element = theCommonInfo.element
            self.lifePath = theCommonInfo.avatarBaseType
            let charNameHash = theCommonInfo.avatarName.hash.description
            self.localizedName = theDB.locTable[charNameHash] ?? "EnkaId: \(charId)"
        }

        // MARK: Public

        public let localizedName: String
        /// Unique Character ID number used by both Enka Network and MiHoYo.
        public let uniqueCharId: Int
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

        public var photoFileName: String {
            "\(uniqueCharId).png"
        }

        public var photoFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.character.rawValue)/\(photoFileName)"
        }

        public var avatarFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.profileAvatar.rawValue)/\(photoFileName)"
        }
    }
}

extension EnkaHSR.AvatarSummarized.AvatarMainInfo {
    /// Base Skill Set of a Character, excluding Technique since it doesn't have a level.
    public struct BaseSkillSet: Codable, Hashable {
        // MARK: Lifecycle

        public init?(
            fetched: [EnkaHSR.QueryRelated.DetailInfo.SkillTreeItem]
        ) {
            guard fetched.count >= 4, let firstTreeItem = fetched.first else { return nil }
            let charIdStr = firstTreeItem.pointId.description.prefix(4).description
            self.basicAttack = .init(charIdStr: charIdStr, adjustedLevel: fetched[0].level, type: .basicAttack)
            self.elementalSkill = .init(charIdStr: charIdStr, adjustedLevel: fetched[1].level, type: .elementalSkill)
            self.elementalBurst = .init(charIdStr: charIdStr, adjustedLevel: fetched[2].level, type: .elementalBurst)
            self.talent = .init(charIdStr: charIdStr, adjustedLevel: fetched[3].level, type: .talent)
        }

        // MARK: Public

        public struct BaseSkill: Codable, Hashable {
            public enum SkillType: String, Codable, Hashable {
                case basicAttack = "basic_atk"
                case elementalSkill = "skill"
                case elementalBurst = "ultimate"
                case talent
            }

            public let charIdStr: String
            /// Base skill level with amplification by constellations.
            public let adjustedLevel: Int
            public let type: SkillType

            public var iconFileName: String {
                "\(charIdStr)_\(type.rawValue).png"
            }

            public var iconFilePath: String {
                "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.skills.rawValue)/\(iconFileName)"
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

// MARK: - PropertyPair

extension EnkaHSR.AvatarSummarized {
    public struct PropertyPair: Codable, Hashable, Identifiable {
        // MARK: Lifecycle

        public init(theDB: EnkaHSR.EnkaDB, type: EnkaHSR.PropertyType, value: Double, isArtifact: Bool = false) {
            self.type = type
            self.value = value
            self.localizedTitle = (theDB.locTable[type.rawValue] ?? type.rawValue)
            self.isArtifact = isArtifact
        }

        // MARK: Public

        public let type: EnkaHSR.PropertyType
        public let value: Double
        public let localizedTitle: String
        public let isArtifact: Bool

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

        public var iconFilePath: String? {
            type.iconFilePath
        }
    }
}

// MARK: - WeaponPanel

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
            self.basicProps = fetched.flat.props.compactMap { currentRecord in
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

        /// Unique Artifact ID, defining its Rarity, Set Suite, and Body Part.
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

        public var iconFileName: String {
            "\(enkaId).png"
        }

        public var iconFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.weapon.rawValue)/\(iconFileName)"
        }
    }
}

// MARK: - ArtifactInfo

extension EnkaHSR.AvatarSummarized {
    public struct ArtifactInfo: Codable, Hashable, Identifiable {
        // MARK: Lifecycle

        public init?(theDB: EnkaHSR.EnkaDB, fetched: EnkaHSR.QueryRelated.DetailInfo.ArtifactItem) {
            guard let theCommonInfo = theDB.artifacts[fetched.tid.description] else { return nil }
            self.enkaId = fetched.tid
            self.commonInfo = theCommonInfo
            self.paramDataFetched = fetched
            let props: [PropertyPair] = fetched.flat.props.compactMap { currentRecord in
                if let theType = EnkaHSR.PropertyType(rawValue: currentRecord.type) {
                    return PropertyPair(theDB: theDB, type: theType, value: currentRecord.value, isArtifact: true)
                }
                return nil
            }
            guard let theMainProp = props.first else { return nil }
            self.mainProp = theMainProp
            self.subProps = Array(props.dropFirst())
        }

        // MARK: Public

        /// Unique Artifact ID, defining its Rarity, Set Suite, and Body Part.
        public let enkaId: Int
        /// Common information fetched from EnkaDB.
        public let commonInfo: EnkaHSR.DBModels.Artifact
        /// Data from Enka query result profile.
        public let paramDataFetched: EnkaHSR.QueryRelated.DetailInfo.ArtifactItem
        public let mainProp: PropertyPair
        public let subProps: [PropertyPair]

        public var trainedLevel: Int { paramDataFetched.level ?? 0 }
        public var rarityStars: Int { commonInfo.rarity }
        public var id: Int { enkaId }

        public var iconFileName: String {
            let str = paramDataFetched.tid.description
            guard str.count == 5 else { return "ARTIFACT_IMG_FOR_TID_\(str)" }
            let coreStr = str.dropFirst().dropLast()
            var lastDigit = (Int(str.last?.description ?? "2") ?? 2)
            if lastDigit >= 5 { lastDigit -= 4 }
            lastDigit -= 1
            return "\(coreStr)_\(lastDigit).png"
        }

        public var iconFilePath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.artifact.rawValue)/\(iconFileName)"
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
