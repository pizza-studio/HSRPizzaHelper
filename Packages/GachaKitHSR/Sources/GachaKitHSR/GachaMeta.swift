//
//  GachaLocalizationMap.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/10.
//

import EnkaKitHSR
import Foundation
import GachaMetaDB
import HBMihoyoAPI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - SPMConfig

enum SPMConfig {
    static let otherMetaFolderName: String = "other_meta"
    static let gachaMetaFolderName: String = "gacha_meta"
    static let gachaMetaIndexFileName: String = "gacha_meta.json"
}

// MARK: - GachaMetaManager

public class GachaMetaManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public static let shared: GachaMetaManager = .init()

    public func getLocalizedName(id: String, langOverride: GachaLanguageCode? = nil) -> String? {
        guard let meta = getMeta(id: id) else { return nil }
        return meta.l10nMap?[(langOverride ?? Locale.gachaLangauge).rawValue] ?? "ID:\(id)"
    }

    public func getRankType(id: String) -> GachaItem.Rank? {
        guard let initialValue = getMeta(id: id)?.rank else { return nil }
        return .init(rawValue: initialValue.description)
    }

    // MARK: Private

    private func getMeta(id: String) -> ItemMeta? {
        let result = GachaMetaDB.shared.mainDB[id]
        if result == nil {
            Task.detached { @MainActor in
                try? await GachaMetaDBExposed.Sputnik.updateLocalGachaMetaDB()
            }
        }
        return result
    }
}

// MARK: - ItemMeta

private typealias ItemMeta = GachaItemMetadata
