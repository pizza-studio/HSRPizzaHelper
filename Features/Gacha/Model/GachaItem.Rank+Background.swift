//
//  GachaItem.Rank+Background.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/10.
//

import Foundation
import HBMihoyoAPI

extension GachaItem.Rank {
    var backgroundKey: String {
        "UI_QualityBg_\(rawValue)"
    }
}
