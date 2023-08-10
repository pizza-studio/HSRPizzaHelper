//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

extension Locale {
    /// Get the language code used for miHoYo API according to current preferred localization.
    public static var miHoYoAPILanguage: MiHoYoAPILanguage {
        switch Bundle.main.preferredLocalizations.first {
        case "zh-Hans":
            return .chineseSimplified
        case "zh-Hant":
            return .chineseTraditional
        case "en":
            return .englishUS
        case "ja":
            return .japanese
        case "ru":
            return .russian
        case "vi":
            return .vietnamese
        case "es":
            return .spanish
        default:
            return .englishUS
        }
    }
}
