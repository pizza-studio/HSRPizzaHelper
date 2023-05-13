//
//  Account+CoreDataClass.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//
//

import CoreData
import Foundation
import HBMihoyoAPI

@objc(Account)
public class Account: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(Account.uuid))
        setPrimitiveValue(Server.china.rawValue, forKey: #keyPath(Account.serverRawValue))
        setPrimitiveValue("", forKey: #keyPath(Account.name))
        setPrimitiveValue("", forKey: #keyPath(Account.cookie))
        setPrimitiveValue("", forKey: #keyPath(Account.uid))
        setPrimitiveValue(true as NSNumber, forKey: #keyPath(Account.allowNotification))
    }

    public override func didSave() {
        super.didSave()
        if !(allowNotification as? Bool ?? true) {
            HSRNotificationCenter.deleteDailyNoteNotification(for: self)
        }
    }
}
