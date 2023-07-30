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
            let container: KeyedDecodingContainer<HSRDictionaryTranslationResult.Translation.CodingKeys> = try decoder
                .container(keyedBy: HSRDictionaryTranslationResult.Translation.CodingKeys.self)
            self.vocabularyId = try container.decode(
                Int.self,
                forKey: HSRDictionaryTranslationResult.Translation.CodingKeys.vocabularyId
            )
            self.target = try container.decode(
                String.self,
                forKey: HSRDictionaryTranslationResult.Translation.CodingKeys.target
            )
            self.targetLanguage = try container.decode(
                DictionaryLanguage.self,
                forKey: HSRDictionaryTranslationResult.Translation.CodingKeys.targetLanguage
            )
            let translationDictionary = try container.decode(
                [String: String].self,
                forKey: HSRDictionaryTranslationResult.Translation.CodingKeys.translationDictionary
            )
            var temp: [DictionaryLanguage: String] = .init()
            for (key, value) in translationDictionary {
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
        case total
        case page
        case pageSize = "page_size"
        case translations
    }

    var total: Int
    var page: Int
    var pageSize: Int
    var translations: [Translation]
}

// MARK: - DictionaryLanguage

enum DictionaryLanguage: String, Decodable {
    case english = "En"
    case portuguese = "Pt"
    case japanese = "Jp"
    case indonesian = "Id"
    case korean = "Kr"
    case thai = "Th"
    case french = "Fr"
    case simplifiedChinese = "Chs"
    case russian = "Ru"
    case german = "De"
    case traditionalChinese = "Cht"
    case spanish = "Es"
    case vietnamese = "Vi"
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
