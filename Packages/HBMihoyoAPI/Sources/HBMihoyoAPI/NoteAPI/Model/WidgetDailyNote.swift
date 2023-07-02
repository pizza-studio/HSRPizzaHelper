//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/7/2.
//

import Foundation

public struct WidgetDailyNote: DecodableFromMiHoYoAPIJSONResult, DailyNote {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.staminaInformation = try decoder.decode(StaminaInformation.self)
        self.expeditionInformation = try decoder.decode(ExpeditionInformation.self)
        self.simulatedUniverseInformation = try decoder.decode(SimulatedUniverseInformation.self)
        self.dailyTrainingInformation = try decoder.decode(DailyTrainingInformation.self)
    }

    // MARK: Public

    /// Stamina information
    public var staminaInformation: StaminaInformation
    /// Expedition information
    public var expeditionInformation: ExpeditionInformation
    /// The time when this struct is generated
    public let fetchTime: Date = .init()

    public let simulatedUniverseInformation: SimulatedUniverseInformation

    public let dailyTrainingInformation: DailyTrainingInformation
}
