//
//  StringExtensions.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  Strings 功能扩充。

import Foundation

extension String {
    /// 返回一个无参数String的本地化值。
    var localized: String {
        String(format: NSLocalizedString(self, comment: "namecards"))
    }

    /// 检测是否包含汉字或假名。
    /// Remark: 暂无全形标点检测之功能。
    var containsKanjiOrKana: Bool {
        range(of: #"\p{Script=Han}|\p{Script=Katakana}|\p{Script=Hiragana}"#, options: .regularExpression) != nil
    }
}
