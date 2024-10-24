// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

/// This Struct is the codable clone of GachaItemMO.
/// We can do the data conversion inside the GachaKitHSR into GachaEntry
/// and then use encode-decode method to convert GachaEntry into GachaItemMO.
/// This allows easier implementation of Unit Tests.
public struct GachaEntry: Codable, Sendable, Hashable, Identifiable {
    // MARK: Lifecycle

    public init(
        count: Int32,
        gachaID: String,
        gachaTypeRawValue: String,
        id: String,
        itemID: String,
        itemTypeRawValue: String,
        langRawValue: String,
        name: String,
        rankRawValue: String,
        time: Date,
        timeRawValue: String?,
        uid: String
    ) {
        self.count = count
        self.gachaID = gachaID
        self.gachaTypeRawValue = gachaTypeRawValue
        self.id = id
        self.itemID = itemID
        self.itemTypeRawValue = itemTypeRawValue
        self.langRawValue = langRawValue
        self.name = name
        self.rankRawValue = rankRawValue
        self.time = time
        self.timeRawValue = timeRawValue
        self.uid = uid
    }

    // MARK: Public

    public var count: Int32
    public var gachaID: String
    public var gachaTypeRawValue: String
    public var id: String
    public var itemID: String
    public var itemTypeRawValue: String
    public var langRawValue: String
    public var name: String
    public var rankRawValue: String
    public var time: Date
    public var timeRawValue: String?
    public var uid: String
}
