//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/6/11.
//

import Foundation

public struct Verification: Decodable, DecodableFromMiHoYoAPIJSONResult {
    let challenge: String
    let gt: String
    let newCaptcha: Int
    let success: Int

    enum CodingKeys: String, CodingKey {
        case challenge
        case gt
        case newCaptcha = "new_captcha"
        case success
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.challenge = try container.decode(String.self, forKey: .challenge)
        self.gt = try container.decode(String.self, forKey: .gt)
        self.newCaptcha = try container.decode(Int.self, forKey: .newCaptcha)
        self.success = try container.decode(Int.self, forKey: .success)
    }
}
