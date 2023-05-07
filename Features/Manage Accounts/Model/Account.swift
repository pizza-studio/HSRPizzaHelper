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
    func isValid() -> Bool {
        true
            && uid != nil
            && uid != ""
            && cookie != nil
            && cookie != ""
            && Server(rawValue: serverRawValue ?? "") != nil
            && uuid != nil
            && priority != nil
            && name != nil
    }
}
