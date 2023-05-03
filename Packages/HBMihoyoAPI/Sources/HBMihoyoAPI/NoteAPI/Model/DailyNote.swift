//
//  Model.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

/// Result of `note` API.
public struct DailyNote: Decodable {
    public let staminaInformation: StaminaInformation
    public let expeditionInformation: ExpeditionInformation

    /// The time this struct generated
    public let fetchTime: Date = Date()

    public init(from decoder: Decoder) throws {
        var decoder = try decoder.singleValueContainer()
        self.staminaInformation = try decoder.decode(StaminaInformation.self)
        self.expeditionInformation = try decoder.decode(ExpeditionInformation.self)
    }
}

extension DailyNote: DecodableFromMiHoYoAPIJSONResult {}

fileprivate struct DailyNoteDecodeHelper {
    let current_stamina: Int
    let max_stamina: Int
    let stamina_recover_time: Int
    let accepted_epedition_num: Int
    let total_expedition_num: Int
    let expeditions: [ExpeditionInformation.Expedition]
}
