//
//  ReviewHandler.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/5.
//  用于弹出App Store评分弹窗

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
        UserDefaults.standard.set(nil, forKey: "lastVersionPromptedForReviewKey")
        #endif
        DispatchQueue.main.async {
            // Keep track of the most recent app version that prompts the user for a review.
            let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReviewKey")

            // Get the current bundle version for the app.
            let infoDictionaryKey = kCFBundleVersionKey as String
            guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary.") }
            // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
            if currentVersion != lastVersionPromptedForReview {
                if let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive
                    }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                    UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReviewKey")
                }
            }
        }
    }

    static func requestReviewIfNotRequestedElseNavigateToAppStore() {
        let lastVersionPromptedForReview = UserDefaults.standard
            .string(forKey: "lastVersionPromptedForReviewKey")
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main
            .object(forInfoDictionaryKey: infoDictionaryKey) as? String
        else { fatalError("Expected to find a bundle version in the info dictionary.") }
        // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
        if currentVersion != lastVersionPromptedForReview {
            ReviewHandler.requestReview()
        } else {
            guard let writeReviewURL =
                URL(string: "https://apps.apple.com/app/id1635319193?action=write-review")
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}
