// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - EnkaHSR

// The namespace of this sub-package.
public enum EnkaHSR {
    /// DBModels namespace is for parsing the JSON files provided in Enka-API-docs repository.
    public enum DBModels {}
    /// QueryRelated namespace is for parsing the JSON files retrieved from Enka Networks website.
    public enum QueryRelated {}

    /// The URL Prefix for Querying Enka Profile Data.
    public static let enkaQueryURLPrefix = "https://enka.network/hsr/api/uid/"

    /// Root Asset Path without ending slash. Can be overridable.
    /// - remark: You have to manually add the ending slash when using this variable.
    public static var assetPathRoot = {
        #if os(OSX) || targetEnvironment(macCatalyst)
        Bundle.main.bundlePath + "/Contents/Resources"
        #else
        Bundle.main.bundlePath
        #endif
    }()
}

// MARK: - Global Level TypeAliases

extension EnkaHSR {
    /// Elements used in HSR, using Ancient Greek namings (same as Genshin).
    ///
    /// 1. HSR doesn't have Dendro and Hydro element as of v2.2 update.
    /// 2. Elements in this SPM are named using Ancient Greek namings (same as Genshin).
    /// e.g.: Posesto = Quantum, Fantastico = Imaginary, Pyro = Ice, etc.
    public typealias Element = DBModels.Element
    public typealias PropertyType = DBModels.PropertyType
    public typealias LifePath = DBModels.LifePath
}

// MARK: EnkaHSR.JSONType

extension EnkaHSR {
    public enum JSONType: String, CaseIterable {
        case profileAvatarIcons = "honker_avatars" // Player Account Profile Picture
        case characters = "honker_characters"
        case metadata = "honker_meta"
        case skillRanks = "honker_ranks"
        case artifacts = "honker_relics"
        case skillTrees = "honker_skilltree"
        case skills = "honker_skills"
        case weapons = "honker_weps"
        case locTable = "hsr"
        case retrieved = "N/A" // The JSON file retrieved from Enka Networks website per each query.

        // MARK: Public

        // Bundle JSON Accessor.
        public var bundledJSONData: Data? {
            guard rawValue != "N/A" else { return nil }
            guard let url = Bundle.module.url(forResource: rawValue, withExtension: "json") else { return nil }
            do {
                return try Data(contentsOf: url)
            } catch {
                NSLog("HBEnkaAPI: Cannot access bundled JSON data \(rawValue).json.")
                return nil
            }
        }
    }
}

// MARK: - Data Implementation

extension Data {
    public func parseAs<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
}

extension Data? {
    public func parseAs<T: Decodable>(_ type: T.Type) throws -> T? {
        guard let this = self else { return nil }
        return try JSONDecoder().decode(T.self, from: this)
    }

    public func assertedParseAs<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self ?? .init([]))
    }
}

// MARK: - EnkaAPI LangCode

extension Locale {
    public static var langCodeForEnkaAPI: String {
        let languageCode = Locale.preferredLanguages.first
            ?? Bundle.module.preferredLocalizations.first
            ?? Bundle.main.preferredLocalizations.first
            ?? "en"
        switch languageCode.prefix(7).lowercased() {
        case "zh-hans": return "zh-cn"
        case "zh-hant": return "zh-tw"
        default: break
        }
        switch languageCode.prefix(5).lowercased() {
        case "zh-cn": return "zh-cn"
        case "zh-tw": return "zh-tw"
        default: break
        }
        return languageCode
    }
}

// MARK: - EnkaHSR.HostType

extension EnkaHSR {
    public enum HostType: Int, Codable, RawRepresentable, Hashable {
        case mainlandChina = 0
        case enkaGlobal = 1

        // MARK: Lifecycle

        public init(uid: String) {
            var theUID = uid
            while theUID.count > 9 {
                theUID = theUID.dropFirst().description
            }
            guard let initial = theUID.first, let initialInt = Int(initial.description) else {
                self = .enkaGlobal
                return
            }
            switch initialInt {
            case 1 ... 5: self = .mainlandChina
            default: self = .enkaGlobal
            }
        }

        // MARK: Public

        public var enkaDBSourceURLHeader: String {
            switch self {
            case .mainlandChina: return "https://gitcode.net/SHIKISUEN/Enka-API-docs/-/raw/master/"
            case .enkaGlobal: return "https://raw.githubusercontent.com/EnkaNetwork/API-docs/master/"
            }
        }

        public var profileQueryURLHeader: String {
            switch self {
            case .mainlandChina: return "https://api.mihomo.me/sr_info/"
            case .enkaGlobal: return "https://enka.network/api/hsr/uid/"
            }
        }

        public func viceVersa() -> Self {
            switch self {
            case .enkaGlobal: return .mainlandChina
            case .mainlandChina: return .enkaGlobal
            }
        }

        public func enkaDBSourceURL(type: EnkaHSR.JSONType) -> URL {
            // swiftlint:disable force_unwrapping
            let urlStr = "\(enkaDBSourceURLHeader)store/hsr/\(type.rawValue).json"
            return .init(string: urlStr)!
            // swiftlint:enable force_unwrapping
        }
    }
}

// MARK: - EnkaHSR.QueryRelated.Exception

extension EnkaHSR.QueryRelated {
    public enum Exception: Error {
        case enkaDBOnlineFetchFailure(details: String)
        case enkaProfileQueryFailure(message: String)
        case refreshTooFast(dateWhenRefreshable: Date)
        case dataInvalid
    }
}
