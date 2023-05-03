//
//  Account.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation
import HBMihoyoAPI

extension Account {
    func isValid() -> Bool {
        true
        && self.uid != nil
        && self.uid != ""
        && self.cookie != nil
        && self.cookie != ""
        && Server(rawValue: self.serverRawValue ?? "") != nil
        && self.uuid != nil
        && self.priority != nil
        && self.name != nil
    }
}
