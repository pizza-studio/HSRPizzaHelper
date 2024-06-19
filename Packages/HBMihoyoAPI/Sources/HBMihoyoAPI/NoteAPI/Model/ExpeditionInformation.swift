//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - ExpeditionInformation

/// A struct representing the expedition information generated by Note API
public struct ExpeditionInformation {
    // MARK: Public

    // MARK: - Expedition

    /// Each expedition information generated by Note API
    public struct Expedition: Hashable {
        // MARK: Public

        /// The status of the expedition
        public enum Status: String, Decodable, Hashable {
            case onGoing = "Ongoing"
            case finished = "Finished"
        }

        public static let totalTime: TimeInterval = 20 * 60 * 60

        @BenchmarkTime public var benchmarkTime: Date

        /// The avatars' icons of the expedition
        public let avatarIconURLs: [URL]
        /// The name of expedition
        public let name: String

        /// Remaining time of expedition
        public var remainingTime: TimeInterval {
            max(_remainingTime - benchmarkTime.timeIntervalSince(fetchTime), 0)
        }

        /// The status of the expedition
        public var status: Status {
            remainingTime == 0 ? .finished : .onGoing
        }

        /// The finished time of expedition
        public var finishedTime: Date {
            Date(timeInterval: _remainingTime, since: fetchTime)
        }

        /// Percentage of Completion
        public var percOfCompletion: Double {
            1.0 - remainingTime / Self.totalTime
        }

        // MARK: Private

        // MARK: CodingKeys

        private enum CodingKeys: String, CodingKey {
            case status
            case remainingTime = "remaining_time"
            case avatarIconURLs = "avatars"
            case name
        }

        /// The time when this struct is generated
        private let fetchTime: Date = .init()

        /// Remaining time of expedition when fetch
        private let _remainingTime: TimeInterval
    }

    /// Details of all accepted expeditions
    public var expeditions: [Expedition]
    /// Max expeditions number
    public let totalExpeditionNumber: Int
    /// Current accepted expedition number
    public let acceptedExpeditionNumber: Int

    /// The number on going expeditions
    public var onGoingExpeditionNumber: Int {
        expeditions.map { expedition in
            expedition.status == .onGoing ? 1 : 0
        }.reduce(0, +)
    }

    // MARK: Private

    // MARK: CodingKeys

    private enum CodingKeys: String, CodingKey {
        case expeditions
        case totalExpeditionNumber = "total_expedition_num"
        case acceptedExpeditionNumber = "accepted_epedition_num"
        // Mihoyo's api has a spell error here. So there are 2 keys for this field.
        case alterKeyForAcceptedExpeditionNumber = "accepted_expedition_num"
    }
}

// MARK: Decodable

extension ExpeditionInformation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.expeditions = try container.decode([ExpeditionInformation.Expedition].self, forKey: .expeditions)
        self.totalExpeditionNumber = try container.decode(Int.self, forKey: .totalExpeditionNumber)
        if let acceptedExpeditionNumber = try? container.decode(Int.self, forKey: .acceptedExpeditionNumber) {
            self.acceptedExpeditionNumber = acceptedExpeditionNumber
        } else {
            self.acceptedExpeditionNumber = try container.decode(Int.self, forKey: .alterKeyForAcceptedExpeditionNumber)
        }
    }
}

// MARK: - ExpeditionInformation.Expedition + Decodable

extension ExpeditionInformation.Expedition: Decodable {
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder
            .container(keyedBy: CodingKeys.self)
        self._remainingTime = try container.decode(TimeInterval.self, forKey: .remainingTime)
        self.avatarIconURLs = try container.decode([URL].self, forKey: .avatarIconURLs)
        self.name = try container.decode(String.self, forKey: .name)
    }
}

// MARK: - ExpeditionInformation.Expedition + Identifiable

extension ExpeditionInformation.Expedition: Identifiable {
    public var id: String { name }
}

// MARK: - ExpeditionInformation.Expedition + ReferencingBenchmarkTime

extension ExpeditionInformation.Expedition: ReferencingBenchmarkTime {}

// MARK: - ExpeditionInformation + BenchmarkTimeEditable

extension ExpeditionInformation: BenchmarkTimeEditable {
    public func replacingBenchmarkTime(_ newBenchmarkTime: Date) -> ExpeditionInformation {
        var information = self
        information.expeditions = expeditions.map { expedition in
            expedition.replacingBenchmarkTime(newBenchmarkTime)
        }
        return information
    }
}
