//
//  Account.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI

extension Account {
    /// Returns true if the account object is valid.
    var isValid: Bool {
        true
            && uid != nil
            && uid != ""
            && cookie != nil
            && cookie != ""
            && uuid != nil
            && priority != nil
            && name != nil
    }

    var isInvalid: Bool { !isValid }
}
