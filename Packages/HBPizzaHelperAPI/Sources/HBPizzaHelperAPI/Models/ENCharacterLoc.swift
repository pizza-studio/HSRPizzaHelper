//
//  ENCharacterLoc.swift
//
//
//  Created by Bill Haku on 2023/3/27.
//

import Foundation

// swiftlint:disable identifier_name
public struct ENCharacterLoc: Codable {
    // MARK: Public

    public struct LocDict: Codable {
        // MARK: Lifecycle

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: LocKey.self)

            var contentDict = [String: String]()
            for key in container.allKeys {
                if let model = try? container.decode(String.self, forKey: key) {
                    contentDict[key.stringValue] = model
                }
            }
            self.content = contentDict
        }

        // MARK: Public

        public struct LocKey: CodingKey {
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

        public var content: [String: String]
    }

    public var en: LocDict
    public var ru: LocDict
    public var vi: LocDict
    public var th: LocDict
    public var pt: LocDict
    public var ko: LocDict
    public var ja: LocDict
    public var id: LocDict
    public var fr: LocDict
    public var es: LocDict
    public var de: LocDict
    public var zh_tw: LocDict
    public var zh_cn: LocDict

    public func getLocalizedDictionary() -> [String: String] {
        switch Bundle.main.preferredLocalizations.first {
        case "zh-CN", "zh-Hans":
            return zh_cn.content
        case "zh-Hant", "zh-Hant-HK", "zh-Hant-TW", "zh-HK", "zh-TW":
            return zh_tw.content
        case "en":
            return en.content
        case "ja":
            return ja.content
        case "fr":
            return fr.content
        case "ru":
            return ru.content
        case "vi":
            return vi.content
        default:
            return en.content
        }
    }

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case en, ru, vi, th, pt, ko, ja, id, fr, es, de
        case zh_tw = "zh-TW"
        case zh_cn = "zh-CN"
    }
}
