//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - StaminaInformation

public struct StaminaInformation {
    // MARK: Public

    /// Each stamina needs 6 minutes to recover
    public static let eachStaminaRecoveryTime: TimeInterval = 60 * 6

    /// Max stamina.
    public let maxStamina: Int

    /// Current stamina
    public var currentStamina: Int {
        maxStamina - restOfStamina
    }

    /// Rest of recovery time
    public var remainingTime: TimeInterval {
        let restOfTime = _staminaRecoverTime - benchmarkTime.timeIntervalSince(fetchTime)
        if restOfTime > 0 {
            return restOfTime
        } else {
            return 0
        }
    }

    /// The time when stamina is full
    public var fullTime: Date {
        Date(timeInterval: _staminaRecoverTime, since: fetchTime)
    }

    /// The time when next stamina recover. If the stamina is full, return `nil`
    public var nextStaminaTime: Date? {
        let nextRecoverTimeInterval = remainingTime.truncatingRemainder(dividingBy: Self.eachStaminaRecoveryTime)
        if nextRecoverTimeInterval != 0 {
            return Date(timeInterval: nextRecoverTimeInterval + 1, since: benchmarkTime)
        } else {
            return nil
        }
    }

    // MARK: Private

    /// Stamina when data is fetched.
    private let _currentStamina: Int
    /// Recovery time interval when data is fetched.
    private let _staminaRecoverTime: TimeInterval

    /// The time this struct generated
    private let fetchTime: Date = .init()

    private var restOfStamina: Int {
        Int(ceil(remainingTime / Self.eachStaminaRecoveryTime))
    }

    @BenchmarkTime public var benchmarkTime: Date
}

// MARK: Decodable

extension StaminaInformation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxStamina = try container.decode(Int.self, forKey: .maxStamina)
        self._currentStamina = try container.decode(Int.self, forKey: .currentStamina)
        self._staminaRecoverTime = try TimeInterval(container.decode(Int.self, forKey: .staminaRecoverTime))
    }

    enum CodingKeys: String, CodingKey {
        case maxStamina = "max_stamina"
        case currentStamina = "current_stamina"
        case staminaRecoverTime = "stamina_recover_time"
    }
}

// MARK: ReferencingBenchmarkTime

extension StaminaInformation: ReferencingBenchmarkTime {}
