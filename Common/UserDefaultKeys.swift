//
//  UserDefaultKeys.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import SwiftyUserDefaults

/// An adapter class that handles fetching and storing user defaults values
var Defaults = DefaultsAdapter<DefaultsKeys>(
    // swiftlint:disable:next force_unwrapping
    defaults: UserDefaults(suiteName: AppConfig.appGroupID)!,
    keyStore: .init()
)

/// An extension of `DefaultsKeys` to define the keys to use when getting and setting values in user defaults
extension DefaultsKeys {
    private var example: DefaultsKey<String> {
        .init("example", defaultValue: "Hello World!")
    }

    // MARK: - In app

    /// The version of the app for which the user was prompted to leave a review
    var lastVersionPromptedForReview: DefaultsKey<String?> {
        .init("lastVersionPromptedForReview")
    }

    /// Whether the user has seen a policy agreement screen
    var isPolicyShown: DefaultsKey<Bool> {
        .init("isPolicyShown", defaultValue: false)
    }

    /// The latest version the app checked last time
    var checkedNewestVersion: DefaultsKey<Int> {
        .init("checkedNewestVersion", defaultValue: 0)
    }

    /// The version which update notice has been shown to user
    var checkedUpdateVersions: DefaultsKey<[Int]> {
        .init("checkedUpdateVersions", defaultValue: [])
    }

    // MARK: - For widgets
}
