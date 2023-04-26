//
//  NetworkReachability.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//  Check network available

import Foundation
#if !os(watchOS)
import SystemConfiguration

// 检查网络可用性
@available(iOS 13, *)
class NetworkReachability: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.reachable = checkConnection()
    }

    // MARK: Internal

    @Published
    private(set) var reachable: Bool = false

    func checkConnection() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)

        return isNetworkReachable(with: flags)
    }

    // MARK: Private

    private let reachability = SCNetworkReachabilityCreateWithName(
        nil,
        "https://api-takumi-record.mihoyo.com"
    )

    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags)
        -> Bool {
        let isReachable = flags.contains(.reachable)
        let connectionRequired = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags
            .contains(.connectionOnDemand) || flags
            .contains(.connectionOnTraffic)
        let canConnectWithoutIntervention = canConnectAutomatically &&
            !flags
            .contains(.interventionRequired)
        return isReachable &&
            (!connectionRequired || canConnectWithoutIntervention)
    }
}
#else
@available(watchOS 6.0, *)
class NetworkReachability: ObservableObject {
    @Published
    private(set) var reachable: Bool = true
}
#endif

// MARK: - ConnectStatus

enum ConnectStatus {
    case unknown
    case success
    case fail
    case testing
}
