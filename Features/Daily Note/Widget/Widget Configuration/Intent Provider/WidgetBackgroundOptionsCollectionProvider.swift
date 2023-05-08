//
//  WidgetBackgroundOptionsCollectionProvider.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import Intents
import SwifterSwift

enum WidgetBackgroundOptionsProvider {
    // MARK: Internal

    static func provideBackgroundOptionsCollection(folderName: String) throws
        -> [WidgetBackground] {
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

    static func getWidgetBackgroundUrlsFromFolder(in imageFolderUrl: URL) throws
        -> [URL] {
        let imageUrls = try FileManager.default.contentsOfDirectory(at: imageFolderUrl, includingPropertiesForKeys: nil)
        return imageUrls
    }

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

    static func documentBackgroundFolderUrl(folderName: String) throws -> URL {
        let backgroundFolderUrl = URL(
            string: AppConfig.backgroundImageFolderName
        )!.appendingPathComponent(folderName, isDirectory: true)
        let url = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: backgroundFolderUrl,
            create: true
        )
        return url
    }

    // MARK: Private

    private static func getWidgetBackgroundOptionsCollectionFromFolder(in imageFolderUrl: URL) throws
        -> [WidgetBackground] {
        let imageUrls = try getWidgetBackgroundUrlsFromFolder(in: imageFolderUrl)
        let widgetBackgroundOptionsCollection = imageUrls.map { url in
            WidgetBackground(
                identifier: url.lastPathComponent,
                display: url.deletingPathExtension().lastPathComponent
                    .localized(comment: "key like: widget.background.filename")
            )
        }
        return widgetBackgroundOptionsCollection
    }
}
