// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation
import SwiftUI

// MARK: - Wallpaper

public enum Wallpaper: Int, CaseIterable {
    case namelessJourney = 221000
    case ingeniumDreams = 221001
    case conductorsTreat = 221002
    case starfireParkland = 221003
    case planetOfFestivities = 221004
    case cosmodyssey = 221005
}

// MARK: _DefaultsSerializable

extension Wallpaper: _DefaultsSerializable {}

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
extension Wallpaper {
    private static let langDB: [String: String] = {
        let url = Bundle.module.url(forResource: "Wallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    public var localizedTitle: String {
        Self.langDB[rawValue.description] ?? String(describing: self)
    }

    public var imageData: CGImage {
        EnkaHSR.queryImageAsset(for: "WP\(rawValue)")!
    }
}

// swiftlint:enable force_try
// swiftlint:enable force_unwrapping
