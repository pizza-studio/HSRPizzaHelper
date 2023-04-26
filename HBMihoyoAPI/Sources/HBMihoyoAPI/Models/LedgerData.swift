//
//  LedgerData.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//

import Foundation

public struct LedgerData: Codable {
    public struct MonthData: Codable {
        public struct LedgerDataGroup: Codable {
            public var percent: Int
            public var num: Int
            public var actionId: Int
            public var action: String
        }

        public var currentPrimogems: Int
        /// 国际服没有
        public var currentPrimogemsLevel: Int?
        public var lastMora: Int
        /// 国服使用
        public var primogemsRate: Int?
        /// 国际服使用
        public var primogemRate: Int?
        public var moraRate: Int
        public var groupBy: [LedgerDataGroup]
        public var lastPrimogems: Int
        public var currentMora: Int
    }

    public struct DayData: Codable {
        public var currentMora: Int
        /// 国际服没有
        public var lastPrimogems: Int?
        /// 国际服没有
        public var lastMora: Int?
        public var currentPrimogems: Int
    }

    public var uid: Int
    public var monthData: MonthData
    public var dataMonth: Int
    /// 国际服没有
    public var date: String?
    /// 国际服没有
    public var dataLastMonth: Int?
    public var region: String
    public var optionalMonth: [Int]
    public var month: Int
    public var nickname: String
    /// 国际服没有
    public var accountId: Int?
    /// 国际服没有
    public var lantern: Bool?
    public var dayData: DayData
}
