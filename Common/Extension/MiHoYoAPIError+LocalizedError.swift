//
//  MiHoYoAPIError+LocalizedError.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/15.
//

import Foundation
import HBMihoyoAPI

extension MiHoYoAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .other(retcode: retcode, message: message):
            return String(
                format: "mihoyoapi.error.errdesc"
                    .localized(comment: "Error(retcode): message"),
                retcode,
                message
            )
        case .verificationNeeded:
            return "mihoyoapi.error.verification_needed.description".localized()
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .other(retcode: retcode, message: message):
            return String(
                format: "mihoyoapi.error.errdesc"
                    .localized(comment: "Error(retcode): message"),
                retcode,
                message
            )
        case .verificationNeeded:
            return "mihoyoapi.error.verification_needed.recovery_suggestion".localized()
        }
    }
}
