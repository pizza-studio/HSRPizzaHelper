//
//  UserDefaultKeys.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import SwiftyUserDefaults

// Store all value in App Group user default.
var Defaults = DefaultsAdapter<DefaultsKeys>(
    // swiftlint:disable:next force_unwrapping
    defaults: UserDefaults(suiteName: AppConfig.appGroupID)!,
    keyStore: .init()
)

extension DefaultsKeys {
    var example: DefaultsKey<String> { .init("example", defaultValue: "Hello World!") }

    // MARK: - In app
    var lastVersionPromptedForReview: DefaultsKey<String?> {
        .init("lastVersionPromptedForReview")
    }

    var isPolicyShown: DefaultsKey<Bool> {
        .init("isPolicyShown", defaultValue: false)
    }

    // MARK: - For widgets
}
