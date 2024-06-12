//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/8.
//

import Defaults
import Foundation

extension UserDefaults {
    // 此处的 suiteName 与 container ID 一致。
    public static let hsrSuite = UserDefaults(suiteName: "group.Canglong.HSRPizzaHelper") ?? .standard
}

extension Defaults.Keys {
    // MARK: - In app

    /// Remembering the most-recent tab index.
    public static let appTabIndex = Key<Int>("appTabIndex", default: 0, suite: .hsrSuite)

    /// Remembering the most-recent tab index.
    public static let restoreTabOnLaunching = Key<Bool>("restoreTabOnLaunching", default: true, suite: .hsrSuite)

    /// The version of the app for which the user was prompted to leave a review
    public static let lastVersionPromptedForReview = Key<String?>(
        "lastVersionPromptedForReview",
        default: nil,
        suite: .hsrSuite
    )

    /// Whether the user has seen a policy agreement screen
    public static let isPolicyShown = Key<Bool>("isPolicyShown", default: false, suite: .hsrSuite)

    /// The latest version the app checked last time
    public static let checkedNewestVersion = Key<Int>("checkedNewestVersion", default: 0, suite: .hsrSuite)

    /// The version which update notice has been shown to user
    public static let checkedUpdateVersions = Key<[Int]>("checkedUpdateVersions", default: [], suite: .hsrSuite)

    /// Whether using Paimon to evaluate the gacha records.
    public static let useGuestGachaEvaluator = Key<Bool>("useGuestGachaEvaluator", default: false, suite: .hsrSuite)

    // MARK: - For widgets

    public static let widgetTimelineLatestStartAppRefreshTime = Key<Date?>(
        "widgetTimelineLatestUpdatedOnAppearOfApp",
        default: nil,
        suite: .hsrSuite
    )
}
