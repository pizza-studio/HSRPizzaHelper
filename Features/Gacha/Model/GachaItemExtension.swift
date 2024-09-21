// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import Foundation
import GachaKitHSR
import HBMihoyoAPI
import SwiftUI

extension GachaItemProtocol {
    var localizedName: String {
        let initialValue = GachaMetaManager.shared.getLocalizedName(id: itemIDGuarded)
        let secondaryValue: String? = {
            if let this = self as? GachaItemMO {
                return this.name
            }
            if let this = self as? GachaItem {
                return this.name
            }
            return nil
        }()
        return initialValue ?? secondaryValue ?? "MissingName: \(itemIDGuarded)"
    }

    var icon: Image? {
        switch itemType {
        case .lightCones:
            EnkaHSR.queryWeaponImageSUI(for: itemIDGuarded)
        case .characters:
            EnkaHSR.queryOfficialCharAvatarSUI(for: itemIDGuarded)
        }
    }
}
