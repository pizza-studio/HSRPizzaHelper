//
//  AppConfig.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation

// MARK: - AppConfig

/// A namespace for storing the app configuration variables
enum AppConfig {
    // MARK: Internal

    /// A string representing the App Group identifier
    static let appGroupID: String = "group.Canglong.HSRPizzaHelper"

    /// The name of folder which stores all background image
    static let backgroundImageFolderName: String = "background_image"

    static let rectangularBackgroundImageFolderName: String = "rectangular_widget_background"

    static let squareBackgroundImageFolderName: String = "square_widget_background"

    // This can be used to add debug statements.
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var appConfiguration: AppConfiguration {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }

    // MARK: Private

    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?
        .lastPathComponent == "sandboxReceipt"
}

// MARK: - AppConfiguration

enum AppConfiguration {
    case debug
    case testFlight
    case appStore
}
