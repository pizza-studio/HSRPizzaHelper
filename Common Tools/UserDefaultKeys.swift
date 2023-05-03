//
//  UserDefaultKeys.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import SwiftyUserDefaults

// Store all value in App Group user default.
// swiftlint:disable identifier_name
var Defaults = DefaultsAdapter<DefaultsKeys>(
    defaults: UserDefaults(suiteName: AppConfig.appGroupID)!,
    keyStore: .init()
)
// swiftlint:enable identifier_name

extension DefaultsKeys {
    var example: DefaultsKey<String> { .init("example", defaultValue: "Hello World!") }

    // MARK: - In app

    // MARK: - For widgets
}
