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

extension GachaItem {
    var localizedName: String {
        GachaMetaManager.shared.getLocalizedName(id: itemID, type: itemType) ?? name
    }

    var icon: UIImage? {
        GachaMetaManager.shared.getIcon(id: itemID, type: itemType)
    }
}
