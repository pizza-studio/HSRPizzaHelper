//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

extension Locale {
    /// Get the language code used for miHoYo API according to current preferred localization.
    public static var langCodeForAPI: String {
        let languageCode = Bundle.main.preferredLocalizations.first ?? "en-us"
        switch languageCode.prefix(2) {
        case "zh": return "zh-cn"
        case "ja": return "ja-jp"
        case "ru": return "ru-ru"
        case "en": return "en-us"
        default: return languageCode
        }
    }
}
