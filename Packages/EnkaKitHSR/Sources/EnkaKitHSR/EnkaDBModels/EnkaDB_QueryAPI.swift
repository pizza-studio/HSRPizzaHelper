// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.EnkaDB {
    public func queryLocalizedNameForChar(id: String) -> String {
        guard let character = characters[id] else { return "NULL-CHAR(\(id))" }
        let nameHash = character.avatarName.hash
        return EnkaHSR.Sputnik.sharedDB.locTable[nameHash.description] ?? "NULL-LOC(\(id))"
    }

    public func queryGachaAssetPathForChar(id: String) -> String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.profileAvatar.rawValue)/\(id).png"
    }

    public func queryGachaAssetPathForWeapon(id: String) -> String {
        "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.weapon.rawValue)/\(id).png"
    }
}
