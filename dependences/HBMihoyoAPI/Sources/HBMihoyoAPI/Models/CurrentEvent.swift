//
//  CurrentEvent.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//

import Foundation

// MARK: - CurrentEvent

public struct CurrentEvent: Codable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EventKey.self)

        var events = [String: EventModel]()
        for key in container.allKeys {
            if let model = try? container.decode(EventModel.self, forKey: key) {
                events[key.stringValue] = model
            }
        }
        self.event = events
    }

    // MARK: Public

    public struct EventKey: CodingKey {
        // MARK: Lifecycle

        public init?(stringValue: String) {
            self.stringValue = stringValue
        }

        public init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        // MARK: Public

        public var stringValue: String
        public var intValue: Int?
    }

    public var event: [String: EventModel]
}

// MARK: - EventModel

public struct EventModel: Codable {
    public struct MultiLanguageContents: Codable {
        public var EN: String
        public var RU: String
        public var CHS: String
        public var CHT: String
        public var KR: String
        public var JP: String
    }

    public var id: Int
    public var name: MultiLanguageContents
    public var nameFull: MultiLanguageContents
    public var description: MultiLanguageContents
    public var banner: MultiLanguageContents
    public var endAt: String
}
