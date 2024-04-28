//
//  Model.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - GeneralDailyNote

/// A struct representing the result of note API
public struct GeneralDailyNote: DecodableFromMiHoYoAPIJSONResult, DailyNote {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.staminaInformation = try decoder.decode(StaminaInformation.self)
        self.expeditionInformation = try decoder.decode(ExpeditionInformation.self)
    }

    // MARK: Public

    /// Stamina information
    public var staminaInformation: StaminaInformation
    /// Expedition information
    public var expeditionInformation: ExpeditionInformation
    /// The time when this struct is generated
    public let fetchTime: Date = .init()
}

extension GeneralDailyNote {
    public static func example() -> DailyNote {
        let exampleURL = Bundle.module.url(forResource: "daily_note_example", withExtension: "json")!
        // swiftlint:disable force_try
        // swiftlint:disable force_unwrapping
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! GeneralDailyNote.decodeFromMiHoYoAPIJSONResult(
            data: exampleData
        ) as DailyNote
        // swiftlint:enable force_try
        // swiftlint:enable force_unwrapping
    }
}
