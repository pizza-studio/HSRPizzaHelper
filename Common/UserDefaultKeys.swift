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

    /// A `DefaultsKey` representing the version of the app for which the user was prompted to leave a review
    var lastVersionPromptedForReview: DefaultsKey<String?> {
        .init("lastVersionPromptedForReview")
    }

    /// A `DefaultsKey` representing whether the user has seen a policy agreement screen
    var isPolicyShown: DefaultsKey<Bool> {
        .init("isPolicyShown", defaultValue: false)
    }

    /// A `DefaultsKey` representing whether the user has seen a policy agreement screen
    var checkedNewestVersion: DefaultsKey<Int> {
        .init("checkedNewestVersion", defaultValue: 0)
    }

    /// A `DefaultsKey` representing whether the user has seen a policy agreement screen
    var checkedUpdateVersions: DefaultsKey<[Int]> {
        .init("checkedUpdateVersions", defaultValue: [])
    }

    // MARK: - For widgets
}
