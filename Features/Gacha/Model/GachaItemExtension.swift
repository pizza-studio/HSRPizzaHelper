//
//  GachaItemExtension.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/11.
//

import Foundation
import HBMihoyoAPI
import SRGFKit
import UIKit

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

    var icon: UIImage? {
        GachaMetaManager.shared.getIcon(id: itemID, type: itemType)
    }
}
