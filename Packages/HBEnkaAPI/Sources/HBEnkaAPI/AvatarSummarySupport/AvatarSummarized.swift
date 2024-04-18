// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR {
    /// The backend struct dedicated for rendering EachAvatarStatView.
    public struct AvatarSummarized: Codable {
        public let mainInfo: AvatarMainInfo
        public let equippedWeapon: WeaponPanel
        public let avatarProperties: [PropertyPair]
        public let artifacts: [ArtifactInfo]
    }
}

// MARK: - AvatarMainInfo & BaseSkillSet

extension EnkaHSR.AvatarSummarized {
    public struct AvatarMainInfo: Codable {
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
            self.localizedName = theDB.locTable[charNameHash] ?? charNameHash
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

        public var photoFileSubPath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.character)/\(photoFileName)"
        }
    }
}

extension EnkaHSR.AvatarSummarized.AvatarMainInfo {
    /// Base Skill Set of a Character, excluding Technique since it doesn't have a level.
    public struct BaseSkillSet: Codable {
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

        public struct BaseSkill: Codable {
            public enum SkillType: String, Codable {
                case basicAttack = "base_atk"
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

            public var iconFileSubPath: String {
                "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.skills)/\(iconFileName)"
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
    public struct PropertyPair: Codable {
        // MARK: Lifecycle

        public init(theDB: EnkaHSR.EnkaDB, type: EnkaHSR.PropertyType, value: Double) {
            self.type = type
            self.value = value
            self.localizedTitle = theDB.locTable[type.rawValue] ?? type.rawValue
        }

        // MARK: Public

        public let type: EnkaHSR.PropertyType
        public let value: Double
        public let localizedTitle: String

        public var valueString: String {
            // TODO: Need to implement something here to determine whether it should be represented as percentage.
            value.roundToPlaces(places: 2).description
        }

        public var iconFileName: String? {
            type.iconFileName
        }

        public var iconFileSubPath: String? {
            guard let iconFileName = iconFileName else { return nil }
            return "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.property)/\(iconFileName)"
        }
    }
}

// MARK: - WeaponPanel

extension EnkaHSR.AvatarSummarized {
    public struct WeaponPanel: Codable {
        // MARK: Lifecycle

        public init?(
            theDB: EnkaHSR.EnkaDB,
            fetched: EnkaHSR.QueryRelated.DetailInfo.Equipment
        ) {
            guard let theCommonInfo = theDB.weapons[fetched.tid.description] else { return nil }
            self.enkaId = fetched.tid
            self.commonInfo = theCommonInfo
            self.paramDataFetched = fetched
            self.localizedName = theDB.locTable[fetched.tid.description] ?? "EnkaId: \(fetched.tid)"
            self.props = fetched.flat.props.compactMap { currentRecord in
                if let theType = EnkaHSR.PropertyType(rawValue: currentRecord.type) {
                    return PropertyPair(theDB: theDB, type: theType, value: currentRecord.value)
                }
                return nil
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
        public let props: [PropertyPair]

        public var rarityStars: Int { commonInfo.rarity }

        public var iconFileName: String {
            "\(enkaId).png"
        }

        public var iconFileSubPath: String {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.weapon)/\(iconFileName)"
        }
    }
}

// MARK: - ArtifactInfo

extension EnkaHSR.AvatarSummarized {
    public struct ArtifactInfo: Codable {
        // MARK: Lifecycle

        public init?(theDB: EnkaHSR.EnkaDB, fetched: EnkaHSR.QueryRelated.DetailInfo.ArtifactItem) {
            guard let theCommonInfo = theDB.artifacts[fetched.tid.description] else { return nil }
            self.enkaId = fetched.tid
            self.commonInfo = theCommonInfo
            self.paramDataFetched = fetched
            let props: [PropertyPair] = fetched.flat.props.compactMap { currentRecord in
                if let theType = EnkaHSR.PropertyType(rawValue: currentRecord.type) {
                    return PropertyPair(theDB: theDB, type: theType, value: currentRecord.value)
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

        public var rarityStars: Int { commonInfo.rarity }

        public var iconFileName: String {
            let str = paramDataFetched.tid.description
            guard str.count == 5 else { return "ARTIFACT_IMG_FOR_TID_\(str)" }
            let coreStr = str.dropFirst().dropLast()
            let lastDigit = (Int(str.last?.description ?? "2") ?? 2) - 1
            return "\(coreStr)_\(lastDigit)"
        }

        public var iconFileSubPath: String? {
            "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.artifact)/\(iconFileName)"
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
