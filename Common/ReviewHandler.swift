//
//  ReviewHandler.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/5.
//  用于弹出App Store评分弹窗

import Defaults
import DefaultsKeys
import Foundation
import StoreKit
import SwiftUI

class ReviewHandler {
    // MARK: Lifecycle

//    static func requestReview() {
//        DispatchQueue.main.async {
//            if let scene = UIApplication.shared.connectedScenes
//                .first(where: { $0.activationState == .foregroundActive
//                }) as? UIWindowScene {
//                SKStoreReviewController.requestReview(in: scene)
//            }
//        }
//    }
    private init() {}

    // MARK: Internal

    static func requestReview() {
        #if DEBUG
        Defaults[.lastVersionPromptedForReview] = nil
        #endif
        DispatchQueue.main.async {
            // Keep track of the most recent app version that prompts the user for a review.
            let lastVersionPromptedForReview = Defaults[.lastVersionPromptedForReview]

            // Get the current bundle version for the app.
            let infoDictionaryKey: String = kCFBundleVersionKey as String
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey)
            guard let currentVersion = currentVersion as? String else {
                fatalError("Expected to find a bundle version in the info dictionary.")
            }
            // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
            if currentVersion != lastVersionPromptedForReview {
                if let windowScene = getCurrentUIWindowScene() {
                    SKStoreReviewController.requestReview(in: windowScene)
                    Defaults[.lastVersionPromptedForReview] = currentVersion
                }
            }
        }
    }

    static func requestReviewIfNotRequestedElseNavigateToAppStore() {
        let lastVersionPromptedForReview = Defaults[.lastVersionPromptedForReview]
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main
            .object(forInfoDictionaryKey: infoDictionaryKey) as? String
        else { fatalError("Expected to find a bundle version in the info dictionary.") }
        // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
        if currentVersion != lastVersionPromptedForReview {
            ReviewHandler.requestReview()
        } else {
            guard let writeReviewURL =
                URL(string: "https://apps.apple.com/app/id6448894222?action=write-review")
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }

    // MARK: Private

    private static func getCurrentUIWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}
