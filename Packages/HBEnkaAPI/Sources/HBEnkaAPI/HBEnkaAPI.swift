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
}

// MARK: - Global Level TypeAliases

extension EnkaHSR {
    /// Elements used in HSR, using Ancient Greek namings (same as Genshin).
    ///
    /// 1. HSR doesn't have Dendro and Hydro element as of v2.2 update.
    /// 2. Elements in this SPM are named using Ancient Greek namings (same as Genshin).
    /// e.g.: Posesto = Quantum, Fantastico = Imaginary, Pyro = Ice, etc.
    public typealias Element = DBModels.Element
    public typealias PropType = DBModels.PropType
    public typealias LifePath = DBModels.LifePath
}

// MARK: - EnkaHSR.JSONTypes

extension EnkaHSR {
    public enum JSONTypes: String {
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
