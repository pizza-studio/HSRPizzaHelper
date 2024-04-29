// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - SRGFKit

public enum SRGFKit {}

extension DateFormatter {
    public static func forSRGFEntry(
        timeZoneDelta: Int = (TimeZone.current.secondsFromGMT() / 3600)
    )
        -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = .init(secondsFromGMT: timeZoneDelta * 3600)
        return dateFormatter
    }

    public static var forSRGFFileName: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        return dateFormatter
    }
}

extension Date {
    public func asSRGFDate(
        timeZoneDelta: Int = (TimeZone.current.secondsFromGMT() / 3600)
    )
        -> String {
        DateFormatter.forSRGFEntry(timeZoneDelta: timeZoneDelta).string(from: self)
    }
}
