//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

public struct StaminaInformation: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxStamina = try container.decode(Int.self, forKey: .maxStamina)
        self.currentStamina = try container.decode(Int.self, forKey: .currentStamina)
        self.staminaRecoverTime = try TimeInterval(container.decode(Int.self, forKey: .staminaRecoverTime))
    }

    // MARK: Public

    public let maxStamina: Int
    public let currentStamina: Int
    public let staminaRecoverTime: TimeInterval

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case maxStamina = "max_stamina"
        case currentStamina = "current_stamina"
        case staminaRecoverTime = "stamina_recover_time"
    }

    // MARK: Private

    /// The time this struct generated
    private let fetchTime: Date = .init()
}
