//
//  GachaLocalizationMap.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/10.
//

import Foundation
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

    public func getLocalizedName(
        id: String, type: GachaItem.ItemType,
        langOverride: GachaLanguageCode? = nil
    )
        -> String? {
        guard let meta = getMeta(id: id, type: type) else { return nil }
        return meta.nameLocalizationMap[langOverride ?? Locale.gachaLangauge]!
    }

    #if canImport(UIKit)
    public func getIcon(id: String, type: GachaItem.ItemType) -> UIImage? {
        guard let meta = getMeta(id: id, type: type) else { return nil }
        return meta.icon
    }

    #elseif canImport(AppKit)
    public func getIcon(id: String, type: GachaItem.ItemType) -> NSImage? {
        guard let meta = getMeta(id: id, type: type) else { return nil }
        return meta.icon
    }
    #endif

    // MARK: Private

    private lazy var meta: GachaMeta = {
        let url = Bundle.module.url(
            forResource: SPMConfig.gachaMetaIndexFileName, withExtension: nil
        )
        // swiftlint:disable force_try
        let data = try! Data(contentsOf: url!)
        return try! JSONDecoder().decode(GachaMeta.self, from: data)
        // swiftlint:enable force_try
    }()

    private func getMeta(id: String, type: GachaItem.ItemType) -> ItemMeta? {
        switch type {
        case .lightCones:
            return meta.lightCone[id]
        case .characters:
            return meta.character[id]
        }
    }
}

// MARK: - ItemMeta

private protocol ItemMeta {
    var nameLocalizationMap: [GachaLanguageCode: String] { get }
    var rank: GachaItem.Rank { get }
    var iconFilePath: String { get }
}

extension ItemMeta {
    #if canImport(UIKit)
    public var icon: UIImage? {
        UIImage(data: iconData ?? .init([11, 4, 51, 4]))
    }

    #elseif canImport(AppKit)
    public var icon: NSImage? {
        NSImage(data: iconData ?? .init([11, 4, 51, 4]))
    }
    #endif

    private var iconData: Data? {
        var data: Data = .init([11, 4, 51, 4]) // 垃圾数据，垫底用。UIImage 读了会出 nil。
        if iconFilePath.contains("character") {
            let charIconFilePath = iconFilePath.replacingOccurrences(of: "character", with: "avatar")
            let url = Bundle.main.url(
                forResource: charIconFilePath, withExtension: nil,
                subdirectory: SPMConfig.otherMetaFolderName
            )
            if let url = url, let newData = try? Data(contentsOf: url) { data = newData }
        } else {
            let url2 = Bundle.main.url(
                forResource: iconFilePath, withExtension: nil,
                subdirectory: SPMConfig.gachaMetaFolderName
            )
            if let url = url2, let newData = try? Data(contentsOf: url) { data = newData }
        }
        return data
    }
}

// MARK: - GachaMeta

private struct GachaMeta: Decodable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.character = try container.decode([String: GachaMeta.Character].self, forKey: .character)
        self.lightCone = try container.decode([String: GachaMeta.LightCone].self, forKey: .lightCone)
    }

    // MARK: Internal

    struct Character: Decodable, ItemMeta {
        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GachaMeta.Character.CodingKeys> = try decoder
                .container(keyedBy: GachaMeta.Character.CodingKeys.self)
            let nameLocalizationMap = try container.decode(
                [String: String].self,
                forKey: GachaMeta.Character.CodingKeys.nameLocalizationMap
            )
            self.nameLocalizationMap = Dictionary(uniqueKeysWithValues: nameLocalizationMap.map { key, value in
                (GachaLanguageCode(rawValue: key) ?? .enUS, value)
            })
            self.iconFilePath = try container.decode(String.self, forKey: GachaMeta.Character.CodingKeys.iconFilePath)
            self.rank = try container.decode(GachaItem.Rank.self, forKey: GachaMeta.Character.CodingKeys.rank)
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case nameLocalizationMap = "name_localization_map"
            case iconFilePath = "icon_file_path"
            case rank
        }

        let nameLocalizationMap: [GachaLanguageCode: String]
        let rank: GachaItem.Rank

        // MARK: Fileprivate

        fileprivate let iconFilePath: String
    }

    struct LightCone: Decodable, ItemMeta {
        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GachaMeta.LightCone.CodingKeys> = try decoder
                .container(keyedBy: GachaMeta.LightCone.CodingKeys.self)
            let nameLocalizationMap = try container.decode(
                [String: String].self,
                forKey: GachaMeta.LightCone.CodingKeys.nameLocalizationMap
            )
            self.nameLocalizationMap = Dictionary(uniqueKeysWithValues: nameLocalizationMap.map { key, value in
                (GachaLanguageCode(rawValue: key) ?? .enUS, value)
            })
            self.iconFilePath = try container.decode(String.self, forKey: GachaMeta.LightCone.CodingKeys.iconFilePath)
            self.rank = try container.decode(GachaItem.Rank.self, forKey: GachaMeta.LightCone.CodingKeys.rank)
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case nameLocalizationMap = "name_localization_map"
            case iconFilePath = "icon_file_path"
            case rank
        }

        let nameLocalizationMap: [GachaLanguageCode: String]
        let rank: GachaItem.Rank

        // MARK: Fileprivate

        fileprivate let iconFilePath: String
    }

    enum CodingKeys: String, CodingKey {
        case character
        case lightCone = "light_cone"
    }

    let character: [String: Character]
    let lightCone: [String: LightCone]
}
