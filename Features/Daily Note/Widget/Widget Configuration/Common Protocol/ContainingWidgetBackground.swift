//
//  CanProvideWidgetBackground.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import SwiftUI

// MARK: - CanProvideWidgetBackground

protocol CanProvideWidgetBackground: ContainingWidgetBackground {
    var background: WidgetBackground { get }
}

extension CanProvideWidgetBackground {
    func backgroundImage() -> Image? {
        try! bundleBackgroundFolderUrl()
        try! documentBackgroundFolderUrl()
        background.identifier!
        guard let bundleBackgroundFolderUrl = try? bundleBackgroundFolderUrl(),
              let documentBackgroundFolderUrl = try? documentBackgroundFolderUrl(),
              let filename = background.identifier
        else {
            return nil
        }
        let url = findFolderURLWithImage(
            name: filename,
            inFolders: [bundleBackgroundFolderUrl, documentBackgroundFolderUrl]
        )

        url!
        try! Data(contentsOf: url!)

        if let url = url,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
}

// MARK: - ContainingWidgetBackground

protocol ContainingWidgetBackground {
    var backgroundFolderName: String { get }
}

extension ContainingWidgetBackground {
    func allAvailableBackgroundsOptions() throws -> [WidgetBackground] {
        try WidgetBackgroundOptionsProvider.provideBackgroundOptionsCollection(folderName: backgroundFolderName)
    }

    func bundleBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.bundleBackgroundFolderUrl(folderName: backgroundFolderName)
    }

    func documentBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.documentBackgroundFolderUrl(folderName: backgroundFolderName)
    }
}

// MARK: - StaticContainingProvideWidgetBackground

protocol StaticContainingProvideWidgetBackground {
    static var backgroundFolderName: String { get }
}

extension StaticContainingProvideWidgetBackground {
    static func allAvailableBackgrounds() throws -> [WidgetBackground] {
        try WidgetBackgroundOptionsProvider.provideBackgroundOptionsCollection(folderName: Self.backgroundFolderName)
    }

    static func bundleBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.bundleBackgroundFolderUrl(folderName: Self.backgroundFolderName)
    }

    static func documentBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.documentBackgroundFolderUrl(folderName: Self.backgroundFolderName)
    }
}

extension ContainingWidgetBackground where Self: StaticContainingProvideWidgetBackground {
    var backgroundFolderName: String {
        Self.backgroundFolderName
    }
}

func findFolderURLWithImage(name imageName: String, inFolders folders: [URL]) -> URL? {
    let fileManager = FileManager.default
    for folderURL in folders {
        do {
            let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            return contents.first { fileUrl in
                fileUrl.lastPathComponent == imageName
            }
        } catch {
            print("Error while enumerating files \(folderURL.path): \(error.localizedDescription)")
        }
    }
    return nil
}
