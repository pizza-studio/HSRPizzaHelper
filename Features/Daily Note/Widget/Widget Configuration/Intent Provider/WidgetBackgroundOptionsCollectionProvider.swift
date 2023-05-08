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

    static func provideBackgroundOptionsCollection(bundleFolder: String, documentsFolder: String) throws
        -> [WidgetBackground] {
        guard let bundleBackgroundFolderUrl = Bundle.main.url(
            forResource: bundleFolder,
            withExtension: nil,
            subdirectory: "Background Images"
        ) else {
            throw NSError(
                domain: NSCocoaErrorDomain,
                code: NSFileNoSuchFileError,
                userInfo: [NSFilePathErrorKey: bundleFolder]
            )
        }
        var options: [WidgetBackground] = []
        let bundleBackgroundOptions = try getWidgetBackgroundOptionsCollectionFromFolder(in: bundleBackgroundFolderUrl)
        options.append(contentsOf: bundleBackgroundOptions)
        // TODO: customize dictionary
//        let documentsFolderBackgroundOptions =
//            try getWidgetBackgroundOptionsCollectionFromFolder(in: bundleBackgroundFolderUrl)
        return options
    }

    // MARK: Private

    private static func getWidgetBackgroundOptionsCollectionFromFolder(in imageFolderUrl: URL) throws
        -> [WidgetBackground] {
        let imageUrls = try FileManager.default.contentsOfDirectory(at: imageFolderUrl, includingPropertiesForKeys: nil)
        let widgetBackgroundOptionsCollection = imageUrls.map { url in
            let squareWidgetBackground = WidgetBackground(
                identifier: url.deletingPathExtension().lastPathComponent,
                display: url.deletingPathExtension().lastPathComponent
                    .localized(comment: "key like: widget.background.filename")
            )
            squareWidgetBackground.backgroundImageUrl = url
            return squareWidgetBackground
        }
        return widgetBackgroundOptionsCollection
    }
}
