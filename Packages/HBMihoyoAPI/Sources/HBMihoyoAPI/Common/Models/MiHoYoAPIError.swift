//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - MiHoYoAPIError

/// The error returned by miHoYo when `retcode != 0`
@available(iOS 15.0, *)
public enum MiHoYoAPIError: Error {
    case verificationNeeded(verification: Verification)
    case other(retcode: Int, message: String)

    // MARK: Lifecycle

    /// Init an error where the request may need verification.
    public init(retcode: Int, message: String, request: URLRequest) async throws {
        if retcode == 1034 {
            let header = request.allHTTPHeaderFields ?? [:]
            let verification = try await MiHoYoAPI.createVerification(
                cookie: header.first(where: { $0.key.lowercased() == "cookie" })?.value ?? "",
                deviceFingerPrint: header.first(where: { $0.key.lowercased() == "x-rpc-device_fp" })?.value ?? ""
            )
            self = .verificationNeeded(verification: verification)
        } else {
            self = .other(retcode: retcode, message: message)
        }
    }

    /// Init an error where the request NEVER needs verification.
    public init(retcode: Int, message: String) {
        self = .other(retcode: retcode, message: message)
    }
}
