// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Defaults
import DefaultsKeys
import Foundation

// MARK: - EnkaHSR.EnkaDB

extension EnkaHSR {
    public class EnkaDB: Codable, ObservableObject {
        // MARK: Lifecycle

        public init(
            locTag: String? = nil,
            locTable: EnkaHSR.DBModels.LocTable,
            profileAvatars: EnkaHSR.DBModels.ProfileAvatarDict,
            characters: EnkaHSR.DBModels.CharacterDict,
            meta: EnkaHSR.DBModels.Meta,
            skillRanks: EnkaHSR.DBModels.SkillRanksDict,
            artifacts: EnkaHSR.DBModels.ArtifactsDict,
            skills: EnkaHSR.DBModels.SkillsDict,
            skillTrees: EnkaHSR.DBModels.SkillTreesDict,
            weapons: EnkaHSR.DBModels.WeaponsDict
        ) {
            let locTag = locTag ?? Locale.langCodeForEnkaAPI
            self.langTag = Self.sanitizeLangTag(locTag)
            self.locTable = locTable
            self.profileAvatars = profileAvatars
            self.characters = characters
            self.meta = meta
            self.skillRanks = skillRanks
            self.artifacts = artifacts
            self.skills = skills
            self.skillTrees = skillTrees
            self.weapons = weapons
            let locTablesRN = try? EnkaHSR.JSONType.realNameTable.bundledJSONData
                .assertedParseAs(EnkaHSR.DBModels.RawLocTables.self)
            self.realNameTable = locTablesRN?[locTag] ?? [:]
        }

        public init?(
            locTag: String? = nil,
            locTables: EnkaHSR.DBModels.RawLocTables,
            profileAvatars: EnkaHSR.DBModels.ProfileAvatarDict,
            characters: EnkaHSR.DBModels.CharacterDict,
            meta: EnkaHSR.DBModels.Meta,
            skillRanks: EnkaHSR.DBModels.SkillRanksDict,
            artifacts: EnkaHSR.DBModels.ArtifactsDict,
            skills: EnkaHSR.DBModels.SkillsDict,
            skillTrees: EnkaHSR.DBModels.SkillTreesDict,
            weapons: EnkaHSR.DBModels.WeaponsDict
        ) {
            let locTag = locTag ?? Locale.langCodeForEnkaAPI
            self.langTag = Self.sanitizeLangTag(locTag)
            self.langTag = locTag
            guard let langTable = locTables[langTag] else { return nil }
            self.locTable = langTable
            self.profileAvatars = profileAvatars
            self.characters = characters
            self.meta = meta
            self.skillRanks = skillRanks
            self.artifacts = artifacts
            self.skills = skills
            self.skillTrees = skillTrees
            self.weapons = weapons
            let locTablesRN = try? EnkaHSR.JSONType.realNameTable.bundledJSONData
                .assertedParseAs(EnkaHSR.DBModels.RawLocTables.self)
            self.realNameTable = locTablesRN?[locTag] ?? [:]
        }

