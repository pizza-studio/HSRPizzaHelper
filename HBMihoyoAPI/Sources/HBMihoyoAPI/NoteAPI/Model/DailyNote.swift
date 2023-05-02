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

    public init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        self.staminaInformation = try decoder.decode(StaminaInformation.self)
        self.expeditionInformation = try decoder.decode(ExpeditionInformation.self)
    }
}

extension DailyNote: DecodableFromMiHoYoAPIJSONResult {}
