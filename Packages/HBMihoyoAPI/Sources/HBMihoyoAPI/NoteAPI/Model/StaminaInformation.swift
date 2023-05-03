//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

public struct StaminaInformation: Decodable {
    public let maxStamina: Int
    public let currentStamina: Int
    public let staminaRecoverTime: TimeInterval

    /// The time this struct generated
    private let fetchTime: Date = Date()

    enum CodingKeys: String, CodingKey {
        case maxStamina = "max_stamina"
        case currentStamina = "current_stamina"
        case staminaRecoverTime = "stamina_recover_time"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxStamina = try container.decode(Int.self, forKey: .maxStamina)
        self.currentStamina = try container.decode(Int.self, forKey: .currentStamina)
        self.staminaRecoverTime = TimeInterval(try container.decode(Int.self, forKey: .staminaRecoverTime))
    }
}
