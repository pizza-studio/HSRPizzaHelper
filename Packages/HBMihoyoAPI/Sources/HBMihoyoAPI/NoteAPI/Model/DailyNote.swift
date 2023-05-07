//
//  Model.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - DailyNote

/// A struct representing the result of note API
public struct DailyNote: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.staminaInformation = try decoder.decode(StaminaInformation.self)
        self.expeditionInformation = try decoder.decode(ExpeditionInformation.self)
    }

    // MARK: Public

    /// Stamina information
    public let staminaInformation: StaminaInformation
    /// Expedition information
    public let expeditionInformation: ExpeditionInformation
    /// The time when this struct is generated
    public let fetchTime: Date = .init()

    // MARK: Internal

    /// Deccoding keys for the decoder
    enum CodingKeys: String, CodingKey {
        case staminaInformation = "stamina_info"
        case expeditionInformation = "daily_expedition"
    }
}

// MARK: DecodableFromMiHoYoAPIJSONResult

extension DailyNote: DecodableFromMiHoYoAPIJSONResult {}

extension DailyNote {
    public static func example() -> DailyNote {
        let exampleURL = Bundle.module.url(forResource: "daily_note_example", withExtension: "json")!
        // swiftlint:disable:next
        let exampleData = try! Data(contentsOf: exampleURL)
        // swiftlint:disable:next
        return try! DailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
