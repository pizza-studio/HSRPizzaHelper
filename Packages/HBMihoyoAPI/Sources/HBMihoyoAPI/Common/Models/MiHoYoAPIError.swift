//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

/// The error returned by miHoYo when `retcode != 0`
struct MiHoYoAPIError: Error {
    /// The retcode returned by miHoYo API
    let retcode: Int
    /// The message returned by miHoYo API
    let message: String
}
