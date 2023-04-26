//
//  ServersModel.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  返回识别服务器信息的工具类

import Foundation
import HBMihoyoAPI

// extention for CoreData to save Server
extension AccountConfiguration {
    var server: Server {
        get {
            Server(rawValue: serverRawValue!)!
        }
        set {
            serverRawValue = newValue.rawValue
        }
    }
}
