//
//  GachaLocalizationMap.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/10.
//

import Foundation
import HBMihoyoAPI
import UIKit

// MARK: - GachaMetaManager

class GachaMetaManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared: GachaMetaManager = .init()

    func getLocalizedName(id: String, type: GachaItem.ItemType) -> String? {
        guard let meta = getMeta(id: id, type: type) else { return nil }
        return meta.nameLocalizationMap[Locale.miHoYoAPILanguage]!
    }

    func getIcon(id: String, type: GachaItem.ItemType) -> UIImage? {
        guard let meta = getMeta(id: id, type: type) else { return nil }
        return meta.icon
    }

    // MARK: Private

    private lazy var meta: GachaMeta = {
        #if os(OSX) || targetEnvironment(macCatalyst)
        let url = Bundle.main.bundleURL.appendingPathComponent(
            "Contents/Resources/" + AppConfig.gachaMetaFolderName,
            isDirectory: true
        ).appendingPathComponent("gacha_meta", conformingTo: .json)
        #else
        let url = Bundle.main.bundleURL.appendingPathComponent(
            AppConfig.gachaMetaFolderName,
            isDirectory: true
        ).appendingPathComponent("gacha_meta", conformingTo: .json)
        #endif
        // swiftlint:disable force_try
        let data = try! Data(contentsOf: url)
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
    var nameLocalizationMap: [MiHoYoAPILanguage: String] { get }
    var rank: GachaItem.Rank { get }
    var iconFilePath: String { get }
}

extension ItemMeta {
    var icon: UIImage? {
        #if os(OSX) || targetEnvironment(macCatalyst)
        let url = Bundle.main.bundleURL.appendingPathComponent(
            "Contents/Resources/" + AppConfig.gachaMetaFolderName,
            isDirectory: true
        ).appendingPathComponent(iconFilePath, conformingTo: .json)
        #else
        let url = Bundle.main.bundleURL.appendingPathComponent(
            AppConfig.gachaMetaFolderName,
            isDirectory: true
        ).appendingPathComponent(iconFilePath, conformingTo: .json)
        #endif
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
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
                (MiHoYoAPILanguage(rawValue: key)!, value)
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

        let nameLocalizationMap: [MiHoYoAPILanguage: String]
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
                (MiHoYoAPILanguage(rawValue: key)!, value)
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

        let nameLocalizationMap: [MiHoYoAPILanguage: String]
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
