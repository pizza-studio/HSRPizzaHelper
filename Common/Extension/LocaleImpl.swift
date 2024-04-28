// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

//  检测当前介面语言是否是简体中文或繁体中文，以及在这种情况下的一些特殊操作。

import Defaults
import Foundation

extension Locale {
    public static var isUILanguagePanChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.prefix(3).description == "zh-"
    }

    public static var isUILanguageJapanese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.prefix(2).description == "ja"
    }

    public static var isUILanguageSimplifiedChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.contains("zh-Hans") || firstLocale.contains("zh-CN")
    }

    public static var isUILanguageTraditionalChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.contains("zh-Hant") || firstLocale
            .contains("zh-TW") || firstLocale.contains("zh-HK")
    }
}
