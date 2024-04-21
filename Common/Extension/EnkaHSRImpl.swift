// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBEnkaAPI

extension EnkaHSR.QueryRelated.Exception: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .enkaDBOnlineFetchFailure(details: details):
            return String(format: "error.EnkaAPI.Query.OnlineFetchFailure:%@".localized(), arguments: [details])
        case let .enkaProfileQueryFailure(message: message):
            return String(format: "error.EnkaAPI.Query.ProfileQueryFailure:%@".localized(), arguments: [message])
        case let .refreshTooFast(dateWhenRefreshable: dateWhenRefreshable):
            return String(
                format: "error.EnkaAPI.Query.PlzRefrainFromQueryingUntil:%@".localized(),
                arguments: [dateWhenRefreshable.description]
            )
        case .dataInvalid:
            return "error.EnkaAPI.Query.DataInvalid".localized()
        }
    }
}
