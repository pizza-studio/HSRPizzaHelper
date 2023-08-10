//
//  GachaLocalizationMap.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/10.
//

import Foundation
import HBMihoyoAPI

struct GachaMeta: Decodable {
    let character: [String : Character]
    let lightCone: [String : LightCone]

    struct Character: Decodable {
        let nameLocalizationMap: [ MiHoYoAPILanguage : String ]
        private let iconFilePath: String
        let rank: GachaItem.Rank
    }

    struct LightCone: Decodable {
        let nameLocalizationMap: [ MiHoYoAPILanguage : String ]
        private let iconFilePath: String
        let rank: GachaItem.Rank
    }
}
