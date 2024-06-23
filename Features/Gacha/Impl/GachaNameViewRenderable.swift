// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import Foundation
import HBMihoyoAPI
import SwiftUI

// MARK: - GachaNameViewRenderable

protocol GachaNameViewRenderable {
    var itemType: GachaItem.ItemType { get }
    var localizedName: String { get }
    var itemID: String { get }
}

extension GachaNameViewRenderable {
    func localizedNameView(officialNameOnly: Bool) -> Text {
        guard itemType == .characters else { return Text(verbatim: localizedName) }
        let resultText = EnkaHSR.Sputnik.sharedDB.queryLocalizedNameForChar(
            id: itemID,
            officialNameOnly: officialNameOnly
        ) {
            localizedName
        }
        return Text(verbatim: resultText)
    }
}

// MARK: - GachaItem + GachaNameViewRenderable

extension GachaItem: GachaNameViewRenderable {}

// MARK: - GachaItemMO + GachaNameViewRenderable

extension GachaItemMO: GachaNameViewRenderable {}
