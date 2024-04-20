// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Foundation

extension EnkaHSR {
    public class EnkaDB: Codable, ObservableObject {
        // MARK: Lifecycle

        public init(
            locTag: String,
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
        }

        /// Use bundled resources to initiate an EnkaDB instance.
        public init?(locTag: String = Locale.langCodeForEnkaAPI) {
            do {
                let locTables = try EnkaHSR.JSONTypes.locTable.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.RawLocTables.self)
                guard let locTableSpecified = locTables[locTag] else { return nil }
                self.langTag = Self.sanitizeLangTag(locTag)
                self.locTable = locTableSpecified
                self.profileAvatars = try EnkaHSR.JSONTypes.profileAvatarIcons.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.ProfileAvatarDict.self)
                self.characters = try EnkaHSR.JSONTypes.characters.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.CharacterDict.self)
                self.meta = try EnkaHSR.JSONTypes.metadata.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.Meta.self)
                self.skillRanks = try EnkaHSR.JSONTypes.skillRanks.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.SkillRanksDict.self)
                self.artifacts = try EnkaHSR.JSONTypes.artifacts.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.ArtifactsDict.self)
                self.skills = try EnkaHSR.JSONTypes.skills.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.SkillsDict.self)
                self.skillTrees = try EnkaHSR.JSONTypes.skillTrees.bundledJSONData
                    .assertedParseAs(EnkaHSR.DBModels.SkillTreesDict.self)
                self.weapons = try EnkaHSR.JSONTypes.weapons.bundledJSONData
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

        public static func sanitizeLangTag(_ target: some StringProtocol) -> String {
            var target = target.lowercased()
            target = target.replacingOccurrences(of: "cht", with: "zh-tw")
            target = target.replacingOccurrences(of: "chs", with: "zh-cn")
            if !Self.allowedLangTags.contains(target) {
                target = "en"
            }
            return target
        }
    }
}

extension EnkaHSR.EnkaDB {
    public enum ExtraTerms {
        public static let constellation: [String: String] = [
            "en": "Eidolon Resonance",
            "fr": "Résona. d'Eidolon",
            "ja": "星魂同調",
            "ko": "성혼 동조",
            "ru": "Эйдолоны",
            "vi": "Tinh Hồn Đồng Điệu",
            "zh-cn": "星魂同调",
            "zh-tw": "星魂同調",
        ]

        public static let characterLevel: [String: String] = [
            "en": "Level",
            "fr": "Level",
            "ja": "レベル",
            "ko": "레벨",
            "ru": "Уровень",
            "vi": "Cấp",
            "zh-cn": "等级",
            "zh-tw": "等級",
        ]
    }
}
