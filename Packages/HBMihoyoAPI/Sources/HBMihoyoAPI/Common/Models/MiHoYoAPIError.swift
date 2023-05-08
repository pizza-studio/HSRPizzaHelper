//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - MiHoYoAPIError

/// The error returned by miHoYo when `retcode != 0`
public struct MiHoYoAPIError: Error {
    // MARK: Lifecycle

    public init(retcode: Int, message: String) {
        self.retcode = retcode
        self.message = message
    }

    // MARK: Public

    /// The retcode returned by miHoYo API
    public let retcode: Int
    /// The message returned by miHoYo API
    public let message: String
}

// MARK: LocalizedError

// TODO: implement this protocol
extension MiHoYoAPIError: LocalizedError {}
