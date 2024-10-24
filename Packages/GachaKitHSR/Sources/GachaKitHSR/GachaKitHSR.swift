// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBMihoyoAPI

// MARK: - UIGFFormat

public enum UIGFFormat: String, Identifiable, Sendable, Hashable {
    case uigfv4
    case srgfv1

    // MARK: Public

    public var id: String { rawValue }
}

// MARK: - GachaKitHSR

public enum GachaKitHSR {}

extension DateFormatter {
    public static func forUIGFEntry(
        timeZoneDelta: Int
    )
        -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = .init(secondsFromGMT: timeZoneDelta * 3600)
        return dateFormatter
    }

    public static var forUIGFFileName: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        return dateFormatter
    }
}

extension Date {
    public func asUIGFDate(
        timeZoneDelta: Int
    )
        -> String {
        DateFormatter.forUIGFEntry(timeZoneDelta: timeZoneDelta).string(from: self)
    }
}

// swiftlint:disable cyclomatic_complexity
extension GachaItem.ItemType {
    func translatedRaw(for lang: GachaLanguageCode) -> String {
        switch (self, lang) {
        case (.characters, .de): return "Figur"
        case (.characters, .enUS): return "Character"
        case (.characters, .es): return "Personaje"
        case (.characters, .fr): return "Personnage"
        case (.characters, .id): return "Karakter"
        case (.characters, .ja): return "キャラクター"
        case (.characters, .ko): return "캐릭터"
        case (.characters, .pt): return "Personagem"
        case (.characters, .ru): return "Персонаж"
        case (.characters, .th): return "ตัวละคร"
        case (.characters, .vi): return "Nhân Vật"
        case (.characters, .zhHans): return "角色"
        case (.characters, .zhHant): return "角色"
        case (.lightCones, .de): return "Lichtkegel"
        case (.lightCones, .enUS): return "Light Cone"
        case (.lightCones, .es): return "Cono de luz"
        case (.lightCones, .fr): return "Cône de lumière"
        case (.lightCones, .id): return "Light Cone"
        case (.lightCones, .ja): return "光円錐"
        case (.lightCones, .ko): return "광추"
        case (.lightCones, .pt): return "Cone de Luz"
        case (.lightCones, .ru): return "Световой конус"
        case (.lightCones, .th): return "Light Cone"
        case (.lightCones, .vi): return "Nón Ánh Sáng"
        case (.lightCones, .zhHans): return "光锥"
        case (.lightCones, .zhHant): return "光錐"
        }
    }
}

// swiftlint:enable cyclomatic_complexity
