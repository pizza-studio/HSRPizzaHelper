//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - MiHoYoAPIError

/// The error returned by miHoYo when `retcode != 0`
public enum MiHoYoAPIError: Error, LocalizedError {
    case verificationNeeded
    case fingerPrintInvalidOrMissing
    case sTokenV2InvalidOrMissing
    case reloginRequired
    case serverUnderMaintenanceUpgrade
    case insufficientDataVisibility
    case other(retcode: Int, message: String)

    // MARK: Lifecycle

    public init(retcode: Int, message: String) {
        self = switch retcode {
        case 1034, 10035: .verificationNeeded
        case 5003, 10041: .fingerPrintInvalidOrMissing
        case 10102: .insufficientDataVisibility
        case 10001: .reloginRequired
        case 10307: .serverUnderMaintenanceUpgrade
        default: .other(retcode: retcode, message: message)
        }
    }

    // MARK: Public

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        switch self {
        case .verificationNeeded: "MiHoYoAPIError.verificationNeeded".i18nHYK
        case .fingerPrintInvalidOrMissing: "MiHoYoAPIError.fingerPrintInvalidOrMissing".i18nHYK
        case .sTokenV2InvalidOrMissing: "MiHoYoAPIError.sTokenV2InvalidOrMissing".i18nHYK
        case .reloginRequired: "MiHoYoAPIError.reloginRequired".i18nHYK
        case .serverUnderMaintenanceUpgrade: "MiHoYoAPIError.serverUnderMaintenanceUpgrade".i18nHYK
        case .insufficientDataVisibility: "MiHoYoAPIError.insufficientDataVisibility".i18nHYK
        case let .other(retcode, message): "[HoYoAPIErr] Ret: \(retcode); Msg: \(message)"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }
}
