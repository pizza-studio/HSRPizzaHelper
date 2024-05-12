//
//  File.swift
//
//
//  Created by 戴藏龙 on 2024/5/11.
//

import Foundation

// MARK: - QueryQRCodeStatus

public enum QueryQRCodeStatus: Decodable {
    case unscanned
    case scanned
    case confirmed(accountId: String, token: String)

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let statusKeys: StatusCodingKeys = try container.decode(StatusCodingKeys.self, forKey: .status)
        switch statusKeys {
        case .unscanned:
            self = .unscanned
        case .scanned:
            self = .scanned
        case .confirmed:
            let payload = try container.decode(Payload.self, forKey: .payload)
            let jsonString = payload.raw
            let decoder = JSONDecoder()
            let decodedConfirmedData = try decoder.decode(
                ConfirmedDataDecodeHelper.self,
                from: jsonString.data(using: .utf8)!
            )
            self = .confirmed(accountId: decodedConfirmedData.uid, token: decodedConfirmedData.token)
        }
    }

    // MARK: Internal

    // decode helper
    struct Payload: Decodable {
        let proto: String

        // json data for "comfirmed"
        let raw: String
        let ext: String
    }

    enum CodingKeys: String, CodingKey {
        case status = "stat"
        case payload
    }

    enum StatusCodingKeys: String, Decodable {
        case unscanned = "Init"
        case scanned = "Scanned"
        case confirmed = "Confirmed"
    }

    struct ConfirmedDataDecodeHelper: Decodable {
        let uid: String
        let token: String
    }
}

// MARK: DecodableFromMiHoYoAPIJSONResult

extension QueryQRCodeStatus: DecodableFromMiHoYoAPIJSONResult {}
