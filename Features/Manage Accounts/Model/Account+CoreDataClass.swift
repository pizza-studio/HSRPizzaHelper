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
        uuid = UUID()
        serverRawValue = Server.china.rawValue
        name = name ?? ""
        cookie = cookie ?? ""
        priority = 0
        uid = uid ?? ""
    }
}
