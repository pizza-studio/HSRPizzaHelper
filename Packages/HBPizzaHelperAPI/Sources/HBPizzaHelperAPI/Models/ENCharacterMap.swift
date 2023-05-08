//
//  ENCharacterMap.swift
//
//
//  Created by Bill Haku on 2023/3/27.
//

import Foundation

// MARK: - ENCharacterMap

// swiftlint:disable identifier_name
public struct ENCharacterMap: Codable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CharacterKey.self)

        var character = [String: Character]()
        for key in container.allKeys {
            if let model = try? container.decode(Character.self, forKey: key) {
                character[key.stringValue] = model
            }
        }
        self.characterDetails = character
    }

    // MARK: Public

    public struct CharacterKey: CodingKey {
        // MARK: Lifecycle

        public init?(stringValue: String) {
            self.stringValue = stringValue
        }

        public init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        // MARK: Public

        public var stringValue: String
        public var intValue: Int?
    }

    public struct Character: Codable {
        public struct Skill: Codable {
            // MARK: Lifecycle

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: SkillKey.self)

                var skill = [String: String]()
                for key in container.allKeys {
                    if let model = try? container.decode(
                        String.self,
                        forKey: key
                    ) {
                        skill[key.stringValue] = model
                    }
                }
                self.skillData = skill
            }

            // MARK: Public

            public struct SkillKey: CodingKey {
                // MARK: Lifecycle

                public init?(stringValue: String) {
                    self.stringValue = stringValue
                }

                public init?(intValue: Int) {
                    self.stringValue = "\(intValue)"
                    self.intValue = intValue
                }

                // MARK: Public

                public var stringValue: String
                public var intValue: Int?
            }

            public var skillData: [String: String]
        }

        public struct ProudMap: Codable {
            // MARK: Lifecycle

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: ProudKey.self)

                var proud = [String: Int]()
                for key in container.allKeys {
                    if let model = try? container
                        .decode(Int.self, forKey: key) {
                        proud[key.stringValue] = model
                    }
                }
                self.proudMapData = proud
            }

            // MARK: Public

            public struct ProudKey: CodingKey {
                // MARK: Lifecycle

                public init?(stringValue: String) {
                    self.stringValue = stringValue
                }

                public init?(intValue: Int) {
                    self.stringValue = "\(intValue)"
                    self.intValue = intValue
                }

                // MARK: Public

                public var stringValue: String
                public var intValue: Int?
            }

            public var proudMapData: [String: Int]
        }

        /// 元素
        public var Element: String
        /// 技能图标
        public var Consts: [String]
        /// 技能顺序
        public var SkillOrder: [Int]
        /// 技能
        public var Skills: Skill
        /// 与命之座有关的技能加成资料?
        public var ProudMap: ProudMap
        /// 名字的hashmap
        public var NameTextMapHash: Int
        /// 侧脸图
        public var SideIconName: String
        /// 星级
        public var QualityType: String

        /// 正脸图
        public var iconString: String {
            SideIconName.replacingOccurrences(of: "_Side", with: "")
        }

        /// icon用的名字
        public var nameID: String {
            iconString.replacingOccurrences(of: "UI_AvatarIcon_", with: "")
        }

        /// 检测是否是主角兄妹当中的某位。都不是的话则返回 nil。
        /// 是 Hotaru 則返回 true，是 Sora 則返回 false。
        public var isLumine: Bool? {
            switch nameID {
            case "PlayerGirl": return true
            case "PlayerBoy": return false
            default: return nil
            }
        }

        /// 名片
        public var namecardIconString: String {
            // 主角没有对应名片
            if nameID == "PlayerGirl" || nameID == "PlayerBoy" {
                return "UI_NameCardPic_Bp2_P"
            } else if nameID == "Yae" {
                return "UI_NameCardPic_Yae1_P"
            } else {
                return "UI_NameCardPic_\(nameID)_P"
            }
        }
    }

    public var characterDetails: [String: Character]
}

extension Dictionary
    where Key == String, Value == ENCharacterMap.Character {
    public func getIconString(id: String) -> String {
        self[id]?.iconString ?? ""
    }

    public func getSideIconString(id: String) -> String {
        self[id]?.SideIconName ?? ""
    }

    public func getNameID(id: String) -> String {
        self[id]?.nameID ?? ""
    }
}
