//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/7/2.
//

import Foundation

// MARK: - DailyNote

public protocol DailyNote: BenchmarkTimeEditable {
    /// Stamina information
    var staminaInformation: StaminaInformation { get }
    /// Expedition information
    var expeditionInformation: ExpeditionInformation { get }
    /// The time when this struct is generated
    var fetchTime: Date { get }
}
