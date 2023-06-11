//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/6/11.
//

import Foundation

// MARK: - Verification

public struct Verification: Decodable, DecodableFromMiHoYoAPIJSONResult {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.challenge = try container.decode(String.self, forKey: .challenge)
        self.gt = try container.decode(String.self, forKey: .gt)
        self.newCaptcha = try container.decode(Int.self, forKey: .newCaptcha)
        self.success = try container.decode(Int.self, forKey: .success)
    }

    // MARK: Public

    public let challenge: String
    // swiftlint:disable:next identifier_name
    public let gt: String
    public let newCaptcha: Int
    public let success: Int

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case challenge
        // swiftlint:disable:next identifier_name
        case gt
        case newCaptcha = "new_captcha"
        case success
    }
}

// MARK: - VerifyVerification

public struct VerifyVerification: Decodable, DecodableFromMiHoYoAPIJSONResult {
    let challenge: String
}
