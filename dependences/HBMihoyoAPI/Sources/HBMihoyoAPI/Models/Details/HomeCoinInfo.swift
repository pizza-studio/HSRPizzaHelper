//
//  HomeCoinInfo.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  洞天宝钱信息

import Foundation

public struct HomeCoinInfo: Codable {
    // MARK: Lifecycle

    public init(
        _ currentHomeCoin: Int,
        _ maxHomeCoin: Int,
        _ homeCoinRecoverySecond: Int
    ) {
        self.currentHomeCoin = currentHomeCoin
        self.maxHomeCoin = maxHomeCoin
        self.recoveryTime = RecoveryTime(second: homeCoinRecoverySecond)
    }

    // MARK: Public

    public let currentHomeCoin: Int
    public let maxHomeCoin: Int
    public let recoveryTime: RecoveryTime

    public var isFull: Bool { recoveryTime.isComplete }

    public var percentage: Double {
        Double(currentHomeCoin) / Double(maxHomeCoin)
    }

    public var score: Float {
        if percentage > 0.7, maxHomeCoin != 300 {
            return Float(percentage)
        } else { return 0 }
    }
}
