//
//  RequestRelated.swift
//
//
//  Created by Bill Haku on 2023/3/27.
//

import Foundation

// MARK: - RequestError

public enum RequestError: Error {
    case dataTaskError(String)
    case noResponseData
    case responseError
    case decodeError(String)
    case errorWithCode(Int)
}

// MARK: - ErrorCode

public struct ErrorCode: Codable {
    var code: Int
    var message: String?
}
