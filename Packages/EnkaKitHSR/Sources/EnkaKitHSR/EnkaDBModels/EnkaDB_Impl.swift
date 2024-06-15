// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults

// MARK: - Local Query APIs.

extension EnkaHSR.EnkaDB {
    public func queryLocalizedNameForChar(id: String, officialNameOnly: Bool = false) -> String {
        guard let character = characters[id] else { return "NULL-CHAR(\(id))" }
        let nameHash = character.avatarName.hash
        let officialName = EnkaHSR.Sputnik.sharedDB.locTable[nameHash.description] ?? "NULL-LOC(\(id))"
        let realName = EnkaHSR.Sputnik.sharedDB.realNameTable[id]
        return officialNameOnly ? officialName : realName ?? officialName
    }

    public func queryGachaAssetPathForChar(id: String) -> String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.profileAvatar.rawValue)/\(id).heic"
    }

    public func queryGachaAssetPathForWeapon(id: String) -> String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.weapon.rawValue)/\(id).heic"
    }
}

// MARK: - APIs for Checking Expiry Status.

extension EnkaHSR.EnkaDB {
    public func updateExpiryStatus(against profile: EnkaHSR.QueryRelated.DetailInfo? = nil) {
        var arrProfiles = [EnkaHSR.QueryRelated.DetailInfo]()
        if let profile = profile {
            arrProfiles.append(profile)
        } else {
            arrProfiles.append(contentsOf: Defaults[.queriedEnkaProfiles].values)
        }

        // Check characters.
        let charIDsInProfile = Set<String>(
            arrProfiles.map { $0.avatarDetailList.map(\.avatarId.description) }.reduce([], +)
        )
        let charIDsInDB = Set<String>(characters.keys)
        guard charIDsInProfile.isSubset(of: charIDsInDB) else {
            isExpired = true
            return
        }
        // Check weapons.
        let weaponIDsInProfile = Set<String>(
            arrProfiles.map { $0.avatarDetailList.compactMap(\.equipment?.tid.description) }.reduce([], +)
        )
        let weaponIDsInDB = Set<String>(weapons.keys)
        guard weaponIDsInProfile.isSubset(of: weaponIDsInDB) else {
            isExpired = true
            return
        }
        // Check artifacts, the most time-consuming check.
        let artifactIDsInProfile = Set<String>(
            arrProfiles.map {
                $0.avatarDetailList.compactMap { avatar in
                    avatar.artifactList.map(\.tid.description)
                }.reduce([], +)
            }.reduce([], +)
        )
        let artifactIDsInDB = Set<String>(artifacts.keys)
        guard artifactIDsInProfile.isSubset(of: artifactIDsInDB) else {
            isExpired = true
            return
        }
    }
}
