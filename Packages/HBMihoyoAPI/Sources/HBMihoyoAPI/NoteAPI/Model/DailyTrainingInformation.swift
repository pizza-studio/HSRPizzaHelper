//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/7/2.
//

import Foundation

// MARK: - DailyTrainingInformation

public struct DailyTrainingInformation {
    public let currentScore: Int
    public let maxScore: Int
}

// MARK: Decodable

extension DailyTrainingInformation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentScore = try container.decode(Int.self, forKey: .currentScore)
        self.maxScore = try container.decode(Int.self, forKey: .maxScore)
    }

    enum CodingKeys: String, CodingKey {
        case currentScore = "current_train_score"
        case maxScore = "max_train_score"
    }
}
