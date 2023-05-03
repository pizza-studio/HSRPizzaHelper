//
//  Model.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - DailyNote

/// Result of `note` API.
public struct DailyNote: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        var decoder = try decoder.singleValueContainer()
        self.staminaInformation = try decoder.decode(StaminaInformation.self)
        self.expeditionInformation = try decoder.decode(ExpeditionInformation.self)
    }

    // MARK: Public

    public let staminaInformation: StaminaInformation
    public let expeditionInformation: ExpeditionInformation

    /// The time this struct generated
    public let fetchTime: Date = .init()
}

// MARK: DecodableFromMiHoYoAPIJSONResult

extension DailyNote: DecodableFromMiHoYoAPIJSONResult {}
