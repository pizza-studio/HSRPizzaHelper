//
//  UserDefaultKeys.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import SwiftUI
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

    var widgetTimelineLatestStartAppRefreshTime: DefaultsKey<Date?> {
        .init("widgetTimelineLatestUpdatedOnAppearOfApp")
    }

    var widgetRefreshFrequencyInHour: DefaultsKey<Double> {
        .init("widgetRefreshFrequencyInHour", defaultValue: 5.0)
    }
}

// MARK: - ObservableSwiftyUserDefault

class ObservableSwiftyUserDefault<T: DefaultsSerializable>: ObservableObject
    where T.T == T {
    // MARK: Lifecycle

    init(keyPath: KeyPath<DefaultsKeys, DefaultsKey<T>>) {
        self._value = SwiftyUserDefault(keyPath: keyPath, adapter: Defaults)
    }

    // MARK: Internal

    @SwiftyUserDefault var value: T {
        didSet {
            objectWillChange.send()
        }
    }
}
