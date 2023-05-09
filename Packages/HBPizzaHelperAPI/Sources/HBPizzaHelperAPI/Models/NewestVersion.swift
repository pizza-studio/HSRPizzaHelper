//
//  NewestVersion.swift
//
//
//  Created by Bill Haku on 2023/3/27.
//

import Foundation

// swiftlint:disable identifier_name
public struct NewestVersion: Codable {
    public struct MultiLanguageContents: Codable {
        public var en: [String]
        public var zhcn: [String]
        public var ja: [String]
        public var fr: [String]?
        public var zhtw: [String]?
        public var ru: [String]?
    }

    public struct VersionHistory: Codable {
        public struct MultiLanguageContents: Codable {
            public var en: [String]
            public var zhcn: [String]
            public var ja: [String]
            public var fr: [String]?
            public var zhtw: [String]?
            public var ru: [String]?
        }

        public var shortVersion: String
        public var buildVersion: Int
        public var updates: MultiLanguageContents
    }

    public var shortVersion: String
    public var buildVersion: Int
    public var updates: MultiLanguageContents
    public var notice: MultiLanguageContents
    public var updateHistory: [VersionHistory]
}

// swiftlint:enable identifier_name
