//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

/// Abstract class help generate api url request
@available(iOS 15.0, *)
enum URLRequestHelper {
    /// Calculate the DS used in url request headers
    /// - Parameters:
    ///   - region: the region of account. `.china` for miyoushe and `.global` for hoyolab.
    ///   - queries: query items of url request
    ///   - body: body of this url request
    /// - Returns: `ds` used in url request headers
    static func getDS(region: Region, query: String, body: Data? = nil) -> String {
        let salt: String = URLRequestHelperConfiguration.salt(region: region)

        let time = String(Int(Date().timeIntervalSince1970))
        let randomNumber = String(Int.random(in: 100_000 ..< 200_000))

        let bodyString: String
        if let body = body {
            bodyString = String(data: body, encoding: .utf8) ?? ""
        } else {
            bodyString = ""
        }

        let verification = "salt=\(salt)&t=\(time)&r=\(randomNumber)&b=\(bodyString)&q=\(query)".md5

        return time + "," + randomNumber + "," + verification
    }
}
