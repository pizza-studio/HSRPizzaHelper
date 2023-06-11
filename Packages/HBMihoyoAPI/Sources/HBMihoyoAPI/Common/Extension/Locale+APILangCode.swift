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
        switch Bundle.main.preferredLocalizations.first {
        case "zh-Hans":
            return "zh-cn"
        case "zh-Hant":
            return "zh-tw"
        case "en":
            return "en-us"
        case "ja":
            return "ja-jp"
        default:
            return "en-us"
        }
    }
}
