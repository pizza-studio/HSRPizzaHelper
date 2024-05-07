// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - EnkaHSR.CharacterName

extension EnkaHSR {
    public enum CharacterName {
        case ofCaelus
        case ofStelle
        case isSomeoneElse(pid: String)

        // MARK: Public

        public static func convertPIDForProtagonist(_ pid: String) -> String {
            guard pid.count == 4, let first = pid.first, first == "8" else { return pid }
            guard let last = pid.last?.description, var lastDigi = Int(last) else { return pid }
            guard lastDigi >= 1 else { return pid }
            lastDigi = lastDigi % 2
            if lastDigi == 0 { lastDigi += 2 }
            return String(pid.dropLast()) + lastDigi.description
        }
    }
}

// MARK: - EnkaHSR.CharacterName + RawRepresentable, Hashable, Codable, Sendable

extension EnkaHSR.CharacterName: RawRepresentable, Hashable, Codable, Sendable {
    public init(pid: Int) {
        self = EnkaHSR.CharacterName(rawValue: pid.description)
    }

    public init(pidStr: String) {
        self = EnkaHSR.CharacterName(rawValue: pidStr)
    }

    public init(rawValue: String) {
        switch Self.convertPIDForProtagonist(rawValue) {
        case "8001": self = .ofCaelus
        case "8002": self = .ofStelle
        default: self = .isSomeoneElse(pid: rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case let .isSomeoneElse(name): return name
        case .ofCaelus: return "8001"
        case .ofStelle: return "8002"
        }
    }
}

// MARK: - EnkaHSR.CharacterName + Identifiable

extension EnkaHSR.CharacterName: Identifiable {
    public var id: String { rawValue }
}

// MARK: - EnkaHSR.CharacterName + CustomStringConvertible

extension EnkaHSR.CharacterName: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ofCaelus: Self.locTableCaelus[EnkaHSR.EnkaDB.currentLangTag] ?? "Caelus"
        case .ofStelle: Self.locTableStelle[EnkaHSR.EnkaDB.currentLangTag] ?? "Stelle"
        case let .isSomeoneElse(pid):
            EnkaHSR.Sputnik.sharedDB.queryLocalizedNameForChar(id: pid)
        }
    }

    public func i18n(theDB: EnkaHSR.EnkaDB? = nil) -> String {
        guard let theDB = theDB else { return description }
        switch self {
        case .ofCaelus: return Self.locTableCaelus[theDB.langTag] ?? "Caelus"
        case .ofStelle: return Self.locTableStelle[theDB.langTag] ?? "Stelle"
        case let .isSomeoneElse(pid):
            guard let theCommonInfo = theDB.characters[rawValue] else { return description }
            let charNameHash = theCommonInfo.avatarName.hash.description
            return theDB.locTable[charNameHash] ?? "EnkaId: \(pid)"
        }
    }

    private static let locTableStelle: [String: String] = [
        "de": "Stella",
        "en": "Stelle",
        "es": "Estela",
        "fr": "Stelle",
        "id": "Stelle",
        "ja": "星",
        "ko": "스텔레",
        "pt": "Stelle",
        "ru": "Стелла",
        "th": "Stelle",
        "vi": "Stelle",
        "zh-cn": "星",
        "zh-tw": "星",
    ]

    private static let locTableCaelus: [String: String] = [
        "de": "Caelus",
        "en": "Caelus",
        "es": "Caelus",
        "fr": "Caelus",
        "id": "Caelus",
        "ja": "穹",
        "ko": "카일루스",
        "pt": "Caelus",
        "ru": "Келус",
        "th": "Caelus",
        "vi": "Caelus",
        "zh-cn": "穹",
        "zh-tw": "穹",
    ]
}
