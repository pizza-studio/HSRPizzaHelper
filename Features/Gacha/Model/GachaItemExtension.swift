// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import Foundation
import GachaKit
import HBMihoyoAPI
import SwiftUI

extension GachaItemProtocol {
    var localizedName: String {
        let initialValue = GachaMetaManager.shared.getLocalizedName(id: itemID, type: itemType)
        let secondaryValue: String? = {
            if let this = self as? GachaItemMO {
                return this.name
            }
            if let this = self as? GachaItem {
                return this.name
            }
            return nil
        }()
        return initialValue ?? secondaryValue ?? "MissingName: \(itemID)"
    }

    var icon: Image? {
        switch itemType {
        case .lightCones:
            EnkaHSR.queryWeaponImageSUI(for: itemID)
        case .characters:
            EnkaHSR.queryOfficialCharAvatarSUI(for: itemID)
        }
    }
}
