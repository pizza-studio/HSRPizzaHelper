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

/// An extension of `CanProvideWidgetBackground` protocol to add functionality of returning the background image.
extension CanProvideWidgetBackground {
    /// Returns the background image.
    /// - Returns: An optional `Image` object representing the background image.
    func backgroundImage() -> Image? {
        // Get the URLs for bundle and document background folders and the identifier of the background.
        guard let bundleBackgroundFolderUrl = try? bundleBackgroundFolderUrl(),
              let documentBackgroundFolderUrl = try? documentBackgroundFolderUrl(),
              let filename = background.identifier
        else {
            return nil
        }

        // Find the URL of the folder containing the image.
        let url = findFolderURLWithImage(
            name: filename,
            inFolders: [bundleBackgroundFolderUrl, documentBackgroundFolderUrl]
        )

        // If a URL is found, try to load and resize the image.
        if let url = url,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data)?.resized() {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
}

// MARK: - ContainingWidgetBackground

/// A protocol to be implemented by objects that contain a background folder.
protocol ContainingWidgetBackground {
    /// The name of the background folder.
    var backgroundFolderName: String { get }
}

// MARK: - ContainingWidgetBackground

/// An extension of `ContainingWidgetBackground` protocol to add functionality of returning the URLs
/// for the bundle and document background folders and all available widget backgrounds.
extension ContainingWidgetBackground {
    /// Returns an array of all available widget backgrounds.
    /// - Returns: An array of `WidgetBackground` objects representing all available widget backgrounds.
    func allAvailableBackgroundsOptions() throws -> [WidgetBackground] {
        try WidgetBackgroundOptionsProvider.provideBackgroundOptionsCollection(folderName: backgroundFolderName)
    }

    /// Returns the URL of the bundle background folder.
    /// - Returns: A `URL` object representing the URL of the bundle background folder.
    func bundleBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.bundleBackgroundFolderUrl(folderName: backgroundFolderName)
    }

    /// Returns the URL of the document background folder.
    /// - Returns: A `URL` object representing the URL of the document background folder.
    func documentBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.documentBackgroundFolderUrl(folderName: backgroundFolderName)
    }
}

// MARK: - StaticContainingProvideWidgetBackground

/// A protocol to be implemented by static objects that provide a background folder.
protocol StaticContainingProvideWidgetBackground {
    /// The name of the background folder.
    static var backgroundFolderName: String { get }
}

/// An extension of `StaticContainingProvideWidgetBackground` protocol to add functionality of returning the URLs
/// for the bundle and document background folders and all available widget backgrounds.
extension StaticContainingProvideWidgetBackground {
    /// Returns an array of all available widget backgrounds.
    /// - Returns: An array of `WidgetBackground` objects representing all available widget backgrounds.
    static func allAvailableBackgrounds() throws -> [WidgetBackground] {
        try WidgetBackgroundOptionsProvider.provideBackgroundOptionsCollection(folderName: Self.backgroundFolderName)
    }

    /// Returns the URL of the bundle background folder.
    /// - Returns: A `URL` object representing the URL of the bundle background folder.
    static func bundleBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.bundleBackgroundFolderUrl(folderName: Self.backgroundFolderName)
    }

    /// Returns the URL of the document background folder.
    /// - Returns: A `URL` object representing the URL of the document background folder.
    static func documentBackgroundFolderUrl() throws -> URL {
        try WidgetBackgroundOptionsProvider.documentBackgroundFolderUrl(folderName: Self.backgroundFolderName)
    }
}

/// An extension of `ContainingWidgetBackground` protocol to add functionality of returning the `backgroundFolderName`.
extension ContainingWidgetBackground where Self: StaticContainingProvideWidgetBackground {
    /// Returns the `backgroundFolderName`.
    var backgroundFolderName: String {
        Self.backgroundFolderName
    }
}

/// Finds the URL of a folder containing an image with the specified name.
/// - Parameters:
///     - imageName: The name of the image to find.
///     - folders: An array of `URL` objects representing the folders to search for the image.
/// - Returns: The URL of the folder containing the image with the specified name. Returns `nil` if not found.
func findFolderURLWithImage(name imageName: String, inFolders folders: [URL]) -> URL? {
    let fileManager = FileManager.default

    for folderURL in folders {
        do {
            let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            if let url = contents.first(where: { fileUrl in
                fileUrl.lastPathComponent == imageName
            }) {
                return url
            }
        } catch {
            print("Error while enumerating files \(folderURL.path): \(error.localizedDescription)")
        }
    }
    return nil
}

/// An extension of `UIImage` to add functionality of resizing images.
extension UIImage {
    /// Resizes the image to a specified width and height.
    /// - Parameters:
    ///     - width: The width to resize the image to.
    ///     - isOpaque: A boolean indicating whether the resulting image should be opaque or not.
    /// - Returns: A `UIImage` object representing the resized image.
    fileprivate func resized(toWidth width: CGFloat = 860, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(
            size: canvas,
            format: format
        )
        .image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