        /// Use bundled resources to initiate an EnkaDB instance.
        public init?(locTag: String? = nil) {
            do {
                let locTables = try EnkaHSR.JSONType.locTable.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.RawLocTables.self)
                let locTag = locTag ?? Locale.langCodeForEnkaAPI
                guard let locTableSpecified = locTables[locTag] else { return nil }
                self.langTag = Self.sanitizeLangTag(locTag)
                self.locTable = locTableSpecified
                let locTablesRN = try EnkaHSR.JSONType.realNameTable.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.RawLocTables.self)
                guard let locTableSpecifiedRN = locTablesRN[locTag] else { return nil }
                self.realNameTable = locTableSpecifiedRN
                self.profileAvatars = try EnkaHSR.JSONType.profileAvatarIcons.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.ProfileAvatarDict.self)
                self.characters = try EnkaHSR.JSONType.characters.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.CharacterDict.self)
                self.meta = try EnkaHSR.JSONType.metadata.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.Meta.self)
                self.skillRanks = try EnkaHSR.JSONType.skillRanks.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.SkillRanksDict.self)
                self.artifacts = try EnkaHSR.JSONType.artifacts.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.ArtifactsDict.self)
                self.skills = try EnkaHSR.JSONType.skills.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.SkillsDict.self)
                self.skillTrees = try EnkaHSR.JSONType.skillTrees.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.SkillTreesDict.self)
                self.weapons = try EnkaHSR.JSONType.weapons.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.WeaponsDict.self)
            } catch {
                print("\n\(error)\n")
                return nil
            }
        }

        // MARK: Public

        public static let allowedLangTags: [String] = [
            "en", "ru", "vi", "th", "pt", "ko",
            "ja", "id", "fr", "es", "de", "zh-tw", "zh-cn",
        ]

        public static var currentLangTag: String {
            Locale.langCodeForEnkaAPI
        }

        public private(set) var realNameTable: EnkaHSR.DBModels.LocTable

        public var langTag: String {
            didSet {
                objectWillChange.send()
            }
        }

        public var locTable: EnkaHSR.DBModels.LocTable {
            didSet {
                objectWillChange.send()
            }
        }

        public var profileAvatars: EnkaHSR.DBModels.ProfileAvatarDict {
            didSet {
                objectWillChange.send()
            }
        }

        public var characters: EnkaHSR.DBModels.CharacterDict {
            didSet {
                objectWillChange.send()
            }
        }

        public var meta: EnkaHSR.DBModels.Meta {
            didSet {
                objectWillChange.send()
            }
        }

        public var skillRanks: EnkaHSR.DBModels.SkillRanksDict {
            didSet {
                objectWillChange.send()
            }
        }

        public var artifacts: EnkaHSR.DBModels.ArtifactsDict {
            didSet {
                objectWillChange.send()
            }
        }

        public var skills: EnkaHSR.DBModels.SkillsDict {
            didSet {
                objectWillChange.send()
            }
        }

        public var skillTrees: EnkaHSR.DBModels.SkillTreesDict {
            didSet {
                objectWillChange.send()
            }
        }

        public var weapons: EnkaHSR.DBModels.WeaponsDict {
            didSet {
                objectWillChange.send()
            }
        }

        public var isExpired: Bool = false {
            didSet {
                objectWillChange.send()
            }
        }

        public static func sanitizeLangTag(_ target: some StringProtocol) -> String {
            var target = target.lowercased()
            if target.prefix(2) == "zh" {
                if target.contains("cht") || target.contains("hant") {
                    target = "zh-tw"
                } else if target.contains("chs") || target.contains("hans") {
                    target = "zh-cn"
                }
            }
            if !Self.allowedLangTags.contains(target) {
                target = "en"
            }
            return target
        }

        public func update(new: EnkaHSR.EnkaDB) {
            langTag = new.langTag
            locTable = new.locTable
            profileAvatars = new.profileAvatars
            characters = new.characters
            meta = new.meta
            skillRanks = new.skillRanks
            artifacts = new.artifacts
            skills = new.skills
            skillTrees = new.skillTrees
            weapons = new.weapons
            refreshRealNameTable()
            isExpired = false
        }

        public func refreshRealNameTable() {
            let locTablesRN = try? EnkaHSR.JSONType.realNameTable.bundledJSONData
                .assertedParseAs(EnkaHSR.DBModels.RawLocTables.self)
            realNameTable = locTablesRN?[langTag] ?? [:]
        }
    }
}

// MARK: - EnkaHSR.EnkaDB.ExtraTerms

extension EnkaHSR.EnkaDB {
    public struct ExtraTerms: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(lang: String = Locale.langCodeForEnkaAPI) {
            let lang = EnkaHSR.EnkaDB.sanitizeLangTag(lang)
            self.langTag = lang
            self.levelName = Self.charLevelNameDict[lang] ?? "Lv."
            self.constellationName = Self.constellationDict[lang] ?? "Cons."
            self.artifactRatingName = Self.artifactRatingNameDict[lang] ?? "Artifact Compatibility Rate"
            self.artifactRatingUnit = Self.artifactRatingUnitDict[lang] ?? "pt"
        }

        // MARK: Public

        public static let constellationDict: [String: String] = [
            "en": "Eidolon Resonance",
            "fr": "Résona. d'Eidolon",
            "ja": "星魂同調",
            "ko": "성혼 동조",
            "ru": "Эйдолоны",
            "vi": "Tinh Hồn Đồng Điệu",
            "zh-cn": "星魂同调",
            "zh-tw": "星魂同調",
        ]

        public static let charLevelNameDict: [String: String] = [
            "en": "Level",
            "fr": "Level",
            "ja": "レベル",
            "ko": "레벨",
            "ru": "Уровень",
            "vi": "Cấp",
            "zh-cn": "等级",
            "zh-tw": "等級",
        ]

        public static let artifactRatingNameDict: [String: String] = [
            "en": "Artifact Compatibility",
            "fr": "Compatibilité des artefacts",
            "ja": "聖遺物互換性",
            "ko": "유물 호환성 비율",
            "ru": "Совместимость Артефактов",
            "vi": "Tỷ lệ tương thích hiện vật",
            "zh-cn": "圣遗物契合度",
            "zh-tw": "聖遺物契合度",
        ]

        public static let artifactRatingUnitDict: [String: String] = [
            "en": "pt",
            "fr": "pt",
            "ja": "点",
            "ko": "pt",
            "ru": "pt",
            "vi": "pt",
            "zh-cn": "分",
            "zh-tw": "分",
        ]

        public let langTag: String
        public let levelName: String
        public let constellationName: String
        public let artifactRatingName: String
        public let artifactRatingUnit: String
    }
}
