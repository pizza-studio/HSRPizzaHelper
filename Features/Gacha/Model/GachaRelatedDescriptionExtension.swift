//
//  GachaRelatedDescriptionExtension.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/15.
//

import Foundation
import HBMihoyoAPI

// MARK: - GachaError + LocalizedError

#if hasFeature(RetroactiveAttribute)
extension GachaError: @retroactive LocalizedError {}
#else
extension GachaError: LocalizedError {}
#endif

extension GachaError {
    public var errorDescription: String? {
        switch self {
        case let .fetchDataError(page: page, size: size, gachaType: gachaType, error: error):
            return String(
                format: "gacha.gacha_error.error_description.fetch_data_error"
                    .localized(comment: "Error while fetching %@ at page %lld because %@"),
                gachaType.description,
                page,
                size,
                error.localizedDescription
            )
        }
    }
}

// MARK: - ParseGachaURLError + LocalizedError

#if hasFeature(RetroactiveAttribute)
extension ParseGachaURLError: @retroactive LocalizedError {}
#else
extension ParseGachaURLError: LocalizedError {}
#endif

extension ParseGachaURLError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "gacha.parse_gacha_url_error.invalid_url".localized()
        case .noAuthenticationKey:
            return "gacha.parse_gacha_url_error.no_authentication_key".localized()
        case .noAuthenticationKeyVersion:
            return "gacha.parse_gacha_url_error.no_authentication_key_version".localized()
        case .noServer:
            return "gacha.parse_gacha_url_error.no_server".localized()
        case .invalidServer:
            return "gacha.parse_gacha_url_error.invalid_server".localized()
        case .noSignType:
            return "gacha.parse_gacha_url_error.no_sign_type".localized()
        }
    }
}

// MARK: - GachaType + CustomStringConvertible

#if hasFeature(RetroactiveAttribute)
extension GachaType: @retroactive CustomStringConvertible {}
#else
extension GachaType: CustomStringConvertible {}
#endif

extension GachaType {
    public var description: String {
        switch self {
        case .characterEventWarp:
            return "gacha.gacha_type.character_event_warp".localized()
        case .lightConeEventWarp:
            return "gacha.gacha_type.lightCon_event_warp".localized()
        case .stellarWarp:
            return "gacha.gacha_type.stellar_warp".localized()
        case .departureWarp:
            return "gacha.gacha_type.departure_warp".localized()
        }
    }
}

// MARK: - GachaItem.ItemType + CustomStringConvertible

#if hasFeature(RetroactiveAttribute)
extension GachaItem.ItemType: @retroactive CustomStringConvertible {}
#else
extension GachaItem.ItemType: CustomStringConvertible {}
#endif

extension GachaItem.ItemType {
    public var description: String {
        switch self {
        case .lightCones:
            return "gacha.gacha_item.item_type.light_cones".localized()
        case .characters:
            return "gacha.gacha_item.item_type.characters".localized()
        }
    }
}
