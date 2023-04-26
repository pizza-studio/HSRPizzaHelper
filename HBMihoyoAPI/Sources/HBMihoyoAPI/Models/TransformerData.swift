//
//  TransformerData.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//

import Foundation

public struct TransformerData: Codable {
    // MARK: Lifecycle

    public init() {
        self.obtained = false
        self.recoveryTime = TransRecoveryTime()
    }

    public init(recoveryTime: TransRecoveryTime, obtained: Bool) {
        self.recoveryTime = recoveryTime
        self.obtained = obtained
    }

    // MARK: Public

    public struct TransRecoveryTime: Codable {
        // MARK: Lifecycle

        public init() {
            self.day = -1
            self.hour = -1
            self.minute = -1
            self.second = -1
        }

        public init(day: Int, hour: Int, minute: Int, second: Int) {
            self.day = day
            self.hour = hour
            self.minute = minute
            self.second = second
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case day = "Day"
            case hour = "Hour"
            case minute = "Minute"
            case second = "Second"
        }

        public let day: Int
        public let hour: Int
        public let minute: Int
        public let second: Int
    }

    public let recoveryTime: TransRecoveryTime
    public let obtained: Bool
}
