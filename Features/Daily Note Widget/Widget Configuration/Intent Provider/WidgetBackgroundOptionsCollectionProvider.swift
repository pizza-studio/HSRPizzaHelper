//
//  WidgetBackgroundOptionsCollectionProvider.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import Intents
import SwifterSwift

/// An enum providing functions to retrieve an array of `WidgetBackground`s.
enum WidgetBackgroundOptionsProvider {
    // MARK: Internal

    /// Provides an array of `WidgetBackground`s from the bundle and documents directory.
    /// - Parameter folderName: The name of the folder where the `WidgetBackground`s are stored.
    /// - Throws: An `NSError` if no folder with the given `folderName` in the bundle is found.
    /// - Returns: An array of `WidgetBackground`s.
    static func provideBackgroundOptionsCollection(folderName: String) throws -> [WidgetBackground] {
        var options: [WidgetBackground] = []

        let bundleBackgroundFolderUrl = try Self.bundleBackgroundFolderUrl(folderName: folderName)
        let bundleBackgroundOptions = try getWidgetBackgroundOptionsCollectionFromFolder(in: bundleBackgroundFolderUrl)
        options.append(contentsOf: bundleBackgroundOptions)

        let documentsBackgroundFolderUrl = try Self.documentBackgroundFolderUrl(folderName: folderName)
        let documentsBackgroundOptions =
            try getWidgetBackgroundOptionsCollectionFromFolder(in: documentsBackgroundFolderUrl)
        options.append(contentsOf: documentsBackgroundOptions)
        return options
    }

    /// Retrieves an array of `URL`s of `WidgetBackground`s in the given folder.
    /// - Parameter imageFolderUrl: The URL of the folder where the `WidgetBackground`s are stored.
    /// - Throws: An error if contents of the directory at the `imageFolderUrl` cannot be retrieved.
    /// - Returns: An array of `URL`s of `WidgetBackground`s.
    static func getWidgetBackgroundUrlsFromFolder(in imageFolderUrl: URL) throws -> [URL] {
        let imageUrls = try FileManager.default.contentsOfDirectory(
            at: imageFolderUrl,
            includingPropertiesForKeys: nil
        )
        return imageUrls
    }

    /// Retrieves the URL of the folder where the `WidgetBackground`s are stored in the bundle.
    /// - Parameter folderName: The name of the folder where the `WidgetBackground`s are stored.
    /// - Throws: An `NSError` if no folder with the given `folderName` in the bundle is found.
    /// - Returns: The URL of the folder where the `WidgetBackground`s are stored in the bundle.
    static func bundleBackgroundFolderUrl(folderName: String) throws -> URL {
        guard let bundleBackgroundFolderUrl = Bundle.main.url(
            forResource: folderName,
            withExtension: nil,
            subdirectory: AppConfig.backgroundImageFolderName
        ) else {
            throw NSError(
                domain: NSCocoaErrorDomain,
                code: NSFileNoSuchFileError,
                userInfo: [NSFilePathErrorKey: folderName]
            )
        }
        return bundleBackgroundFolderUrl
    }

    /// Retrieves the URL of the folder where the `WidgetBackground`s are stored in the documents directory.
    /// - Parameter folderName: The name of the folder where the `WidgetBackground`s are stored.
    /// - Returns: The URL of the folder where the `WidgetBackground`s are stored in the documents directory.
    static func documentBackgroundFolderUrl(folderName: String) throws -> URL {
        let backgroundFolderUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppConfig.appGroupID)!
            .appendingPathComponent(AppConfig.backgroundImageFolderName, isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(
            at: backgroundFolderUrl,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderUrl
    }

    // MARK: Private

    /// Retrieves an array of `WidgetBackground`s from the given folder.
    /// - Parameter imageFolderUrl: The URL of the folder where the `WidgetBackground`s are stored.
    /// - Throws: An error if contents of the directory at the `imageFolderUrl` cannot be retrieved.
    /// - Returns: An array of `WidgetBackground`s.
    private static func getWidgetBackgroundOptionsCollectionFromFolder(in imageFolderUrl: URL) throws
        -> [WidgetBackground] {
        let imageUrls = try getWidgetBackgroundUrlsFromFolder(in: imageFolderUrl)
        let widgetBackgroundOptionsCollection = imageUrls.map { url in
            WidgetBackground(
                identifier: url.lastPathComponent,
                display: url.deletingPathExtension().lastPathComponent
                    .localized(comment: "key is the file name: Widget_Background_xxx")
            )
        }
        return widgetBackgroundOptionsCollection
    }
}
