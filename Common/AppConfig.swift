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

    static let gachaMetaFolderName: String = "gacha_meta"

    static let rectangularBackgroundImageFolderName: String = "rectangular_widget_background"

    static let squareBackgroundImageFolderName: String = "square_widget_background"

    static let widgetRefreshFrequencyInHour: Double = 2.0

    static let widgetRefreshWhenErrorMinute: Int = 15

    static let enterAppShouldRefreshWidgetAfterMinute: Double = 5.0

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

    static var appLanguage: AppLanguage {
        guard let strFirst = Bundle.main.preferredLocalizations.first else { return .en }
        switch strFirst.prefix(2) {
        case "zh":
            return (strFirst.contains("CN") || strFirst.contains("Hans")) ? .zhcn : .zhtw
        case "en":
            return .en
        case "ja":
            return .ja
        default:
            return .en
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

// MARK: - AppLanguage

// swiftlint:disable identifier_name
enum AppLanguage {
    /// Simplified Chinese
    case zhcn
    /// Traditional Chinese
    case zhtw
    /// English
    case en
    /// Japanese
    case ja
}

// swiftlint:enable identifier_name
