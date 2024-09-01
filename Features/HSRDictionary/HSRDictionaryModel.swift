//
//  HSRDictionaryModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/30.
//

import Foundation

// MARK: - HSRDictionaryTranslationResult

struct HSRDictionaryTranslationResult: Decodable {
    struct Translation: Decodable, Identifiable {
        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vocabularyId = try container.decode(Int.self, forKey: .vocabularyId)
            self.target = try container.decode(String.self, forKey: .target)
            self.targetLanguage = try container.decode(DictionaryLanguage.self, forKey: .targetLanguage)
            let rawTransMap = try container.decode([String: String].self, forKey: .translationDictionary)
            var temp: [DictionaryLanguage: String] = .init()
            for (key, value) in rawTransMap {
                if let key = DictionaryLanguage(rawValue: key) {
                    temp[key] = value
                }
            }
            self.translationDictionary = temp
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case vocabularyId = "vocabulary_id"
            case target
            case targetLanguage = "target_lang"
            case translationDictionary = "lan_dict"
        }

        let vocabularyId: Int
        let target: String
        let targetLanguage: DictionaryLanguage
        let translationDictionary: [DictionaryLanguage: String]

        var id: Int { vocabularyId }
    }

    enum CodingKeys: String, CodingKey {
        case totalPage = "total_page"
        case translations = "results"
    }

    var totalPage: Int
    var translations: [Translation]
}

// MARK: - DictionaryLanguage

enum DictionaryLanguage: String, Decodable {
    case english = "en"
    case portuguese = "pt"
    case japanese = "jp"
    case indonesian = "id"
    case korean = "kr"
    case thai = "th"
    case french = "fr"
    case simplifiedChinese = "chs"
    case russian = "ru"
    case german = "de"
    case traditionalChinese = "cht"
    case spanish = "es"
    case vietnamese = "vi"
}

// MARK: CustomStringConvertible

extension DictionaryLanguage: CustomStringConvertible {
    var description: String {
        switch self {
        case .english:
            return "tool.dictionary.language.english".localized()
        case .portuguese:
            return "tool.dictionary.language.portuguese".localized()
        case .japanese:
            return "tool.dictionary.language.japanese".localized()
        case .indonesian:
            return "tool.dictionary.language.indonesian".localized()
        case .korean:
            return "tool.dictionary.language.korean".localized()
        case .thai:
            return "tool.dictionary.language.thai".localized()
        case .french:
            return "tool.dictionary.language.french".localized()
        case .simplifiedChinese:
            return "tool.dictionary.language.simplified_chinese".localized()
        case .russian:
            return "tool.dictionary.language.russian".localized()
        case .german:
            return "tool.dictionary.language.german".localized()
        case .traditionalChinese:
            return "tool.dictionary.language.traditional_chinese".localized()
        case .spanish:
            return "tool.dictionary.language.spanish".localized()
        case .vietnamese:
            return "tool.dictionary.language.vietnamese".localized()
        }
    }
}
