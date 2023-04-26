//
//  TransformerDetail.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  参量质变仪信息

import Foundation

public struct TransformerInfo {
    // MARK: Lifecycle

    public init(_ transformerData: TransformerData) {
        self.obtained = transformerData.obtained
        self.recoveryTime = RecoveryTime(
            transformerData.recoveryTime.day,
            transformerData.recoveryTime.hour,
            transformerData.recoveryTime.minute,
            transformerData.recoveryTime.second
        )
    }

    // MARK: Public

    public let obtained: Bool
    public let recoveryTime: RecoveryTime

    public var isComplete: Bool { recoveryTime.isComplete }

    public var percentage: Double {
        // 因为返回的只会精准到天，所以多加十二个小时以符合直觉
        if recoveryTime.second > (24 * 60 * 60) {
            let pct = (604800.0 - Double(recoveryTime.second + 12 * 60 * 60)) /
                604800.0
            if pct > 1 {
                return 1.0
            } else {
                return pct
            }
        } else {
            return (604800.0 - Double(recoveryTime.second)) / 604800.0
        }
    }

    public var score: Float {
        if isComplete { return 1 } else { return 0 }
    }
}
